package ldap;

import org.apache.kafka.common.acl.AccessControlEntryFilter;
import org.apache.kafka.common.acl.AclBinding;
import org.apache.kafka.common.acl.AclBindingFilter;
import org.apache.kafka.common.acl.AclPermissionType;
import org.apache.kafka.common.resource.PatternType;
import org.apache.kafka.common.resource.ResourcePattern;
import org.apache.kafka.common.resource.ResourcePatternFilter;
import org.apache.kafka.common.security.auth.KafkaPrincipal;
import org.apache.kafka.common.security.auth.SecurityProtocol;
import org.apache.kafka.server.authorizer.Action;
import org.apache.kafka.server.authorizer.AuthorizableRequestContext;
import org.apache.kafka.server.authorizer.AuthorizationResult;
import org.apache.kafka.server.authorizer.Authorizer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Set;

final class AuthorizationResultOverrider {

    private static final Logger LOG = LoggerFactory.getLogger(AuthorizationResultOverrider.class);
    private static final String GROUP_TYPE = "Group";
    private static final String GROUP_TYPE_AND_COLON = GROUP_TYPE + ":";

    private AuthorizationResultOverrider() {
    }

    public static void overrideForGroups(final Authorizer authorizer, final AuthorizableRequestContext requestContext, final List<AuthorizationResult> results, final List<Action> actions) {
        if (isOverridableContext(requestContext)) {
            overrideResultsByGroup(authorizer, requestContext, results, actions);
        }
    }

    private static boolean isOverridableContext(final AuthorizableRequestContext context) {
        return isPrincipalToOverride(context.principal()) && isSecurityProtocolToOverride(context.securityProtocol());
    }

    private static boolean isPrincipalToOverride(final KafkaPrincipal principal) {
        return principal.getPrincipalType().equals(KafkaPrincipal.USER_TYPE);
    }

    private static boolean isSecurityProtocolToOverride(final SecurityProtocol protocol) {
        return protocol == SecurityProtocol.SASL_SSL || protocol == SecurityProtocol.SASL_PLAINTEXT;
    }

    private static void overrideResultsByGroup(final Authorizer authorizer, final AuthorizableRequestContext requestContext, final List<AuthorizationResult> results, final List<Action> actions) {
        final KafkaPrincipal principal = requestContext.principal();
        final Set<String> groupsForUser = UserToGroupsCache.getInstance().getGroupsForUser(principal.getName());
        if (groupsForUser == null || groupsForUser.isEmpty()) {
            /* Nothing to do. We are only concerned with group matching. */
            return;
        }
        for (int q = results.size() - 1; q >= 0; q--) {
            final AuthorizationResult originalResult = results.get(q);
            if (originalResult == AuthorizationResult.ALLOWED) {
                continue;
            }
            final Action action = actions.get(q);
            final AuthorizationResult alternativeResult = authorize(authorizer, groupsForUser, action);
            if (alternativeResult != originalResult && (alternativeResult == AuthorizationResult.ALLOWED || alternativeResult == AuthorizationResult.DENIED)) {
                results.set(q, alternativeResult);
                LOG.info("*** Overriding " + originalResult + ", changing to " + alternativeResult + " due to matching group rule for \"" + principal + "\" on \"" + action.resourcePattern().name() + "\"");
            }
        }
    }

    private static AuthorizationResult authorize(final Authorizer authorizer, final Set<String> groups, final Action action) {
        final ResourcePattern resourcePattern = action.resourcePattern();
        final ResourcePatternFilter resourcePatternFilter = new ResourcePatternFilter(resourcePattern.resourceType(), resourcePattern.name(), PatternType.MATCH);
        final AccessControlEntryFilter accessControlEntryFilter = new AccessControlEntryFilter(null, null, action.operation(), AclPermissionType.ANY);
        final AclBindingFilter aclBindingFilter = new AclBindingFilter(resourcePatternFilter, accessControlEntryFilter);
        final Iterable<AclBinding> acls = authorizer.acls(aclBindingFilter);
        AuthorizationResult result = AuthorizationResult.DENIED;
        for (final AclBinding aclBinding : acls) {
            if (!aclBindingFilter.matches(aclBinding)) {
                LOG.warn("Got an ACL Binding that does not match the filter we provided. This should not happen.");
                continue;
            }
            if (isGroupMatch(groups, aclBinding)) {
                /* The principal in the AclBinding is a Group-principal that matches a
                 * group in which the calling principal is a member. */
                final AclPermissionType permissionType = aclBinding.entry().permissionType();
                if (permissionType == AclPermissionType.DENY) {
                    /* There is a DENY on a group in which the principal is a member. This wins. */
                    return AuthorizationResult.DENIED;
                }
                if (permissionType == AclPermissionType.ALLOW) {
                    result = AuthorizationResult.ALLOWED;
                }
            }
        }
        return result;
    }

    private static boolean isGroupMatch(final Set<String> groups, final AclBinding aclBinding) {
        final String aclPrincipal = aclBinding.entry().principal();
        if (!aclPrincipal.startsWith(GROUP_TYPE_AND_COLON)) {
            return false;
        }
        final String groupName = aclPrincipal.substring(GROUP_TYPE_AND_COLON.length()).trim();
        return groups.contains(groupName);
    }

}

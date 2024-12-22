package ldap;

import kafka.security.authorizer.AclAuthorizer;
import org.apache.kafka.server.authorizer.Action;
import org.apache.kafka.server.authorizer.AuthorizableRequestContext;
import org.apache.kafka.server.authorizer.AuthorizationResult;

import java.util.List;

/**
 * NOTE!
 *
 * This class does not support DENY rules! It will call the original AclAuthorizer first, and
 * change any DENIED to ALLOWED if there is a group rule that ALLOWs access. This means that
 * a user that has explicitly been DENIED access, may gain access anyway, based on group
 * membership!
 *
 * The reason for this is that when we process the results of the original AclAuthorizer,
 * we do not know whether a DENIED is explicit or implicit, som we must assume the latter.
 *
 * Using explicit denies is a bad security practice anyway (blacklisting instead of whitelisting),
 * and we do not use that practice at our place.
 */
public final class LdapGroupAclAuthorizer
extends AclAuthorizer {

    @Override
    public List<AuthorizationResult> authorize(final AuthorizableRequestContext requestContext, final List<Action> actions) {
        final List<AuthorizationResult> results = super.authorize(requestContext, actions);
        AuthorizationResultOverrider.overrideForGroups(this, requestContext, results, actions);
        return results;
    }

}

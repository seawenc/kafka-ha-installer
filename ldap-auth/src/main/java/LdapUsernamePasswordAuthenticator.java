import utils.LdapConnectionSpec;
import utils.LdapUtils;
import utils.UsernamePasswordAuthenticator;
import utils.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.naming.NamingException;
import javax.naming.ldap.LdapContext;
import java.util.Objects;

public final class LdapUsernamePasswordAuthenticator
implements UsernamePasswordAuthenticator {

    private static final Logger LOG = LoggerFactory.getLogger(LdapUsernamePasswordAuthenticator.class);
    private static final String GROUP_MEMBER_OF_FIELD = "memberOf";

    private final LdapConnectionSpec ldapConnectionSpec;
    private final String usernameToDnFormat;
    private final String usernameToUniqueSearchFormat;
    private final boolean useUserContextForFetchingGroups;

    public LdapUsernamePasswordAuthenticator(final LdapConnectionSpec ldapConnectionSpec, final String usernameToDnFormat, final String usernameToUniqueSearchFormat, final String userDn, final String userPassword) {
        this.ldapConnectionSpec = Objects.requireNonNull(ldapConnectionSpec);
        this.usernameToDnFormat = Objects.requireNonNull(usernameToDnFormat);
        this.usernameToUniqueSearchFormat = usernameToUniqueSearchFormat;
        if (!StringUtils.isBlank(userDn) && !StringUtils.isBlank(userPassword)) {
            LOG.info("Will use LDAP service user \"" + userDn + "\" to look up groups.");
            final SystemUserGroupsFetcher userToGroupsFetcher = new SystemUserGroupsFetcher(ldapConnectionSpec, userDn, userPassword.toCharArray(), GROUP_MEMBER_OF_FIELD, usernameToUniqueSearchFormat);
            UserToGroupsCache.getInstance().setUserToGroupsFetcher(userToGroupsFetcher);
            useUserContextForFetchingGroups = false;
            /* Connect to LDAP to get errors early. */
            if (userToGroupsFetcher.getContext() == null) {
                LOG.error("Unable to connect to LDAP server \"" + ldapConnectionSpec.getUrl() +  "\" as \"" + userDn
                          + "\". Probably incorrect user or password. Group-based authorization will not work.");
            }
        } else {
            LOG.info("No LDAP service user provided. Will use the authenticated user to look up groups.");
            useUserContextForFetchingGroups = true;
        }
    }

    @Override
    public boolean authenticate(final String username, final char[] password) {
        if (StringUtils.isBlank(username)) {
            return false;
        }
        final String userDn = String.format(usernameToDnFormat, LdapUtils.escape(username));
        return authenticateByDn(userDn, password, username);
    }

    public boolean authenticateByDn(final String userDn, final char[] password) {
        return authenticateByDn(userDn, password, null);
    }

    private boolean authenticateByDn(final String userDn, final char[] password, final String originalUsername) {
        final LdapContext context = LdapUtils.connect(ldapConnectionSpec, userDn, password);
        if (context == null) {
            return false;
        }
        if (useUserContextForFetchingGroups && !StringUtils.isBlank(usernameToUniqueSearchFormat) && originalUsername != null) {
            populateGroups(context, originalUsername);
        }
        try {
            context.close();
        } catch (final NamingException e) {
            LOG.warn("Ignoring exception when closing LDAP context.", e);
        }
        return true;
    }

    private void populateGroups(final LdapContext context, final String username) {
        UserToGroupsCache.getInstance().fetchGroupsForUserIfNeeded(username, s -> {
            if (!s.equals(username)) {
                LOG.warn("Expected \"" + username + "\", but got \"" + s + "\"");
            }
            return LdapUtils.findGroups(context, username, GROUP_MEMBER_OF_FIELD, usernameToUniqueSearchFormat);
        });
    }

}

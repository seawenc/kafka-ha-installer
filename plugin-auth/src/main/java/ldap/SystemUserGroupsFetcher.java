package ldap;

import ldap.utils.LdapConnectionSpec;
import ldap.utils.LdapUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.naming.NamingException;
import javax.naming.ldap.LdapContext;
import java.util.Collections;
import java.util.Set;

final class SystemUserGroupsFetcher
implements UserToGroupsFetcher {

    private static final Logger LOG = LoggerFactory.getLogger(SystemUserGroupsFetcher.class);
    private final LdapConnectionSpec connectionSpec;
    private final String userDn;
    private final char[] password;
    private final String groupMemberOfField;
    private final String usernameToUniqueSearchFormat;
    private final Object contextLock = new Object();
    private LdapContext context;
    private int numReconnects;

    SystemUserGroupsFetcher(final LdapConnectionSpec connectionSpec, final String userDn, final char[] password, final String groupMemberOfField, final String usernameToUniqueSearchFormat) {
        this.connectionSpec = connectionSpec;
        this.userDn = userDn;
        this.password = password;
        this.groupMemberOfField = groupMemberOfField;
        this.usernameToUniqueSearchFormat = usernameToUniqueSearchFormat;
    }

    LdapContext getContext() {
        synchronized (contextLock) {
            if (context == null) {
                context = LdapUtils.connect(connectionSpec, userDn, password);
                ++numReconnects;
            }
            return context;
        }
    }

    public int getNumReconnects() {
        return numReconnects;
    }

    @Override
    public Set<String> fetchGroups(final String username) {
        synchronized (contextLock) {
            final LdapContext ldapContext = getContext();
            if (ldapContext == null) {
                /* Reason is logged in LdapUtils. */
                return Collections.emptySet();
            }
            try {
                return LdapUtils.findGroupsWithoutErrorHandling(ldapContext, username, groupMemberOfField, usernameToUniqueSearchFormat);
            } catch (final NamingException e) {
                LOG.info("Got NamingException. Retrying. " + e.getMessage());
                try {
                    ldapContext.close();
                } catch (final Exception e2) {
                    LOG.debug("Ignoring exception when closing LdapContext");
                }
                context = null;
                return LdapUtils.findGroups(getContext(), username, groupMemberOfField, usernameToUniqueSearchFormat);
            }
        }
    }

    void makeUseless() {
        synchronized (contextLock) {
            if (context != null) {
                try {
                    context.close();
                } catch (final NamingException e) {
                    LOG.debug("Got error when closing context", e);
                }
            }
        }
    }

}

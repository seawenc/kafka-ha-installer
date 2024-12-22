package ldap.utils;

import javax.naming.AuthenticationException;
import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;
import javax.naming.ldap.InitialLdapContext;
import javax.naming.ldap.LdapContext;
import java.util.Collections;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

public final class LdapUtils {

    private static final Logger LOG = Logger.getLogger(LdapUtils.class.getName());
    private static final char[] HEX_CHARS = "0123456789abcdef".toCharArray();

    private LdapUtils() {
    }

    public static String escape(final String s) {
        /* See RFC 2253, section 2.4 */
        final StringBuilder sb = new StringBuilder();
        final int len = s.length();
        for (int q = 0; q < len; q++) {
            final int c = s.charAt(q);
            boolean doEscape = false;
            if (q == 0 && (c == ' ' || c == '#')) {
                doEscape = true;
            } else if (q == len - 1 && c == ' ') {
                doEscape = true;
            } else if (",+\"\\<>;".indexOf(c) >= 0) {
                doEscape = true;
            } else if (c < 32 || c > 126) {
                /* The standard actually allows values outside this range, but since we are allowed
                 * to escape anything, we do it just to avoid potential problems. */
                /* Update 2007-04-24: only escape the low ones. */
                if (c < 32) {
                    doEscape = true;
                }
            }
            if (doEscape) {
                sb.append('\\');
                if (" #,+\"\\<>;".indexOf(c) >= 0) {
                    sb.append((char) c);
                } else {
                    if (c > 255) {
                        sb.append(HEX_CHARS[(c >> 12) & 0xf]);
                        sb.append(HEX_CHARS[(c >> 8) & 0xf]);
                        sb.append('\\');
                    }
                    sb.append(HEX_CHARS[(c >> 4) & 0xf]);
                    sb.append(HEX_CHARS[c & 0xf]);
                }
            } else {
                sb.append((char) c);
            }
        }
        return sb.toString();
    }

    public static LdapContext connect(final LdapConnectionSpec ldapConnectionSpec, final String userDn, final char[] password) {
        if (StringUtils.isBlank(userDn) || password == null || password.length == 0) {
            return null;
        }
        final Hashtable<String, Object> env = new Hashtable<>();
        /* As per https://docs.oracle.com/javase/jndi/tutorial/ldap/connect/pool.html,
         * not using connection pooling, since we change the principal of the connection. */
        env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
        env.put("com.sun.jndi.ldap.read.timeout", "5000");
        env.put("com.sun.jndi.ldap.connect.timeout", "5000");
        env.put(Context.PROVIDER_URL, ldapConnectionSpec.getUrl());
        env.put(Context.SECURITY_AUTHENTICATION, "simple");
        env.put(Context.SECURITY_PRINCIPAL, userDn);
        env.put(Context.SECURITY_CREDENTIALS, password);
        env.put(Context.REFERRAL, "follow");
        try {
            return new InitialLdapContext(env, null);
        } catch (final AuthenticationException e) {
            LOG.info("Authentication failure for user \"" + userDn + "\": " + e.getMessage());
            return null;
        } catch (final NamingException e) {
            LOG.log(Level.WARNING, "Got unexpected exception when connecting to " + ldapConnectionSpec.getUrl() + " as \"" + userDn + "\"", e);
            throw new UncheckedNamingException(e);
        }
    }

    public static Set<String> findGroups(final LdapContext ldap, final String username, final String groupMemberOfField, final String usernameToUniqueSearchFormat) {
        try {
            return findGroupsWithoutErrorHandling(ldap, username, groupMemberOfField, usernameToUniqueSearchFormat);
        } catch (final NamingException e) {
            LOG.log(Level.WARNING, "Exception while fetching groups for \"" + username + "\". Will return no groups.", e);
            return Collections.emptySet();
        }
    }

    public static Set<String> findGroupsWithoutErrorHandling(final LdapContext ldap, final String username, final String groupMemberOfField, final String usernameToUniqueSearchFormat)
    throws NamingException {
        final Set<String> set = new HashSet<>();
        final SearchControls sc = new SearchControls();
        sc.setSearchScope(SearchControls.SUBTREE_SCOPE);
        sc.setReturningAttributes(new String[] { groupMemberOfField });
        final String filter = "(" + String.format(usernameToUniqueSearchFormat, LdapUtils.escape(username)) + ")";
        final NamingEnumeration<SearchResult> ne = ldap.search("", filter, sc);
        if (ne.hasMore()) {
            final SearchResult sr = ne.next();
            final Attributes attributes = sr.getAttributes();
            if (attributes != null) {
                final Attribute attribute = attributes.get(groupMemberOfField);
                if (attribute != null) {
                    final NamingEnumeration<?> allGroups = attribute.getAll();
                    while (allGroups.hasMore()) {
                        set.add(allGroups.next().toString());
                    }
                }
            }
        }
        if (ne.hasMore()) {
            LOG.warning("Expected to find unique entry for \"" + filter + "\", but found several. Will not return any groups.");
            set.clear();
        }
        return set;
    }

}

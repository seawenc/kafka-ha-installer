package ldap.utils;

public final class LdapConnectionSpec {

    private final String server;
    private final int port;
    private final boolean useTls;
    private final String baseDn;

    public LdapConnectionSpec(final String server, final int port, final boolean useTls, final String baseDn) {
        this.server = server;
        this.port = port;
        this.useTls = useTls;
        this.baseDn = baseDn;
    }

    public String getUrl() {
        return (useTls ? "ldaps" : "ldap") + "://" + server + ":" + port + "/" + baseDn;
    }

}

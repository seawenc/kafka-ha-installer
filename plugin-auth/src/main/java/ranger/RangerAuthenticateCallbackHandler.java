package ranger;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import javax.security.auth.callback.Callback;
import javax.security.auth.callback.NameCallback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.AppConfigurationEntry;
import org.apache.kafka.common.security.auth.*;
import org.apache.kafka.common.security.plain.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class RangerAuthenticateCallbackHandler implements AuthenticateCallbackHandler {

    private static final Logger LOG = LoggerFactory.getLogger(RangerAuthenticateCallbackHandler.class);
    private static final String CONFIG_RANGER_HOST = "authz.ranger.host";
    private static final String CONFIG_RANGER_PORT = "authz.ranger.port";
    private static final String SASL_PLAIN = "PLAIN";
    private static final Integer DEFAULT_PORT = 6080;

    private String host ="";
    private int port = 6080;

    @Override
    public void configure(final Map<String, ?> configs, final String saslMechanism, final List<AppConfigurationEntry> jaasConfigEntries) {
        if (!SASL_PLAIN.equals(saslMechanism)) {
            throw new IllegalArgumentException("Only SASL mechanism \"" + SASL_PLAIN + "\" is supported.");
        }
        configure(configs);
    }

    private void configure(final Map<String, ?> configs) {
        host = getRequiredStringProperty(configs, CONFIG_RANGER_HOST);
        port =  getIntProperty(configs, CONFIG_RANGER_PORT,DEFAULT_PORT);
        LOG.info("ranger plugin Configured");
    }

    private int getIntProperty(final Map<String, ?> configs, final String name,Integer defaultValue) {
        String stringValue = getStringProperty(configs, name);
        stringValue=stringValue == null ? defaultValue+"" : stringValue;
        try {
            return Integer.parseInt(stringValue);
        } catch (final NumberFormatException e) {
            throw new IllegalArgumentException("Value must be numeric in configuration property \"" + name + "\".");
        }
    }

    private String getStringProperty(final Map<String, ?> configs, final String name) {
        final Object value = configs.get(name);
        return value == null ? null : value.toString();
    }

    private String getRequiredStringProperty(final Map<String, ?> configs, final String name) {
        final Object value = configs.get(name);
        if (value == null) {
            throw new IllegalArgumentException("Missing required configuration property \"" + name + "\".");
        }
        return value.toString();
    }

    @Override
    public void close() {
        LOG.info("Closed.");
    }

    @Override
    public void handle(final Callback[] callbacks)
    throws UnsupportedCallbackException {
        if (host == null) {
            throw new IllegalStateException("Handler not init，please set: authz.ranger.host，authz.ranger.port");
        }
        String username = null;
        PlainAuthenticateCallback plainAuthenticateCallback = null;
        for (final Callback callback : callbacks) {
            if (callback instanceof NameCallback) {
                username = ((NameCallback) callback).getDefaultName();
            } else if (callback instanceof PlainAuthenticateCallback) {
                plainAuthenticateCallback = (PlainAuthenticateCallback) callback;
            } else {
                throw new UnsupportedCallbackException(callback);
            }
        }
        if (username == null) {
            throw new IllegalStateException("not get username.");
        }
        if (plainAuthenticateCallback == null) {
            throw new IllegalStateException("Expected PlainAuthenticationCallback was not found.");
        }
        String password=new String(plainAuthenticateCallback.password());

        boolean authenticated=false;
        try {
            authenticated = authenticate(username, password);
        } catch (Exception e) {
            LOG.error("user \"" + username + "\" login fail .error:"+e.getMessage(),e);
        }
        if (authenticated) {
            LOG.info("user: \"" + username + "\" login success.");
        } else {
            LOG.warn("user:  \"" + username + "\" login "+String.format("http://%s:%s/login",host,port)+" fail.");
        }
        plainAuthenticateCallback.authenticated(authenticated);
    }

    private boolean authenticate(String username, String password) throws Exception {
        String path = String.format("http://%s:%s/login", host, port);
        URL url = new URL(path);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");
        connection.setDoOutput(true);
        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        String encodedPassword = URLEncoder.encode(password, StandardCharsets.UTF_8.toString());
        String data = String.format("username=%s&password=%s", username, encodedPassword);
        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = data.getBytes("utf-8");
            os.write(input, 0, input.length);
        }catch (Exception e){
            // ranger不可用
            LOG.error("ranger service is unavailable and the login operation is not possible:" + path);
            return false;
        }

        int responseCode = connection.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) { // 检查是否成功
            return true;
        }
        LOG.warn("user : " + username+" login fail,responseCode:"+responseCode);
        return false;
    }

    public static void main(String[] args) throws Exception {
        RangerAuthenticateCallbackHandler handler=new RangerAuthenticateCallbackHandler();
        handler.host="192.168.56.10";
        handler.authenticate("admin", "aaBB@112233");
    }

}

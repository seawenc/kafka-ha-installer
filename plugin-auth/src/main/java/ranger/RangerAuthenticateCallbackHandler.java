package ranger;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.security.auth.callback.Callback;
import javax.security.auth.callback.NameCallback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.AppConfigurationEntry;
import org.apache.kafka.common.security.auth.AuthenticateCallbackHandler;
import org.apache.kafka.common.security.plain.PlainAuthenticateCallback;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.apache.kafka.common.security.auth.SecurityProtocol.SASL_PLAINTEXT;

public final class RangerAuthenticateCallbackHandler implements AuthenticateCallbackHandler {

    private static final Logger LOG = LoggerFactory.getLogger(RangerAuthenticateCallbackHandler.class);
    private static final String ENV_RANGER_HOST = "RANGER_AUTH_HOST";
    private static final String ENV_RANGER_PORT = "RANGER_AUTH_PORT";
    private static final String SASL_PLAIN = "PLAIN";
    private static final Integer DEFAULT_PORT = 6080;

    private String host = "";
    private int port = DEFAULT_PORT;
    // account,password
    private static Map<String, String> accounts = new HashMap<>();


    @Override
    public void configure(final Map<String, ?> configs, final String saslMechanism,
                          final List<AppConfigurationEntry> jaasConfigEntries) {
        if (!SASL_PLAIN.equals(saslMechanism)) {
            throw new IllegalArgumentException("Only SASL mechanism \"" + SASL_PLAINTEXT + "\" is supported.");
        }

        // ✅ 从环境变量读取配置
        host = System.getenv(ENV_RANGER_HOST);
        String portStr = System.getenv(ENV_RANGER_PORT);

        try {
            port = Integer.parseInt(portStr);
        } catch (NumberFormatException e) {
            LOG.warn("环境变量 {} 不是有效数字: {},使用默认端口 {}", "ENV_RANGER_PORT", portStr,DEFAULT_PORT);
            port = DEFAULT_PORT;
        }
        // 最终验证
        if (host == null || host.isEmpty()) {
            String errorMsg = "请配置环境变量：RANGER_AUTH_HOST，如：RANGER_AUTH_HOST=192.168.56.11";
            LOG.error(errorMsg);
            throw new IllegalArgumentException(errorMsg);
        }
        LOG.info("RANGER,初始化成功，认证地址: http://{}:{}/login", host, port);
    }
    
    @Override
    public void close() {
        LOG.warn("=== RangerAuthenticateCallbackHandler.close() ===");
    }

    @Override
    public void handle(final Callback[] callbacks) throws UnsupportedCallbackException {

        String username = null;
        PlainAuthenticateCallback plainAuthenticateCallback = null;

        for (int i = 0; i < callbacks.length; i++) {
            final Callback callback = callbacks[i];
            if (callback instanceof NameCallback) {
                username = ((NameCallback) callback).getDefaultName();
            } else if (callback instanceof PlainAuthenticateCallback) {
                plainAuthenticateCallback = (PlainAuthenticateCallback) callback;
            } else {
                LOG.error("不支持的回调类型: {}", callback.getClass().getName());
                throw new UnsupportedCallbackException(callback);
            }
        }

        if (username == null) {
            throw new IllegalStateException("未找到用户名");
        }

        if (plainAuthenticateCallback == null) {
            throw new IllegalStateException("未找到 PlainAuthenticateCallback");
        }

        String password = new String(plainAuthenticateCallback.password());
        // 检查缓存
        if (accounts.containsKey(username) && password.equals(accounts.get(username))) {
            LOG.info("用户 '{}' 认证成功 (使用缓存)", username);
            plainAuthenticateCallback.authenticated(true);
            return;
        }
        
        // 远程认证（如果缓存与当前密码不一致，则重新认证）
        boolean authenticated = false;
        try {
            authenticated = authenticate(username, password);
        } catch (Exception e) {
            LOG.error("用户 '{}' 认证报错: {}", username, e.getMessage(), e);
        }

        if (authenticated) {
            LOG.info("用户 '{}' 认证成功", username);
            accounts.put(username, password);
        } else {
            LOG.error("用户 '{}' 认证失败", username);
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
        connection.setConnectTimeout(5000);
        connection.setReadTimeout(5000);

        String encodedPassword = URLEncoder.encode(password, StandardCharsets.UTF_8.toString());
        String data = String.format("username=%s&password=%s", username, encodedPassword);

        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = data.getBytes("utf-8");
            os.write(input, 0, input.length);
            os.flush();
        } catch (Exception e) {
            LOG.error("Ranger服务不可用: {}", path, e);
            return false;
        }

        int responseCode = connection.getResponseCode();

        if (responseCode == HttpURLConnection.HTTP_OK) {
            return true;
        }

        LOG.error("用户 '{}' 认证失败，响应码: {}", username, responseCode);
        return false;
    }
}
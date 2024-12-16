package utils;

public interface UsernamePasswordAuthenticator {

    boolean authenticate(String username, char[] password);

}

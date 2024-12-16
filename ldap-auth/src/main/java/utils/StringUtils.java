package utils;

public final class StringUtils {

    public static boolean isBlank(final String s) {
        return s == null || s.trim().isEmpty();
    }

}

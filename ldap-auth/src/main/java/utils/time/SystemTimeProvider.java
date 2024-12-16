package utils.time;

public final class SystemTimeProvider
implements TimeProvider {

    @Override
    public long currentTimeMillis() {
        return System.currentTimeMillis();
    }

}

package utils.cache;

import utils.time.TimeProvider;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public final class TimeoutCache<K, V>
implements Clearable {

    private final TimeProvider timeProvider;
    private final Map<K, CacheResult<V>> map = new HashMap<>();

    public TimeoutCache(final TimeProvider timeProvider) {
        this.timeProvider = timeProvider;
    }

    public final class CacheResult<V> {

        private final long whenTimeoutMs;
        private final V value;

        private CacheResult(final long whenTimeoutMs, final V value) {
            this.whenTimeoutMs = whenTimeoutMs;
            this.value = value;
        }

        public V getValue() {
            return value;
        }

        public boolean isTimedOut() {
            return whenTimeoutMs <= timeProvider.currentTimeMillis();
        }

        public long getExpiresInMs() {
            return whenTimeoutMs - timeProvider.currentTimeMillis();
        }

    }

    @Override
    public void clear() {
        synchronized (map) {
            map.clear();
        }
    }

    public void put(final K key, final V value, final long whenTimeoutMs) {
        Objects.requireNonNull(key);
        final CacheResult<V> entry = new CacheResult<>(whenTimeoutMs, value);
        synchronized (map) {
            if (entry.isTimedOut()) {
                map.remove(key);
            } else {
                map.put(key, entry);
            }
        }
    }

    public V get(final K key) {
        final CacheResult<V> cacheResult = getAsCacheResult(key);
        if (cacheResult == null) {
            return null;
        }
        return cacheResult.getValue();
    }

    public long getExpiresInMs(final K key) {
        final CacheResult<V> cacheResult = getAsCacheResult(key);
        if (cacheResult == null) {
            return -1L;
        }
        return cacheResult.getExpiresInMs();
    }

    public CacheResult<V> getAsCacheResult(final K key) {
        Objects.requireNonNull(key);
        synchronized (map) {
            final CacheResult<V> cacheResult = map.get(key);
            if (cacheResult == null) {
                return null;
            }
            if (cacheResult.isTimedOut()) {
                map.remove(key);
                return null;
            }
            return cacheResult;
        }
    }

}

import utils.time.SystemTimeProvider;
import utils.time.TimeProvider;
import utils.cache.TimeoutCache;

import java.util.Set;

final class UserToGroupsCache {

    private static final UserToGroupsCache INSTANCE = new UserToGroupsCache();
    private UserToGroupsFetcher userToGroupsFetcher;
    static final long TTL = 10L * 60L * 1000L;
    static final long REFRESH_WHEN_LESS_THAN_MS = 30L * 1000L;
    private final TimeoutCache<String, Set<String>> cache;
    private final TimeProvider timeProvider;

    private UserToGroupsCache() {
        this(new SystemTimeProvider());
    }

    /**
     * Only intended to be used for unit tests.
     */
    UserToGroupsCache(final TimeProvider timeProvider) {
        this.timeProvider = timeProvider;
        cache = new TimeoutCache<>(timeProvider);
    }

    public static UserToGroupsCache getInstance() {
        return INSTANCE;
    }

    public void setGroupsForUser(final String userName, final Set<String> groups) {
        cache.put(userName, groups, timeProvider.currentTimeMillis() + TTL);
    }

    public Set<String> getGroupsForUser(final String userName) {
        if (userToGroupsFetcher != null) {
            fetchGroupsForUserIfNeeded(userName, userToGroupsFetcher);
        }
        return cache.get(userName);
    }

    public void fetchGroupsForUserIfNeeded(final String user, final UserToGroupsFetcher fetcher) {
        if (cache.getExpiresInMs(user) >= REFRESH_WHEN_LESS_THAN_MS) {
            return;
        }
        setGroupsForUser(user, fetcher.fetchGroups(user));
    }

    public void clear() {
        cache.clear();
    }

    public void setUserToGroupsFetcher(final UserToGroupsFetcher userToGroupsFetcher) {
        this.userToGroupsFetcher = userToGroupsFetcher;
    }

    /** For testing */
    public void makeUseless() {
        if (userToGroupsFetcher != null && userToGroupsFetcher instanceof SystemUserGroupsFetcher) {
            ((SystemUserGroupsFetcher) userToGroupsFetcher).makeUseless();
        }
        clear();
    }

    /** For testing */
    public int getNumReconnects() {
        if (userToGroupsFetcher != null && userToGroupsFetcher instanceof SystemUserGroupsFetcher) {
            return ((SystemUserGroupsFetcher) userToGroupsFetcher).getNumReconnects();
        }
        return 0;
    }

}

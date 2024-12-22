package ldap;

import java.util.Set;

interface UserToGroupsFetcher {

    Set<String> fetchGroups(String username);

}

import 'package:sociale_vote/domain/identity/entities/account_follow_state.dart';
import 'package:sociale_vote/domain/identity/entities/account_discovery_item.dart';

abstract class AccountFollowRepository {
  Future<AccountFollowState> getState(String targetUserId);

  Future<AccountFollowState> toggleFollow(String targetUserId);

  Future<Set<String>> getFollowedAccountIds();

  Future<List<AccountDiscoveryItem>> getFollowing({
    int limit = 50,
    int offset = 0,
  });

  Future<List<AccountDiscoveryItem>> getFollowers({
    int limit = 50,
    int offset = 0,
  });
}

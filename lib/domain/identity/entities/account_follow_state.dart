class AccountFollowState {
  final bool isFollowing;
  final int followerCount;
  final int followingCount;
  final bool canFollow;

  const AccountFollowState({
    required this.isFollowing,
    required this.followerCount,
    required this.followingCount,
    required this.canFollow,
  });
}

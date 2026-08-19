import 'package:sociale_vote/domain/identity/entities/user_profile.dart';

class AccountDiscoveryItem {
  final UserProfile profile;
  final int followerCount;
  final bool isFollowing;

  const AccountDiscoveryItem({
    required this.profile,
    required this.followerCount,
    required this.isFollowing,
  });
}

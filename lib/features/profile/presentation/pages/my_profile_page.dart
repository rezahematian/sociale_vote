import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sociale_vote/app/di.dart';

import 'package:sociale_vote/features/profile/application/profile_controller.dart';
import 'package:sociale_vote/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_comments_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_favorites_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_followed_scopes_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_polls_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_posts_page.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AppDI.instance.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'You must be logged in to view your profile.\n\n'
              'Accedi o registrati dalla home per vedere le tue attività.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ProfileController(
        getUserProfile: AppDI.instance.getUserProfile,
        updateUserProfile: AppDI.instance.updateUserProfile,
      )..loadProfile(currentUserId),
      child: _MyProfileView(currentUserId: currentUserId),
    );
  }
}

class _MyProfileView extends StatelessWidget {
  final String currentUserId;

  const _MyProfileView({
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<ProfileController>();
    final profile = controller.profile;

    final avatarUrl = profile?.avatarUrl?.trim() ?? '';
    final displayName = profile?.displayName?.trim() ?? '';
    final bio = profile?.bio?.trim() ?? '';
    final country = profile?.country?.trim() ?? '';
    final city = profile?.city?.trim() ?? '';
    final accountType = (profile?.accountType.trim().isNotEmpty ?? false)
        ? profile!.accountType.trim()
        : 'citizen';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProfileController>().loadProfile(currentUserId),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: controller.isLoading && profile == null
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundImage:
                                    avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 32)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName.isNotEmpty ? displayName : 'User',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          accountType,
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        if (profile?.isVerified == true) ...[
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.verified,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (bio.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        bio,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                    finalLocation(city: city, country: country) != null
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              finalLocation(city: city, country: country)!,
                                              style:
                                                  theme.textTheme.bodySmall?.copyWith(
                                                color: theme.textTheme.bodySmall?.color
                                                    ?.withOpacity(0.8),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    const SizedBox(height: 8),
                                    Text(
                                      currentUserId,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color
                                            ?.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: controller.isSaving
                                  ? null
                                  : () async {
                                      final result = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const EditProfilePage(),
                                        ),
                                      );

                                      if (result == true && context.mounted) {
                                        await context
                                            .read<ProfileController>()
                                            .loadProfile(currentUserId);
                                      }
                                    },
                              icon: controller.isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.edit_outlined),
                              label: const Text('Edit Profile'),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    controller.errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _ProfileSectionTile(
              title: 'My Polls',
              icon: Icons.how_to_vote,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyPollsPage(),
                  ),
                );
              },
            ),
            _ProfileSectionTile(
              title: 'My Posts',
              icon: Icons.forum,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyPostsPage(),
                  ),
                );
              },
            ),
            _ProfileSectionTile(
              title: 'My Comments',
              icon: Icons.comment,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyCommentsPage(),
                  ),
                );
              },
            ),
            _ProfileSectionTile(
              title: 'My Favorites',
              icon: Icons.star,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyFavoritesPage(),
                  ),
                );
              },
            ),
            _ProfileSectionTile(
              title: 'My Followed Scopes',
              icon: Icons.public,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyFollowedScopesPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String? finalLocation({
    required String city,
    required String country,
  }) {
    if (city.isNotEmpty && country.isNotEmpty) {
      return '$city, $country';
    }
    if (city.isNotEmpty) {
      return city;
    }
    if (country.isNotEmpty) {
      return country;
    }
    return null;
  }
}

class _ProfileSectionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _ProfileSectionTile({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
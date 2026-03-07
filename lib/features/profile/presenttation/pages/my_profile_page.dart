import 'package:flutter/material.dart';
import 'package:sociale_vote/app/di.dart';

import 'package:sociale_vote/features/profile/presentation/pages/my_polls_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_posts_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_comments_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_favorites_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_followed_scopes_page.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    child: Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User ID',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUserId,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Profile details (name, email, roles) '
                          'verranno collegati in una fase successiva.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

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
    );
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
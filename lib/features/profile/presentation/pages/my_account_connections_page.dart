import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/identity/entities/account_discovery_item.dart';
import 'package:sociale_vote/features/profile/presentation/pages/public_user_profile_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/ui/avatar.dart';
import 'package:sociale_vote/shared/widgets/user_identity_mark.dart';

class MyAccountConnectionsPage extends StatefulWidget {
  const MyAccountConnectionsPage({super.key});

  @override
  State<MyAccountConnectionsPage> createState() =>
      _MyAccountConnectionsPageState();
}

class _MyAccountConnectionsPageState
    extends State<MyAccountConnectionsPage> {
  List<AccountDiscoveryItem> _following = const <AccountDiscoveryItem>[];
  List<AccountDiscoveryItem> _followers = const <AccountDiscoveryItem>[];
  final Set<String> _busyUserIds = <String>{};
  bool _isLoading = true;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }

    try {
      final repository = AppDI.instance.accountFollowRepository;
      final results = await Future.wait<List<AccountDiscoveryItem>>(
        <Future<List<AccountDiscoveryItem>>>[
          repository.getFollowing(limit: 100),
          repository.getFollowers(limit: 100),
        ],
      );

      if (!mounted) return;

      setState(() {
        _following = List<AccountDiscoveryItem>.unmodifiable(results[0]);
        _followers = List<AccountDiscoveryItem>.unmodifiable(results[1]);
        _isLoading = false;
        _hasLoadError = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasLoadError = true;
      });
    }
  }

  Future<void> _toggleFollow(AccountDiscoveryItem item) async {
    final userId = item.profile.id.trim();
    if (userId.isEmpty || _busyUserIds.contains(userId)) {
      return;
    }

    setState(() {
      _busyUserIds.add(userId);
    });

    try {
      final state = await AppDI.instance.accountFollowRepository
          .toggleFollow(userId);

      if (!mounted) return;

      final updatedItem = AccountDiscoveryItem(
        profile: item.profile,
        followerCount: state.followerCount,
        isFollowing: state.isFollowing,
      );

      setState(() {
        _followers = _replaceConnection(
          _followers,
          updatedItem,
          removeWhenNotFollowing: false,
        );

        _following = _replaceConnection(
          _following,
          updatedItem,
          removeWhenNotFollowing: true,
          addWhenFollowing: true,
        );
      });

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isFollowing
                ? l10n.publicProfileFollowSuccess
                : l10n.publicProfileUnfollowSuccess,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.publicProfileFollowError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyUserIds.remove(userId);
        });
      }
    }
  }

  List<AccountDiscoveryItem> _replaceConnection(
    List<AccountDiscoveryItem> source,
    AccountDiscoveryItem updated, {
    required bool removeWhenNotFollowing,
    bool addWhenFollowing = false,
  }) {
    final targetUserId = updated.profile.id;
    final index = source.indexWhere(
      (item) => item.profile.id == targetUserId,
    );

    if (!updated.isFollowing && removeWhenNotFollowing) {
      return List<AccountDiscoveryItem>.unmodifiable(
        source.where((item) => item.profile.id != targetUserId),
      );
    }

    if (index < 0) {
      if (!addWhenFollowing || !updated.isFollowing) {
        return source;
      }

      return List<AccountDiscoveryItem>.unmodifiable(<AccountDiscoveryItem>[
        updated,
        ...source,
      ]);
    }

    final copy = List<AccountDiscoveryItem>.from(source);
    copy[index] = updated;
    return List<AccountDiscoveryItem>.unmodifiable(copy);
  }

  Future<void> _openProfile(AccountDiscoveryItem item) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PublicUserProfilePage(userId: item.profile.id),
      ),
    );

    if (mounted) {
      await _loadConnections();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileAccountConnectionsTitle),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: l10n.accountConnectionsFollowingTab),
              Tab(text: l10n.accountConnectionsFollowersTab),
            ],
          ),
        ),
        body: _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasLoadError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.accountConnectionsLoadError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _loadConnections,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.publicProfileFollowRetry),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      children: <Widget>[
        _AccountConnectionList(
          items: _following,
          emptyMessage: l10n.accountConnectionsEmptyFollowing,
          busyUserIds: _busyUserIds,
          onRefresh: _loadConnections,
          onOpenProfile: _openProfile,
          onToggleFollow: _toggleFollow,
        ),
        _AccountConnectionList(
          items: _followers,
          emptyMessage: l10n.accountConnectionsEmptyFollowers,
          busyUserIds: _busyUserIds,
          onRefresh: _loadConnections,
          onOpenProfile: _openProfile,
          onToggleFollow: _toggleFollow,
        ),
      ],
    );
  }
}

class _AccountConnectionList extends StatelessWidget {
  final List<AccountDiscoveryItem> items;
  final String emptyMessage;
  final Set<String> busyUserIds;
  final Future<void> Function() onRefresh;
  final Future<void> Function(AccountDiscoveryItem item) onOpenProfile;
  final Future<void> Function(AccountDiscoveryItem item) onToggleFollow;

  const _AccountConnectionList({
    required this.items,
    required this.emptyMessage,
    required this.busyUserIds,
    required this.onRefresh,
    required this.onOpenProfile,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final profile = item.profile;
          final displayName = _displayName(profile.displayName, profile.username);
          final username = profile.username?.trim() ?? '';
          final isBusy = busyUserIds.contains(profile.id);
          final l10n = AppLocalizations.of(context)!;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Avatar(
              name: displayName,
              imageUrl: profile.avatarUrl,
              size: 44,
            ),
            title: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (UserIdentityMark.shouldShowForProfile(profile))
                  UserIdentityMark.fromProfile(profile, size: 16),
              ],
            ),
            subtitle: Text(
              <String>[
                if (username.isNotEmpty) '@$username',
                '${item.followerCount} ${l10n.publicProfileFollowersLabel}',
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: item.isFollowing
                ? OutlinedButton(
                    onPressed: isBusy ? null : () => onToggleFollow(item),
                    child: isBusy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.publicProfileUnfollowAction),
                  )
                : FilledButton.tonal(
                    onPressed: isBusy ? null : () => onToggleFollow(item),
                    child: isBusy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.publicProfileFollowAction),
                  ),
            onTap: isBusy ? null : () => onOpenProfile(item),
          );
        },
      ),
    );
  }

  static String _displayName(String? displayName, String? username) {
    final normalizedDisplayName = displayName?.trim() ?? '';
    if (normalizedDisplayName.isNotEmpty) {
      return normalizedDisplayName;
    }

    final normalizedUsername = username?.trim() ?? '';
    if (normalizedUsername.isNotEmpty) {
      return normalizedUsername;
    }

    return 'Social Vote';
  }
}

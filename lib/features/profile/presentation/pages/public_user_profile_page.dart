import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/entities/account_follow_state.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/post_detail_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/ui/avatar.dart';
import 'package:sociale_vote/shared/widgets/user_identity_mark.dart';

class PublicUserProfilePage extends StatefulWidget {
  final String userId;

  const PublicUserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<PublicUserProfilePage> createState() => _PublicUserProfilePageState();
}

class _PublicUserProfilePageState extends State<PublicUserProfilePage> {
  UserProfile? _profile;
  List<Poll> _polls = const [];
  List<Post> _posts = const [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _pollsLoading = false;
  bool _pollsLoadError = false;
  bool _postsLoading = false;
  bool _postsLoadError = false;
  bool _blockStateLoading = false;
  bool _blockStateLoadError = false;
  bool _blockActionLoading = false;
  bool _isBlocked = false;
  AccountFollowState? _followState;
  bool _followStateLoading = false;
  bool _followStateLoadError = false;
  bool _followActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _loadProfile();

    if (!mounted || _profile == null) {
      return;
    }

    await Future.wait<void>([
      _loadBlockState(),
      _loadFollowState(),
    ]);
    if (!mounted) return;

    await _loadPolls();
    if (!mounted) return;

    await _loadPosts();
  }

  Future<void> _loadProfile() async {
    final normalizedUserId = widget.userId.trim();

    if (normalizedUserId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _profile = null;
        _polls = const [];
        _posts = const [];
        _isLoading = false;
        _hasLoadError = false;
        _pollsLoading = false;
        _pollsLoadError = false;
        _postsLoading = false;
        _postsLoadError = false;
        _blockStateLoading = false;
        _blockStateLoadError = false;
        _blockActionLoading = false;
        _isBlocked = false;
        _followState = null;
        _followStateLoading = false;
        _followStateLoadError = false;
        _followActionLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }

    try {
      final profile = await AppDI.instance.userProfileRepository
          .getUserProfile(normalizedUserId);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
        _hasLoadError = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _profile = null;
        _polls = const [];
        _posts = const [];
        _isLoading = false;
        _hasLoadError = true;
        _pollsLoading = false;
        _pollsLoadError = false;
        _postsLoading = false;
        _postsLoadError = false;
        _blockStateLoading = false;
        _blockStateLoadError = false;
        _blockActionLoading = false;
        _isBlocked = false;
        _followState = null;
        _followStateLoading = false;
        _followStateLoadError = false;
        _followActionLoading = false;
      });
    }
  }

  Future<void> _loadBlockState() async {
    final currentUserId = AppDI.instance.currentUserId?.trim();
    final targetUserId = widget.userId.trim();

    if (currentUserId == null ||
        currentUserId.isEmpty ||
        targetUserId.isEmpty ||
        currentUserId == targetUserId) {
      if (!mounted) return;
      setState(() {
        _isBlocked = false;
        _blockStateLoading = false;
        _blockStateLoadError = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _blockStateLoading = true;
        _blockStateLoadError = false;
      });
    }

    try {
      final blocked = await AppDI.instance.moderationRepository.isUserBlocked(
        blockerUserId: currentUserId,
        blockedUserId: targetUserId,
      );

      if (!mounted) return;

      setState(() {
        _isBlocked = blocked;
        _blockStateLoading = false;
        _blockStateLoadError = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _blockStateLoading = false;
        _blockStateLoadError = true;
      });
    }
  }

  Future<void> _confirmToggleBlock(AppLocalizations l10n) async {
    if (_blockActionLoading) {
      return;
    }

    final currentUserId = AppDI.instance.currentUserId?.trim();
    final targetUserId = widget.userId.trim();

    if (currentUserId == null ||
        currentUserId.isEmpty ||
        targetUserId.isEmpty ||
        currentUserId == targetUserId) {
      return;
    }

    final unblock = _isBlocked;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            unblock
                ? l10n.publicProfileUnblockDialogTitle
                : l10n.publicProfileBlockDialogTitle,
          ),
          content: Text(
            unblock
                ? l10n.publicProfileUnblockDialogMessage
                : l10n.publicProfileBlockDialogMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                unblock
                    ? l10n.publicProfileUnblockUserAction
                    : l10n.publicProfileBlockUserAction,
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _blockActionLoading = true;
    });

    try {
      if (unblock) {
        await AppDI.instance.moderationRepository.unblockUser(
          blockerUserId: currentUserId,
          blockedUserId: targetUserId,
        );
      } else {
        await AppDI.instance.moderationRepository.blockUser(
          blockerUserId: currentUserId,
          blockedUserId: targetUserId,
        );
      }

      if (!mounted) return;

      setState(() {
        _isBlocked = !unblock;
        _blockActionLoading = false;
        _blockStateLoadError = false;
      });

      await _loadFollowState();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unblock
                ? l10n.publicProfileUnblockSuccess
                : l10n.publicProfileBlockSuccess,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _blockActionLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.publicProfileBlockError),
        ),
      );
    }
  }

  Future<void> _loadFollowState() async {
    if (!mounted) return;
    final targetUserId = widget.userId.trim();
    if (targetUserId.isEmpty) {
      return;
    }

    setState(() {
      _followStateLoading = true;
      _followStateLoadError = false;
    });

    try {
      final state = await AppDI.instance.accountFollowRepository
          .getState(targetUserId);
      if (!mounted) return;

      setState(() {
        _followState = state;
        _followStateLoading = false;
        _followStateLoadError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _followStateLoading = false;
        _followStateLoadError = true;
      });
    }
  }

  Future<void> _toggleAccountFollow(AppLocalizations l10n) async {
    final currentUserId = AppDI.instance.currentUserId?.trim();
    final targetUserId = widget.userId.trim();
    final state = _followState;

    if (currentUserId == null ||
        currentUserId.isEmpty ||
        targetUserId.isEmpty ||
        currentUserId == targetUserId ||
        state == null ||
        !state.canFollow ||
        _followActionLoading) {
      return;
    }

    setState(() {
      _followActionLoading = true;
    });

    try {
      final updated = await AppDI.instance.accountFollowRepository
          .toggleFollow(targetUserId);
      if (!mounted) return;

      setState(() {
        _followState = updated;
        _followActionLoading = false;
        _followStateLoadError = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isFollowing
                ? l10n.publicProfileFollowSuccess
                : l10n.publicProfileUnfollowSuccess,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _followActionLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.publicProfileFollowError)),
      );
    }
  }

  List<Widget> _buildAppBarActions(AppLocalizations l10n) {
    final currentUserId = AppDI.instance.currentUserId?.trim();
    final targetUserId = widget.userId.trim();

    final canManageBlock = currentUserId != null &&
        currentUserId.isNotEmpty &&
        targetUserId.isNotEmpty &&
        currentUserId != targetUserId;

    if (!canManageBlock) {
      return const [];
    }

    if (_blockStateLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ];
    }

    if (_blockStateLoadError) {
      return [
        IconButton(
          onPressed: _loadBlockState,
          tooltip: l10n.publicProfileBlockError,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ];
    }

    return [
      PopupMenuButton<String>(
        enabled: !_blockActionLoading,
        onSelected: (_) => _confirmToggleBlock(l10n),
        itemBuilder: (_) => [
          PopupMenuItem<String>(
            value: 'toggle_block',
            child: Row(
              children: [
                Icon(
                  _isBlocked
                      ? Icons.person_add_alt_1_outlined
                      : Icons.block_outlined,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Text(
                  _isBlocked
                      ? l10n.publicProfileUnblockUserAction
                      : l10n.publicProfileBlockUserAction,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Future<void> _loadPolls() async {
    final normalizedUserId = widget.userId.trim();
    if (normalizedUserId.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _pollsLoading = true;
        _pollsLoadError = false;
      });
    }

    try {
      final polls = await AppDI.instance.pollRepository.getPollsByAuthor(
        authorUserId: normalizedUserId,
        limit: 20,
        offset: 0,
      );

      if (!mounted) return;

      setState(() {
        _polls = polls;
        _pollsLoading = false;
        _pollsLoadError = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _polls = const [];
        _pollsLoading = false;
        _pollsLoadError = true;
      });
    }
  }

  Future<void> _loadPosts() async {
    final normalizedUserId = widget.userId.trim();
    if (normalizedUserId.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _postsLoading = true;
        _postsLoadError = false;
      });
    }

    try {
      final posts = await AppDI.instance.postRepository.getPostsByAuthor(
        authorUserId: normalizedUserId,
        limit: 20,
        offset: 0,
      );

      if (!mounted) return;

      setState(() {
        _posts = posts;
        _postsLoading = false;
        _postsLoadError = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _posts = const [];
        _postsLoading = false;
        _postsLoadError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.publicProfilePageTitle),
        actions: _buildAppBarActions(l10n),
      ),
      body: _buildBody(context, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasLoadError) {
      return _PublicProfileMessageState(
        icon: Icons.error_outline_rounded,
        message: l10n.publicProfileLoadError,
        onRetry: _loadAll,
      );
    }

    final profile = _profile;
    if (profile == null) {
      return _PublicProfileMessageState(
        icon: Icons.person_off_outlined,
        message: l10n.publicProfileNotFound,
        onRetry: _loadAll,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _PublicProfileHeader(
            profile: profile,
            l10n: l10n,
            followState: _followState,
            followStateLoading: _followStateLoading,
            followStateLoadError: _followStateLoadError,
            followActionLoading: _followActionLoading,
            onToggleFollow: () => _toggleAccountFollow(l10n),
            onRetryFollow: _loadFollowState,
          ),
          const SizedBox(height: 20),
          _buildPublicContentSection(
            context,
            l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildPublicContentSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isItalian = locale.toLowerCase().startsWith('it');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.publicProfileContentSectionTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),

        // Poll pubblici
        Row(
          children: [
            Icon(
              Icons.how_to_vote_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${l10n.publicProfilePollsAction} · ${_polls.length}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_pollsLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_pollsLoadError)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isItalian
                          ? 'Impossibile caricare i sondaggi pubblici.'
                          : 'Unable to load public polls.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadPolls,
                    tooltip: MaterialLocalizations.of(context)
                        .refreshIndicatorSemanticLabel,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
          )
        else if (_polls.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isItalian
                          ? 'Nessun sondaggio pubblico.'
                          : 'No public polls.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.68,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._polls.map(
            (poll) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PublicPollTile(
                poll: poll,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PollDetailPage(
                        pollId: poll.id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        const SizedBox(height: 18),

        // Post pubblici
        Row(
          children: [
            Icon(
              Icons.article_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${l10n.publicProfilePostsAction} · ${_posts.length}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_postsLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_postsLoadError)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isItalian
                          ? 'Impossibile caricare i post pubblici.'
                          : 'Unable to load public posts.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadPosts,
                    tooltip: MaterialLocalizations.of(context)
                        .refreshIndicatorSemanticLabel,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
          )
        else if (_posts.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isItalian ? 'Nessun post pubblico.' : 'No public posts.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.68,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._posts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PublicPostTile(
                post: post,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PostDetailPage(
                        postId: post.id.value,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _PublicProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final AppLocalizations l10n;
  final AccountFollowState? followState;
  final bool followStateLoading;
  final bool followStateLoadError;
  final bool followActionLoading;
  final VoidCallback onToggleFollow;
  final VoidCallback onRetryFollow;

  const _PublicProfileHeader({
    required this.profile,
    required this.l10n,
    required this.followState,
    required this.followStateLoading,
    required this.followStateLoadError,
    required this.followActionLoading,
    required this.onToggleFollow,
    required this.onRetryFollow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final displayName = _normalize(profile.displayName);
    final username = _normalize(profile.username);
    final bio = _normalize(profile.bio);
    final identityDetail = _normalize(profile.identityDetailLabel);
    final residence = _residenceLabel(profile, l10n);

    final nameLabel = displayName ?? l10n.publicProfileUserFallback;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(
                  name: nameLabel,
                  imageUrl: _normalize(profile.avatarUrl),
                  size: 72,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              nameLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (UserIdentityMark.shouldShowForProfile(profile))
                            UserIdentityMark.fromProfile(
                              profile,
                              size: 18,
                            ),
                        ],
                      ),
                      if (username != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '@$username',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (identityDetail != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          identityDetail,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _AccountFollowSummary(
              state: followState,
              isLoading: followStateLoading,
              hasError: followStateLoadError,
              isActionLoading: followActionLoading,
              l10n: l10n,
              onToggle: onToggleFollow,
              onRetry: onRetryFollow,
            ),
            const SizedBox(height: 18),
            Text(
              bio ?? l10n.publicProfileNoBio,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: bio == null
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.58)
                    : null,
                fontStyle: bio == null ? FontStyle.italic : null,
              ),
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 14),
            _PublicProfileInfoRow(
              icon: Icons.location_on_outlined,
              label: l10n.publicProfileResidenceLabel,
              value: residence,
            ),
            const SizedBox(height: 12),
            _PublicProfileInfoRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.publicProfileMemberSinceLabel,
              value: MaterialLocalizations.of(context).formatMediumDate(
                profile.createdAt.toLocal(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String _residenceLabel(
    UserProfile profile,
    AppLocalizations l10n,
  ) {
    final country = _normalize(profile.country);
    final city = _normalize(profile.city);

    if (country == null && city == null) {
      return l10n.publicProfileResidenceUnknown;
    }

    if (country == null) {
      return city!;
    }

    if (city == null) {
      return country;
    }

    return '$city, $country';
  }
}

class _AccountFollowSummary extends StatelessWidget {
  final AccountFollowState? state;
  final bool isLoading;
  final bool hasError;
  final bool isActionLoading;
  final AppLocalizations l10n;
  final VoidCallback onToggle;
  final VoidCallback onRetry;

  const _AccountFollowSummary({
    required this.state,
    required this.isLoading,
    required this.hasError,
    required this.isActionLoading,
    required this.l10n,
    required this.onToggle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading && state == null) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (hasError && state == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l10n.publicProfileFollowRetry),
        ),
      );
    }

    final currentState = state;
    if (currentState == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FollowCount(
          value: currentState.followerCount,
          label: l10n.publicProfileFollowersLabel,
        ),
        _FollowCount(
          value: currentState.followingCount,
          label: l10n.publicProfileFollowingLabel,
        ),
        if (currentState.canFollow)
          FilledButton.tonalIcon(
            onPressed: isActionLoading ? null : onToggle,
            icon: isActionLoading
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    currentState.isFollowing
                        ? Icons.person_remove_outlined
                        : Icons.person_add_alt_1_outlined,
                  ),
            label: Text(
              currentState.isFollowing
                  ? l10n.publicProfileUnfollowAction
                  : l10n.publicProfileFollowAction,
            ),
          ),
        if (hasError && state != null)
          IconButton(
            onPressed: onRetry,
            tooltip: l10n.publicProfileFollowRetry,
            icon: Icon(
              Icons.refresh_rounded,
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}

class _FollowCount extends StatelessWidget {
  final int value;
  final String label;

  const _FollowCount({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: label),
        ],
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}

class _PublicProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PublicProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: secondaryColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublicPollTile extends StatelessWidget {
  final Poll poll;
  final VoidCallback onTap;

  const _PublicPollTile({
    required this.poll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = poll.description?.trim() ?? '';
    final createdAt = poll.createdAt;
    final publishedAs = poll.publishedAsDisplayName?.trim();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poll.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                  ),
                ),
              ],
              if (publishedAs != null && publishedAs.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: 15,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        publishedAs,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.62,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (createdAt != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 15,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.52),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      MaterialLocalizations.of(context).formatMediumDate(
                        createdAt.toLocal(),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.58,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.46),
                    ),
                  ],
                ),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.46),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicPostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _PublicPostTile({
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = post.title.trim();
    final content = post.content.trim();
    final dateLabel = MaterialLocalizations.of(context).formatMediumDate(
      post.createdAt.toLocal(),
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              if (title.isNotEmpty && content.isNotEmpty)
                const SizedBox(height: 6),
              if (content.isNotEmpty)
                Text(
                  content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.58),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.46),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicProfileMessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Future<void> Function() onRetry;

  const _PublicProfileMessageState({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 44,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            IconButton.filledTonal(
              onPressed: onRetry,
              tooltip: MaterialLocalizations.of(context)
                  .refreshIndicatorSemanticLabel,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

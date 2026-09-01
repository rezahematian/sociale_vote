import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/entities/account_follow_state.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/organization/entities/organization_models.dart';
import 'package:sociale_vote/features/organization/presentation/widgets/organization_cover_header.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/post_detail_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';
import 'package:sociale_vote/shared/widgets/user_identity_mark.dart';

class PublicUserProfilePage extends StatefulWidget {
  final String userId;
  final String? organizationId;

  const PublicUserProfilePage({
    super.key,
    required this.userId,
    this.organizationId,
  });

  @override
  State<PublicUserProfilePage> createState() => _PublicUserProfilePageState();
}

class _PublicUserProfilePageState extends State<PublicUserProfilePage> {
  UserProfile? _profile;
  OrganizationProfile? _organization;
  List<OrganizationExternalLink> _organizationExternalLinks = const [];
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
  OrganizationFollowState? _organizationFollowState;
  bool _organizationFollowStateLoading = false;
  bool _organizationFollowStateLoadError = false;
  bool _organizationFollowActionLoading = false;
  int _contentFilterIndex = 0;

  String? get _explicitOrganizationId {
    final normalized = widget.organizationId?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

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

    final profile = _profile!;
    final profileTasks = <Future<void>>[
      _loadBlockState(),
      _loadOrganization(),
    ];
    if (_explicitOrganizationId == null && !profile.isOrganizationActor) {
      profileTasks.add(_loadFollowState());
    }

    await Future.wait<void>(profileTasks);
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
        _organization = null;
        _organizationExternalLinks = const [];
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
        _organizationFollowState = null;
        _organizationFollowStateLoading = false;
        _organizationFollowStateLoadError = false;
        _organizationFollowActionLoading = false;
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
        _organization = null;
        _organizationExternalLinks = const [];
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
        _organizationFollowState = null;
        _organizationFollowStateLoading = false;
        _organizationFollowStateLoadError = false;
        _organizationFollowActionLoading = false;
      });
    }
  }

  Future<void> _loadOrganization() async {
    final profile = _profile;
    final organizationId = _explicitOrganizationId;
    if (profile == null ||
        (organizationId == null && !profile.isOrganizationActor)) {
      if (mounted) {
        setState(() {
          _organization = null;
          _organizationExternalLinks = const [];
          _organizationFollowState = null;
          _organizationFollowStateLoading = false;
          _organizationFollowStateLoadError = false;
          _organizationFollowActionLoading = false;
        });
      }
      return;
    }

    try {
      final organization = organizationId == null
          ? await AppDI.instance.organizationRepository
              .getPublicOrganizationByOperator(widget.userId)
          : await AppDI.instance.organizationRepository
              .getPublicOrganizationById(organizationId);
      if (!mounted) return;

      setState(() => _organization = organization);

      if (organization != null) {
        await Future.wait<void>(<Future<void>>[
          _loadOrganizationFollowState(organization),
          _loadOrganizationExternalLinks(organization),
        ]);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _organization = null;
        _organizationExternalLinks = const [];
        _organizationFollowState = null;
        _organizationFollowStateLoading = false;
        _organizationFollowStateLoadError = true;
        _organizationFollowActionLoading = false;
      });
    }
  }

  Future<void> _loadOrganizationExternalLinks(
    OrganizationProfile organization,
  ) async {
    try {
      final links = await AppDI.instance.organizationRepository
          .listPublicExternalLinks(organization.id);
      if (!mounted || _organization?.id != organization.id) return;
      setState(() => _organizationExternalLinks = links);
    } catch (_) {
      if (!mounted || _organization?.id != organization.id) return;
      setState(() => _organizationExternalLinks = const []);
    }
  }

  Future<void> _loadOrganizationFollowState(
    OrganizationProfile organization,
  ) async {
    if (!mounted) return;

    setState(() {
      _organizationFollowStateLoading = true;
      _organizationFollowStateLoadError = false;
    });

    try {
      final state = await AppDI.instance.organizationRepository
          .getOrganizationFollowState(organization.id);
      if (!mounted || _organization?.id != organization.id) return;

      setState(() {
        _organizationFollowState = state;
        _organizationFollowStateLoading = false;
        _organizationFollowStateLoadError = false;
      });
    } catch (_) {
      if (!mounted || _organization?.id != organization.id) return;
      setState(() {
        _organizationFollowStateLoading = false;
        _organizationFollowStateLoadError = true;
      });
    }
  }

  Future<void> _toggleOrganizationFollow(AppLocalizations l10n) async {
    if (_organizationFollowActionLoading) {
      return;
    }

    final organization = _organization;
    if (organization == null || organization.id.trim().isEmpty) {
      return;
    }

    final currentUserId = AppDI.instance.currentUserId?.trim();
    final operatorUserId = widget.userId.trim();
    if (currentUserId != null &&
        currentUserId.isNotEmpty &&
        currentUserId == operatorUserId) {
      return;
    }

    final authenticated = await AuthGuard.ensureAuthenticated(
      context,
      actionLabel: l10n.publicProfileFollowAction,
    );
    if (!mounted || !authenticated) {
      return;
    }

    setState(() {
      _organizationFollowActionLoading = true;
    });

    try {
      final updated = await AppDI.instance.organizationRepository
          .toggleOrganizationFollow(organization.id);
      if (!mounted || _organization?.id != organization.id) return;

      setState(() {
        _organizationFollowState = updated;
        _organizationFollowActionLoading = false;
        _organizationFollowStateLoadError = false;
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
        _organizationFollowActionLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.publicProfileFollowError)),
      );
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
      final state =
          await AppDI.instance.accountFollowRepository.getState(targetUserId);
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
    if (_explicitOrganizationId != null) {
      return const <Widget>[];
    }

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
      final organizationId = _explicitOrganizationId;
      final polls = organizationId == null
          ? await AppDI.instance.pollRepository.getPollsByAuthor(
              authorUserId: normalizedUserId,
              limit: 20,
              offset: 0,
            )
          : await AppDI.instance.pollRepository
              .getPollsByPublisherOrganizations(
              organizationIds: <String>{organizationId},
              limit: 20,
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
      final organizationId = _explicitOrganizationId;
      final posts = organizationId == null
          ? await AppDI.instance.postRepository.getPostsByAuthor(
              authorUserId: normalizedUserId,
              limit: 20,
              offset: 0,
            )
          : await AppDI.instance.postRepository
              .getPostsByPublisherOrganizations(
              organizationIds: <String>{organizationId},
              limit: 20,
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
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_organization != null) ...[
                    OrganizationCoverHeader(
                      organization: _organization!,
                      verifiedLabel: l10n.organizationVerifiedLabel,
                      compact: true,
                    ),
                    const SizedBox(height: 12),
                    _OrganizationPublicActions(
                      organization: _organization!,
                      externalLinks: _organizationExternalLinks,
                      followState: _organizationFollowState,
                      followStateLoading: _organizationFollowStateLoading,
                      followStateLoadError: _organizationFollowStateLoadError,
                      followActionLoading: _organizationFollowActionLoading,
                      showFollowAction: AppDI.instance.currentUserId?.trim() !=
                          widget.userId.trim(),
                      l10n: l10n,
                      onToggleFollow: () => _toggleOrganizationFollow(l10n),
                      onRetryFollow: () =>
                          _loadOrganizationFollowState(_organization!),
                    ),
                  ] else
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
                  const SizedBox(height: 18),
                  _buildPublicContentSection(
                    context,
                    l10n,
                  ),
                ],
              ),
            ),
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
    final showPolls = _contentFilterIndex == 0 || _contentFilterIndex == 2;
    final showPosts = _contentFilterIndex == 0 || _contentFilterIndex == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.publicProfileContentSectionTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${_polls.length + _posts.length}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PublicContentFilterChip(
              label: l10n.searchTypeAll,
              count: _polls.length + _posts.length,
              selected: _contentFilterIndex == 0,
              onSelected: () => setState(() => _contentFilterIndex = 0),
            ),
            _PublicContentFilterChip(
              label: l10n.publicProfilePostsAction,
              count: _posts.length,
              selected: _contentFilterIndex == 1,
              onSelected: () => setState(() => _contentFilterIndex = 1),
            ),
            _PublicContentFilterChip(
              label: l10n.publicProfilePollsAction,
              count: _polls.length,
              selected: _contentFilterIndex == 2,
              onSelected: () => setState(() => _contentFilterIndex = 2),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (showPosts) ...[
          _PublicContentGroupHeader(
            icon: Icons.article_outlined,
            label: l10n.publicProfilePostsAction,
            count: _posts.length,
          ),
          const SizedBox(height: 8),
          _buildPostsContent(context, l10n),
          if (showPolls) const SizedBox(height: 18),
        ],
        if (showPolls) ...[
          _PublicContentGroupHeader(
            icon: Icons.how_to_vote_outlined,
            label: l10n.publicProfilePollsAction,
            count: _polls.length,
          ),
          const SizedBox(height: 8),
          _buildPollsContent(context, l10n),
        ],
      ],
    );
  }

  Widget _buildPollsContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (_pollsLoading) {
      return const _PublicContentLoading();
    }

    if (_pollsLoadError) {
      return _PublicContentError(
        message: l10n.publicProfilePollsLoadError,
        onRetry: _loadPolls,
      );
    }

    if (_polls.isEmpty) {
      return _PublicContentEmpty(
        message: l10n.publicProfilePollsEmpty,
      );
    }

    return Column(
      children: _polls
          .map(
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
          )
          .toList(growable: false),
    );
  }

  Widget _buildPostsContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (_postsLoading) {
      return const _PublicContentLoading();
    }

    if (_postsLoadError) {
      return _PublicContentError(
        message: l10n.publicProfilePostsLoadError,
        onRetry: _loadPosts,
      );
    }

    if (_posts.isEmpty) {
      return _PublicContentEmpty(
        message: l10n.publicProfilePostsEmpty,
      );
    }

    return Column(
      children: _posts
          .map(
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
          )
          .toList(growable: false),
    );
  }
}

class _PublicContentFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  const _PublicContentFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      avatar: selected
          ? Icon(
              Icons.check_rounded,
              size: 16,
              color: theme.colorScheme.onSecondaryContainer,
            )
          : null,
      label: Text('$label $count'),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }
}

class _PublicContentGroupHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _PublicContentGroupHeader({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.onSurface.withValues(alpha: 0.58);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PublicContentLoading extends StatelessWidget {
  const _PublicContentLoading();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _PublicContentError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PublicContentError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
                message,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
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

class _PublicContentEmpty extends StatelessWidget {
  final String message;

  const _PublicContentEmpty({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationPublicActions extends StatelessWidget {
  final OrganizationProfile organization;
  final List<OrganizationExternalLink> externalLinks;
  final OrganizationFollowState? followState;
  final bool followStateLoading;
  final bool followStateLoadError;
  final bool followActionLoading;
  final bool showFollowAction;
  final AppLocalizations l10n;
  final VoidCallback onToggleFollow;
  final VoidCallback onRetryFollow;

  const _OrganizationPublicActions({
    required this.organization,
    required this.externalLinks,
    required this.followState,
    required this.followStateLoading,
    required this.followStateLoadError,
    required this.followActionLoading,
    required this.showFollowAction,
    required this.l10n,
    required this.onToggleFollow,
    required this.onRetryFollow,
  });

  String _organizationTypeLabel(
    AppLocalizations l10n,
    OrganizationEntityType type,
  ) {
    return switch (type) {
      OrganizationEntityType.association => l10n.organizationTypeAssociation,
      OrganizationEntityType.nonprofit => l10n.organizationTypeNonprofit,
      OrganizationEntityType.company => l10n.organizationTypeCompany,
      OrganizationEntityType.cooperative => l10n.organizationTypeCooperative,
      OrganizationEntityType.sports => l10n.organizationTypeSports,
      OrganizationEntityType.publicBody => l10n.organizationTypePublicBody,
      OrganizationEntityType.committee => l10n.organizationTypeCommittee,
      OrganizationEntityType.other => l10n.organizationTypeOther,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final website = organization.websiteUrl?.trim();
    final typeLabel = _organizationTypeLabel(l10n, organization.entityType);
    final showType = organization.entityType != OrganizationEntityType.other;

    final websiteButton = website == null || website.isEmpty
        ? null
        : OutlinedButton.icon(
            onPressed: () async {
              final normalized = website.startsWith('http://') ||
                      website.startsWith('https://')
                  ? website
                  : 'https://$website';
              final uri = Uri.tryParse(normalized);
              if (uri != null) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            icon: const Icon(Icons.language_rounded),
            label: Text(l10n.organizationOfficialWebsiteAction),
          );

    final channelButtons = externalLinks
        .where((link) => link.isPublic)
        .map(
          (link) => OutlinedButton.icon(
            onPressed: () => _openExternalLink(link.canonicalUrl),
            icon: Icon(_externalIcon(link.provider)),
            label: Text(link.provider.label),
          ),
        )
        .toList(growable: false);

    final actions = <Widget>[
      if (websiteButton != null) websiteButton,
      ...channelButtons,
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (showType)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 17,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.60,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        typeLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.72,
                          ),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                _OrganizationFollowSummary(
                  state: followState,
                  isLoading: followStateLoading,
                  hasError: followStateLoadError,
                  isActionLoading: followActionLoading,
                  showAction: showFollowAction,
                  l10n: l10n,
                  onToggle: onToggleFollow,
                  onRetry: onRetryFollow,
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openExternalLink(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || uri.scheme != 'https') return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  IconData _externalIcon(OrganizationExternalLinkProvider provider) {
    return switch (provider) {
      OrganizationExternalLinkProvider.youtube =>
        Icons.play_circle_outline_rounded,
      OrganizationExternalLinkProvider.linkedin => Icons.work_outline_rounded,
      OrganizationExternalLinkProvider.whatsapp => Icons.chat_outlined,
      OrganizationExternalLinkProvider.instagram => Icons.photo_camera_outlined,
      OrganizationExternalLinkProvider.telegram => Icons.send_outlined,
    };
  }
}

class _OrganizationFollowSummary extends StatelessWidget {
  final OrganizationFollowState? state;
  final bool isLoading;
  final bool hasError;
  final bool isActionLoading;
  final bool showAction;
  final AppLocalizations l10n;
  final VoidCallback onToggle;
  final VoidCallback onRetry;

  const _OrganizationFollowSummary({
    required this.state,
    required this.isLoading,
    required this.hasError,
    required this.isActionLoading,
    required this.showAction,
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
      return TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(l10n.publicProfileFollowRetry),
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
        if (showAction)
          FilledButton.tonalIcon(
            onPressed: isActionLoading ? null : onToggle,
            icon: isActionLoading
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    currentState.isFollowing
                        ? Icons.notifications_active_outlined
                        : Icons.add_circle_outline_rounded,
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
    final memberSince = MaterialLocalizations.of(context).formatMediumDate(
      profile.createdAt.toLocal(),
    );

    final nameLabel = displayName ?? l10n.publicProfileUserFallback;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;

            final identity = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PublisherAvatar(
                  displayName: nameLabel,
                  imageUrl: _normalize(profile.avatarUrl),
                  actorType: profile.actorType,
                  verificationLevel: profile.verificationLevel,
                  institutionLevel: profile.institutionLevel,
                  size: compact ? 68 : 78,
                  showTooltip: false,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            nameLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
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
                        const SizedBox(height: 3),
                        Text(
                          '@$username',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (identityDetail != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          identityDetail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.70,
                            ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );

            final follow = _AccountFollowSummary(
              state: followState,
              isLoading: followStateLoading,
              hasError: followStateLoadError,
              isActionLoading: followActionLoading,
              l10n: l10n,
              onToggle: onToggleFollow,
              onRetry: onRetryFollow,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 14),
                follow,
                const SizedBox(height: 14),
                Text(
                  bio ?? l10n.publicProfileNoBio,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: bio == null
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.56)
                        : null,
                    fontStyle: bio == null ? FontStyle.italic : null,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 18,
                  runSpacing: 10,
                  children: [
                    _PublicProfileMeta(
                      icon: Icons.location_on_outlined,
                      value: residence,
                    ),
                    _PublicProfileMeta(
                      icon: Icons.calendar_today_outlined,
                      value: memberSince,
                    ),
                  ],
                ),
              ],
            );
          },
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

class _PublicProfileMeta extends StatelessWidget {
  final IconData icon;
  final String value;

  const _PublicProfileMeta({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.onSurface.withValues(alpha: 0.62);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: secondary,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: secondary,
            fontWeight: FontWeight.w700,
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

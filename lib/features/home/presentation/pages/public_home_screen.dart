import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/geo/application/follow_scope_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

// 🔍 Trending
import 'package:sociale_vote/features/discovery/application/trending_controller.dart';
// ⭐ For You
import 'package:sociale_vote/features/discovery/application/for_you_feed_controller.dart';

// 🔍 Search page
import 'package:sociale_vote/features/search/presentation/pages/search_page.dart';

// Auth pages
import 'package:sociale_vote/features/auth/presentation/pages/login_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/register_page.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  GeoScopeController get _geoScopeController =>
      AppDI.instance.geoScopeController;

  FollowScopeController get _followScopeController =>
      AppDI.instance.followScopeController;

  @override
  void initState() {
    super.initState();
  }

  void _setWorld() => _geoScopeController.setWorld();
  void _setItaly() => _geoScopeController.setCountry('IT');
  void _setTorino() =>
      _geoScopeController.setCity(countryCode: 'IT', cityId: 'TORINO');

  void _handleSearchSubmitted(String rawQuery) {
    final l10n = AppLocalizations.of(context)!;
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    final q = query.toLowerCase();

    // --- GEO SEARCH (places) ---
    if (q == 'world' || q == 'mondo' || q == 'global') {
      _setWorld();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeScopeChangedWorld)),
      );
      return;
    }

    if (q == 'italy' || q == 'italia' || q == 'it') {
      _setItaly();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeScopeChangedItaly)),
      );
      return;
    }

    if (q == 'torino' || q == 'turin') {
      _setTorino();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeScopeChangedTorino)),
      );
      return;
    }

    // --- CONTENT SEARCH (SearchPage) ---
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SearchPage(),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _onRegisterPressed() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _onLogoutPressed() async {
    final l10n = AppLocalizations.of(context)!;

    await AppDI.instance.sessionRepository.clearSession();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.homeLogoutMessage,
        ),
      ),
    );
  }

  void _onProfilePressed() {
    Navigator.pushNamed(context, '/profile');
  }

  String _scopeLabel(GeoScope scope) {
    final l10n = AppLocalizations.of(context)!;

    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.homeScopeLabelWorld;
      case GeoScopeLevel.country:
        return l10n.homeScopeLabelCountry;
      case GeoScopeLevel.city:
        return l10n.homeScopeLabelCity;
    }
  }

  String _scopeShortLabel(GeoScope scope) {
    final l10n = AppLocalizations.of(context)!;

    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.homeScopeShortWorld;
      case GeoScopeLevel.country:
        return scope.countryCode ?? l10n.homeScopeShortCountry;
      case GeoScopeLevel.city:
        return scope.cityId ?? l10n.homeScopeShortCity;
    }
  }

  bool _isScopeFollowed(GeoScope scope) {
    return _followScopeController.isScopeFollowed(scope);
  }

  Future<void> _onToggleFollowScope(GeoScope scope) async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.followScope,
    );
    if (!allowed) return;

    await _followScopeController.toggleFollowForScope(scope);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final String? currentUserId = AppDI.instance.currentUserId;
    final bool isLoggedIn = currentUserId != null;

    return AnimatedBuilder(
      animation: _geoScopeController,
      builder: (context, _) {
        final scope = _geoScopeController.scope;
        final scopeLabel = _scopeLabel(scope);
        final scopeShortLabel = _scopeShortLabel(scope);

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            titleSpacing: 16,
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sociale Vote',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scopeShortLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (!isLoggedIn) ...[
                  TextButton(
                    onPressed: _onLoginPressed,
                    child: Text(l10n.homeLoginButton),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: _onRegisterPressed,
                    child: Text(l10n.homeRegisterButton),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: _onProfilePressed,
                    child: Text(l10n.homeProfileButton),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: _onLogoutPressed,
                    child: Text(l10n.homeLogoutButton),
                  ),
                ],
              ],
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                // ====== SEARCH BAR ======
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.homeSearchHint,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: _handleSearchSubmitted,
                  ),
                ),

                // ====== STATO UTENTE ======
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isLoggedIn
                                ? l10n.homeUserStatusLoggedIn(
                                    currentUserId!,
                                  )
                                : l10n.homeUserStatusGuest,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ====== MAPPA ======
                SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CivicMapWidget(
                        currentScopeLabel: scopeShortLabel,
                      ),
                    ),
                  ),
                ),

                // ====== SCOPE PANEL ======
                _buildScopePanel(context, scope, scopeLabel),

                const Divider(height: 1),

                // ====== CONTENUTO PRINCIPALE ======
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      // TRENDING
                      ChangeNotifierProvider<TrendingController>(
                        key: ValueKey(
                          'home_trending_${scope.level}_${scope.countryCode}_${scope.cityId}_${isLoggedIn ? currentUserId : 'guest'}',
                        ),
                        create: (_) =>
                            AppDI.instance.createTrendingController(),
                        child: const _HomeTrendingSection(),
                      ),
                      const SizedBox(height: 24),

                      // FOR YOU
                      ChangeNotifierProvider<ForYouFeedController>(
                        key: ValueKey(
                          'home_for_you_${scope.level}_${scope.countryCode}_${scope.cityId}_${isLoggedIn ? currentUserId : 'guest'}',
                        ),
                        create: (_) {
                          final controller =
                              AppDI.instance.createForYouFeedController();
                          controller.load(userId: currentUserId);
                          return controller;
                        },
                        child: _HomeForYouSection(
                          scopeShortLabel: scopeShortLabel,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // POLLS
                      ChangeNotifierProvider<PollListController>(
                        key: ValueKey(
                          'home_polls_${scope.level}_${scope.countryCode}_${scope.cityId}',
                        ),
                        create: (_) {
                          final controller =
                              AppDI.instance.createPollListController();
                          final userId = AppDI.instance.currentUserId;
                          controller.loadPolls(userId: userId);
                          return controller;
                        },
                        child: _HomePollsSection(
                          scopeShortLabel: scopeShortLabel,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // NEWS
                      ChangeNotifierProvider<NewsController>(
                        key: ValueKey(
                          'home_news_${scope.level}_${scope.countryCode}_${scope.cityId}',
                        ),
                        create: (_) =>
                            AppDI.instance.createNewsController()
                              ..loadNews(),
                        child: _HomeNewsSection(
                          scopeShortLabel: scopeShortLabel,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SOCIAL
                      ChangeNotifierProvider<FeedController>(
                        key: ValueKey(
                          'home_social_${scope.level}_${scope.countryCode}_${scope.cityId}',
                        ),
                        create: (_) =>
                            AppDI.instance.createFeedController()
                              ..loadFeed(),
                        child: _HomeSocialSection(
                          scopeShortLabel: scopeShortLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScopePanel(
    BuildContext context,
    GeoScope scope,
    String scopeLabel,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isWorld = scope.level == GeoScopeLevel.world;
    final isItaly = scope.level == GeoScopeLevel.country &&
        (scope.countryCode ?? '').toUpperCase() == 'IT';
    final isTorino = scope.level == GeoScopeLevel.city &&
        (scope.cityId ?? '').toUpperCase() == 'TORINO';

    final isFollowed = _isScopeFollowed(scope);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.public,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scopeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FollowScopeButton(
                    isFollowed: isFollowed,
                    onToggle: () => _onToggleFollowScope(scope),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n.homeScopeChipWorld),
                    selected: isWorld,
                    onSelected: (_) => _setWorld(),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n.homeScopeChipItaly),
                    selected: isItaly,
                    onSelected: (_) => _setItaly(),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n.homeScopeChipTorino),
                    selected: isTorino,
                    onSelected: (_) => _setTorino(),
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

class _FollowScopeButton extends StatelessWidget {
  final bool isFollowed;
  final VoidCallback onToggle;

  const _FollowScopeButton({
    required this.isFollowed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return OutlinedButton.icon(
      onPressed: onToggle,
      icon: Icon(
        isFollowed ? Icons.check : Icons.add_location_alt_outlined,
        size: 18,
      ),
      label: Text(
        isFollowed
            ? l10n.followScopeButtonFollowed
            : l10n.followScopeButtonFollow,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isFollowed
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        side: BorderSide(
          color: isFollowed
              ? theme.colorScheme.primary
              : theme.dividerColor.withOpacity(0.6),
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Sezione "Trending now"
class _HomeTrendingSection extends StatelessWidget {
  const _HomeTrendingSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<TrendingController>();

    final posts = controller.posts;

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.trending_up,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homeTrendingTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    Widget content;

    if (controller.isLoading && posts.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.hasError) {
      content = Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 8),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            l10n.homeTrendingError,
          ),
        ),
      );
    } else if (posts.isEmpty) {
      content = Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 8),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            l10n.homeTrendingEmpty,
          ),
        ),
      );
    } else {
      final topPosts = posts.length <= 3
          ? posts
          : posts.take(3).toList(growable: false);

      content = Column(
        children: topPosts
            .map(
              (post) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _TrendingPostCard(post: post),
              ),
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        content,
      ],
    );
  }
}

class _HomeForYouSection extends StatelessWidget {
  final String scopeShortLabel;

  const _HomeForYouSection({
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<ForYouFeedController>();

    final posts = controller.posts;

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.secondary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.star,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homeForYouTitle(scopeShortLabel),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    Widget content;

    if (controller.isLoading && posts.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.hasError) {
      content = Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 8),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            l10n.homeForYouError,
          ),
        ),
      );
    } else if (posts.isEmpty) {
      content = Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 8),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            l10n.homeForYouEmpty,
          ),
        ),
      );
    } else {
      final topPosts = posts.length <= 3
          ? posts
          : posts.take(3).toList(growable: false);

      content = Column(
        children: topPosts
            .map(
              (post) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _PostPreviewCard(post: post),
              ),
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        content,
      ],
    );
  }
}

class _TrendingPostCard extends StatelessWidget {
  final Post post;

  const _TrendingPostCard({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(context, AppRouter.social);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (post.content.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  post.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatPostCreatedAt(post.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPostCreatedAt(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _HomePollsSection extends StatelessWidget {
  final String scopeShortLabel;

  const _HomePollsSection({
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<PollListController>();

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.how_to_vote,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homePollsTitle(scopeShortLabel),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final allPolls = controller.polls;

    Widget content;

    if (controller.isLoading && allPolls.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (allPolls.isEmpty) {
      content = _HomePollsPlaceholderCard(
        title: l10n.homePollsEmptyTitle,
        subtitle: l10n.homePollsEmptySubtitle,
      );
    } else {
      final sorted = List<Poll>.from(allPolls);
      sorted.sort((a, b) {
        final heatA =
            controller.likeCountForPoll(a) -
                controller.dislikeCountForPoll(a);
        final heatB =
            controller.likeCountForPoll(b) -
                controller.dislikeCountForPoll(b);
        return heatB.compareTo(heatA);
      });

      final polls = sorted.length <= 3
          ? sorted
          : sorted.take(3).toList(growable: false);

      content = Column(
        children: polls
            .map(
              (poll) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.pollDetail,
                      arguments: poll.id,
                    );
                  },
                  child: PollCard(poll: poll),
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.polls,
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.homePollsViewAllButton),
          ),
        ),
      ],
    );
  }
}

class _HomePollsPlaceholderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HomePollsPlaceholderCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color
                    ?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeNewsSection extends StatelessWidget {
  final String scopeShortLabel;

  const _HomeNewsSection({
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<NewsController>();

    final allNews = controller.news;
    final sorted = List<NewsItem>.from(allNews);
    sorted.sort((a, b) {
      final summaryA = controller.summaryForNews(a);
      final summaryB = controller.summaryForNews(b);
      final heatA =
          (summaryA?.likeCount ?? 0) -
              (summaryA?.dislikeCount ?? 0);
      final heatB =
          (summaryB?.likeCount ?? 0) -
              (summaryB?.dislikeCount ?? 0);
      return heatB.compareTo(heatA);
    });

    final newsList = sorted.length <= 3
        ? sorted
        : sorted.take(3).toList(growable: false);

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.article,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homeNewsTitle(scopeShortLabel),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    Widget content;

    if (controller.isLoading && newsList.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.hasError) {
      content = _HomeNewsPlaceholderCard(
        title: l10n.homeNewsErrorTitle,
        subtitle: l10n.homeNewsErrorSubtitle,
      );
    } else if (newsList.isEmpty) {
      content = _HomeNewsPlaceholderCard(
        title: l10n.homeNewsEmptyTitle,
        subtitle: l10n.homeNewsEmptySubtitle,
      );
    } else {
      content = Column(
        children: newsList
            .map(
              (news) {
                final summary = controller.summaryForNews(news);
                final fire = summary?.likeCount ?? 0;
                final ice = summary?.dislikeCount ?? 0;
                final userReaction = summary?.userReaction;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NewsPreviewCard(
                    news: news,
                    fireCount: fire,
                    iceCount: ice,
                    userReaction: userReaction,
                    onFireTap: () async {
                      final allowed =
                          await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId = AppDI.instance.currentUserId!;
                      controller.toggleFireForNews(
                        userId: userId,
                        newsItem: news,
                      );
                    },
                    onIceTap: () async {
                      final allowed =
                          await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId = AppDI.instance.currentUserId!;
                      controller.toggleIceForNews(
                        userId: userId,
                        newsItem: news,
                      );
                    },
                  ),
                );
              },
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.news,
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.homeNewsViewAllButton),
          ),
        ),
      ],
    );
  }
}

class _HomeNewsPlaceholderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HomeNewsPlaceholderCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color
                    ?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsPreviewCard extends StatelessWidget {
  final NewsItem news;
  final int fireCount;
  final int iceCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const _NewsPreviewCard({
    required this.news,
    this.fireCount = 0,
    this.iceCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final newsController = context.read<NewsController>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ChangeNotifierProvider<NewsController>.value(
                value: newsController,
                child: NewsDetailPage(news: news),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.isBreaking) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.homeNewsBreakingBadge,
                    style:
                        theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
              Text(
                news.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (news.summary != null &&
                  news.summary!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  news.summary!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatPublishedAt(news.publishedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 4),
              EngagementBar(
                fireCount: fireCount,
                iceCount: iceCount,
                userReaction: userReaction,
                onFireTap: onFireTap,
                onIceTap: onIceTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPublishedAt(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

class _HomeSocialSection extends StatelessWidget {
  final String scopeShortLabel;

  const _HomeSocialSection({
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<FeedController>();

    final posts = controller.posts;

    final sorted = List<Post>.from(posts);
    sorted.sort((a, b) {
      final heatA =
          controller.likeCountForPost(a) -
              controller.dislikeCountForPost(a);
      final heatB =
          controller.likeCountForPost(b) -
              controller.dislikeCountForPost(b);
      return heatB.compareTo(heatA);
    });

    final topPosts = sorted.length <= 3
        ? sorted
        : sorted.take(3).toList(growable: false);

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.forum,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homeSocialTitle(scopeShortLabel),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    Widget content;

    if (controller.isLoading && topPosts.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.hasError) {
      content = _buildSocialPlaceholderCard(
        context,
        title: l10n.homeSocialErrorTitle,
        subtitle: l10n.homeSocialErrorSubtitle,
      );
    } else if (topPosts.isEmpty) {
      content = _buildSocialPlaceholderCard(
        context,
        title: l10n.homeSocialEmptyTitle,
        subtitle: l10n.homeSocialEmptySubtitle,
      );
    } else {
      content = Column(
        children: topPosts
            .map(
              (post) {
                final fire =
                    controller.likeCountForPost(post);
                final ice =
                    controller.dislikeCountForPost(post);
                final ReactionType? userReaction =
                    controller.userReactionForPost(post);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PostPreviewCard(
                    post: post,
                    fireCount: fire,
                    iceCount: ice,
                    userReaction: userReaction,
                    onFireTap: () async {
                      final allowed =
                          await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId = AppDI.instance.currentUserId!;
                      controller.toggleFireForPost(
                        userId: userId,
                        post: post,
                      );
                    },
                    onIceTap: () async {
                      final allowed =
                          await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId = AppDI.instance.currentUserId!;
                      controller.toggleIceForPost(
                        userId: userId,
                        post: post,
                      );
                    },
                  ),
                );
              },
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.social,
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.homeSocialViewFeedButton),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialPlaceholderCard(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color
                    ?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostPreviewCard extends StatelessWidget {
  final Post post;
  final int fireCount;
  final int iceCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const _PostPreviewCard({
    required this.post,
    this.fireCount = 0,
    this.iceCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(context, AppRouter.social);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (post.content.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  post.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatPostCreatedAt(post.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 4),
              EngagementBar(
                fireCount: fireCount,
                iceCount: iceCount,
                userReaction: userReaction,
                onFireTap: onFireTap,
                onIceTap: onIceTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPostCreatedAt(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
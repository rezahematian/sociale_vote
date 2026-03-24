import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/auth/presentation/pages/login_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/register_page.dart';
import 'package:sociale_vote/features/discovery/application/for_you_feed_controller.dart';
import 'package:sociale_vote/features/discovery/application/trending_controller.dart';
import 'package:sociale_vote/features/geo/application/follow_scope_controller.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_for_you_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_hero_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_map_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_news_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_poll_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_scope_header.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_search_bar.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_social_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_top_bar.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_trending_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_user_status.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/notifications/application/notifications_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/search/presentation/pages/search_page.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

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

  StreamSubscription<String?>? _sessionSub;
  NotificationsController? _homeNotificationsController;

  String _homeNewsLanguageKey = 'auto';
  bool _isRefreshingHomeNewsLanguageKey = false;

  @override
  void initState() {
    super.initState();

    _sessionSub = AppDI.instance.sessionRepository.watchCurrentUserId().listen((
      userId,
    ) {
      _rebuildHomeNotificationsController(userId);

      if (!mounted) return;
      setState(() {});
    });

    _refreshHomeNewsLanguageKey();
    _rebuildHomeNotificationsController(AppDI.instance.currentUserId);
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _disposeHomeNotificationsController();
    super.dispose();
  }

  void _handleHomeNotificationsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _disposeHomeNotificationsController() {
    final controller = _homeNotificationsController;
    if (controller == null) {
      return;
    }

    controller.removeListener(_handleHomeNotificationsChanged);
    controller.dispose();
    _homeNotificationsController = null;
  }

  void _rebuildHomeNotificationsController(String? userId) {
    _disposeHomeNotificationsController();

    final normalizedUserId = userId?.trim();
    if (normalizedUserId == null || normalizedUserId.isEmpty) {
      return;
    }

    final controller =
        AppDI.instance.createNotificationsControllerForUser(normalizedUserId);
    controller.addListener(_handleHomeNotificationsChanged);
    _homeNotificationsController = controller;
    unawaited(controller.refreshUnreadCount());
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

    await AppDI.instance.logoutCurrentUser();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.homeLogoutMessage),
      ),
    );
  }

  Future<void> _onOpenNewsPressed() async {
    await Navigator.pushNamed(context, AppRouter.news);
    if (!mounted) return;
    _refreshHomeNewsLanguageKey();
  }

  Future<void> _onNotificationsPressed() async {
    await Navigator.pushNamed(context, AppRouter.notifications);
    if (!mounted) return;

    final controller = _homeNotificationsController;
    if (controller != null) {
      unawaited(controller.refreshUnreadCount());
    }
  }

  void _onProfilePressed() {
    Navigator.pushNamed(context, AppRouter.profile);
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

  String _normalizeHomeNewsLanguageKey(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return 'auto';
    }
    return normalized;
  }

  void _refreshHomeNewsLanguageKey() {
    if (_isRefreshingHomeNewsLanguageKey) {
      return;
    }

    _isRefreshingHomeNewsLanguageKey = true;

    AppDI.instance
        .getContentLanguagePreference()
        .then((value) {
          if (!mounted) return;

          final normalized = _normalizeHomeNewsLanguageKey(value);
          if (_homeNewsLanguageKey != normalized) {
            setState(() {
              _homeNewsLanguageKey = normalized;
            });
          }
        })
        .catchError((_) {})
        .whenComplete(() {
          _isRefreshingHomeNewsLanguageKey = false;
        });
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AppDI.instance.currentUserId;
    final bool isLoggedIn = currentUserId != null;
    final int unreadNotificationsCount = isLoggedIn
        ? (_homeNotificationsController?.unreadCount ?? 0)
        : 0;

    return AnimatedBuilder(
      animation: _geoScopeController,
      builder: (context, _) {
        final scope = _geoScopeController.scope;
        final scopeLabel = _scopeLabel(scope);
        final scopeShortLabel = _scopeShortLabel(scope);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 16,
            title: HomeTopBar(
              scopeShortLabel: scopeShortLabel,
              isLoggedIn: isLoggedIn,
              unreadNotificationsCount: unreadNotificationsCount,
              onLoginPressed: _onLoginPressed,
              onRegisterPressed: _onRegisterPressed,
              onProfilePressed: _onProfilePressed,
              onLogoutPressed: _onLogoutPressed,
              onNotificationsPressed:
                  isLoggedIn ? _onNotificationsPressed : null,
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF8FAFC),
                        Color(0xFFEFF4FF),
                        Color(0xFFF5F7FB),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -70,
                right: -40,
                child: IgnorePointer(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF60A5FA).withOpacity(0.10),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 190,
                left: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFA78BFA).withOpacity(0.08),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: HomeHeroSection(
                        scopeShortLabel: scopeShortLabel,
                        onOpenPolls: () {
                          Navigator.pushNamed(context, AppRouter.polls);
                        },
                        onOpenNews: _onOpenNewsPressed,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: HomeSearchBar(
                        onSubmitted: _handleSearchSubmitted,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: HomeUserStatus(
                        isLoggedIn: isLoggedIn,
                        currentUserId: currentUserId,
                      ),
                    ),
                    HomeMapSection(
                      scopeShortLabel: scopeShortLabel,
                    ),
                    HomeScopeHeader(
                      scope: scope,
                      scopeLabel: scopeLabel,
                      isFollowed: _isScopeFollowed(scope),
                      onToggleFollow: () => _onToggleFollowScope(scope),
                      onSetWorld: _setWorld,
                      onSetItaly: _setItaly,
                      onSetTorino: _setTorino,
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        children: [
                          ChangeNotifierProvider<TrendingController>(
                            key: ValueKey(
                              'home_trending_${scope.level}_${scope.countryCode}_${scope.cityId}_${isLoggedIn ? currentUserId : 'guest'}',
                            ),
                            create: (_) =>
                                AppDI.instance.createTrendingController(),
                            child: const HomeTrendingSection(),
                          ),
                          const SizedBox(height: 24),
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
                            child: HomeForYouSection(
                              scopeShortLabel: scopeShortLabel,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ChangeNotifierProvider<PollListController>(
                            key: ValueKey(
                              'home_polls_${scope.level}_${scope.countryCode}_${scope.cityId}_${isLoggedIn ? currentUserId : 'guest'}',
                            ),
                            create: (_) {
                              final controller =
                                  AppDI.instance.createPollListController();
                              final userId = AppDI.instance.currentUserId;
                              controller.loadPolls(userId: userId);
                              return controller;
                            },
                            child: HomePollSection(
                              scopeShortLabel: scopeShortLabel,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ChangeNotifierProvider<NewsController>(
                            key: ValueKey(
                              'home_news_${scope.level}_${scope.countryCode}_${scope.cityId}_$_homeNewsLanguageKey',
                            ),
                            create: (_) =>
                                AppDI.instance.createNewsController()
                                  ..loadNews(),
                            child: HomeNewsSection(
                              scopeShortLabel: scopeShortLabel,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ChangeNotifierProvider<FeedController>(
                            key: ValueKey(
                              'home_social_${scope.level}_${scope.countryCode}_${scope.cityId}',
                            ),
                            create: (_) =>
                                AppDI.instance.createFeedController()
                                  ..loadFeed(),
                            child: HomeSocialSection(
                              scopeShortLabel: scopeShortLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
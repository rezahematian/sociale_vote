import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
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
import 'package:sociale_vote/features/home/presentation/widgets/home_social_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_top_bar.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_trending_section.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/notifications/application/notifications_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/search/presentation/pages/search_page.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart' as country_data;
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
  bool _isRefreshingHome = false;
  int _homeRefreshVersion = 0;

  String? _heroUserChipLabel;
  int _heroUserChipRequestId = 0;

  @override
  void initState() {
    super.initState();

    _sessionSub = AppDI.instance.sessionRepository.watchCurrentUserId().listen((
      userId,
    ) async {
      _rebuildHomeNotificationsController(userId);
      await _refreshHeroUserChipLabel(userId);

      if (!mounted) return;
      setState(() {});
    });

    _refreshHomeNewsLanguageKey();
    _rebuildHomeNotificationsController(AppDI.instance.currentUserId);
    unawaited(_refreshHeroUserChipLabel(AppDI.instance.currentUserId));
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

  Future<void> _selectCountryScope() async {
    final countryCode = await showDialog<String>(
      context: context,
      builder: (_) => _CountryScopeDialog(
        selectedCountryCode: _geoScopeController.scope.countryCode,
      ),
    );

    if (!mounted || countryCode == null) {
      return;
    }

    _geoScopeController.setCountry(countryCode);
  }

  Future<void> _selectCityScope() async {
    var countryCode =
        _geoScopeController.scope.countryCode?.trim().toUpperCase();

    if (countryCode == null || countryCode.isEmpty) {
      countryCode = await showDialog<String>(
        context: context,
        builder: (_) => const _CountryScopeDialog(),
      );
    }

    if (!mounted || countryCode == null || countryCode.isEmpty) {
      return;
    }

    final cityScope = await showDialog<GeoScope>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CityScopeDialog(
        countryCode: countryCode!,
        initialCityName: _geoScopeController.scope.level == GeoScopeLevel.city
            ? _geoScopeController.scope.cityId
            : null,
      ),
    );

    if (!mounted || cityScope == null) {
      return;
    }

    _geoScopeController.setScope(cityScope);
  }

  Future<void> _openSearchPage() async {
    await Navigator.of(context).push(
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

  Future<void> _onTrendingPressed() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _TrendingNowPage(),
      ),
    );
  }

  Future<void> _onForYouPressed() async {
    final currentUserId = AppDI.instance.currentUserId;
    final scopeShortLabel = _scopeShortLabel(_geoScopeController.scope);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ForYouPage(
          userId: currentUserId,
          scopeShortLabel: scopeShortLabel,
        ),
      ),
    );
  }

  void _onProfilePressed() {
    Navigator.pushNamed(context, AppRouter.account);
  }

  void _onThemeModeChanged(ThemeMode mode) {
    AppThemeModeController.setThemeMode(mode);
  }

  String _scopeLabel(GeoScope scope) {
    final l10n = AppLocalizations.of(context)!;

    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.homeScopeLabelWorld;
      case GeoScopeLevel.country:
        return _countryName(scope.countryCode) ?? l10n.homeScopeLabelCountry;
      case GeoScopeLevel.city:
        final cityName = scope.cityId?.trim();
        final countryName = _countryName(scope.countryCode);

        if (cityName != null && cityName.isNotEmpty && countryName != null) {
          return '$cityName, $countryName';
        }
        if (cityName != null && cityName.isNotEmpty) {
          return cityName;
        }
        return countryName ?? l10n.homeScopeLabelCity;
    }
  }

  String _scopeShortLabel(GeoScope scope) {
    final l10n = AppLocalizations.of(context)!;

    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.homeScopeShortWorld;
      case GeoScopeLevel.country:
        return _countryName(scope.countryCode) ??
            scope.countryCode ??
            l10n.homeScopeShortCountry;
      case GeoScopeLevel.city:
        return scope.cityId ?? l10n.homeScopeShortCity;
    }
  }

  String? _countryName(String? countryCode) {
    final normalizedCode = countryCode?.trim().toUpperCase();
    if (normalizedCode == null || normalizedCode.isEmpty) {
      return null;
    }

    for (final country in country_data.Countries.all) {
      if (country.code.toUpperCase() == normalizedCode) {
        return country.name;
      }
    }

    return normalizedCode;
  }

  String? _normalizeHeroChipText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String _fallbackHeroUserChipLabel(String userId) {
    final compact = userId.replaceAll('-', '').trim();
    return compact.isNotEmpty ? compact : userId;
  }

  Future<void> _refreshHeroUserChipLabel(String? userId) async {
    final requestId = ++_heroUserChipRequestId;
    final normalizedUserId = userId?.trim();

    if (normalizedUserId == null || normalizedUserId.isEmpty) {
      if (!mounted || requestId != _heroUserChipRequestId) {
        return;
      }
      setState(() {
        _heroUserChipLabel = null;
      });
      return;
    }

    try {
      final profile = await AppDI.instance.getUserProfile(normalizedUserId);

      if (!mounted || requestId != _heroUserChipRequestId) {
        return;
      }

      final username = _normalizeHeroChipText(profile.username);
      final displayName = _normalizeHeroChipText(profile.displayName);

      setState(() {
        _heroUserChipLabel = username != null
            ? '@$username'
            : (displayName ?? _fallbackHeroUserChipLabel(normalizedUserId));
      });
    } catch (_) {
      if (!mounted || requestId != _heroUserChipRequestId) {
        return;
      }

      setState(() {
        _heroUserChipLabel = _fallbackHeroUserChipLabel(normalizedUserId);
      });
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

  Future<void> _onRefreshHome() async {
    if (_isRefreshingHome) {
      return;
    }

    setState(() {
      _isRefreshingHome = true;
      _homeRefreshVersion += 1;
    });

    _refreshHomeNewsLanguageKey();
    await _refreshHeroUserChipLabel(AppDI.instance.currentUserId);

    final notificationsController = _homeNotificationsController;
    if (notificationsController != null) {
      try {
        await notificationsController.refreshUnreadCount();
      } catch (_) {
        // best effort
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;
    setState(() {
      _isRefreshingHome = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AppDI.instance.currentUserId;
    final bool isLoggedIn = currentUserId != null;
    final int unreadNotificationsCount =
        isLoggedIn ? (_homeNotificationsController?.unreadCount ?? 0) : 0;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _geoScopeController,
        AppThemeModeController.themeMode,
      ]),
      builder: (context, _) {
        final scope = _geoScopeController.scope;
        final scopeShortLabel = _scopeShortLabel(scope);
        final scopeLabel = _scopeLabel(scope);
        final currentThemeMode = AppThemeModeController.themeMode.value;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final screenWidth = MediaQuery.sizeOf(context).width;
        final isCompactGuestTopBar = !isLoggedIn && screenWidth < 520.0;
        final appBarToolbarHeight =
            isLoggedIn ? 74.0 : (isCompactGuestTopBar ? 104.0 : 74.0);

        final backgroundGradient = isDark
            ? [
                Color.alphaBlend(
                  AppColors.primary.withValues(alpha: 0.10),
                  AppColors.backgroundDark,
                ),
                Color.alphaBlend(
                  AppColors.cool.withValues(alpha: 0.10),
                  AppColors.backgroundAltDark,
                ),
                Color.alphaBlend(
                  AppColors.primaryLight.withValues(alpha: 0.08),
                  AppColors.surfaceDark,
                ),
              ]
            : [
                Color.alphaBlend(
                  AppColors.primary.withValues(alpha: 0.07),
                  AppColors.background,
                ),
                Color.alphaBlend(
                  AppColors.cool.withValues(alpha: 0.06),
                  AppColors.backgroundAlt,
                ),
                Color.alphaBlend(
                  AppColors.primaryLight.withValues(alpha: 0.10),
                  AppColors.surfaceVariant,
                ),
              ];

        final topGlowColor = isDark
            ? AppColors.primary.withValues(alpha: 0.14)
            : AppColors.primaryLight.withValues(alpha: 0.14);

        final sideGlowColor = isDark
            ? AppColors.cool.withValues(alpha: 0.11)
            : AppColors.cool.withValues(alpha: 0.10);

        final bottomGlowColor = isDark
            ? AppColors.primaryLight.withValues(alpha: 0.07)
            : AppColors.primary.withValues(alpha: 0.07);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleSpacing: 16,
            toolbarHeight: appBarToolbarHeight,
            title: HomeTopBar(
              scopeShortLabel: scopeShortLabel,
              isLoggedIn: isLoggedIn,
              unreadNotificationsCount: unreadNotificationsCount,
              onLoginPressed: _onLoginPressed,
              onRegisterPressed: _onRegisterPressed,
              onProfilePressed: _onProfilePressed,
              onLogoutPressed: _onLogoutPressed,
              onTrendingPressed: isLoggedIn ? _onTrendingPressed : null,
              onForYouPressed: isLoggedIn ? _onForYouPressed : null,
              onNotificationsPressed:
                  isLoggedIn ? _onNotificationsPressed : null,
              currentThemeMode: currentThemeMode,
              onThemeModeChanged: _onThemeModeChanged,
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: backgroundGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -72,
                right: -44,
                child: IgnorePointer(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: topGlowColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 210,
                left: -76,
                child: IgnorePointer(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sideGlowColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -90,
                right: 40,
                child: IgnorePointer(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bottomGlowColor,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _onRefreshHome,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 18, 30, 0),
                        child: HomeHeroSection(
                          scopeShortLabel: scopeShortLabel,
                          userLabel: isLoggedIn ? _heroUserChipLabel : null,
                          onOpenPolls: () {
                            Navigator.pushNamed(context, AppRouter.polls);
                          },
                          onOpenNews: _onOpenNewsPressed,
                          onOpenSearch: _openSearchPage,
                        ),
                      ),
                      HomeMapSection(
                        key: ValueKey(
                          'home_map_${scope.level}_${scope.countryCode}_${scope.cityId}_$_homeRefreshVersion',
                        ),
                        scopeShortLabel: scopeShortLabel,
                      ),
                      _HomeScopeSelector(
                        scope: scope,
                        scopeLabel: scopeLabel,
                        countryLabel: _countryName(scope.countryCode),
                        isFollowed: _isScopeFollowed(scope),
                        onToggleFollow: () => _onToggleFollowScope(scope),
                        onSetWorld: _setWorld,
                        onSelectCountry: _selectCountryScope,
                        onSelectCity: _selectCityScope,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          children: [
                            ChangeNotifierProvider<PollListController>(
                              key: ValueKey(
                                'home_polls_${scope.level}_${scope.countryCode}_${scope.cityId}_${isLoggedIn ? currentUserId : 'guest'}_$_homeRefreshVersion',
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
                                'home_news_${scope.level}_${scope.countryCode}_${scope.cityId}_${_homeNewsLanguageKey}_$_homeRefreshVersion',
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
                                'home_social_${scope.level}_${scope.countryCode}_${scope.cityId}_$_homeRefreshVersion',
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeScopeSelector extends StatelessWidget {
  final GeoScope scope;
  final String scopeLabel;
  final String? countryLabel;
  final bool isFollowed;
  final VoidCallback onToggleFollow;
  final VoidCallback onSetWorld;
  final Future<void> Function() onSelectCountry;
  final Future<void> Function() onSelectCity;

  const _HomeScopeSelector({
    required this.scope,
    required this.scopeLabel,
    required this.countryLabel,
    required this.isFollowed,
    required this.onToggleFollow,
    required this.onSetWorld,
    required this.onSelectCountry,
    required this.onSelectCity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isWorld = scope.level == GeoScopeLevel.world;
    final isCountry = scope.level == GeoScopeLevel.country;
    final isCity = scope.level == GeoScopeLevel.city;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _scopeIcon(),
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
                  if (!isWorld) ...[
                    const SizedBox(width: 8),
                    FollowScopeButton(
                      isFollowed: isFollowed,
                      onToggle: onToggleFollow,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _scopeChip(
                    context,
                    label: l10n.homeScopeChipWorld,
                    icon: Icons.public,
                    selected: isWorld,
                    onTap: onSetWorld,
                  ),
                  _scopeChip(
                    context,
                    label: isCountry || isCity
                        ? (countryLabel ?? 'Paese')
                        : 'Scegli paese',
                    icon: Icons.flag_outlined,
                    selected: isCountry,
                    onTap: () => onSelectCountry(),
                  ),
                  _scopeChip(
                    context,
                    label: isCity ? (scope.cityId ?? 'Città') : 'Scegli città',
                    icon: Icons.location_city_outlined,
                    selected: isCity,
                    onTap: () => onSelectCity(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scopeChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.82),
      ),
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.82),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      side: BorderSide(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.45)
            : theme.dividerColor.withValues(alpha: 0.6),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  IconData _scopeIcon() {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return Icons.public;
      case GeoScopeLevel.country:
        return Icons.flag_outlined;
      case GeoScopeLevel.city:
        return Icons.location_city_outlined;
    }
  }
}

class _CountryScopeDialog extends StatefulWidget {
  final String? selectedCountryCode;

  const _CountryScopeDialog({
    this.selectedCountryCode,
  });

  @override
  State<_CountryScopeDialog> createState() => _CountryScopeDialogState();
}

class _CountryScopeDialogState extends State<_CountryScopeDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final countries = country_data.Countries.all.where((country) {
      if (normalizedQuery.isEmpty) {
        return true;
      }

      return country.name.toLowerCase().contains(normalizedQuery) ||
          country.code.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);

    return AlertDialog(
      title: const Text('Scegli paese'),
      content: SizedBox(
        width: 480,
        height: 460,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cerca paese o codice...',
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  final selected = country.code.toUpperCase() ==
                      widget.selectedCountryCode?.trim().toUpperCase();

                  return ListTile(
                    leading: selected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : const Icon(Icons.flag_outlined),
                    title: Text(country.name),
                    subtitle: Text(country.code),
                    onTap: () => Navigator.of(context).pop(country.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
      ],
    );
  }
}

class _CityScopeDialog extends StatefulWidget {
  final String countryCode;
  final String? initialCityName;

  const _CityScopeDialog({
    required this.countryCode,
    this.initialCityName,
  });

  @override
  State<_CityScopeDialog> createState() => _CityScopeDialogState();
}

class _CityScopeDialogState extends State<_CityScopeDialog> {
  late final TextEditingController _cityController;
  bool _isResolving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.initialCityName ?? '');
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cityName = _cityController.text.trim();
    if (cityName.isEmpty || _isResolving) {
      setState(() {
        _errorMessage = 'Inserisci una città.';
      });
      return;
    }

    setState(() {
      _isResolving = true;
      _errorMessage = null;
    });

    try {
      final resolved =
          await AppDI.instance.geocodingRepository.geocodeContentLocation(
        ContentLocation(
          source: ContentLocationSource.manual,
          countryCode: widget.countryCode,
          cityName: cityName,
        ),
      );

      if (!mounted) {
        return;
      }

      if (resolved == null ||
          (!resolved.hasCenter && !resolved.hasExactPoint)) {
        setState(() {
          _errorMessage = 'Città non trovata nel paese selezionato.';
        });
        return;
      }

      final resolvedCityName = resolved.cityName?.trim();
      final effectiveCityName =
          resolvedCityName == null || resolvedCityName.isEmpty
              ? cityName
              : resolvedCityName;
      final latitude = resolved.centerLat ?? resolved.latitude;
      final longitude = resolved.centerLng ?? resolved.longitude;

      Navigator.of(context).pop(
        GeoScope.city(
          countryCode: widget.countryCode,
          cityId: effectiveCityName,
          centerLat: latitude,
          centerLng: longitude,
          radiusKm: 35,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Impossibile verificare la città. Riprova.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scegli città'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paese: ${widget.countryCode.toUpperCase()}'),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              autofocus: true,
              enabled: !_isResolving,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Città',
                hintText: 'Es. Roma, São Paulo, Tehran',
                errorText: _errorMessage,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isResolving ? null : () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton.icon(
          onPressed: _isResolving ? null : _submit,
          icon: _isResolving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(_isResolving ? 'Verifica...' : 'Applica'),
        ),
      ],
    );
  }
}

class _TrendingNowPage extends StatelessWidget {
  const _TrendingNowPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Now'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ChangeNotifierProvider<TrendingController>(
            create: (_) => AppDI.instance.createTrendingController(),
            child: const HomeTrendingSection(),
          ),
        ),
      ),
    );
  }
}

class _ForYouPage extends StatelessWidget {
  final String? userId;
  final String scopeShortLabel;

  const _ForYouPage({
    required this.userId,
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For You'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ChangeNotifierProvider<ForYouFeedController>(
            create: (_) {
              final controller = AppDI.instance.createForYouFeedController();
              controller.load(userId: userId);
              return controller;
            },
            child: HomeForYouSection(
              scopeShortLabel: scopeShortLabel,
            ),
          ),
        ),
      ),
    );
  }
}

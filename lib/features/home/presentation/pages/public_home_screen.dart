import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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
import 'package:sociale_vote/features/discovery/presentation/pages/discovery_page.dart';
import 'package:sociale_vote/features/geo/application/follow_scope_controller.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_hero_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_map_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_news_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_poll_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_scope_header.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_social_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_top_bar.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_web_world_panel.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/notifications/application/notifications_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/scientific_sky_background.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/search/presentation/pages/search_page.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/features/social/presentation/pages/create_post_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart' as country_data;
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  static const Duration _nativePollWarmupDelay = Duration(milliseconds: 1400);
  static const Duration _nativeNewsWarmupDelay = Duration(milliseconds: 2200);
  static const Duration _nativeSocialWarmupDelay = Duration(milliseconds: 3000);
  static const Duration _nativeNotificationsWarmupDelay =
      Duration(milliseconds: 2600);

  final ValueNotifier<Offset> _homeSkyOrientation =
      ValueNotifier<Offset>(Offset.zero);

  GeoScopeController get _geoScopeController =>
      AppDI.instance.geoScopeController;

  FollowScopeController get _followScopeController =>
      AppDI.instance.followScopeController;

  StreamSubscription<String?>? _sessionSub;
  NotificationsController? _homeNotificationsController;
  Timer? _homeNotificationsWarmupTimer;
  String? _homeNotificationsControllerUserId;

  String _homeNewsLanguageKey = 'auto';
  bool _isRefreshingHomeNewsLanguageKey = false;
  bool _isRefreshingHome = false;
  int _homeRefreshVersion = 0;
  bool _isHomeGlobeScrollLocked = false;
  bool _isScopeSelectorActive = false;

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
    _homeSkyOrientation.dispose();
    super.dispose();
  }

  void _handleHomeGlobeOrientationChanged(Offset orientation) {
    _homeSkyOrientation.value = orientation;
  }

  void _handleHomeGlobeScrollLockChanged(bool locked) {
    if (!mounted || _isHomeGlobeScrollLocked == locked) {
      return;
    }

    setState(() {
      _isHomeGlobeScrollLocked = locked;
    });
  }

  void _handleHomeNotificationsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _disposeHomeNotificationsController() {
    _homeNotificationsWarmupTimer?.cancel();
    _homeNotificationsWarmupTimer = null;

    final controller = _homeNotificationsController;
    _homeNotificationsControllerUserId = null;
    if (controller == null) {
      return;
    }

    controller.removeListener(_handleHomeNotificationsChanged);
    controller.dispose();
    _homeNotificationsController = null;
  }

  void _rebuildHomeNotificationsController(String? userId) {
    final normalizedUserId = userId?.trim();
    if (normalizedUserId == null || normalizedUserId.isEmpty) {
      _disposeHomeNotificationsController();
      return;
    }

    if (_homeNotificationsController != null &&
        _homeNotificationsControllerUserId == normalizedUserId) {
      return;
    }

    _disposeHomeNotificationsController();

    final controller =
        AppDI.instance.createNotificationsControllerForUser(normalizedUserId);
    controller.addListener(_handleHomeNotificationsChanged);
    _homeNotificationsController = controller;
    _homeNotificationsControllerUserId = normalizedUserId;

    if (kIsWeb) {
      unawaited(controller.refreshUnreadCount());
      return;
    }

    _homeNotificationsWarmupTimer = Timer(
      _nativeNotificationsWarmupDelay,
      () {
        if (!mounted || !identical(_homeNotificationsController, controller)) {
          return;
        }
        unawaited(controller.refreshUnreadCount());
      },
    );
  }

  void _scheduleHomeLoad(
    Duration nativeDelay,
    Future<void> Function() load,
  ) {
    if (kIsWeb) {
      unawaited(load());
      return;
    }

    unawaited(Future<void>.delayed(nativeDelay, load));
  }

  void _setWorld() => _geoScopeController.setWorld();

  Future<bool> _selectCountryScope() async {
    final countryCode = await showDialog<String>(
      context: context,
      builder: (_) => _CountryScopeDialog(
        selectedCountryCode: _geoScopeController.scope.countryCode,
      ),
    );

    if (!mounted || countryCode == null) {
      return false;
    }

    _geoScopeController.setCountry(countryCode);
    return true;
  }

  Future<bool> _selectCityScope() async {
    var countryCode =
        _geoScopeController.scope.countryCode?.trim().toUpperCase();

    if (countryCode == null || countryCode.isEmpty) {
      countryCode = await showDialog<String>(
        context: context,
        builder: (_) => const _CountryScopeDialog(),
      );
    }

    if (!mounted || countryCode == null || countryCode.isEmpty) {
      return false;
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
      return false;
    }

    _geoScopeController.setScope(cityScope);
    return true;
  }

  Future<void> _openScopeSelectorSheet() async {
    if (_isScopeSelectorActive) {
      return;
    }

    setState(() {
      _isScopeSelectorActive = true;
      _isHomeGlobeScrollLocked = false;
    });

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }

    try {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          return AnimatedBuilder(
            animation: Listenable.merge([
              _geoScopeController,
              _followScopeController,
            ]),
            builder: (context, _) {
              final scope = _geoScopeController.scope;

              return SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 12,
                  ),
                  child: _HomeScopeSelector(
                    scope: scope,
                    scopeLabel: _scopeLabel(scope),
                    countryLabel: _countryName(scope.countryCode),
                    isFollowed: _isScopeFollowed(scope),
                    isLoggedIn: AppDI.instance.currentUserId != null,
                    appearanceMode: AppThemeModeController.appearanceMode.value,
                    onAppearanceModeChanged: (appearance) {
                      Navigator.of(sheetContext).pop();
                      _onAppearanceModeChanged(appearance);
                    },
                    onToggleFollow: () => _onToggleFollowScope(scope),
                    onSetWorld: () {
                      _setWorld();
                      Navigator.of(sheetContext).pop();
                    },
                    onSelectCountry: () async {
                      final changed = await _selectCountryScope();
                      if (changed && sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    onSelectCity: () async {
                      final changed = await _selectCityScope();
                      if (changed && sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScopeSelectorActive = false;
        });
      }
    }
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
    _geoScopeController.setWorld();
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

  Future<void> _onCreatePressed() async {
    final isItalian =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'it';
    final allowed = await AuthGuard.ensureAuthenticated(
      context,
      actionLabel: isItalian
          ? 'creare contenuti'
          : deOrEnglish(context,
              english: 'create content', german: 'Inhalte zu erstellen'),
    );
    if (!allowed || !mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    l10n.homeHeroCreateAction,
                    style:
                        Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.how_to_vote_outlined),
                  title: Text(l10n.createPollSubmitLabel),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openCreatePoll();
                  },
                ),
                const SizedBox(height: 4),
                ListTile(
                  leading: const Icon(Icons.post_add_outlined),
                  title: Text(l10n.socialFeedCreatePostButton),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openCreatePost();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCreatePoll() async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.createPoll,
    );
    if (!allowed || !mounted) {
      return;
    }

    final result = await Navigator.of(context).pushNamed(AppRouter.createPoll);
    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _homeRefreshVersion += 1;
    });
  }

  Future<void> _openCreatePost() async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.createPost,
    );
    if (!allowed || !mounted) {
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreatePostPage(),
      ),
    );

    if (!mounted || result != true) {
      return;
    }

    setState(() {
      _homeRefreshVersion += 1;
    });
  }

  Future<void> _onExplorePressed() async {
    _handleHomeGlobeScrollLockChanged(false);
    await Navigator.of(context).pushNamed(AppRouter.civicMap);
  }

  Future<void> _onNotificationsPressed() async {
    await Navigator.pushNamed(context, AppRouter.notifications);
    if (!mounted) return;

    final controller = _homeNotificationsController;
    if (controller != null) {
      unawaited(controller.refreshUnreadCount());
    }
  }

  Future<void> _onDiscoveryPressed() async {
    final scopeShortLabel = _scopeShortLabel(_geoScopeController.scope);

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DiscoveryPage(
          scopeShortLabel: scopeShortLabel,
        ),
      ),
    );
  }

  Future<void> _onHowItWorksPressed() async {
    await Navigator.of(context).pushNamed(AppRouter.howItWorks);
  }

  void _onProfilePressed() {
    Navigator.pushNamed(context, AppRouter.account);
  }

  void _onAppearanceModeChanged(AppAppearanceMode appearance) {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      return;
    }

    unawaited(
      AppThemeModeController.setAppearanceForUser(
        userId: userId,
        appearance: appearance,
      ),
    );
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

    return country_data.Countries.nameForCode(
      normalizedCode,
      languageCode: Localizations.localeOf(context).languageCode,
      fallback: normalizedCode,
    );
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

  ThemeData _spaceHomeTheme(ThemeData base) {
    const primary = Color(0xFF78B7FF);
    const secondary = Color(0xFFA8A2FF);
    const surface = Color(0xD90A1220);
    const surfaceHigh = Color(0xD9142032);
    const onSurface = Color(0xFFF7FAFF);
    const onSurfaceVariant = Color(0xFFC4CFDF);
    const outline = Color(0xFF5E718D);

    const scheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Color(0xFF03101F),
      secondary: secondary,
      onSecondary: Color(0xFF0A0820),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceHigh,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: Color(0xFF31435C),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF2B0502),
    );

    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      dividerColor: const Color(0xFF7A8DA8).withValues(alpha: 0.24),
      textTheme: base.textTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      iconTheme: const IconThemeData(
        color: onSurface,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
      dividerTheme: DividerThemeData(
        color: const Color(0xFF7A8DA8).withValues(alpha: 0.24),
      ),
    );
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
        _followScopeController,
        AppThemeModeController.themeMode,
        AppThemeModeController.appearanceMode,
      ]),
      builder: (context, _) {
        final scope = _geoScopeController.scope;
        final scopeShortLabel = _scopeShortLabel(scope);
        final currentAppearanceMode =
            AppThemeModeController.appearanceMode.value;
        final baseTheme = Theme.of(context);
        final isDark = baseTheme.brightness == Brightness.dark;
        final isSpaceHome =
            isLoggedIn && currentAppearanceMode == AppAppearanceMode.space;
        final homeContentTheme =
            isSpaceHome ? _spaceHomeTheme(baseTheme) : baseTheme;

        final screenWidth = MediaQuery.sizeOf(context).width;
        // WEB-G1B: use logical CSS pixels. 900 keeps ordinary desktop
        // windows in the split layout even with 125% display/browser scaling.
        final isDesktopWeb = kIsWeb && screenWidth >= 900.0;
        final isCompactGuestTopBar = !isLoggedIn && screenWidth < 520.0;
        final appBarToolbarHeight =
            isLoggedIn ? 74.0 : (isCompactGuestTopBar ? 104.0 : 74.0);

        final backgroundGradient = isDark
            ? const [
                AppColors.backgroundDark,
                AppColors.backgroundAltDark,
              ]
            : const [
                AppColors.background,
                AppColors.backgroundAlt,
              ];

        return Directionality(
            // Stable product geometry: Persian changes language, not the
            // physical position/order of Home controls and content sections.
            textDirection: TextDirection.ltr,
            child: Scaffold(
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
                  onDiscoveryPressed: _onDiscoveryPressed,
                  onHowItWorksPressed: _onHowItWorksPressed,
                  onNotificationsPressed:
                      isLoggedIn ? _onNotificationsPressed : null,
                  currentAppearanceMode:
                      isLoggedIn ? currentAppearanceMode : null,
                  onAppearanceModeChanged:
                      isLoggedIn ? _onAppearanceModeChanged : null,
                ),
              ),
              body: Theme(
                data: homeContentTheme,
                child: Stack(
                  children: [
                    // CLASSIC stays exactly on the approved Home gradient.
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

                    if (isSpaceHome) ...[
                      Positioned.fill(
                        child: ScientificSkyBackground(
                          orientationListenable: _homeSkyOrientation,
                          fieldOfViewDegrees: 96.0,
                          exposure: 0.60,
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isDark
                                    ? [
                                        Colors.black.withValues(alpha: 0.08),
                                        const Color(0xFF030712)
                                            .withValues(alpha: 0.16),
                                        Colors.black.withValues(alpha: 0.28),
                                      ]
                                    : [
                                        const Color(0xFF030712)
                                            .withValues(alpha: 0.10),
                                        const Color(0xFF050B18)
                                            .withValues(alpha: 0.20),
                                        Colors.white.withValues(alpha: 0.20),
                                      ],
                                stops: const [0.0, 0.68, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    SafeArea(
                      child: RefreshIndicator(
                        onRefresh: _onRefreshHome,
                        child: ListView(
                          physics: _isHomeGlobeScrollLocked
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 16),
                          children: [
                            if (isDesktopWeb)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(32, 20, 32, 6),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1440,
                                    ),
                                    child: SizedBox(
                                      height: 560,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 45,
                                            child: Column(
                                              children: [
                                                HomeHeroSection(
                                                  scopeShortLabel:
                                                      scopeShortLabel,
                                                  spaceStyle: isSpaceHome,
                                                  desktopCompact: true,
                                                  onOpenPolls: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppRouter.polls,
                                                    );
                                                  },
                                                  onOpenNews:
                                                      _onOpenNewsPressed,
                                                  onCreate: _onCreatePressed,
                                                  onExplore: _onExplorePressed,
                                                  onOpenSearch: _openSearchPage,
                                                  onScopePressed:
                                                      _openScopeSelectorSheet,
                                                ),
                                                const SizedBox(height: 14),
                                                Expanded(
                                                  child: HomeWebWorldPanel(
                                                    key: ValueKey(
                                                      'home_web_info_${scope.level}_${scope.countryCode}_${scope.cityId}_${currentUserId ?? 'guest'}_$_homeRefreshVersion',
                                                    ),
                                                    scopeShortLabel:
                                                        scopeShortLabel,
                                                    currentUserId:
                                                        currentUserId,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 22),
                                          Expanded(
                                            flex: 55,
                                            child: HomeMapSection(
                                              key: ValueKey(
                                                'home_web_map_${scope.level}_${scope.countryCode}_${scope.cityId}_$_homeRefreshVersion',
                                              ),
                                              scopeShortLabel: scopeShortLabel,
                                              desktopHeroMode: true,
                                              suspendWebSurface:
                                                  _isScopeSelectorActive,
                                              onGlobeScrollLockChanged: null,
                                              onGlobeOrientationChanged:
                                                  _handleHomeGlobeOrientationChanged,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  30,
                                  14,
                                  30,
                                  0,
                                ),
                                child: HomeHeroSection(
                                  scopeShortLabel: scopeShortLabel,
                                  spaceStyle: isSpaceHome,
                                  onOpenPolls: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.polls,
                                    );
                                  },
                                  onOpenNews: _onOpenNewsPressed,
                                  onCreate: _onCreatePressed,
                                  onExplore: _onExplorePressed,
                                  onOpenSearch: _openSearchPage,
                                  onScopePressed: _openScopeSelectorSheet,
                                ),
                              ),
                              HomeMapSection(
                                key: ValueKey(
                                  'home_map_${scope.level}_${scope.countryCode}_${scope.cityId}_$_homeRefreshVersion',
                                ),
                                scopeShortLabel: scopeShortLabel,
                                suspendWebSurface: _isScopeSelectorActive,
                                onGlobeScrollLockChanged:
                                    _handleHomeGlobeScrollLockChanged,
                                onGlobeOrientationChanged:
                                    _handleHomeGlobeOrientationChanged,
                              ),
                            ],
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                isDesktopWeb ? 32 : 16,
                                12,
                                isDesktopWeb ? 32 : 16,
                                16,
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        isDesktopWeb ? 1180 : double.infinity,
                                  ),
                                  child: Column(
                                    children: [
                                      ChangeNotifierProvider<
                                          PollListController>(
                                        key: ValueKey(
                                          'home_polls_${scope.level}_${scope.countryCode}_${scope.cityId}_${isLoggedIn ? currentUserId : 'guest'}_$_homeRefreshVersion',
                                        ),
                                        create: (_) {
                                          final controller = AppDI.instance
                                              .createPollListController();
                                          final userId =
                                              AppDI.instance.currentUserId;
                                          _scheduleHomeLoad(
                                            _nativePollWarmupDelay,
                                            () => controller.loadPolls(
                                              userId: userId,
                                            ),
                                          );
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
                                        create: (_) {
                                          final controller = AppDI.instance
                                              .createNewsController();
                                          _scheduleHomeLoad(
                                            _nativeNewsWarmupDelay,
                                            () => controller.loadNews(),
                                          );
                                          return controller;
                                        },
                                        child: HomeNewsSection(
                                          scopeShortLabel: scopeShortLabel,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ChangeNotifierProvider<FeedController>(
                                        key: ValueKey(
                                          'home_social_${scope.level}_${scope.countryCode}_${scope.cityId}_${AppDI.instance.currentUserId ?? 'guest'}_$_homeRefreshVersion',
                                        ),
                                        create: (_) {
                                          final controller = AppDI.instance
                                              .createFeedController();
                                          final userId =
                                              AppDI.instance.currentUserId;
                                          _scheduleHomeLoad(
                                            _nativeSocialWarmupDelay,
                                            () => controller.loadFeed(
                                              userId: userId,
                                            ),
                                          );
                                          return controller;
                                        },
                                        child: HomeSocialSection(
                                          scopeShortLabel: scopeShortLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}

class _HomeScopeSelector extends StatelessWidget {
  final GeoScope scope;
  final String scopeLabel;
  final String? countryLabel;
  final bool isFollowed;
  final bool isLoggedIn;
  final AppAppearanceMode appearanceMode;
  final ValueChanged<AppAppearanceMode> onAppearanceModeChanged;
  final VoidCallback onToggleFollow;
  final VoidCallback onSetWorld;
  final Future<void> Function() onSelectCountry;
  final Future<void> Function() onSelectCity;

  const _HomeScopeSelector({
    required this.scope,
    required this.scopeLabel,
    required this.countryLabel,
    required this.isFollowed,
    required this.isLoggedIn,
    required this.appearanceMode,
    required this.onAppearanceModeChanged,
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
    final isItalian =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'it';
    final styleTitle = isItalian
        ? 'Aspetto'
        : deOrEnglish(context, english: 'Appearance', german: 'Darstellung');
    final lightLabel = isItalian
        ? 'Chiaro'
        : deOrEnglish(context, english: 'Light', german: 'Hell');
    final darkLabel = isItalian
        ? 'Scuro'
        : deOrEnglish(context, english: 'Dark', german: 'Dunkel');

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 16, 30, 0),
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
                        ? (countryLabel ?? l10n.homeScopeShortCountry)
                        : l10n.homeScopeChooseCountry,
                    icon: Icons.flag_outlined,
                    selected: isCountry,
                    onTap: () => onSelectCountry(),
                  ),
                  _scopeChip(
                    context,
                    label: isCity
                        ? (scope.cityId ?? l10n.homeScopeShortCity)
                        : l10n.homeScopeChooseCity,
                    icon: Icons.location_city_outlined,
                    selected: isCity,
                    onTap: () => onSelectCity(),
                  ),
                ],
              ),
              if (isLoggedIn) ...[
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.45),
                ),
                const SizedBox(height: 12),
                Text(
                  styleTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<AppAppearanceMode>(
                  segments: <ButtonSegment<AppAppearanceMode>>[
                    ButtonSegment<AppAppearanceMode>(
                      value: AppAppearanceMode.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(lightLabel),
                    ),
                    ButtonSegment<AppAppearanceMode>(
                      value: AppAppearanceMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(darkLabel),
                    ),
                    const ButtonSegment<AppAppearanceMode>(
                      value: AppAppearanceMode.space,
                      icon: Icon(Icons.auto_awesome),
                      label: Text('Space'),
                    ),
                  ],
                  selected: <AppAppearanceMode>{appearanceMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      onAppearanceModeChanged(selection.first);
                    }
                  },
                ),
                if (appearanceMode == AppAppearanceMode.space) ...[
                  const SizedBox(height: 8),
                  Text(
                    ScientificSkyBackground.credit,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
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
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final mediaSize = MediaQuery.sizeOf(context);
    final isCompact = mediaSize.width < 600;
    final horizontalInset = isCompact ? 12.0 : 40.0;
    final contentHorizontalPadding = isCompact ? 16.0 : 24.0;
    final availableContentWidth = math.max(
      220.0,
      mediaSize.width - (horizontalInset * 2) - (contentHorizontalPadding * 2),
    );
    final dialogContentWidth = math.min(480.0, availableContentWidth);
    final dialogContentHeight = math.min(
      460.0,
      math.max(300.0, mediaSize.height * (isCompact ? 0.58 : 0.66)),
    );
    final normalizedQuery = _query.trim().toLowerCase();
    final countries = country_data.Countries.all.where((country) {
      if (normalizedQuery.isEmpty) {
        return true;
      }

      final localizedName = country.localizedName(languageCode).toLowerCase();
      return localizedName.contains(normalizedQuery) ||
          country.name.toLowerCase().contains(normalizedQuery) ||
          country.code.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: isCompact ? 16 : 24,
      ),
      titlePadding: EdgeInsets.fromLTRB(
        contentHorizontalPadding,
        isCompact ? 18 : 22,
        contentHorizontalPadding,
        12,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        contentHorizontalPadding,
        0,
        contentHorizontalPadding,
        8,
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        contentHorizontalPadding,
        4,
        contentHorizontalPadding,
        isCompact ? 12 : 16,
      ),
      title: Text(l10n.homeScopeChooseCountry),
      content: SizedBox(
        width: dialogContentWidth,
        height: dialogContentHeight,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.homeScopeCountrySearchHint,
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
                    title: Text(country.localizedName(languageCode)),
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
          child: Text(l10n.commonCancelButton),
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
    final l10n = AppLocalizations.of(context)!;
    final cityName = _cityController.text.trim();
    if (cityName.isEmpty || _isResolving) {
      setState(() {
        _errorMessage = l10n.homeScopeCityRequiredError;
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
          _errorMessage = l10n.homeScopeCityNotFoundError;
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
        _errorMessage = l10n.homeScopeCityVerificationError;
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
    final l10n = AppLocalizations.of(context)!;
    final mediaSize = MediaQuery.sizeOf(context);
    final isCompact = mediaSize.width < 600;
    final horizontalInset = isCompact ? 12.0 : 40.0;
    final contentHorizontalPadding = isCompact ? 16.0 : 24.0;
    final availableContentWidth = math.max(
      220.0,
      mediaSize.width - (horizontalInset * 2) - (contentHorizontalPadding * 2),
    );
    final dialogContentWidth = math.min(420.0, availableContentWidth);

    return AlertDialog(
      scrollable: true,
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: isCompact ? 16 : 24,
      ),
      titlePadding: EdgeInsets.fromLTRB(
        contentHorizontalPadding,
        isCompact ? 18 : 22,
        contentHorizontalPadding,
        12,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        contentHorizontalPadding,
        0,
        contentHorizontalPadding,
        8,
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        contentHorizontalPadding,
        4,
        contentHorizontalPadding,
        isCompact ? 12 : 16,
      ),
      title: Text(l10n.homeScopeChooseCity),
      content: SizedBox(
        width: dialogContentWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeScopeCountryWithCode(
                widget.countryCode.toUpperCase(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              autofocus: true,
              enabled: !_isResolving,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.homeScopeCityFieldLabel,
                hintText: l10n.homeScopeCityExampleHint,
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
          child: Text(l10n.commonCancelButton),
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
          label: Text(
            _isResolving
                ? l10n.homeScopeVerifyingButton
                : l10n.commonApplyButton,
          ),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/app_theme.dart';
import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/features/auth/presentation/widgets/biometric_session_gate.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/navigation_service.dart';
import 'package:sociale_vote/shared/services/egress_policy_service.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';
import 'package:sociale_vote/shared/services/social_vote_hud_service.dart';
import 'package:sociale_vote/shared/services/web_document_language.dart';

enum AppAppearanceMode {
  light,
  dark,
  space,
}

class AppThemeModeController {
  AppThemeModeController._();

  static const String _appearancePreferenceKeyPrefix = 'app_appearance_v1';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static final ValueNotifier<AppAppearanceMode> appearanceMode =
      ValueNotifier<AppAppearanceMode>(AppAppearanceMode.light);

  static String? _activeUserId;
  static int _loadRequestId = 0;

  static String _preferenceKeyForUser(String userId) {
    return '$_appearancePreferenceKeyPrefix:$userId';
  }

  static ThemeMode _themeForAppearance(AppAppearanceMode appearance) {
    switch (appearance) {
      case AppAppearanceMode.light:
        return ThemeMode.light;
      case AppAppearanceMode.dark:
      case AppAppearanceMode.space:
        return ThemeMode.dark;
    }
  }

  static AppAppearanceMode _appearanceFromStorage(String? value) {
    switch (value) {
      case 'dark':
        return AppAppearanceMode.dark;
      case 'space':
        return AppAppearanceMode.space;
      case 'light':
      default:
        return AppAppearanceMode.light;
    }
  }

  static void _applyAppearance(AppAppearanceMode appearance) {
    if (appearanceMode.value != appearance) {
      appearanceMode.value = appearance;
    }

    final nextThemeMode = _themeForAppearance(appearance);
    if (themeMode.value != nextThemeMode) {
      themeMode.value = nextThemeMode;
    }
  }

  /// Loads the appearance for the active authenticated account.
  ///
  /// Guest has no personal appearance preference: it falls back to the
  /// platform theme and does not read/write an anonymous shared preference.
  static Future<void> loadForUser(String? userId) async {
    final requestId = ++_loadRequestId;
    _activeUserId = userId;

    if (userId == null) {
      appearanceMode.value = AppAppearanceMode.light;
      themeMode.value = ThemeMode.system;
      return;
    }

    String? saved;

    try {
      saved = await AppDI.instance.storageService.readString(
        _preferenceKeyForUser(userId),
      );
    } catch (_) {
      saved = null;
    }

    if (requestId != _loadRequestId || _activeUserId != userId) {
      return;
    }

    _applyAppearance(_appearanceFromStorage(saved));
  }

  /// Changes and persists Light / Dark / Space for one authenticated account.
  ///
  /// Space intentionally uses the app's Dark Theme outside Home while Home
  /// additionally enables the scientific-sky visual layer.
  static Future<void> setAppearanceForUser({
    required String userId,
    required AppAppearanceMode appearance,
  }) async {
    _activeUserId = userId;
    _loadRequestId++;

    _applyAppearance(appearance);

    try {
      await AppDI.instance.storageService.writeString(
        _preferenceKeyForUser(userId),
        appearance.name,
      );
    } catch (_) {
      // The choice stays active for this session even if local persistence
      // is temporarily unavailable.
    }
  }

  // Compatibility helper for older call sites while appearance migration
  // settles. New UI should call setAppearanceForUser().
  static void setThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        _applyAppearance(AppAppearanceMode.dark);
        break;
      case ThemeMode.light:
        _applyAppearance(AppAppearanceMode.light);
        break;
      case ThemeMode.system:
        themeMode.value = ThemeMode.system;
        break;
    }
  }

  static ThemeMode next(ThemeMode current) {
    switch (current) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }
}

class AppLocaleController {
  AppLocaleController._();

  static const String _legacyLocalePreferenceKey = 'app_locale_preference';
  static const String _localePreferenceKeyPrefix = 'app_locale_preference_v2';
  static const Set<String> _supportedLanguageCodes = <String>{
    'it',
    'en',
    'de',
    'fa',
    'es',
    'pt',
    'fr',
    'ar',
    'ro',
    'ru',
    'zh',
  };

  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static String? _activeUserId;
  static int _loadRequestId = 0;

  static String _preferenceKeyForUser(String userId) {
    return '$_localePreferenceKeyPrefix:$userId';
  }

  static String? _normalizedSupportedLanguageCode(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || !_supportedLanguageCodes.contains(normalized)) {
      return null;
    }
    return normalized;
  }

  /// Uses the first supported platform language and otherwise falls back to EN.
  ///
  /// `locale == null` in MaterialApp means "System". The app geometry remains
  /// physical/LTR; Persian and Arabic affect writing direction only on text surfaces.
  static Locale resolveSystemLocale(
    List<Locale>? platformLocales,
    Iterable<Locale> supportedLocales,
  ) {
    final supportedByLanguage = <String, Locale>{
      for (final supportedLocale in supportedLocales)
        supportedLocale.languageCode.toLowerCase(): supportedLocale,
    };

    for (final platformLocale in platformLocales ?? const <Locale>[]) {
      final match =
          supportedByLanguage[platformLocale.languageCode.toLowerCase()];
      if (match != null) {
        return match;
      }
    }

    return supportedByLanguage['en'] ?? const Locale('en');
  }

  /// Locale preference is account-scoped.
  ///
  /// Guest always uses System and never inherits a language selected by a
  /// previously authenticated account. A legacy global preference is migrated
  /// once to the active authenticated account only.
  static Future<void> loadForUser(String? userId) async {
    final requestId = ++_loadRequestId;
    _activeUserId = userId;

    if (userId == null) {
      locale.value = null;
      return;
    }

    String? saved;

    try {
      saved = await AppDI.instance.storageService.readString(
        _preferenceKeyForUser(userId),
      );

      if (_normalizedSupportedLanguageCode(saved) == null) {
        final legacy = await AppDI.instance.storageService.readString(
          _legacyLocalePreferenceKey,
        );
        final migrated = _normalizedSupportedLanguageCode(legacy);
        if (migrated != null) {
          saved = migrated;
          await AppDI.instance.storageService.writeString(
            _preferenceKeyForUser(userId),
            migrated,
          );
          await AppDI.instance.storageService.remove(
            _legacyLocalePreferenceKey,
          );
        }
      }
    } catch (_) {
      saved = null;
    }

    if (requestId != _loadRequestId || _activeUserId != userId) {
      return;
    }

    final languageCode = _normalizedSupportedLanguageCode(saved);
    locale.value = languageCode == null ? null : Locale(languageCode);
  }

  /// Changes the language for the active authenticated account.
  ///
  /// `null` means System. Guest can only remain on System, preventing a stale
  /// authenticated preference from leaking into guest Home.
  static Future<void> setLocale(Locale? value) async {
    final normalized = _normalizedSupportedLanguageCode(value?.languageCode);
    final nextLocale = normalized == null ? null : Locale(normalized);
    final userId = _activeUserId;

    if (locale.value != nextLocale) {
      locale.value = nextLocale;
    }

    if (userId == null) {
      return;
    }

    try {
      if (nextLocale == null) {
        await AppDI.instance.storageService.remove(
          _preferenceKeyForUser(userId),
        );
        return;
      }

      await AppDI.instance.storageService.writeString(
        _preferenceKeyForUser(userId),
        nextLocale.languageCode,
      );
    } catch (_) {
      // The selection stays active for the current session even if persistence
      // is temporarily unavailable.
    }
  }
}

class SocialeVoteApp extends StatefulWidget {
  const SocialeVoteApp({super.key});

  @override
  State<SocialeVoteApp> createState() => _SocialeVoteAppState();
}

class _SocialeVoteAppState extends State<SocialeVoteApp> {
  StreamSubscription<AuthState>? _authStateSubscription;
  StreamSubscription<String?>? _appearanceUserSubscription;
  StreamSubscription<String?>? _localeUserSubscription;
  bool _passwordRecoveryOpened = false;

  @override
  void initState() {
    super.initState();
    unawaited(EgressPolicyService.instance.initialize());
    unawaited(RadioMondoService.instance.initialize());

    _appearanceUserSubscription =
        AppDI.instance.sessionRepository.watchCurrentUserId().listen(
      (userId) {
        unawaited(AppThemeModeController.loadForUser(userId));
      },
    );
    unawaited(
      AppThemeModeController.loadForUser(AppDI.instance.currentUserId),
    );

    _localeUserSubscription =
        AppDI.instance.sessionRepository.watchCurrentUserId().listen(
      (userId) {
        unawaited(AppLocaleController.loadForUser(userId));
      },
    );
    unawaited(
      AppLocaleController.loadForUser(AppDI.instance.currentUserId),
    );

    _listenAuthRecovery();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapRecoveryFlow();
    });
  }

  bool _hasRecoverySignal(Uri uri) {
    final raw = uri.toString().toLowerCase();
    final fragment = uri.fragment.toLowerCase();

    if (raw.contains('type=recovery') || fragment.contains('type=recovery')) {
      return true;
    }

    if (uri.queryParameters.containsKey('code')) {
      return true;
    }

    return false;
  }

  void _listenAuthRecovery() {
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      unawaited(_handleAuthStateChange(data));
    });
  }

  Future<void> _handleAuthStateChange(AuthState data) async {
    if (data.event != AuthChangeEvent.initialSession) {
      await _syncAppSession(data.session);
    }

    if (data.session == null) {
      return;
    }

    // On Android/iOS the recovery deep link is consumed by supabase_flutter,
    // so Uri.base does not reliably contain `type=recovery`. The auth event is
    // the authoritative signal for a native password-recovery flow.
    if (data.event == AuthChangeEvent.passwordRecovery) {
      _openResetPasswordPage();
      return;
    }

    // Keep the URL-signal fallback for Web / cold-start cases where the
    // recovery parameters are still visible in the browser URI.
    if (!_hasRecoverySignal(Uri.base)) {
      return;
    }

    switch (data.event) {
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
        _openResetPasswordPage();
        break;
      default:
        break;
    }
  }

  Future<void> _syncAppSession(Session? supabaseSession) async {
    final sessionRepository = AppDI.instance.sessionRepository;

    if (supabaseSession == null) {
      await sessionRepository.clearSession();
      return;
    }

    final user = supabaseSession.user;
    final userMetadata = user.userMetadata ?? const <String, dynamic>{};
    final appMetadata = user.appMetadata;
    final rawDisplayName = userMetadata['display_name'];
    final rawRole = appMetadata['role'];
    final displayName =
        rawDisplayName is String && rawDisplayName.trim().isNotEmpty
            ? rawDisplayName.trim()
            : null;

    await sessionRepository.saveSession(
      AuthSession(
        userId: user.id,
        accessToken: supabaseSession.accessToken,
        refreshToken: supabaseSession.refreshToken,
        email: user.email,
        displayName: displayName,
        role: RoleX.fromStorageKey(rawRole is String ? rawRole : null),
      ),
    );
  }

  Future<void> _bootstrapRecoveryFlow() async {
    if (!_hasRecoverySignal(Uri.base)) {
      return;
    }

    final auth = Supabase.instance.client.auth;

    for (var i = 0; i < 30; i++) {
      if (!mounted || _passwordRecoveryOpened) {
        return;
      }

      if (auth.currentSession != null) {
        _openResetPasswordPage();
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  void _openResetPasswordPage() {
    if (_passwordRecoveryOpened) {
      return;
    }

    final navigator = NavigationService.navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openResetPasswordPage();
        }
      });
      return;
    }

    _passwordRecoveryOpened = true;
    navigator.pushNamed(AppRouter.resetPassword).whenComplete(() {
      _passwordRecoveryOpened = false;
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    _appearanceUserSubscription?.cancel();
    _appearanceUserSubscription = null;
    _localeUserSubscription?.cancel();
    _localeUserSubscription = null;
    unawaited(RadioMondoService.instance.shutdown());
    SocialVoteHud.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: AppLocaleController.locale,
      builder: (context, appLocale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppThemeModeController.themeMode,
          builder: (context, themeMode, _) {
            return MaterialApp(
              navigatorKey: NavigationService.navigatorKey,
              title: 'Social Vote',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: appLocale,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                scrollbars: false,
              ),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              localeListResolutionCallback:
                  AppLocaleController.resolveSystemLocale,
              builder: (context, child) {
                updateWebDocumentLanguage(
                  Localizations.localeOf(context).languageCode,
                );
                return Directionality(
                  // Product geometry is physical and stable across locales:
                  // Persian/Arabic change the writing direction of their strings,
                  // not the position/order of buttons, navigation or controls.
                  // Authored content keeps its own script direction on content
                  // surfaces via socialVoteContentDirection(...).
                  textDirection: TextDirection.ltr,
                  child: BiometricSessionGate(
                    skipLock: _hasRecoverySignal(Uri.base),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        child ?? const SizedBox.shrink(),
                        const SocialVoteHudOverlay(),
                      ],
                    ),
                  ),
                );
              },
              navigatorObservers: const <NavigatorObserver>[],
              initialRoute: AppRouter.initialRoute,
              onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
              onGenerateRoute: AppRouter.onGenerateRoute,
            );
          },
        );
      },
    );
  }
}

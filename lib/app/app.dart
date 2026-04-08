import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/app_theme.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/navigation_service.dart';

class AppThemeModeController {
  AppThemeModeController._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static void setThemeMode(ThemeMode mode) {
    if (themeMode.value == mode) {
      return;
    }
    themeMode.value = mode;
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

class SocialeVoteApp extends StatefulWidget {
  const SocialeVoteApp({super.key});

  @override
  State<SocialeVoteApp> createState() => _SocialeVoteAppState();
}

class _SocialeVoteAppState extends State<SocialeVoteApp> {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _analyticsObserver =
      FirebaseAnalyticsObserver(analytics: _analytics);

  StreamSubscription<AuthState>? _authStateSubscription;
  bool _passwordRecoveryOpened = false;

  bool get _enableAnalyticsObserver {
    if (kIsWeb) {
      return true;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
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
      if (!_hasRecoverySignal(Uri.base)) {
        return;
      }

      if (data.session == null) {
        return;
      }

      switch (data.event) {
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.passwordRecovery:
        case AuthChangeEvent.tokenRefreshed:
          _openResetPasswordPage();
          break;
        default:
          break;
      }
    });
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
      return;
    }

    _passwordRecoveryOpened = true;
    navigator.pushNamed(AppRouter.resetPassword);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeModeController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          title: 'Sociale Vote',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
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
          navigatorObservers: _enableAnalyticsObserver
              ? <NavigatorObserver>[_analyticsObserver]
              : const <NavigatorObserver>[],
          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
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
    _listenPasswordRecovery();
  }

  void _listenPasswordRecovery() {
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery &&
          !_passwordRecoveryOpened) {
        _passwordRecoveryOpened = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navigator = NavigationService.navigatorKey.currentState;
          if (navigator == null) {
            return;
          }

          navigator.pushNamed(AppRouter.resetPassword);
        });
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Sociale Vote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
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
  }
}
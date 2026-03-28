import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/app_theme.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/navigation_service.dart';

class SocialeVoteApp extends StatelessWidget {
  const SocialeVoteApp({super.key});

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _analyticsObserver =
      FirebaseAnalyticsObserver(analytics: _analytics);

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
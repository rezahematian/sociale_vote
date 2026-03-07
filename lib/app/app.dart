import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/features/home/presentation/pages/public_home_screen.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class SocialeVoteApp extends StatelessWidget {
  const SocialeVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sociale Vote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // 👇 NIENTE initialRoute: partiamo direttamente dalla PublicHomeScreen
      home: PublicHomeScreen(),

      // Manteniamo comunque il router per tutte le navigazioni pushNamed
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
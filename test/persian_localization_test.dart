import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/radio_mondo_dock.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';

void main() {
  Widget persianApp(Widget child) {
    return MaterialApp(
      locale: const Locale('fa'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('Persian locale is generated and uses RTL direction',
      (tester) async {
    const contentKey = ValueKey('persian-content');

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa', 'IR'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Text(
              AppLocalizations.of(context)!.homeLoginButton,
              key: contentKey,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ورود'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byKey(contentKey))),
      TextDirection.rtl,
    );
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
      contains('fa'),
    );
  });

  testWidgets('publisher signature exposes Persian identity semantics',
      (tester) async {
    await tester.pumpWidget(
      persianApp(
        const PublisherSignature(
          displayName: '',
          actorType: ActorType.organization,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('سازمان'), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(
      tooltip.message,
      contains('سازمان تأییدشده'),
    );
  });
  testWidgets('Persian Home labels avoid broken mixed-direction grammar',
      (tester) async {
    late AppLocalizations l10n;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(l10n.homePollsTitle('جهان'), 'Vote · برگزیده (جهان)');
    expect(l10n.homeNewsTitle('جهان'), 'مهم‌ترین خبرها (جهان)');
    expect(l10n.homeSocialTitle('جهان'), 'Voce · جهان');
    expect(l10n.homeTrendingTitle, 'Pulse · اکنون');
  });

  testWidgets('Radio Mondo dock is labelled on wide layouts', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('fa'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [RadioMondoDock()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('radio-mondo-open')), findsOneWidget);
    expect(find.text('رادیوی جهان'), findsOneWidget);
  });
}

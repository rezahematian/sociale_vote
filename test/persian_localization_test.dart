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
    expect(l10n.profileHowItWorksTitle, 'راهنمای برنامه');
    expect(l10n.organizationWorkspaceTitle, 'فضای کاری سازمان');
    expect(l10n.pollList_scopeDescriptionCountry.contains('Vote‌های'), isFalse);
    expect(l10n.adminCenterPollsCreatedMetric.contains('Vote‌های'), isFalse);
    expect(l10n.adminCenterPostsCreatedMetric.contains('Voce‌های'), isFalse);
  });

  testWidgets(
      'Radio Mondo control exposes Persian label without visible chrome',
      (tester) async {
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

    final openControl = find.byKey(const ValueKey<String>('radio-mondo-open'));
    expect(openControl, findsOneWidget);

    final semanticsFinder = find.ancestor(
      of: openControl,
      matching: find.byWidgetPredicate(
        (widget) => widget is Semantics &&
            (widget.properties.label ?? '').contains('رادیوی جهان'),
      ),
    );
    expect(semanticsFinder, findsOneWidget);

    // Globe controls deliberately avoid Tooltip/RawTooltip overlays on
    // Android. Long-press belongs exclusively to the track picker.
    final tooltipFinder = find.ancestor(
      of: openControl,
      matching: find.byType(Tooltip),
    );
    expect(tooltipFinder, findsNothing);

    // The visual treatment is intentionally icon/gramophone-only.
    expect(find.text('رادیوی جهان'), findsNothing);
  });
  testWidgets(
      'Persian localized strings contain no bidi isolate control characters',
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
    for (final value in <String>[
      l10n.homePollsTitle('جهان'),
      l10n.homeNewsTitle('جهان'),
      l10n.homeSocialTitle('جهان'),
      l10n.profileHowItWorksTitle,
    ]) {
      expect(value.contains('\u2066'), isFalse);
      expect(value.contains('\u2069'), isFalse);
    }
  });
}

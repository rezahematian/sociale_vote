import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';

void main() {
  Widget localizedApp(Widget child) {
    return MaterialApp(
      locale: const Locale('it'),
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

  testWidgets(
    'compact and regular publisher signatures share one visual metric',
    (tester) async {
      var openCount = 0;

      await tester.pumpWidget(
        localizedApp(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PublisherSignature(
                key: const ValueKey('compact-signature'),
                displayName: 'Social Vote',
                actorType: ActorType.organization,
                density: PublisherSignatureDensity.compact,
                onTap: () => openCount++,
              ),
              PublisherSignature(
                key: const ValueKey('regular-signature'),
                displayName: 'Social Vote',
                actorType: ActorType.organization,
                density: PublisherSignatureDensity.regular,
                onTap: () => openCount++,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final compactSize =
          tester.getSize(find.byKey(const ValueKey('compact-signature')));
      final regularSize =
          tester.getSize(find.byKey(const ValueKey('regular-signature')));

      expect(compactSize.height, regularSize.height);
      expect(find.byType(Ink), findsNothing);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.byType(InkWell), findsNWidgets(2));

      await tester.tap(find.text('Social Vote').first);
      await tester.pump();
      expect(openCount, 1);
    },
  );

  testWidgets('publisher avatar reserves the same frame for every identity',
      (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PublisherAvatar(
              key: ValueKey('citizen-avatar'),
              displayName: 'Citizen',
              actorType: ActorType.citizen,
              size: 32,
            ),
            PublisherAvatar(
              key: ValueKey('verified-avatar'),
              displayName: 'Verified',
              actorType: ActorType.citizen,
              verificationLevel: VerificationLevel.level2,
              size: 32,
            ),
            PublisherAvatar(
              key: ValueKey('organization-avatar'),
              displayName: 'Organization',
              actorType: ActorType.organization,
              size: 32,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final citizenSize =
        tester.getSize(find.byKey(const ValueKey('citizen-avatar')));
    final verifiedSize =
        tester.getSize(find.byKey(const ValueKey('verified-avatar')));
    final organizationSize =
        tester.getSize(find.byKey(const ValueKey('organization-avatar')));

    expect(citizenSize, verifiedSize);
    expect(verifiedSize, organizationSize);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    expect(find.byIcon(Icons.groups_rounded), findsAtLeastNWidgets(1));
  });
}

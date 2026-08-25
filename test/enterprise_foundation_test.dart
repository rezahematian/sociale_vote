import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';

void main() {
  group('startup routing', () {
    test('keeps supported Web and Android public links', () {
      expect(
        AppRouter.resolveStartupRoute(
          isWeb: true,
          webLocation: 'https://socialevote.com/poll/poll-123?from=share',
          nativeDefaultRouteName: '/',
        ),
        '/poll/poll-123',
      );
      expect(
        AppRouter.resolveStartupRoute(
          isWeb: false,
          webLocation: '/',
          nativeDefaultRouteName: '/post/post-456',
        ),
        '/post/post-456',
      );
      expect(
        AppRouter.resolveStartupRoute(
          isWeb: false,
          webLocation: '/',
          nativeDefaultRouteName:
              'https://socialevote.com/verify/session/report-789',
        ),
        '/verify/session/report-789',
      );
    });

    test('falls back to Home for unsupported startup destinations', () {
      expect(
        AppRouter.resolveStartupRoute(
          isWeb: false,
          webLocation: '/',
          nativeDefaultRouteName: '/private/unknown',
        ),
        AppRouter.home,
      );
    });

    test('keeps Home below public content', () {
      final routes = AppRouter.onGenerateInitialRoutes('/poll/poll-123');
      expect(routes, hasLength(2));
      expect(routes.first.settings.name, AppRouter.home);
      expect(routes.last.settings.name, '/poll/poll-123');
    });
  });

  group('locale resolution', () {
    const supported = <Locale>[
      Locale('de'),
      Locale('en'),
      Locale('fa'),
      Locale('it'),
    ];

    test('preserves IT EN DE and FA', () {
      expect(
        AppLocaleController.resolveSystemLocale(
          const <Locale>[Locale('it', 'IT')],
          supported,
        ).languageCode,
        'it',
      );
      expect(
        AppLocaleController.resolveSystemLocale(
          const <Locale>[Locale('de', 'DE')],
          supported,
        ).languageCode,
        'de',
      );
      expect(
        AppLocaleController.resolveSystemLocale(
          const <Locale>[Locale('en', 'US')],
          supported,
        ).languageCode,
        'en',
      );
      expect(
        AppLocaleController.resolveSystemLocale(
          const <Locale>[Locale('fa', 'IR')],
          supported,
        ).languageCode,
        'fa',
      );
    });

    test('uses English for unsupported or missing device locales', () {
      expect(
        AppLocaleController.resolveSystemLocale(
          const <Locale>[Locale('fr', 'FR')],
          supported,
        ).languageCode,
        'en',
      );
      expect(
        AppLocaleController.resolveSystemLocale(null, supported).languageCode,
        'en',
      );
    });
  });

  group('participation policy', () {
    const policy = ParticipationPolicy();

    test('guest cannot mutate content', () {
      for (final action in ParticipationAction.values) {
        expect(
          policy.canPerform(userId: null, action: action),
          isFalse,
          reason: action.name,
        );
      }
    });

    test('verification and verified country gates are enforced', () {
      const rules = ParticipationRules(
        scope: ParticipationScope.geoScopeOnly,
        countryCode: 'IT',
        minimumVerificationLevel: VerificationLevel.level1,
      );

      expect(
        policy.canVoteOnPoll(
          userId: 'user-1',
          rules: rules,
          userCountryCode: 'IT',
          verificationLevel: VerificationLevel.none,
        ),
        isFalse,
      );
      expect(
        policy.canVoteOnPoll(
          userId: 'user-1',
          rules: rules,
          userCountryCode: 'DE',
          verificationLevel: VerificationLevel.level2,
        ),
        isFalse,
      );
      expect(
        policy.canVoteOnPoll(
          userId: 'user-1',
          rules: rules,
          userCountryCode: 'IT',
          verificationLevel: VerificationLevel.level2,
        ),
        isTrue,
      );
    });

    test('staff and organization capabilities stay separated', () {
      expect(policy.canAccessAdminCenter(role: Role.user), isFalse);
      expect(policy.canAccessAdminCenter(role: Role.moderator), isTrue);
      expect(policy.canManageAccounts(role: Role.moderator), isFalse);
      expect(policy.canManageAccounts(role: Role.admin), isTrue);
      expect(
        policy.canPerform(
          userId: 'organization-operator',
          action: ParticipationAction.manageOrganizationSessions,
          actorType: ActorType.organization,
        ),
        isTrue,
      );
    });
  });

  group('visual language', () {
    test('content colors remain fixed', () {
      expect(
        SocialVoteSymbols.contentColor(SocialVoteContentKind.vote),
        const Color(0xFF2EAD68),
      );
      expect(
        SocialVoteSymbols.contentColor(SocialVoteContentKind.voce),
        const Color(0xFF2F80ED),
      );
      expect(
        SocialVoteSymbols.contentColor(SocialVoteContentKind.news),
        const Color(0xFFE45151),
      );
      expect(
        SocialVoteSymbols.publisherIcon(ActorType.organization),
        Icons.groups_rounded,
      );
    });

    testWidgets('the full publisher signature opens the profile',
        (tester) async {
      var opened = false;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: PublisherSignature(
                displayName: 'Social Vote',
                actorType: ActorType.organization,
                density: PublisherSignatureDensity.regular,
                onTap: () => opened = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Social Vote'));
      await tester.pump();

      expect(opened, isTrue);
    });

    testWidgets('publisher seals distinguish L1 L2 and organization',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('it'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Row(
              children: [
                PublisherAvatar(
                  displayName: 'L1',
                  actorType: ActorType.citizen,
                  verificationLevel: VerificationLevel.level1,
                ),
                PublisherAvatar(
                  displayName: 'L2',
                  actorType: ActorType.citizen,
                  verificationLevel: VerificationLevel.level2,
                ),
                PublisherAvatar(
                  displayName: 'Organization',
                  actorType: ActorType.organization,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<Icon>(find.byIcon(Icons.verified_outlined)).color,
        AppColors.identityVerifiedLv1Foreground,
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.verified_rounded)).color,
        AppColors.identityVerifiedLv2Foreground,
      );
      expect(find.byIcon(Icons.groups_rounded), findsAtLeastNWidgets(1));
    });
  });
}

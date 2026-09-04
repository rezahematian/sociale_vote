import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';
import 'package:sociale_vote/domain/identity/usecases/register_user.dart';
import 'package:sociale_vote/features/admin/presentation/pages/admin_center_page.dart';
import 'package:sociale_vote/features/admin/presentation/pages/world_brief_editor_page.dart';
import 'package:sociale_vote/features/admin/presentation/widgets/admin_finance_control_section.dart';
import 'package:sociale_vote/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart';
import 'package:sociale_vote/features/auth/presentation/widgets/register_form.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_hero_section.dart';
import 'package:sociale_vote/features/map/presentation/widgets/world_globe_widget.dart';
import 'package:sociale_vote/features/onboarding/presentation/first_time_onboarding_gate.dart';
import 'package:sociale_vote/features/onboarding/presentation/how_social_vote_works_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/create_live_session_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/live_session_presenter_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/organization_profile_editor_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/organization_workspace_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_profile_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/organization_verification_request_page.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/auth_api.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';

void main() {
  test('language consolidation target libraries compile together', () {
    final compileTargets = <Type>[
      RegisterUser,
      AuthApi,
      RegisterForm,
      AdminCenterPage,
      WorldBriefEditorPage,
      AdminFinanceControlSection,
      AdminRadioMondoControlSection,
      CommentSection,
      HomeHeroSection,
      WorldGlobeWidget,
      FirstTimeOnboardingGate,
      HowSocialVoteWorksPage,
      CreateLiveSessionPage,
      LiveSessionPresenterPage,
      OrganizationProfileEditorPage,
      OrganizationWorkspacePage,
      EditProfilePage,
      MyProfilePage,
      OrganizationVerificationRequestPage,
      Country,
      Countries,
      ContentTypeMark,
      PublisherSignature,
      SocialVoteDirectionalText,
    ];
    expect(compileTargets.length, 24);
  });

  test('nine ARB catalogs keep exact message and metadata parity', () {
    final root = Directory.current.path;
    final locales = <String>['en', 'it', 'de', 'fa', 'es', 'pt', 'fr', 'ar', 'ro'];

    Map<String, dynamic> load(String code) {
      final file = File('$root/lib/l10n/app_$code.arb');
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    }

    final en = load('en');
    Set<String> messageKeys(Map<String, dynamic> value) => value.keys
        .where((key) => key != '@@locale' && !key.startsWith('@'))
        .toSet();
    Set<String> metadataKeys(Map<String, dynamic> value) =>
        value.keys.where((key) => key.startsWith('@')).toSet();

    final expectedMessages = messageKeys(en);
    final expectedMetadata = metadataKeys(en);
    expect(expectedMessages.length, 1309);

    for (final code in locales) {
      final catalog = load(code);
      expect(messageKeys(catalog), expectedMessages, reason: '$code messages');
      expect(metadataKeys(catalog), expectedMetadata, reason: '$code metadata');
    }
  });

  testWidgets('legacy UI copy has explicit fa/es/pt/fr/ar/ro fallback',
      (tester) async {
    Future<String> localized(String code, String english, String german) async {
      late String result;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              result = deOrEnglish(
                context,
                english: english,
                german: german,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      return result;
    }

    expect(await localized('fa', 'Content location', 'Inhaltsstandort'), 'مکان محتوا');
    expect(await localized('es', 'Content location', 'Inhaltsstandort'), 'Ubicación del contenido');
    expect(await localized('pt', 'Content location', 'Inhaltsstandort'), 'Localização do conteúdo');
    expect(await localized('fr', 'Content location', 'Inhaltsstandort'), 'Emplacement du contenu');
    expect(await localized('ar', 'Content location', 'Inhaltsstandort'), 'موقع المحتوى');
    expect(await localized('ro', 'Content location', 'Inhaltsstandort'), 'Locația conținutului');
  });

  test('country labels cover all six non-EN extended locales', () {
    expect(Countries.nameForCode('IT', languageCode: 'fa'), isNot('Italy'));
    expect(Countries.nameForCode('IT', languageCode: 'es'), 'Italia');
    expect(Countries.nameForCode('IT', languageCode: 'pt'), 'Itália');
    expect(Countries.nameForCode('IT', languageCode: 'fr'), 'Italie');
    expect(Countries.nameForCode('IT', languageCode: 'ar'), 'إيطاليا');
    expect(Countries.nameForCode('IT', languageCode: 'ro'), 'Italia');
  });

  test('guest-only dynamic fallback branch remains once per translation group', () {
    final source = File('lib/app/localization/de_fallback.dart').readAsStringSync();
    const needle =
        ', sign in or create an account. As a guest you can only view content.';
    expect(RegExp(RegExp.escape(needle)).allMatches(source).length, 4);
  });

  test('auth/signup language metadata accepts all nine app languages', () {
    final paths = <String>[
      'lib/features/auth/presentation/widgets/register_form.dart',
      'lib/domain/identity/usecases/register_user.dart',
      'lib/infrastructure/persistence/remote/rest/auth_api.dart',
    ];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      for (final code in <String>['fa', 'es', 'pt', 'fr', 'ar', 'ro']) {
        expect(source, contains("'$code' => '$code'"), reason: '$path / $code');
      }
    }
  });
}

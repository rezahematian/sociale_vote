import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/organization/presentation/workspace_localization.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';

void main() {
  const languageCodes = <String>[
    'en',
    'it',
    'de',
    'fa',
    'es',
    'pt',
    'fr',
    'ar',
    'ro',
    'ru',
    'zh',
  ];

  Map<String, dynamic> arb(String code) => jsonDecode(
        File('lib/l10n/app_$code.arb').readAsStringSync(),
      ) as Map<String, dynamic>;

  String source(String path) => File(path).readAsStringSync();

  test('A. eleven ARB catalogs preserve exact 1309-key parity', () {
    Set<String>? expected;
    for (final code in languageCodes) {
      final keys = arb(code).keys.where((key) => !key.startsWith('@')).toSet();
      expected ??= keys;
      expect(keys, expected, reason: 'ARB key mismatch for $code');
    }
    expect(expected, hasLength(1309));
  });

  test('B. Home RTL ARB copy contains no bidi control code points', () {
    final lri = String.fromCharCode(0x2066);
    final pdi = String.fromCharCode(0x2069);

    for (final code in const <String>['fa', 'ar']) {
      final rawArb = source('lib/l10n/app_$code.arb');
      final purpose = arb(code)['homeHeroPurpose'] as String;

      expect(rawArb, isNot(contains(r'\u2066')), reason: '$code ARB LRI escape');
      expect(rawArb, isNot(contains(r'\u2069')), reason: '$code ARB PDI escape');
      expect(rawArb, isNot(contains(lri)), reason: '$code ARB raw LRI');
      expect(rawArb, isNot(contains(pdi)), reason: '$code ARB raw PDI');
      expect(purpose, contains('Voce'), reason: code);
      expect(purpose, contains('Vote'), reason: code);

      final isolated = socialVoteIsolateFixedProductNames(purpose);
      expect(isolated, contains('${lri}Voce$pdi'), reason: '$code Voce');
      expect(isolated, contains('${lri}Vote$pdi'), reason: '$code Vote');
    }
  });

  test('C. generated FA and AR localization Dart has no raw bidi controls', () {
    final lri = String.fromCharCode(0x2066);
    final pdi = String.fromCharCode(0x2069);
    for (final code in const <String>['fa', 'ar']) {
      final generated = source('lib/l10n/app_localizations_$code.dart');
      expect(generated, isNot(contains(lri)), reason: '$code generated LRI');
      expect(generated, isNot(contains(pdi)), reason: '$code generated PDI');
    }
  });

  test('D. Home applies runtime product-name isolation only to RTL copy', () {
    final home = source(
      'lib/features/home/presentation/widgets/home_hero_section.dart',
    );
    expect(home, contains('localeTextDirection == TextDirection.rtl'));
    expect(home, contains('socialVoteIsolateFixedProductNames('));
    expect(home, contains('textWidthBasis: TextWidthBasis.parent'));
  });

  test('E. Workspace core terms are localized across all 11 languages', () {
    const expected = <String, List<String>>{
      'en': <String>['Sessions', 'Session', 'Team', 'Organization', 'Business'],
      'it': <String>['Sessioni', 'Sessione', 'Gruppo', 'Organizzazione', 'Professionale'],
      'de': <String>['Sitzungen', 'Sitzung', 'Team', 'Organisation', 'Geschäftlich'],
      'fa': <String>['جلسه‌ها', 'جلسه', 'تیم', 'سازمان', 'کسب‌وکار'],
      'es': <String>['Sesiones', 'Sesión', 'Equipo', 'Organización', 'Empresarial'],
      'pt': <String>['Sessões', 'Sessão', 'Equipe', 'Organização', 'Empresarial'],
      'fr': <String>['Sessions', 'Session', 'Équipe', 'Organisation', 'Professionnel'],
      'ar': <String>['الجلسات', 'جلسة', 'الفريق', 'المنظمة', 'الأعمال'],
      'ro': <String>['Sesiuni', 'Sesiune', 'Echipă', 'Organizație', 'Profesional'],
      'ru': <String>['Сессии', 'Сессия', 'Команда', 'Организация', 'Бизнес'],
      'zh': <String>['会议', '会议', '团队', '组织', '商务'],
    };

    for (final entry in expected.entries) {
      final actual = <String>[
        workspaceUiTermForLanguageCode(entry.key, WorkspaceUiTerm.sessions),
        workspaceUiTermForLanguageCode(entry.key, WorkspaceUiTerm.session),
        workspaceUiTermForLanguageCode(entry.key, WorkspaceUiTerm.team),
        workspaceUiTermForLanguageCode(entry.key, WorkspaceUiTerm.organization),
        workspaceUiTermForLanguageCode(entry.key, WorkspaceUiTerm.business),
      ];
      expect(actual, entry.value, reason: entry.key);
    }
  });

  test('F. Workspace high-risk legacy copy no longer falls back to English', () {
    const checks = <String, Map<String, String>>{
      'zh': <String, String>{
        'Workspace active': '工作区已激活',
        'Verified Results': '已验证结果',
        'Manager': '管理员',
      },
      'fa': <String, String>{
        'Workspace active': 'فضای کاری فعال',
        'Verified Results': 'نتایج تأییدشده',
        'Manager': 'مدیر',
      },
      'ar': <String, String>{
        'Workspace active': 'مساحة العمل نشطة',
        'Verified Results': 'النتائج الموثقة',
        'Manager': 'المدير',
      },
      'ru': <String, String>{
        'Workspace active': 'Рабочее пространство активно',
        'Verified Results': 'Проверенные результаты',
        'Manager': 'Менеджер',
      },
    };

    for (final language in checks.entries) {
      for (final copy in language.value.entries) {
        expect(
          workspaceLocalizedOverrideForLanguageCode(language.key, copy.key),
          copy.value,
          reason: '${language.key}: ${copy.key}',
        );
      }
    }
  });

  test('G. Workspace page has no old hardcoded generic navigation terms', () {
    final workspace = source(
      'lib/features/organization/presentation/pages/organization_workspace_page.dart',
    );
    for (final stale in const <String>[
      "_WorkspaceSection.sessions => 'Sessions'",
      "_WorkspaceSection.team => 'Team'",
      "_WorkspaceSection.organization => 'Organization'",
      "title: 'Session'",
      "Text('Manager')",
      "Text('Operator')",
      "Text('Viewer')",
      "'Social Vote Business'",
    ]) {
      expect(workspace, isNot(contains(stale)), reason: stale);
    }
    expect(workspace, contains('workspaceUiTerm('));
    expect(workspace, contains('_roleLabel(context, data.membershipRole)'));
  });

  test('H. Account and preferences localize globe and personal activity entry points', () {
    final profile = source(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    );
    expect(profile, contains('_globeQuickSettingsTitle(context)'));
    expect(profile, contains('ProductSignatureKind.vote'));
    expect(profile, contains('ProductSignatureKind.voce'));
    expect(profile, isNot(contains("title: 'Globe'")));
  });

  test('I. World appearance removes mixed legacy Radio Mondo and GeoScope copy', () {
    final world = source(
      'lib/features/profile/presentation/pages/world_appearance_settings_page.dart',
    );
    expect(world, isNot(contains('Radio Mondo')));
    expect(world, isNot(contains('GeoScope')));
    expect(world, contains("zh: '世界电台'"));
    expect(world, contains("zh: '地球仪风格'"));
  });

  test('J. How-it-works localizes generic service terms but keeps Vote and Voce fixed', () {
    final how = source(
      'lib/features/onboarding/presentation/how_social_vote_works_page.dart',
    );
    expect(how, isNot(contains("badge: 'BUSINESS'")));
    expect(how, isNot(contains("title: 'Session'")));
    expect(how, isNot(contains("it: 'Civic Map:")));
    expect(how, isNot(contains("zh: 'Civic Map")));
    expect(how, isNot(contains("zh: '会话")));
    expect(how, contains("title: 'Voce'"));
    expect(how, contains("title: 'Vote'"));
    expect(how, contains("zh: '公民地图：通过地点探索'"));
  });

  test('K. Vote detail chrome uses 11-language localization paths', () {
    final header = source(
      'lib/features/poll/presentation/widgets/poll_detail_header.dart',
    );
    final page = source(
      'lib/features/poll/presentation/pages/poll_detail_page.dart',
    );

    expect(header, contains('l10n.postDetail_shareAction'));
    expect(header, contains('l10n.commonSaveButton'));
    expect(header, contains('l10n.pollDetail_chipAnonymous'));
    expect(header, contains('l10n.pollDetail_chipPublic'));
    expect(header, contains('l10n.pollCard_resultsVisibleChip'));
    expect(header, contains('Countries.nameForCode('));
    expect(header, contains("'fa' => ('امکان تغییر رأی', 'رأی قفل‌شده')"));
    expect(header, contains("'ar' => ('يمكن تغيير التصويت', 'التصويت مقفل')"));
    expect(header, contains("'zh' => ('可修改投票', '投票已锁定')"));
    expect(header, isNot(contains("en: 'Vote locked'")));
    expect(header, isNot(contains("en: 'Anonymous vote'")));
    expect(header, isNot(contains("en: 'Results always visible'")));
    expect(page, contains(
      'socialVoteIsolateFixedProductNames(l10n.pollDetail_title)',
    ));
  });

}

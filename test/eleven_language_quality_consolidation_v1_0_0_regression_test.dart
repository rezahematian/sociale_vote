import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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

  test('A. eleven ARB catalogs keep exact message-key parity', () {
    Set<String>? expected;
    for (final code in languageCodes) {
      final keys = arb(code)
          .keys
          .where((key) => !key.startsWith('@'))
          .toSet();
      expected ??= keys;
      expect(keys, expected, reason: 'ARB key mismatch for $code');
    }
    expect(expected, hasLength(1309));
  });

  test('B. canonical product entry names remain invariant', () {
    for (final code in languageCodes) {
      final data = arb(code);
      expect(data['appTitle'], 'Social Vote', reason: code);
      expect(data['pollList_title'], 'Vote', reason: code);
      expect(data['socialFeedTitle'], 'Voce', reason: code);
      expect(data['newsFeed_title'], 'News', reason: code);
      expect(data['newsCard_headerTitle'], 'News', reason: code);
      expect(data['homeScopeShortWorld'], 'World', reason: code);
      expect(data['homeTrendingTitle'], 'Pulse Now', reason: code);
      expect((data['homeForYouTitle'] as String).startsWith('Pulse'), isTrue,
          reason: code);
      expect((data['worldBriefEditorTitle'] as String).contains('World Brief'),
          isTrue, reason: code);
    }

    final productSignature =
        source('lib/shared/widgets/product_signature_label.dart');
    for (final canonicalName in const <String>[
      'Social Vote',
      'Vote',
      'Voce',
      'News',
      'World',
      'World Brief',
      'Pulse',
      'Pulse Now',
    ]) {
      expect(productSignature, contains("'$canonicalName'"),
          reason: canonicalName);
    }

    expect(
      source('lib/features/home/presentation/widgets/home_poll_section.dart'),
      contains('ProductSignatureKind.vote'),
    );
    expect(
      source('lib/features/home/presentation/widgets/home_social_section.dart'),
      contains('ProductSignatureKind.voce'),
    );
    expect(
      source('lib/features/home/presentation/widgets/home_news_section.dart'),
      contains('ProductSignatureKind.news'),
    );
  });

  test('C-D-E. Voce and Vote preserve content language end-to-end', () {
    final post = source('lib/domain/content/social/entities/post.dart');
    final postRepository =
        source('lib/infrastructure/social/repositories/post_repository_impl.dart');
    final poll = source('lib/domain/poll/entities/poll.dart');
    final pollRepository =
        source('lib/infrastructure/poll/repositories/poll_repository_supabase.dart');
    final createVoce =
        source('lib/features/social/presentation/pages/create_post_page.dart');
    final createVote =
        source('lib/features/poll/presentation/pages/create_poll_page.dart');

    expect(post, contains('final String languageCode;'));
    expect(post, contains("this.languageCode = 'und'"));
    expect(postRepository, contains("'language_code': post.languageCode"));
    expect(postRepository, contains("row['language_code']"));

    expect(poll, contains('final String languageCode;'));
    expect(poll, contains("this.languageCode = 'und'"));
    expect(pollRepository, contains("'language_code': poll.languageCode"));
    expect(pollRepository, contains("row['language_code']"));

    expect(createVoce, contains('ContentLanguageField('));
    expect(createVoce, contains('_contentLanguageInitialized'));
    expect(createVoce, contains('languageCode: _contentLanguageCode'));
    expect(createVote, contains('ContentLanguageField('));
    expect(createVote, contains('_contentLanguageInitialized'));
    expect(createVote, contains('setLanguageCode('));

    final languageField =
        source('lib/shared/widgets/content_language_field.dart');
    for (final code in languageCodes) {
      expect(languageField, contains("code: '$code'"), reason: code);
    }
    for (final unsupported in const ['tr', 'uk', 'ja', 'ko', 'hi']) {
      expect(languageField, isNot(contains("code: '$unsupported'")),
          reason: unsupported);
    }
  });

  test('F. News contract is 11 languages with app-locale AUTO and EN fallback', () {
    final language = source('lib/features/news/domain/news_language.dart');
    final controller =
        source('lib/features/news/application/news_controller.dart');
    final di = source('lib/app/di.dart');

    for (final code in languageCodes) {
      expect(language, contains(code == 'en' ? 'en,' : '$code,'), reason: code);
    }
    expect(language, contains('auto,'));
    expect(controller, contains('AppLanguageState.selectedLanguageCode'));
    expect(controller, contains("language: 'en'"));
    expect(controller, contains("_activeFeedLanguage = 'en'"));
    expect(di, contains('AppLanguageState.selectedLanguageCode'));
    expect(di, contains("language: 'en'"));
  });

  test('G. signup preserves RU and Simplified-ZH metadata', () {
    for (final path in <String>[
      'lib/features/auth/presentation/widgets/register_form.dart',
      'lib/domain/identity/usecases/register_user.dart',
      'lib/infrastructure/persistence/remote/rest/auth_api.dart',
    ]) {
      final text = source(path);
      expect(text, contains("'ru' => 'ru'"), reason: path);
      expect(text, contains("'zh' => 'zh'"), reason: path);
    }
  });

  test('G2. explicit Traditional Chinese is not coerced to Simplified', () {
    final localeHelper =
        source('lib/core/localization/content_language_code.dart');
    final app = source('lib/app/app.dart');
    expect(localeHelper, contains("script == 'hant'"));
    expect(localeHelper, contains("country == 'TW'"));
    expect(localeHelper, contains("country == 'HK'"));
    expect(localeHelper, contains("country == 'MO'"));
    expect(app, contains('isExplicitTraditionalChineseLocale(platformLocale)'));
  });

  test('H. News detail and World Brief authored text reuse first-strong BiDi', () {
    final detail =
        source('lib/features/news/presentation/pages/news_detail_page.dart');
    expect(detail, contains('content_directionality.dart'));
    expect(detail, contains('socialVoteContentDirection(news.title)'));
    expect(detail, contains('socialVoteContentDirection(bodyText)'));
    expect(detail, contains('socialVoteContentDirection(text)'));
  });

  test('I. Russian plural ICU uses one/few/many/other everywhere', () {
    final data = arb('ru');
    final plurals = data.entries
        .where((entry) => entry.value is String &&
            (entry.value as String).contains('plural'))
        .toList();
    expect(plurals, isNotEmpty);
    for (final entry in plurals) {
      final value = entry.value as String;
      for (final category in const ['one', 'few', 'many', 'other']) {
        expect(value, contains('$category {'),
            reason: '${entry.key} missing $category');
      }
    }
  });

  test('J. Arabic plural ICU uses CLDR zero/one/two/few/many/other', () {
    final data = arb('ar');
    final plurals = data.entries
        .where((entry) => entry.value is String &&
            (entry.value as String).contains('plural'))
        .toList();
    expect(plurals, isNotEmpty);
    for (final entry in plurals) {
      final value = entry.value as String;
      for (final category in const ['zero', 'one', 'two', 'few', 'many', 'other']) {
        expect(value, contains('$category {'),
            reason: '${entry.key} missing $category');
      }
    }
  });

  test('K. RU/ZH SocialVoteSymbols do not fall back to English labels', () {
    final symbols = source('lib/shared/widgets/social_vote_symbols.dart');
    for (final token in const ["'ru' =>", "'zh' =>"]) {
      expect(symbols, contains(token));
    }
    expect(symbols, contains('Организация'));
    expect(symbols, contains('组织'));
    expect(symbols, contains('Открыть профиль'));
    expect(symbols, contains('打开个人资料'));
  });

  test('L. Rules/Vision runtime is text-native and no longer bitmap-dependent', () {
    final page = source(
      'lib/features/onboarding/presentation/how_social_vote_works_page.dart',
    );
    expect(page, contains('_DynamicVisionHero('));
    expect(page, contains('_RulesGrid(rules: _buildRules(context))'));
    expect(page, isNot(contains('_VisionPosterCard(')));
    expect(page, isNot(contains('assets/vision/')));
  });

  test('M. RU/ZH high-visibility non-brand UI no longer keeps English terms', () {
    const forbidden = <String>[
      'Workspace',
      'Presenter',
      'Live Stage',
      'Admin Center',
      'Verified Result',
      'Access Pass',
      'Session Control Room',
    ];
    for (final code in const ['ru', 'zh']) {
      final data = arb(code);
      final values = data.entries
          .where((entry) => !entry.key.startsWith('@'))
          .map((entry) => entry.value)
          .whereType<String>()
          .join('\n');
      for (final term in forbidden) {
        expect(values, isNot(contains(term)), reason: '$code contains $term');
      }
    }
  });

  test('N. non-EN/IT/DE legal pages explicitly disclose English legal text', () {
    final page =
        source('lib/features/auth/presentation/pages/legal_document_page.dart');
    expect(page, contains('usesEnglishLegalText'));
    expect(page, contains('_englishLegalAvailabilityNotice'));
    for (final code in const ['fa', 'es', 'pt', 'fr', 'ar', 'ro', 'ru', 'zh']) {
      expect(page, contains("'$code' =>"), reason: code);
    }
  });
}

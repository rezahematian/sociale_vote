import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_for_you_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_hero_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_news_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_poll_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_social_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_trending_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_web_world_panel.dart';
import 'package:sociale_vote/features/onboarding/presentation/how_social_vote_works_page.dart';
import 'package:sociale_vote/shared/widgets/product_signature_label.dart';

void main() {
  const supported = <String>{
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
  };

  const brandContract = <ProductSignatureKind, String>{
    ProductSignatureKind.socialVote: 'Social Vote',
    ProductSignatureKind.vote: 'Vote',
    ProductSignatureKind.voce: 'Voce',
    ProductSignatureKind.news: 'News',
    ProductSignatureKind.world: 'World',
    ProductSignatureKind.worldBrief: 'World Brief',
    ProductSignatureKind.pulse: 'Pulse',
    ProductSignatureKind.pulseNow: 'Pulse Now',
  };

  test('modified Home and Rules surfaces compile as public widget types', () {
    final types = <Type>[
      HomeForYouSection,
      HomeHeroSection,
      HomeNewsSection,
      HomePollSection,
      HomeSocialSection,
      HomeTrendingSection,
      HomeWebWorldPanel,
      HowSocialVoteWorksPage,
      ProductSignatureLabel,
    ];
    expect(types, hasLength(9));
  });

  test('all eight product names remain invariant in all eleven languages', () {
    for (final language in supported) {
      for (final entry in brandContract.entries) {
        final copy = ProductSignatureCopy.forLanguageCode(language, entry.key);
        expect(copy.brand, entry.value, reason: '$language ${entry.key}');
        expect(copy.descriptor.trim(), isNotEmpty,
            reason: '$language ${entry.key} descriptor');
      }
    }
  });

  test('Vote Voce News World descriptors match the eleven-language contract', () {
    const expected = <String, List<String>>{
      'en': <String>['Voting', 'Opinions and expression', 'Current affairs', 'Global view'],
      'it': <String>['Votazioni', 'Opinioni ed espressione', 'Notizie', 'Mondo'],
      'de': <String>['Abstimmungen', 'Meinung und Ausdruck', 'Nachrichten', 'Welt'],
      'fa': <String>['رأی‌گیری', 'دیدگاه و بیان نظر', 'خبرها', 'جهان'],
      'es': <String>['Votaciones', 'Opinión y expresión', 'Noticias', 'Mundo'],
      'pt': <String>['Votações', 'Opinião e expressão', 'Notícias', 'Mundo'],
      'fr': <String>['Votes et consultations', 'Opinion et expression', 'Actualités', 'Monde'],
      'ar': <String>['التصويت', 'الرأي والتعبير', 'الأخبار', 'العالم'],
      'ro': <String>['Voturi', 'Opinii și exprimare', 'Știri', 'Lume'],
      'ru': <String>['Голосование', 'Мнение и высказывание', 'Новости', 'Мир'],
      'zh': <String>['投票', '观点与表达', '新闻', '世界'],
    };

    for (final entry in expected.entries) {
      final actual = <String>[
        ProductSignatureCopy.forLanguageCode(entry.key, ProductSignatureKind.vote).descriptor,
        ProductSignatureCopy.forLanguageCode(entry.key, ProductSignatureKind.voce).descriptor,
        ProductSignatureCopy.forLanguageCode(entry.key, ProductSignatureKind.news).descriptor,
        ProductSignatureCopy.forLanguageCode(entry.key, ProductSignatureKind.world).descriptor,
      ];
      expect(actual, entry.value, reason: entry.key);
    }
  });

  test('Home primary surfaces use product signature dual labels', () {
    final root = Directory.current.path;
    final files = <String, List<String>>{
      'lib/features/home/presentation/widgets/home_hero_section.dart': <String>[
        'ProductSignatureKind.world',
        'ProductSignatureKind.vote',
        'ProductSignatureKind.news',
      ],
      'lib/features/home/presentation/widgets/home_poll_section.dart': <String>[
        'ProductSignatureKind.vote',
      ],
      'lib/features/home/presentation/widgets/home_social_section.dart': <String>[
        'ProductSignatureKind.voce',
      ],
      'lib/features/home/presentation/widgets/home_news_section.dart': <String>[
        'ProductSignatureKind.news',
      ],
      'lib/features/home/presentation/widgets/home_for_you_section.dart': <String>[
        'ProductSignatureKind.pulse',
      ],
      'lib/features/home/presentation/widgets/home_trending_section.dart': <String>[
        'ProductSignatureKind.pulseNow',
      ],
      'lib/features/home/presentation/widgets/home_web_world_panel.dart': <String>[
        'ProductSignatureKind.world',
        'ProductSignatureKind.vote',
        'ProductSignatureKind.voce',
        'ProductSignatureKind.news',
      ],
    };

    for (final entry in files.entries) {
      final source = File('$root/${entry.key}').readAsStringSync();
      expect(source, contains('ProductSignatureLabel'), reason: entry.key);
      for (final token in entry.value) {
        expect(source, contains(token), reason: '${entry.key}: $token');
      }
    }
  });

  test('Rules Vision count chip uses const constructor', () {
    final source = File(
      '${Directory.current.path}/lib/features/onboarding/presentation/how_social_vote_works_page.dart',
    ).readAsStringSync();

    expect(
      source,
      contains("const Chip(label: Text('10', textDirection: TextDirection.ltr))"),
    );
    expect(
      source,
      isNot(contains("\n                    Chip(label: Text('10',")),
    );
  });
}

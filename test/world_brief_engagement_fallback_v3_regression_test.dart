import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('World Brief detail keeps EngagementBar without NewsController provider',
      () {
    final source = File(
      'lib/features/news/presentation/pages/news_detail_page.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        "import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';",
      ),
    );
    expect(
      source,
      contains(
        "import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';",
      ),
    );
    expect(source, contains('ReactionSummary? _standaloneReactionSummary;'));
    expect(source, contains('_loadStandaloneEngagement();'));
    expect(
      source,
      contains(
        'newsController?.summaryForNews(news) ?? _standaloneReactionSummary',
      ),
    );
    expect(
      source,
      contains('newsController != null || news.worldBrief != null'),
    );
    expect(source, contains('AppDI.instance.getReactionSummary('));
    expect(source, contains('AppDI.instance.toggleReaction('));
    expect(source, contains('ReactionType.like'));
    expect(source, contains('ReactionType.dislike'));
    expect(source, isNot(contains('showEngagement: newsController != null,')));
  });
}

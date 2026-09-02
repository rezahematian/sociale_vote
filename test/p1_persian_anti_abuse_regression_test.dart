import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/features/organization/presentation/pages/create_live_session_page.dart';
import 'package:sociale_vote/features/poll/application/create_poll_controller.dart';
import 'package:sociale_vote/features/poll/application/vote_controller.dart';
import 'package:sociale_vote/features/poll/presentation/pages/create_poll_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_comments_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/create_post_page.dart';
import 'package:sociale_vote/shared/services/anti_abuse_error_service.dart';

void main() {
  test('anti-abuse 54000 detection and localized copy', () {
    expect(isAntiAbuseRateLimitError(Exception('code: 54000')), isTrue);
    expect(
      isAntiAbuseRateLimitError(Exception('detail=rate_limit=comment_create')),
      isTrue,
    );
    expect(
      antiAbuseRateLimitMessageForLanguageCode('fa'),
      contains('دوباره تلاش کنید'),
    );
    expect(
      antiAbuseRateLimitMessageForLanguageCode('it'),
      contains('troppe azioni'),
    );
  });

  test('Persian comments use full-width content direction', () {
    final section = File(
      'lib/features/discussion/presentation/widgets/comment_section.dart',
    ).readAsStringSync();
    final mine = File(
      'lib/features/profile/presentation/pages/my_comments_page.dart',
    ).readAsStringSync();

    expect(section, contains('socialVoteContentDirection(comment.content)'));
    expect(section, contains('socialVoteContentTextAlign(comment.content)'));
    expect(section, contains('width: double.infinity'));
    expect(mine, contains('socialVoteContentDirection(comment.content)'));
    expect(mine, contains('socialVoteContentTextAlign(comment.content)'));
  });

  test('main protected mutation flows recognize the limiter', () {
    final paths = <String>[
      'lib/features/discussion/application/discussion_controller.dart',
      'lib/features/social/presentation/pages/create_post_page.dart',
      'lib/features/poll/application/create_poll_controller.dart',
      'lib/features/poll/application/vote_controller.dart',
      'lib/features/poll/presentation/pages/poll_detail_page.dart',
      'lib/features/organization/presentation/pages/create_live_session_page.dart',
    ];

    for (final path in paths) {
      final source = File(path).readAsStringSync();
      expect(
        source.contains('antiAbuseRateLimit') ||
            source.contains('isAntiAbuseRateLimitError'),
        isTrue,
        reason: path,
      );
    }
  });

  test('modified libraries compile', () {
    expect(CommentSection.new, isNotNull);
    expect(DiscussionController.new, isNotNull);
    expect(MyCommentsPage.new, isNotNull);
    expect(CreatePostPage.new, isNotNull);
    expect(CreatePollController.new, isNotNull);
    expect(CreatePollPage.new, isNotNull);
    expect(VoteController.new, isNotNull);
    expect(PollDetailPage.new, isNotNull);
    expect(CreateLiveSessionPage.new, isNotNull);
  });
}

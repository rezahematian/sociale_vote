import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/poll/presentation/pages/create_poll_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_detail_header.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_profile_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/create_post_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/post_detail_page.dart';
import 'package:sociale_vote/features/social/presentation/widgets/post_card.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';

void main() {
  test('runtime target libraries stay part of targeted compilation', () {
    final compileTargets = <Type>[
      CreatePollPage,
      PollDetailPage,
      PollCard,
      PollDetailHeader,
      MyProfilePage,
      CreatePostPage,
      PostDetailPage,
      PostCard,
    ];
    expect(compileTargets.length, 8);
  });

  test('first strong script decides paragraph direction; digits are neutral', () {
    expect(
      socialVoteContentDirection('سلام دنیا'),
      TextDirection.rtl,
    );
    expect(
      socialVoteContentTextAlign('سلام دنیا'),
      TextAlign.right,
    );
    expect(
      socialVoteContentDirection('سلام دنیا 99999'),
      TextDirection.rtl,
    );
    expect(
      socialVoteContentDirection('99999 سلام دنیا'),
      TextDirection.rtl,
    );
    expect(
      socialVoteContentDirection('Social Vote'),
      TextDirection.ltr,
    );
    expect(
      socialVoteContentTextAlign('Social Vote'),
      TextAlign.left,
    );
    expect(
      socialVoteContentDirection('99999 Social Vote'),
      TextDirection.ltr,
    );
  });

  testWidgets('Persian locale is only the empty-input fallback', (tester) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        supportedLocales: const <Locale>[
          Locale('en'),
          Locale('it'),
          Locale('de'),
          Locale('fa'),
          Locale('es'),
          Locale('pt'),
        ],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ),
    );

    expect(
      socialVoteLocaleTextDirection(capturedContext),
      TextDirection.rtl,
    );
    expect(
      socialVoteEditableTextDirection(capturedContext, ''),
      TextDirection.rtl,
    );
    expect(
      socialVoteEditableTextDirection(capturedContext, 'سلام'),
      TextDirection.rtl,
    );
    expect(
      socialVoteEditableTextDirection(capturedContext, '99999 سلام'),
      TextDirection.rtl,
    );
    expect(
      socialVoteEditableTextDirection(capturedContext, 'Social Vote'),
      TextDirection.ltr,
    );
    expect(
      socialVoteEditableTextDirection(capturedContext, '99999 Social Vote'),
      TextDirection.ltr,
    );
  });

  testWidgets('wrapped Persian authored text keeps full-width RTL paragraph',
      (tester) async {
    const value =
        'سیاتبایذلیسففففففففففففففففییییللللللللللللللللللللللللللللللللللللللللللللللللللللللللللللللللل99999';

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 220,
          child: SocialVoteDirectionalText(value),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text(value));
    expect(text.textDirection, TextDirection.rtl);
    expect(text.textAlign, TextAlign.right);
    expect(text.textWidthBasis, TextWidthBasis.parent);
  });

  test('runtime surfaces use the shared content-aware direction contract', () {
    final root = Directory.current.path;

    String read(String relativePath) {
      return File('$root/$relativePath').readAsStringSync();
    }

    final postCard = read(
      'lib/features/social/presentation/widgets/post_card.dart',
    );
    final postDetail = read(
      'lib/features/social/presentation/pages/post_detail_page.dart',
    );
    final createPost = read(
      'lib/features/social/presentation/pages/create_post_page.dart',
    );
    final pollCard = read(
      'lib/features/poll/presentation/widgets/poll_card.dart',
    );
    final pollHeader = read(
      'lib/features/poll/presentation/widgets/poll_detail_header.dart',
    );
    final pollDetail = read(
      'lib/features/poll/presentation/pages/poll_detail_page.dart',
    );
    final createPoll = read(
      'lib/features/poll/presentation/pages/create_poll_page.dart',
    );

    expect(postCard, contains('SocialVoteDirectionalText('));
    expect(postDetail, contains('SocialVoteDirectionalText('));
    expect(createPost, contains('_refreshEditableDirection'));
    expect(createPost, contains('socialVoteEditableTextDirection('));
    expect(pollCard, contains('SocialVoteDirectionalText('));
    expect(pollHeader, contains('SocialVoteDirectionalText('));
    expect(pollDetail, contains('SocialVoteDirectionalText('));
    expect(createPoll, contains('socialVoteEditableTextDirection('));
    expect(
      createPoll,
      isNot(contains('textDirection: socialVoteLocaleTextDirection(context)')),
    );
  });
}

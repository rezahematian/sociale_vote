import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

import 'package:sociale_vote/features/auth/presentation/pages/login_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/register_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/reset_password_page.dart';
import 'package:sociale_vote/features/home/presentation/pages/public_home_screen.dart';
import 'package:sociale_vote/features/map/presentation/pages/civic_map_page.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_feed_page.dart';
import 'package:sociale_vote/features/notifications/presentation/pages/notifications_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/create_poll_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_list_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_profile_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/post_detail_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/social_feed_page.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String polls = '/polls';
  static const String pollDetail = '/polls/detail';
  static const String createPoll = '/polls/create';
  static const String news = '/news';
  static const String newsDetail = '/news/detail';
  static const String social = '/social';
  static const String socialDetail = '/social/detail';
  static const String civicMap = '/map';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';

  static const String initialRoute = home;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const PublicHomeScreen(),
          settings: settings,
        );

      case polls:
        return MaterialPageRoute<void>(
          builder: (_) => const PollListPage(),
          settings: settings,
        );

      case pollDetail:
        final args = settings.arguments;

        if (args is PollId) {
          return MaterialPageRoute<void>(
            builder: (_) => PollDetailPage(pollId: args),
            settings: settings,
          );
        }

        if (args is String && args.trim().isNotEmpty) {
          return MaterialPageRoute<void>(
            builder: (_) => PollDetailPage(
              pollId: PollId(args.trim()),
            ),
            settings: settings,
          );
        }

        if (args is Map) {
          final rawPollId = args['pollId'];
          final openCommentsOnLoad = args['openCommentsOnLoad'] == true;

          PollId? pollId;

          if (rawPollId is PollId) {
            pollId = rawPollId;
          } else if (rawPollId is String && rawPollId.trim().isNotEmpty) {
            pollId = PollId(rawPollId.trim());
          }

          if (pollId != null) {
            final resolvedPollId = pollId;

            return MaterialPageRoute<void>(
              builder: (_) => PollDetailPage(
                pollId: resolvedPollId,
                openCommentsOnLoad: openCommentsOnLoad,
              ),
              settings: settings,
            );
          }
        }
        break;

      case createPoll:
        return MaterialPageRoute<void>(
          builder: (_) => const CreatePollPage(),
          settings: settings,
        );

      case news:
        return MaterialPageRoute<void>(
          builder: (_) => const NewsFeedPage(),
          settings: settings,
        );

      case newsDetail:
        final args = settings.arguments;
        if (args is NewsItem) {
          return MaterialPageRoute<void>(
            builder: (_) => NewsDetailPage(news: args),
            settings: settings,
          );
        }
        break;

      case social:
        return MaterialPageRoute<void>(
          builder: (_) => const SocialFeedPage(),
          settings: settings,
        );

      case socialDetail:
        final args = settings.arguments;
        if (args is String && args.trim().isNotEmpty) {
          return MaterialPageRoute<void>(
            builder: (_) => PostDetailPage(postId: args),
            settings: settings,
          );
        }
        break;

      case civicMap:
        return MaterialPageRoute<void>(
          builder: (_) => const CivicMapPage(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute<void>(
          builder: (_) => const MyProfilePage(),
          settings: settings,
        );

      case notifications:
        return MaterialPageRoute<void>(
          builder: (_) => NotificationsPage(
            controller: AppDI.instance.createNotificationsController(),
          ),
          settings: settings,
        );

      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case resetPassword:
        return MaterialPageRoute<void>(
          builder: (_) => const ResetPasswordPage(),
          settings: settings,
        );
    }

    return MaterialPageRoute<void>(
      builder: (_) => const PublicHomeScreen(),
      settings: settings,
    );
  }
}
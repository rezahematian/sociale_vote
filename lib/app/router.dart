import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

import 'package:sociale_vote/features/auth/presentation/pages/login_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/register_page.dart';
import 'package:sociale_vote/features/home/presentation/pages/public_home_screen.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_feed_page.dart';
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
  static const String social = '/social';
  static const String socialDetail = '/social/detail';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';

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

      case social:
        return MaterialPageRoute<void>(
          builder: (_) => const SocialFeedPage(),
          settings: settings,
        );

      case socialDetail:
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute<void>(
            builder: (_) => PostDetailPage(postId: args),
            settings: settings,
          );
        }
        break;

      case profile:
        return MaterialPageRoute<void>(
          builder: (_) => const MyProfilePage(),
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
    }

    return MaterialPageRoute<void>(
      builder: (_) => const PublicHomeScreen(),
      settings: settings,
    );
  }
}
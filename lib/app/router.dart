import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

import 'package:sociale_vote/features/admin/presentation/pages/admin_center_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/legal_document_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/login_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/register_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/reset_password_page.dart';
import 'package:sociale_vote/features/home/presentation/pages/public_home_screen.dart';
import 'package:sociale_vote/features/onboarding/presentation/first_time_onboarding_gate.dart';
import 'package:sociale_vote/features/map/presentation/pages/civic_map_page.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_feed_page.dart';
import 'package:sociale_vote/features/notifications/presentation/pages/notifications_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/create_poll_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_list_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_profile_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/verification_review_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/post_detail_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/social_feed_page.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

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
  static const String account = '/account';
  static const String profile = account;
  static const String notifications = '/notifications';
  static const String adminCenter = '/admin';
  static const String verificationReview = '/verification-review';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String privacy = '/privacy';

  static String get initialRoute {
    if (kIsWeb) {
      final path = Uri.base.path;
      if (path == privacy || path == '$privacy/') {
        return privacy;
      }
    }

    return home;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const FirstTimeOnboardingGate(),
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
          builder: (_) => const _CivicMapAccessGate(),
          settings: settings,
        );

      case account:
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

      case adminCenter:
        return MaterialPageRoute<void>(
          builder: (_) => const _AdminCenterAccessGate(),
          settings: settings,
        );

      case verificationReview:
        return MaterialPageRoute<void>(
          builder: (_) => const VerificationReviewPage(),
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

      case privacy:
        return MaterialPageRoute<void>(
          builder: (_) => const LegalDocumentPage(
            type: LegalDocumentType.privacy,
          ),
          settings: settings,
        );
    }

    return MaterialPageRoute<void>(
      builder: (_) => const PublicHomeScreen(),
      settings: settings,
    );
  }
}

class _CivicMapAccessGate extends StatefulWidget {
  const _CivicMapAccessGate();

  @override
  State<_CivicMapAccessGate> createState() => _CivicMapAccessGateState();
}

class _CivicMapAccessGateState extends State<_CivicMapAccessGate> {
  bool _isCheckingAccess = true;
  bool _isAllowed = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccess();
    });
  }

  Future<void> _checkAccess() async {
    final allowed = await AuthGuard.ensureAuthenticated(
      context,
      actionLabel: 'aprire la Civic Map',
    );

    if (!mounted) {
      return;
    }

    if (allowed) {
      setState(() {
        _isCheckingAccess = false;
        _isAllowed = true;
      });
      return;
    }

    setState(() {
      _isCheckingAccess = false;
      _isAllowed = false;
    });

    final popped = await Navigator.of(context).maybePop();
    if (!popped && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAllowed) {
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    return const CivicMapPage();
  }
}

class _AdminCenterAccessGate extends StatefulWidget {
  const _AdminCenterAccessGate();

  @override
  State<_AdminCenterAccessGate> createState() => _AdminCenterAccessGateState();
}

class _AdminCenterAccessGateState extends State<_AdminCenterAccessGate> {
  bool _isCheckingAccess = true;
  Role? _currentRole;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccess();
    });
  }

  Future<void> _checkAccess() async {
    if (AppDI.instance.currentUserId == null) {
      setState(() {
        _isCheckingAccess = false;
        _currentRole = null;
      });

      final popped = await Navigator.of(context).maybePop();
      if (!popped && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.home,
          (route) => false,
        );
      }
      return;
    }

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.accessAdminCenter,
    );

    if (!mounted) {
      return;
    }

    if (!allowed) {
      setState(() {
        _isCheckingAccess = false;
        _currentRole = null;
      });

      final popped = await Navigator.of(context).maybePop();
      if (!popped && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.home,
          (route) => false,
        );
      }
      return;
    }

    final session = await AppDI.instance.sessionRepository.getCurrentSession();
    final currentRole = session?.role;

    if (!mounted) {
      return;
    }

    if (currentRole == null ||
        !AuthGuard.canAccessAdminCenter(role: currentRole)) {
      setState(() {
        _isCheckingAccess = false;
        _currentRole = null;
      });

      final popped = await Navigator.of(context).maybePop();
      if (!popped && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.home,
          (route) => false,
        );
      }
      return;
    }

    setState(() {
      _isCheckingAccess = false;
      _currentRole = currentRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentRole = _currentRole;
    if (currentRole == null) {
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    return AdminCenterPage(
      currentRole: currentRole,
      onRefresh: _checkAccess,
      sectionBuilder: (_, section) {
        if (section == AdminCenterSection.verification) {
          return const VerificationReviewPage();
        }

        return const SizedBox.shrink();
      },
    );
  }
}

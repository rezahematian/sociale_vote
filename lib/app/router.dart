import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

import 'package:sociale_vote/features/admin/presentation/pages/admin_center_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/legal_document_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/login_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/register_page.dart';
import 'package:sociale_vote/features/auth/presentation/pages/reset_password_page.dart';
import 'package:sociale_vote/features/home/presentation/pages/public_home_screen.dart';
import 'package:sociale_vote/features/map/presentation/pages/civic_map_page.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_feed_page.dart';
import 'package:sociale_vote/features/notifications/presentation/pages/notifications_page.dart';
import 'package:sociale_vote/features/onboarding/presentation/first_time_onboarding_gate.dart';
import 'package:sociale_vote/features/poll/presentation/pages/create_poll_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_list_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_profile_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/verification_review_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/post_detail_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/social_feed_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
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
  static const String terms = '/terms';
  static const String privacy = '/privacy';

  static const String publicHost = 'socialevote.com';

  static String publicPollPath(String pollId) {
    final id = pollId.trim();
    return '/poll/${Uri.encodeComponent(id)}';
  }

  static String publicPostPath(String postId) {
    final id = postId.trim();
    return '/post/${Uri.encodeComponent(id)}';
  }

  static String publicCityPath({
    required String countryCode,
    required String cityName,
  }) {
    final country = countryCode.trim().toLowerCase();
    final citySlug =
        cityName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

    return '/city/${Uri.encodeComponent(country)}/${Uri.encodeComponent(citySlug)}';
  }

  static String publicPollUrl(String pollId) {
    return 'https://$publicHost${publicPollPath(pollId)}';
  }

  static String publicPostUrl(String postId) {
    return 'https://$publicHost${publicPostPath(postId)}';
  }

  static String publicCityUrl({
    required String countryCode,
    required String cityName,
  }) {
    return 'https://$publicHost${publicCityPath(countryCode: countryCode, cityName: cityName)}';
  }

  static String get initialRoute {
    if (!kIsWeb) {
      return home;
    }

    final path = _normalizePath(Uri.base.path);
    return _isSupportedWebStartupPath(path) ? path : home;
  }

  /// Public content links must open the requested destination immediately,
  /// while keeping Home underneath it in the Navigator stack. This gives a
  /// first-time visitor a normal Back path into the rest of Social Vote.
  static List<Route<dynamic>> onGenerateInitialRoutes(
    String initialRouteName,
  ) {
    final routeName = _normalizePath(initialRouteName);
    final isPublicDestination =
        _publicContentId(routeName, prefix: 'poll') != null ||
            _publicContentId(routeName, prefix: 'post') != null ||
            _publicCityTarget(routeName) != null;

    if (!isPublicDestination || routeName == home) {
      return <Route<dynamic>>[
        onGenerateRoute(RouteSettings(name: routeName)),
      ];
    }

    return <Route<dynamic>>[
      onGenerateRoute(const RouteSettings(name: home)),
      onGenerateRoute(RouteSettings(name: routeName)),
    ];
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = _normalizePath(settings.name ?? home);

    final publicPollId = _publicContentId(routeName, prefix: 'poll');
    if (publicPollId != null) {
      return MaterialPageRoute<void>(
        builder: (_) => PollDetailPage(pollId: PollId(publicPollId)),
        settings: settings,
      );
    }

    final publicPostId = _publicContentId(routeName, prefix: 'post');
    if (publicPostId != null) {
      return MaterialPageRoute<void>(
        builder: (_) => PostDetailPage(postId: publicPostId),
        settings: settings,
      );
    }

    final publicCity = _publicCityTarget(routeName);
    if (publicCity != null) {
      return MaterialPageRoute<void>(
        builder: (_) => _PublicCityRouteGate(target: publicCity),
        settings: settings,
      );
    }

    switch (routeName) {
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
          builder: (_) => const CivicMapPage(),
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

      case terms:
        return MaterialPageRoute<void>(
          builder: (_) => const LegalDocumentPage(
            type: LegalDocumentType.terms,
          ),
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

  static String _normalizePath(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty || trimmed == home) {
      return home;
    }

    final parsed = Uri.tryParse(trimmed);
    var path = parsed?.path ?? trimmed;
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    while (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }

  static bool _isSupportedWebStartupPath(String path) {
    switch (path) {
      case home:
      case polls:
      case news:
      case social:
      case civicMap:
      case terms:
      case privacy:
      case login:
      case register:
        return true;
    }

    return _publicContentId(path, prefix: 'poll') != null ||
        _publicContentId(path, prefix: 'post') != null ||
        _publicCityTarget(path) != null;
  }

  static String? _publicContentId(
    String path, {
    required String prefix,
  }) {
    final segments = Uri.tryParse(path)?.pathSegments ?? const <String>[];
    if (segments.length != 2 || segments.first.toLowerCase() != prefix) {
      return null;
    }

    final id = segments[1].trim();
    return id.isEmpty ? null : id;
  }

  static _PublicCityTarget? _publicCityTarget(String path) {
    final segments = Uri.tryParse(path)?.pathSegments ?? const <String>[];
    if (segments.length != 3 || segments.first.toLowerCase() != 'city') {
      return null;
    }

    final countryCode = segments[1].trim().toUpperCase();
    final citySlug = segments[2].trim();
    if (countryCode.length != 2 || citySlug.isEmpty) {
      return null;
    }

    final cityName = citySlug.replaceAll('-', ' ').trim();
    if (cityName.isEmpty) {
      return null;
    }

    return _PublicCityTarget(
      countryCode: countryCode,
      cityName: cityName,
    );
  }
}

class _PublicCityTarget {
  final String countryCode;
  final String cityName;

  const _PublicCityTarget({
    required this.countryCode,
    required this.cityName,
  });
}

class _PublicCityRouteGate extends StatefulWidget {
  final _PublicCityTarget target;

  const _PublicCityRouteGate({
    required this.target,
  });

  @override
  State<_PublicCityRouteGate> createState() => _PublicCityRouteGateState();
}

class _PublicCityRouteGateState extends State<_PublicCityRouteGate> {
  late Future<GeoScope?> _scopeFuture;

  @override
  void initState() {
    super.initState();
    _scopeFuture = _resolveScope();
  }

  Future<GeoScope?> _resolveScope() async {
    final resolved =
        await AppDI.instance.geocodingRepository.geocodeContentLocation(
      ContentLocation(
        source: ContentLocationSource.manual,
        countryCode: widget.target.countryCode,
        cityName: widget.target.cityName,
      ),
    );

    if (resolved == null || (!resolved.hasCenter && !resolved.hasExactPoint)) {
      return null;
    }

    final latitude = resolved.centerLat ?? resolved.latitude;
    final longitude = resolved.centerLng ?? resolved.longitude;
    if (latitude == null || longitude == null) {
      return null;
    }

    final resolvedCityName = resolved.cityName?.trim();
    final cityName = resolvedCityName == null || resolvedCityName.isEmpty
        ? widget.target.cityName
        : resolvedCityName;
    final resolvedCountryCode = resolved.countryCode?.trim().toUpperCase();
    final countryCode =
        resolvedCountryCode == null || resolvedCountryCode.isEmpty
            ? widget.target.countryCode
            : resolvedCountryCode;

    final scope = GeoScope.city(
      countryCode: countryCode,
      cityId: cityName,
      centerLat: latitude,
      centerLng: longitude,
      radiusKm: 35,
    );

    AppDI.instance.geoScopeController.setScope(scope);
    return scope;
  }

  void _retry() {
    setState(() {
      _scopeFuture = _resolveScope();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GeoScope?>(
      future: _scopeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Civic Map'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.homeScopeCityNotFoundError,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retry,
                      child: Text(l10n.searchRetryButton),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.home,
                          (route) => false,
                        );
                      },
                      child: const Text('Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const CivicMapPage();
      },
    );
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

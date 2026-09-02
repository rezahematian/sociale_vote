import 'package:flutter_test/flutter_test.dart';

import 'package:sociale_vote/app/router.dart';

void main() {
  test('every supported non-Home startup route keeps Home underneath', () {
    const routesToCheck = <String>[
      AppRouter.polls,
      AppRouter.news,
      AppRouter.social,
      AppRouter.civicMap,
      AppRouter.adminCenter,
      AppRouter.organizationWorkspace,
      AppRouter.terms,
      AppRouter.privacy,
      AppRouter.howItWorks,
      AppRouter.login,
      AppRouter.register,
    ];

    for (final routeName in routesToCheck) {
      final routes = AppRouter.onGenerateInitialRoutes(routeName);

      expect(
        routes,
        hasLength(2),
        reason: '$routeName must retain a visible Back path after refresh',
      );
      expect(routes.first.settings.name, AppRouter.home);
      expect(routes.last.settings.name, routeName);
    }
  });

  test('Home remains a single initial route', () {
    final routes = AppRouter.onGenerateInitialRoutes(AppRouter.home);

    expect(routes, hasLength(1));
    expect(routes.single.settings.name, AppRouter.home);
  });

  test('public content still keeps Home underneath', () {
    final routes = AppRouter.onGenerateInitialRoutes('/poll/poll-123');

    expect(routes, hasLength(2));
    expect(routes.first.settings.name, AppRouter.home);
    expect(routes.last.settings.name, '/poll/poll-123');
  });
}

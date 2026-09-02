import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Workspace session visibility regression guards', () {
    late String source;

    setUpAll(() {
      source = File(
        'lib/features/profile/presentation/pages/my_profile_page.dart',
      ).readAsStringSync();
    });

    test('Organization lookup errors are not rendered as no Workspace', () {
      final errorBranch = source.indexOf('if (snapshot.hasError)');
      final absentBranch = source.indexOf(
        'if (organizationContext == null &&',
      );

      expect(errorBranch, greaterThanOrEqualTo(0));
      expect(absentBranch, greaterThan(errorBranch));
      expect(source, contains('Icons.sync_problem'));
      expect(source, contains('_workspaceAccessCheckFailedMessage'));
      expect(source, isNot(contains('snapshot.error.toString()')));
    });

    test('retry validates the session through the central AuthGuard', () {
      expect(
        source,
        contains(
          "import 'package:sociale_vote/shared/services/auth_guard.dart';",
        ),
      );
      expect(source, contains('_retryOrganizationContextAccess'));
      expect(source, contains('AuthGuard.ensureAuthenticated('));
      expect(source, contains('_refreshOrganizationContext();'));
    });

    test('Workspace visibility remains independent from team role', () {
      expect(
        source,
        contains('any active Organization member can reach Workspace;'),
      );
      expect(source, isNot(contains("membershipRole == 'owner'")));
      expect(source, isNot(contains("membershipRole == 'manager'")));
    });
  });
}

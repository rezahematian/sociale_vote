import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Workspace runtime regression guards', () {
    test('account page caches Organization lookup outside build', () {
      final source = File(
        'lib/features/profile/presentation/pages/my_profile_page.dart',
      ).readAsStringSync();

      expect(
        source,
        contains(
          'late Future<OrganizationContext?> _organizationContextFuture;',
        ),
      );
      expect(source, contains('future: _organizationContextFuture,'));
      expect(
        source,
        isNot(
          contains(
            'future: AppDI.instance.organizationRepository\n'
            '                        .getMyOrganization(),',
          ),
        ),
      );
    });

    test('denied Workspace route leaves while loading instead of flashing', () {
      final source = File('lib/app/router.dart').readAsStringSync();

      expect(source, contains('await _leaveDeniedRoute();'));
      expect(source, contains('if (navigator.canPop())'));
      expect(source, contains('return const OrganizationWorkspacePage();'));
      expect(
        source,
        isNot(
          contains(
            'return _allowed\n'
            '        ? const OrganizationWorkspacePage()',
          ),
        ),
      );
    });

    test('SQL keeps active entitlement separate from billing plan', () {
      final source = File(
        'supabase/migration/20260830_workspace_entitlement_runtime_fix_v1.sql',
      ).readAsStringSync();

      expect(source, contains("v_new_plan := 'pilot';"));
      expect(source, contains("v_new_mode := 'pilot_free';"));
      expect(source, contains('billing_enabled=false'));
      expect(source, isNot(contains("then 'pro'")));
      expect(source, isNot(contains("then 'paid'")));
    });
  });
}

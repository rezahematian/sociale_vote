import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _between(String source, String startMarker, String endMarker) {
  final start = source.indexOf(startMarker);
  final end = source.indexOf(endMarker, start + startMarker.length);
  expect(start, greaterThanOrEqualTo(0), reason: 'Missing $startMarker');
  expect(end, greaterThan(start), reason: 'Missing $endMarker');
  return source.substring(start, end);
}

void main() {
  test('moderator gets user directory and read-only account context', () {
    final ui = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();
    final users = File(
      'supabase/functions/admin-users/index.ts',
    ).readAsStringSync();
    final read = File(
      'supabase/functions/admin-read/index.ts',
    ).readAsStringSync();

    final destinations = _between(
      ui,
      'List<_AdminDestination> _destinationsFor',
      '@override\n  void initState()',
    );
    final usersDestination = _between(
      destinations,
      '// ADMIN_MODERATOR_ACCESS_V1: staff user directory',
      '_AdminDestination(\n        section: AdminCenterSection.verification',
    );

    expect(usersDestination, contains('section: AdminCenterSection.users'));
    expect(
      usersDestination,
      isNot(contains('if (widget.currentRole == Role.admin)')),
    );

    expect(
      ui,
      contains('canManageAdminActions: widget.currentRole == Role.admin'),
    );
    expect(
      ui,
      contains('Vista operativa in sola lettura.'),
    );
    expect(
      ui,
      contains('widget.currentRole == Role.moderator'),
    );

    expect(users, contains('if (callerRole == null)'));
    expect(users, contains("const includeEmail = callerRole === 'admin'"));
    expect(users, contains("error: 'Staff access is required.'"));

    expect(read, contains("operation !== 'user_detail'"));
    expect(read, contains("const canViewEmail = callerRole === 'admin'"));
    expect(read, contains('email: canViewEmail ? row.email : null'));
    expect(read, contains('canViewEmail,'));
  });

  test('critical governance and irreversible actions remain admin-only', () {
    final ui = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();
    final roleChange = File(
      'supabase/functions/set-system-role/index.ts',
    ).readAsStringSync();
    final accountActions = File(
      'supabase/functions/admin-account-actions/index.ts',
    ).readAsStringSync();
    final accountDelete = File(
      'supabase/functions/admin-delete-account/index.ts',
    ).readAsStringSync();
    final read = File(
      'supabase/functions/admin-read/index.ts',
    ).readAsStringSync();

    for (final section in <String>[
      'AdminCenterSection.editorial',
      'AdminCenterSection.finance',
      'AdminCenterSection.radioMondo',
      'AdminCenterSection.audit',
    ]) {
      final index = ui.indexOf('section: $section');
      expect(index, greaterThanOrEqualTo(0), reason: 'Missing $section');
      final prefixStart = index > 180 ? index - 180 : 0;
      final prefix = ui.substring(prefixStart, index);
      expect(
        prefix,
        contains('if (widget.currentRole == Role.admin)'),
        reason: '$section must remain admin-only',
      );
    }

    expect(
      ui,
      contains('onResolveAdminEscalation: widget.currentRole == Role.admin &&'),
    );
    expect(
      ui,
      contains('if (widget.currentRole != Role.admin ||'),
    );

    expect(
      roleChange,
      contains("readSystemRole(caller.app_metadata?.role) !== 'admin'"),
    );
    expect(
      accountActions,
      contains("caller.app_metadata?.role !== 'admin'"),
    );
    expect(
      accountDelete,
      contains("readSystemRole(caller.app_metadata?.role) !== 'admin'"),
    );

    // Moderator access is intentionally limited to dashboard/reports/user_detail.
    expect(read, contains("callerRole !== 'admin' &&"));
    expect(read, contains("operation !== 'dashboard'"));
    expect(read, contains("operation !== 'reports'"));
    expect(read, contains("operation !== 'user_detail'"));
    expect(read, contains("'escalated_reports'"));
    expect(read, contains("'audit'"));
  });
}

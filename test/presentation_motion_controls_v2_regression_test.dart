import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Admin exposes header flicker and cloud motion controls', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();
    final headerService = File(
      'lib/shared/services/brand_header_mode_service.dart',
    ).readAsStringSync();
    final cloudService = File(
      'lib/shared/services/globe_clouds_service.dart',
    ).readAsStringSync();

    expect(admin, contains("it: 'Intensità lampeggio'"));
    expect(admin, contains("it: 'Velocità lampeggio'"));
    expect(admin, contains("it: 'Copertura nuvole'"));
    expect(admin, contains("it: 'Velocità nuvole'"));
    expect(admin, contains("it: 'Direzione nuvole'"));

    expect(
      headerService,
      contains("_adminSetProfileRpc = 'admin_set_header_flicker_profile'"),
    );
    expect(headerService, contains('header_flicker_intensity'));
    expect(headerService, contains('header_flicker_speed'));

    expect(
      cloudService,
      contains("_adminSetProfileRpc = 'admin_set_globe_cloud_profile'"),
    );
    expect(cloudService, contains('globe_cloud_density'));
    expect(cloudService, contains('globe_cloud_speed'));
    expect(cloudService, contains('globe_cloud_direction'));
  });

  test('Backend migration preserves RPC-only admin writes', () {
    final migration = File(
      'supabase/migration/20260929090000_presentation_motion_controls_v2.sql',
    ).readAsStringSync();

    expect(migration, contains('security definer'));
    expect(migration, contains('public.is_current_auth_user_admin()'));
    expect(
      migration,
      contains('admin_set_header_flicker_profile'),
    );
    expect(
      migration,
      contains('admin_set_globe_cloud_profile'),
    );
    expect(migration, contains('revoke all on function'));
    expect(migration, contains('to authenticated'));
  });
}

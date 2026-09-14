import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo admin upload V2 source contract', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final service = File(
      'lib/shared/services/radio_mondo_admin_storage_service.dart',
    ).readAsStringSync();
    final radio = File(
      'lib/shared/services/radio_mondo_service.dart',
    ).readAsStringSync();
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();
    final migration = File(
      'supabase/migration/20260913193000_radio_mondo_admin_upload_v2.sql',
    ).readAsStringSync();

    expect(pubspec, contains('file_picker: ^11.0.3'));
    expect(service, contains("static const String bucket = 'radio-mondo';"));
    expect(service, contains('static const int maxBytes = 25 * 1024 * 1024;'));
    expect(service, contains("<String>['mp3', 'm4a', 'ogg']"));
    expect(service, isNot(contains('service_role')));
    expect(admin, contains('Carica file audio'));
    expect(admin, contains('pickedAudio'));
    expect(admin, contains('rightsConfirmed'));
    expect(radio, contains('final int sortOrder;'));
    expect(radio, contains('sortOrder: 100'));
    expect(radio, contains('sortOrder: 200'));
    expect(radio, contains('sortOrder: 300'));
    expect(radio, contains("row['sort_order']"));
    expect(migration, contains("'radio-mondo'"));
    expect(migration, contains('public.is_current_auth_user_admin()'));
    expect(migration, isNot(contains('service_role')));
  });
}

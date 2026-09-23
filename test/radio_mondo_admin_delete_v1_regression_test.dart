import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';
import 'package:sociale_vote/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart';
import 'package:sociale_vote/infrastructure/admin/repositories/admin_repository_impl.dart';

void main() {
  test('Radio Mondo admin delete V1 keeps deletion explicit and audited', () {
    final contract = File(
      'lib/domain/admin/repositories/admin_repository.dart',
    ).readAsStringSync();
    final repo = File(
      'lib/infrastructure/admin/repositories/admin_repository_impl.dart',
    ).readAsStringSync();
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();
    final migration = File(
      'supabase/migration/20260922090000_radio_mondo_admin_delete_v1.sql',
    ).readAsStringSync();

    expect(contract, contains('deleteRadioMondoTrack'));
    expect(repo, contains("'admin_radio_mondo_delete_v1'"));
    expect(admin, contains('Icons.delete_outline'));
    expect(admin, contains('_RadioDeleteReasonDialog'));
    expect(admin, contains('removeManagedUrlBestEffort(track.audioUrl)'));
    expect(admin, contains('track.isDefault'));

    expect(migration, contains('admin_radio_mondo_delete_v1'));
    expect(migration, contains("'radio_item_delete_v1'"));
    expect(migration, contains('if v_track.is_default then'));
    expect(migration, contains('delete from public.radio_mondo_tracks'));
    expect(migration, contains('public.is_current_auth_user_admin()'));
    expect(migration, isNot(contains('service_role')));

    expect(AdminRepository, isNotNull);
    expect(AdminRepositoryImpl, isNotNull);
    expect(AdminRadioMondoControlSection, isNotNull);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo categories keep auto advance inside the selected category',
      () {
    final service =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(service, contains('enum RadioMondoCategory'));
    expect(service, contains("'jazz_soul'"));
    expect(service, contains("'sounds_atmospheres'"));
    expect(service, contains("_nullable(row['category_key'])"));
    expect(service, contains('station.category == current.category'));
    expect(service, contains('Future<bool> playPrevious()'));
    expect(service, contains('Future<bool> playNext()'));
    expect(service, contains('Future<void> pause()'));
    expect(service, contains('Future<void> resume()'));

    expect(dock, contains('FilterChip('));
    expect(dock, contains('radio.selectCategory(item)'));
    expect(dock, contains('radio.playPrevious()'));
    expect(dock, contains('radio.playNext()'));
    expect(dock, contains('Slider('));
  });

  test('Admin can assign categories and uses audited upsert v4', () {
    final entities = File('lib/domain/admin/entities/admin_entities.dart')
        .readAsStringSync();
    final repository = File(
      'lib/infrastructure/admin/repositories/admin_repository_impl.dart',
    ).readAsStringSync();
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();
    final migration = File(
      'supabase/migration/20261003111500_radio_mondo_categories_playlists_v1.sql',
    ).readAsStringSync();

    expect(entities, contains('enum AdminRadioMondoCategory'));
    expect(entities, contains('final AdminRadioMondoCategory category;'));
    expect(repository, contains("'admin_radio_mondo_upsert_v4'"));
    expect(repository, contains("'p_category_key': category.storageKey"));
    expect(admin, contains('DropdownButtonFormField<AdminRadioMondoCategory>'));
    expect(admin, contains("'Categoria musicale'"));
    expect(admin, contains('playPreviewStation(station)'));

    expect(migration, contains('add column if not exists category_key'));
    expect(migration, contains('radio_mondo_tracks_category_key_check'));
    expect(migration, contains('admin_radio_mondo_upsert_v4'));
    expect(migration, contains("'category_key', t.category_key"));
  });
}

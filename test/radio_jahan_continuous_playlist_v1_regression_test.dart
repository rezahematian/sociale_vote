import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Radio Jahan keeps category playlists and adds a global finite-audio mode',
      () {
    final service =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(service, contains('bool get isJahanMode => _jahanMode;'));
    expect(service, contains('List<RadioMondoStation> get jahanStations'));
    expect(service, contains('Future<void> selectJahan()'));
    expect(service, contains('station.jahanEnabled'));
    expect(
        service, contains('station.sourceType == RadioMondoSourceType.audio'));
    expect(service, contains('!station.isLive'));
    expect(service, contains("station.category == current.category"));
    // Keep this regression assertion formatting-insensitive: dart format may
    // split the ternary expression over multiple lines.
    expect(service, contains('final catalog = _jahanMode'));
    expect(service, contains('_jahanStationsFrom(_stations)'));

    expect(dock, contains("const Text('Radio Jahan')"));
    expect(dock, contains('radio.selectJahan()'));
    expect(dock, contains('radio.jahanStations'));
    expect(dock, contains('selected: !jahanMode && item == category'));
  });

  test('Admin can include tracks, exclude categories and reorder Radio Jahan',
      () {
    final entities = File('lib/domain/admin/entities/admin_entities.dart')
        .readAsStringSync();
    final repository = File(
      'lib/infrastructure/admin/repositories/admin_repository_impl.dart',
    ).readAsStringSync();
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();
    final migration = File(
      'supabase/migration/20261005101500_radio_jahan_continuous_playlist_v1.sql',
    ).readAsStringSync();

    expect(entities, contains('final bool jahanEnabled;'));
    expect(entities, contains('final int jahanOrder;'));
    expect(entities, contains('class AdminRadioJahanPlaylistItem'));

    expect(repository, contains("'admin_radio_mondo_set_jahan_playlist_v1'"));
    expect(repository, contains("'jahan_enabled'"));
    expect(repository, contains("'jahan_order'"));

    expect(admin, contains("const Text('Radio Jahan')"));
    expect(admin, contains('ReorderableListView.builder'));
    expect(admin, contains('onReorderItem:'));
    expect(admin, isNot(contains('onReorder:')));
    expect(admin, contains('FilterChip('));
    expect(
        admin, contains('track.sourceType == AdminRadioMondoSourceType.audio'));
    expect(admin, contains('!track.isLive'));
    expect(admin, contains('setRadioJahanPlaylist'));

    expect(migration, contains('add column if not exists jahan_enabled'));
    expect(migration, contains('add column if not exists jahan_order'));
    expect(migration, contains('admin_radio_mondo_set_jahan_playlist_v1'));
    expect(migration, contains("t.category_key <> 'sounds_atmospheres'"));
    expect(migration, contains("'jahan_enabled', t.jahan_enabled"));
    expect(migration, contains("'jahan_order', t.jahan_order"));
  });
}

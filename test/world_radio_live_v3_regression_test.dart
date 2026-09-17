import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart';
import 'package:sociale_vote/infrastructure/admin/repositories/admin_repository_impl.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';
import 'package:sociale_vote/shared/widgets/radio_mondo_dock.dart';

void main() {
  test('World Radio Live V3 enums and station metadata are available', () {
    expect(AdminRadioMondoSourceType.stream.storageKey, 'stream');
    expect(AdminRadioMondoChannelType.worldBrief.storageKey, 'world_brief');

    const station = RadioMondoStation(
      id: 'remote-test',
      title: 'World Live',
      audioUrl: 'https://example.com/live.mp3',
      sourceType: RadioMondoSourceType.stream,
      channelType: RadioMondoChannelType.liveEvent,
      languageCode: 'it',
      worldBriefId: '11339284-24fe-4142-b1a4-117010588d13',
      isDefault: true,
      isLive: true,
    );

    expect(station.sourceType, RadioMondoSourceType.stream);
    expect(station.channelType, RadioMondoChannelType.liveEvent);
    expect(station.isDefault, isTrue);
    expect(station.isLive, isTrue);
  });

  test('World Radio Live V3 source contracts stay additive', () {
    final service = File('lib/shared/services/radio_mondo_service.dart')
        .readAsStringSync();
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();
    final repo = File(
      'lib/infrastructure/admin/repositories/admin_repository_impl.dart',
    ).readAsStringSync();
    final dock = File('lib/shared/widgets/radio_mondo_dock.dart')
        .readAsStringSync();

    expect(service, contains('RadioMondoSourceType.stream'));
    expect(service, contains('ReleaseMode.stop'));
    expect(service, contains('isDefault'));
    expect(service, contains('isLive'));
    expect(admin, contains('World Brief collegato'));
    expect(admin, contains('Scegli il Brief per titolo'));
    expect(admin, contains('worldBriefs: worldBriefs'));
    expect(admin, contains('LIVE adesso'));
    expect(admin, contains('Stazione predefinita World Live'));
    expect(repo, contains('admin_radio_mondo_upsert_v3'));
    expect(dock, contains("'LIVE'"));

    // Compile-only references for the modified presentation/repository units.
    expect(AdminRadioMondoControlSection, isNotNull);
    expect(AdminRepositoryImpl, isNotNull);
    expect(RadioMondoDock, isNotNull);
  });

  test('World Radio Live V3 SQL exposes metadata and World Brief bridge', () {
    final sql = File(
      'supabase/migration/20260916123000_world_radio_live_v3.sql',
    ).readAsStringSync();

    for (final token in <String>[
      'source_type',
      'channel_type',
      'language_code',
      'world_brief_id',
      'is_default',
      'is_live',
      'admin_radio_mondo_upsert_v3',
      'radio_mondo_tracks_single_default_idx',
      'social_vote_world_briefs',
    ]) {
      expect(sql, contains(token), reason: token);
    }
  });
}

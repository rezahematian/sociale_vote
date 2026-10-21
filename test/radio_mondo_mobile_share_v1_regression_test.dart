import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/app/router.dart';

void main() {
  test('Mobile radio has one horizontal category rail and retains playback',
      () {
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();
    expect(dock, contains('scrollDirection: Axis.horizontal'));
    expect(dock, contains('if (jahanMode && !compact)'));
    expect(dock, contains('0.70 : 0.90'));
    expect(dock, contains('radio.playPrevious()'));
    expect(dock, contains('radio.playNext()'));
    expect(dock, contains('radio.setVolume(value)'));
    expect(dock, contains('RadioMondoTrackShare.share(station)'));
    expect(dock, isNot(contains('rpc(')));
  });

  test('Shared URLs resolve to public Radio Mondo startup routes', () {
    const stationId = 'remote-ec11b64c-12b2-4ae5-a5a1-92a388f474ce';
    final path = AppRouter.publicRadioTrackPath(stationId);
    final url = AppRouter.publicRadioTrackUrl(stationId);
    expect(path, '/radio/track/$stationId');
    expect(url, 'https://socialevote.com$path');
    expect(
      AppRouter.resolveStartupRoute(
        isWeb: true,
        webLocation: url,
        nativeDefaultRouteName: '/',
      ),
      path,
    );
    expect(
      AppRouter.resolveStartupRoute(
        isWeb: false,
        webLocation: '/',
        nativeDefaultRouteName: path,
      ),
      path,
    );
  });

  test('Links are per-track pages with no automatic audio playback', () {
    final router = File('lib/app/router.dart').readAsStringSync();
    final page = File(
            'lib/features/radio/presentation/pages/radio_mondo_track_page.dart')
        .readAsStringSync();
    final share = File('lib/shared/services/radio_mondo_track_share.dart')
        .readAsStringSync();
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(router, contains("'/radio/track/"));
    expect(router, contains('_publicRadioTrackId(routeName)'));
    expect(router, contains('_publicRadioTrackId(path)'));
    // R1 formatter FAIL: do not introduce a second return in the chain.
    expect(
        router, isNot(contains(RegExp(r'\|\|\s*return\s+_publicContentId'))));
    expect(page, contains('for (final item in radio.stations)'));
    expect(page, contains('radio.playStation(station)'));
    expect(page, isNot(contains('reloadCatalog()')));
    expect(page, isNot(contains('initialize()')));
    expect(share, contains('AppRouter.publicRadioTrackUrl(station.id)'));
    expect(share, isNot(contains('audioUrl')));
    expect(manifest, contains('android:pathPrefix="/radio/track/"'));
  });
}

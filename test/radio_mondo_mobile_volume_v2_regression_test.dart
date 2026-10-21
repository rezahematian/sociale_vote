import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compact mobile radio keeps volume on the playback row', () {
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(dock, contains('buildPlaybackControls(compactMobile: true)'));
    expect(dock, contains('compactMobile ? 38 : 46'));
    expect(dock, contains('compactMobile ? 44 : 54'));
    expect(
      dock,
      contains(RegExp(
        r'if \(constraints\.maxWidth < 560\)\s*\{\s*return Row\(',
      )),
    );
    expect(dock, contains('Expanded(child: buildTrackIdentity())'));
    expect(dock, contains('Icons.volume_off_rounded'));
    expect(dock, contains('Icons.volume_down_rounded'));
    expect(dock, contains('Icons.volume_up_rounded'));
    expect(dock, contains('showDialog<void>('));
    expect(dock, contains('radio.setVolume(value)'));
    expect(dock, contains('RadioMondoTrackShare.share(station)'));
    expect(dock, contains('scrollDirection: Axis.horizontal'));
    expect(dock, isNot(contains('rpc(')));
  });
}

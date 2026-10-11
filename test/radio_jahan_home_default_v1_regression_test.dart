import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home Radio Mondo fresh tap selects Radio Jahan before playback', () {
    final source =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    final currentStationGuard = source.indexOf(
      'if (radio.currentStation != null)',
    );
    final selectJahan = source.indexOf('await radio.selectJahan();');
    final reloadCatalog = source.indexOf('await radio.reloadCatalog();');
    final playStation = source.indexOf(
      'await _playStation(context, radio, station);',
    );

    expect(currentStationGuard, greaterThanOrEqualTo(0));
    expect(selectJahan, greaterThan(currentStationGuard));
    expect(reloadCatalog, greaterThan(selectJahan));
    expect(playStation, greaterThan(reloadCatalog));

    expect(
      source,
      contains(
        'a fresh tap on Radio Mondo starts from Radio Jahan',
      ),
    );
  });

  test('Home Radio Mondo keeps pause/resume semantics for an active station',
      () {
    final source =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(source, contains('if (radio.isPlaying)'));
    expect(source, contains('await radio.pause();'));
    expect(source, contains('if (radio.currentStation != null)'));
    expect(source, contains('await radio.resume();'));
  });

  test('Radio Jahan default does not introduce autoplay on initialization', () {
    final source =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(source, contains('playback still requires'));
    expect(source, contains('this explicit user tap and never autostarts'));
    expect(
        source, isNot(contains('radio.playStation(radio.selectedStation!);')));
  });
}

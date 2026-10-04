import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo picker V1.1 uses a compact responsive category layout', () {
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(dock, contains('maxWidth: wideSheet ? 760 : viewport.width'));
    expect(dock, contains('child: Wrap('));
    expect(dock, contains('showCheckmark: false'));
    expect(dock, contains('constraints.maxWidth < 560'));
    expect(dock, contains('foregroundColor: colors.onPrimary'));
    expect(dock, contains('Icons.close_rounded'));
    expect(dock, isNot(contains("' (\$count)'")));
  });

  test('Radio Mondo picker V1.1 preserves playlist controls and category scope',
      () {
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(dock, contains('radio.selectCategory(item)'));
    expect(dock, contains('radio.playPrevious()'));
    expect(dock, contains('radio.playNext()'));
    expect(dock, contains('radio.setVolume(value)'));
    expect(dock, contains('radio.stationsForCategory(category)'));
  });
}

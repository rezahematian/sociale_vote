import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo V1.2 R2 transport controls force visible icon colors', () {
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(dock, contains('Widget transportButton({'));
    expect(dock, contains('backgroundColor: colors.surfaceContainerHighest'));
    expect(dock, contains('foregroundColor: colors.onSurface'));
    expect(dock, contains('foregroundColor: colors.onPrimary'));
    expect(dock, contains('color: controlsEnabled'));
    expect(dock, contains('? colors.onSurface'));
    expect(dock, contains('? colors.onPrimary'));
    expect(dock, contains('width: 44'));
    expect(dock, contains('height: 44'));
    expect(dock, contains('width: 48'));
    expect(dock, contains('height: 48'));
    expect(dock, contains('Icons.skip_previous_rounded'));
    expect(dock, contains('Icons.play_arrow_rounded'));
    expect(dock, contains('Icons.skip_next_rounded'));
    expect(dock, contains('radio.playPrevious()'));
    expect(dock, contains('radio.playNext()'));
  });
}

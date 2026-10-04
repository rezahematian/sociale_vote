import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Radio Mondo V1.3 transport glyphs do not depend on Material transport icons',
      () {
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(dock, contains('Widget transportGlyph({'));
    expect(dock, contains("next ? '▶' : '◀'"));
    expect(dock, contains('Widget playPauseGlyph({'));
    expect(dock, contains("return Text("));
    expect(dock, contains("'▶'"));
    expect(dock, contains('foregroundColor: colors.onPrimary'));
    expect(dock, contains('radio.playPrevious()'));
    expect(dock, contains('radio.playNext()'));

    expect(dock, isNot(contains('Icons.skip_previous_rounded')));
    expect(dock, isNot(contains('Icons.play_arrow_rounded')));
    expect(dock, isNot(contains('Icons.skip_next_rounded')));
  });
}

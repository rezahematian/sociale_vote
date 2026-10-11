import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Jahan public transport glyphs are font independent', () {
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(
        dock, contains('class _TransportGlyphPainter extends CustomPainter'));
    expect(dock, contains('_TransportGlyph.previous'));
    expect(dock, contains('_TransportGlyph.play'));
    expect(dock, contains('_TransportGlyph.pause'));
    expect(dock, contains('_TransportGlyph.next'));

    expect(dock, isNot(contains('Icons.skip_previous_rounded')));
    expect(dock, isNot(contains('Icons.play_arrow_rounded')));
    expect(dock, isNot(contains('Icons.pause_rounded')));
    expect(dock, isNot(contains('Icons.skip_next_rounded')));
  });

  test('Radio Jahan admin drag and identity glyphs are font independent', () {
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();

    expect(
      admin,
      contains('class _JahanDragHandlePainter extends CustomPainter'),
    );
    expect(
      admin,
      contains('class _JahanInfinityGlyphPainter extends CustomPainter'),
    );
    expect(
      RegExp(r'_JahanDragHandlePainter\(').allMatches(admin).length,
      greaterThanOrEqualTo(3),
    );
    expect(
      RegExp(r'_JahanInfinityGlyphPainter\(').allMatches(admin).length,
      greaterThanOrEqualTo(2),
    );

    expect(admin, isNot(contains('Icons.drag_indicator_rounded')));
    expect(admin, isNot(contains('Icons.all_inclusive_rounded')));
  });

  test('Classical category keeps a stable visible fallback icon', () {
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(
      RegExp(r'RadioMondoCategory\.classical => Icons\.album,')
          .allMatches(dock)
          .length,
      2,
    );
    expect(dock, isNot(contains('Icons.piano_rounded')));
  });
}

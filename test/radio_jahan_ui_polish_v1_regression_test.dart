import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Jahan has a distinct player and visible controls', () {
    final dock =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();

    expect(
        dock, contains('class _TransportGlyphPainter extends CustomPainter'));
    expect(dock, contains('_TransportGlyph.previous'));
    expect(dock, contains('_TransportGlyph.play'));
    expect(dock, contains('_TransportGlyph.pause'));
    expect(dock, contains('_TransportGlyph.next'));
    expect(dock, contains('Icons.volume_up_rounded'));
    expect(dock, contains("'Ascolto continuo'"));
    expect(dock, contains('selectedTileColor:'));
    expect(dock, contains('selectedColor: colors.primaryContainer'));
    expect(dock, contains("'Radio Jahan · '"));
  });

  test('Admin catalog is grouped and Jahan reorder is explicit', () {
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();

    expect(admin, contains('FilledButton.tonalIcon'));
    expect(admin, contains('ExpansionTile('));
    expect(admin, contains('_adminCategoryIcon(category)'));
    expect(
      admin,
      contains('class _JahanDragHandlePainter extends CustomPainter'),
    );
    expect(
      admin,
      contains('class _JahanInfinityGlyphPainter extends CustomPainter'),
    );
    expect(admin, contains("'Trascina per riordinare'"));
    expect(admin, contains(r"'${index + 1}'"));
    expect(admin, contains('ReorderableDragStartListener'));
    expect(admin, contains('onReorderItem:'));
  });
}

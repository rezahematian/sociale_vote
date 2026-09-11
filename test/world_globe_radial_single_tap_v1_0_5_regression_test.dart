import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('radial preset buttons receive normal tap without parent dismiss race', () {
    final source = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    final pickerStart = source.indexOf('class _GlobeStyleRadialPicker');
    final buttonStart = source.indexOf('class _GlobeStyleRadialButton');

    expect(pickerStart, greaterThanOrEqualTo(0));
    expect(buttonStart, greaterThan(pickerStart));

    final picker = source.substring(pickerStart, buttonStart);

    // Dismiss is a background sibling, not a GestureDetector parent wrapping
    // all preset InkWells.
    expect(picker, contains('Positioned.fill('));
    expect(picker, contains('onTap: onDismiss'));
    expect(
      picker,
      contains('// detector receives only taps outside a preset.'),
    );

    // Each preset still has its ordinary one-tap selection handler.
    expect(
      picker,
      contains('onTap: () => onSelected(styles[index])'),
    );
    expect(picker, contains('child: _GlobeStyleRadialButton('));

    // The old competing parent structure must not return.
    expect(
      picker,
      isNot(contains(
        'child: GestureDetector(\n'
        '          behavior: HitTestBehavior.opaque,\n'
        '          onTap: onDismiss,\n'
        '          child: Stack(',
      )),
    );
  });
}

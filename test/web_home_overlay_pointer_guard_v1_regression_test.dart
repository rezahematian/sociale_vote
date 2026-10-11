import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Web Home overlays block Globe fall-through pointers', () {
    final source = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('bool _homeOverlayPointerBlocked = false;'),
    );
    expect(
      source,
      contains('Timer? _homeOverlayPointerReleaseTimer;'),
    );
    expect(
      RegExp(
        r'interactionEnabled:\s*!_radioPickerOpen\s*&&\s*'
        r'!_stylePickerOpen\s*&&\s*!_homeOverlayPointerBlocked,',
      ).hasMatch(source),
      isTrue,
    );

    expect(
      source,
      contains('onPointerDown: _handleHomeOverlayPointerDown'),
    );
    expect(
      source,
      contains('onPointerUp: _handleHomeOverlayPointerEnd'),
    );
    expect(
      source,
      contains('onPointerCancel: _handleHomeOverlayPointerEnd'),
    );

    // Radio and Rotate are both direct overlays above the HtmlElementView.
    expect(
      RegExp(r'onPointerDown:\s*_handleHomeOverlayPointerDown')
          .allMatches(source)
          .length,
      greaterThanOrEqualTo(2),
    );

    // The same-pointer time guard remains as a second line of defense.
    expect(
      source,
      contains('Duration(milliseconds: 420)'),
    );
  });

  test('existing Web picker and radial guards remain present', () {
    final source = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(source, contains('bool _radioPickerOpen = false;'));
    expect(source, contains('bool _stylePickerOpen = false;'));
    expect(source, contains('onPickerOpened: () {'));
    expect(source, contains('onPickerDismissed: () {'));
    expect(
      RegExp(r'onTap:\s*\(\)\s*=>\s*onSelected\(styles\[index\]\)')
          .hasMatch(source),
      isTrue,
    );
  });
}

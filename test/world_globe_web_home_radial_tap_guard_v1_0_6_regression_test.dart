import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Web Home radial selection cannot fall through to Civic Map', () {
    final source = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('DateTime? _suppressHomeSurfaceTapUntil;'),
    );
    expect(
      RegExp(
        r'_suppressHomeSurfaceTapUntil\s*=\s*DateTime\.now\(\)\.add\('
        r'const Duration\(milliseconds:\s*420\)\);',
      ).hasMatch(source),
      isTrue,
    );

    final surfaceTap = source.indexOf(
      'void _handleSurfaceTap(double latitude, double longitude)',
    );
    final openClassic = source.indexOf(
      'widget.onUseClassicMap();',
      surfaceTap,
    );
    final guard = source.indexOf(
      'if (_stylePickerOpen ||',
      surfaceTap,
    );
    final guardEnd = source.indexOf(
      'return;',
      guard,
    );

    expect(surfaceTap, greaterThanOrEqualTo(0));
    expect(guard, greaterThan(surfaceTap));
    expect(guardEnd, greaterThan(guard));
    expect(openClassic, greaterThan(guardEnd));

    final guardBlock = source.substring(guard, guardEnd + 'return;'.length);
    expect(guardBlock, contains('_stylePickerOpen'));
    expect(guardBlock, contains('suppressUntil != null'));
    expect(guardBlock, contains('DateTime.now().isBefore(suppressUntil)'));
  });

  test('radial preset remains a normal single-tap action', () {
    final source = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(
      RegExp(r'onTap:\s*\(\)\s*=>\s*onSelected\(styles\[index\]\)')
          .hasMatch(source),
      isTrue,
    );
  });
}

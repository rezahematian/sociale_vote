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
      source,
      contains(
        '_suppressHomeSurfaceTapUntil =\n'
        '          DateTime.now().add(const Duration(milliseconds: 420));',
      ),
    );
    expect(
      source,
      contains(
        'if (_stylePickerOpen ||\n'
        '          (suppressUntil != null &&\n'
        '              DateTime.now().isBefore(suppressUntil))) {\n'
        '        return;',
      ),
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

    expect(surfaceTap, greaterThanOrEqualTo(0));
    expect(guard, greaterThan(surfaceTap));
    expect(openClassic, greaterThan(guard));
  });

  test('radial preset remains a normal single-tap action', () {
    final source = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('onTap: () => onSelected(styles[index])'),
    );
  });
}

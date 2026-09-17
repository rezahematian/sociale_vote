import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('Home marker sheets use one root navigator and replace safely', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      RegExp(r'useRootNavigator:\s*true').allMatches(source).length,
      equals(2),
    );
    expect(
      RegExp(
        r'Navigator\.of\(existing,\s*rootNavigator:\s*true\)\.maybePop\(\)',
      ).allMatches(source).length,
      greaterThanOrEqualTo(4),
    );
    expect(
      RegExp(
        r'Navigator\.of\(sheetContext,\s*rootNavigator:\s*true\)\.pop\(\)',
      ).allMatches(source).length,
      equals(2),
    );
    expect(source, contains('Future<void> _replaceHomeMarkerModal('));
    expect(source, contains('if (_dismissHomeMarkerModal()) {'));
  });

  test('Civic Map 3D empty globe surface clears active preview', () {
    final globe = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );
    final page = _read(
      'lib/features/map/presentation/pages/civic_map_page.dart',
    );

    expect(globe, contains('final VoidCallback? onSurfaceTap;'));
    expect(globe, contains('this.onSurfaceTap,'));
    expect(
      RegExp(r'widget\.onSurfaceTap\?\.call\(\);').allMatches(globe).length,
      equals(2),
    );
    expect(page, contains('onSurfaceTap: controller.clearSelection,'));
  });

  test('Civic Map 2D clearSelection contract remains untouched', () {
    final source = _read(
      'lib/features/map/presentation/widgets/civic_map_widget.dart',
    );

    expect(source, contains('void _handleMapTap()'));
    expect(source, contains('widget.controller?.clearSelection();'));
    expect(source, contains('widget.controller?.selectItem(item);'));
  });
}

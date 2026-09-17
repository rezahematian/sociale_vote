import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('Web Civic Map grouped marker sheet is singleton', () {
    final source = _read(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    );

    expect(source, contains('BuildContext? _markerGroupModalContext;'));
    expect(source, contains('int _markerGroupModalTicket = 0;'));
    expect(source, contains('Future<void> _replaceMarkerGroupModal('));
    expect(source, contains('bool _dismissMarkerGroupModal()'));
    expect(
      source,
      contains('unawaited(_replaceMarkerGroupModal(group));'),
    );
  });

  test('Web group sheet uses root navigator and captures its context', () {
    final source = _read(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    );

    expect(source, contains('useRootNavigator: true'));
    expect(source, contains('onSheetBuilt?.call(sheetContext);'));
    expect(
      source,
      contains(
        'Navigator.of(existing, rootNavigator: true).maybePop()',
      ),
    );
  });

  test('Web outside surface tap closes group picker before forwarding', () {
    final source = _read(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    );

    expect(
      source,
      contains(
        'if (_dismissMarkerGroupModal()) {\n'
        '        return;\n'
        '      }\n\n'
        '      widget.onSurfaceTap(latitude, longitude);',
      ),
    );
    expect(
      source,
      contains('Duration(milliseconds: 360)'),
    );
  });

  test('Web single marker replaces an open group picker', () {
    final source = _read(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    );

    expect(
      source,
      contains(
        'final dismissedGroupPicker = _dismissMarkerGroupModal();',
      ),
    );
    expect(
      source,
      contains('widget.onMarkerTap(item);'),
    );
  });

  test('R5 Civic Map outside-card rule remains installed', () {
    final page = _read(
      'lib/features/map/presentation/pages/civic_map_page.dart',
    );

    expect(page, contains('child: TapRegion('));
    expect(
      page,
      contains('onTapOutside: (_) => controller.clearSelection(),'),
    );
  });
}

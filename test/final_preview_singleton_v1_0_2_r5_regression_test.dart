import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('Civic Map preview closes on any tap outside its card', () {
    final page = _read(
      'lib/features/map/presentation/pages/civic_map_page.dart',
    );

    expect(page, contains('child: TapRegion('));
    expect(
      page,
      contains('onTapOutside: (_) => controller.clearSelection(),'),
    );
    expect(page, contains('child: _MarkerPreviewCard('));
  });

  test('Civic Map native grouped marker picker cannot stack', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(source, contains('BuildContext? _exploreMarkerModalContext;'));
    expect(source, contains('Future<void> _replaceExploreMarkerModal('));
    expect(source, contains('bool _dismissExploreMarkerModal()'));
    expect(
      source,
      contains(
        '_replaceExploreMarkerModal(\n'
        '              (onSheetBuilt) => _showGlobeMarkerGroupPicker(',
      ),
    );
  });

  test('outside globe tap dismisses grouped picker before other action', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      source,
      contains(
        'if (_dismissExploreMarkerModal()) {\n'
        '      return;\n'
        '    }\n\n'
        '    widget.onSurfaceTap?.call();',
      ),
    );
  });

  test('single marker replaces an open grouped picker', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      source,
      contains(
        'final dismissedGroupPicker = _dismissExploreMarkerModal();',
      ),
    );
    expect(
      source,
      contains(
        'WidgetsBinding.instance.addPostFrameCallback((_) {\n'
        '              if (mounted) {\n'
        '                _handleGlobeMarkerTap(markerItem);',
      ),
    );
  });

  test('Home existing modal outside-dismiss contract remains present', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(source, contains('useRootNavigator: true'));
    expect(source, contains('if (_dismissHomeMarkerModal()) {'));
  });
}

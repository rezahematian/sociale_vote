import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('Home marker modal is single-instance and outside taps dismiss only', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(source, contains('BuildContext? _homeMarkerModalContext;'));
    expect(source, contains('int _homeMarkerModalTicket = 0;'));
    expect(source, contains('Future<void> _replaceHomeMarkerModal('));
    expect(source, contains('bool _dismissHomeMarkerModal()'));
    expect(source, contains('onSheetBuilt?.call(sheetContext);'));
    expect(source, contains('if (_dismissHomeMarkerModal()) {'));
    expect(source, contains('Duration(milliseconds: 360)'));
    expect(
      source,
      contains(
        '(markerVisualSize / 2) - group.visualOffset.dy',
      ),
      reason: 'native hit target must match the rendered marker center',
    );
  });

  test('Home native marker groups also replace the current Home modal', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      source,
      contains(
        '(onSheetBuilt) => _showGlobeMarkerGroupPicker(',
      ),
    );
    expect(source, contains('onSheetBuilt: onSheetBuilt'));
    expect(source, contains('if (!mounted || ticket != _homeMarkerModalTicket)'));
    expect(source, contains('_homeMarkerModalContext = null;'));
    expect(source, isNot(contains('identical(_homeMarkerModalContext, openedContext)')));
  });

  test('Voce phone header preserves publisher identity instead of truncating it', () {
    final source = _read(
      'lib/features/social/presentation/pages/post_detail_page.dart',
    );

    expect(source, contains('maxWidth: isCompact'));
    expect(source, contains('? constraints.maxWidth * 0.54'));
    expect(source, contains('FittedBox('));
    expect(source, contains('alignment: AlignmentDirectional.centerEnd'));
  });

  test('Vote result rows use restrained phone density without changing desktop', () {
    final source = _read(
      'lib/features/poll/presentation/pages/poll_detail_page.dart',
    );

    expect(
      source,
      contains('final isPhoneWidth = MediaQuery.sizeOf(context).width < 600;'),
    );
    expect(source, contains('minHeight: isPhoneWidth ? 52 : 68'));
    expect(source, contains('horizontal: isPhoneWidth ? 10 : 16'));
    expect(source, contains('vertical: isPhoneWidth ? 7 : 14'));
    expect(source, contains('size: isPhoneWidth ? 19 : 23'));
  });

  test('V1.0.12 nearest-center renderer fix remains installed', () {
    final source = _read(
      'third_party/flutter_earth_globe_social_vote/lib/rotating_globe.dart',
    );

    expect(source, contains('String? nearestPointId;'));
    expect(source, contains('var nearestDistanceSquared = double.infinity;'));
    expect(source, contains('return nearestPointId;'));
  });
}

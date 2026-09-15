import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('Home marker continuity refreshes on detail route return', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(source, contains('Timer? _homeRouteReturnWatchTimer;'));
    expect(source, contains('bool _homeRouteWasCovered = false;'));
    expect(source, contains('ModalRoute.of(context)?.isCurrent ?? true'));
    expect(source, contains('onOpen: _openHomeMarkerDetail,'));
    expect(source, contains('_lastNativeMarkerInputSignature = null;'));
    expect(source, contains('_syncGlobeContentPoints();'));
    expect(source, contains('_applyNativeRotationPolicy();'));
  });

  test('Home no longer runs passive marker-focus recovery while rotating', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(source, isNot(contains('_homeMarkerVisibilityCheckInterval')));
    expect(source, isNot(contains('_recoverHomeMarkersIfNeeded')));
    expect(source, isNot(contains('_homeMarkerHiddenGrace')));
    expect(source, isNot(contains('_homeMarkerRecoveryCooldown')));
    expect(source, isNot(contains('_homeMarkerVisibilityTimer')));
  });

  test('Globe geometry and Civic Map source contracts stay untouched', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      source,
      contains('_isHomeProfile ? 0.0080 : _nativeApprovedRotationSpeed'),
    );
    expect(source, contains('WorldHomeGlobeGeometry.frameSize'));
    expect(source, contains('WorldHomeGlobeGeometry.sphereDiameter'));
  });
}

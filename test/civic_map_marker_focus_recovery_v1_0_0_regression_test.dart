import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('native marker focus is temporary and refreshes marker labels', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      source,
      contains('refreshMarkersBeforeRecovery = false'),
    );
    expect(
      source,
      contains('refreshMarkersBeforeRecovery: true'),
    );
    expect(
      source,
      contains('delay: const Duration(milliseconds: 740)'),
    );
    expect(source, contains('_lastNativeMarkerInputSignature = null'));
    expect(source, contains('_syncGlobeContentPoints();'));
    expect(
      source,
      contains('if (!_shouldNativeAutoRotate) {\n        return;'),
      reason: 'marker refresh must still run when auto-rotation is disabled',
    );
  });

  test('Web marker focus requests natural-rotation recovery', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );
    final surface = _read(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    );
    final stub = _read(
      'lib/features/map/presentation/widgets/web_world_globe_surface_stub.dart',
    );

    expect(source, contains('recoverToNaturalRotation: true'));
    expect(source, contains('recoveryHoldMs: 260'));
    expect(surface, contains('final bool recoverToNaturalRotation'));
    expect(surface, contains('final int recoveryHoldMs'));
    expect(
      surface,
      contains("'recoverToNaturalRotation': focus.recoverToNaturalRotation"),
    );
    expect(surface, contains("'recoveryHoldMs': focus.recoveryHoldMs"));
    expect(stub, contains('final bool recoverToNaturalRotation'));
  });

  test('Web Globe marker focus returns to natural rotation safely', () {
    final source = _read('web/social_vote_globe.js');

    expect(
      source,
      contains('focus.recoverToNaturalRotation === true'),
    );
    expect(
      source,
      contains('recoveryToken !== this._naturalSettleToken'),
      reason: 'manual interaction must cancel pending marker recovery',
    );
    expect(source, contains('this._settleToNaturalRotation();'));
    expect(
      source,
      contains('Math.min(window.devicePixelRatio || 1, 2.0)'),
      reason: 'keep the approved desktop/Web DPR contract',
    );
    expect(source, contains("powerPreference: 'default'"));
  });

  test('country surface selection remains disabled', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      source,
      contains('static const bool _enableCountrySurfaceSelection = false'),
    );
  });
}

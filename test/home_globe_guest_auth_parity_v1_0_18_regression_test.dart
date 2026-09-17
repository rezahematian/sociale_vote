import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test(
      'native Home uses one interaction path for Guest and authenticated users',
      () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(source, isNot(contains('_isHomeProfile && !isAuthenticated')));
    expect(source, isNot(contains('IgnorePointer(child: globe)')));
    expect(source, contains('onPointerDown: _handleHomePointerDown'));
    expect(source, contains('onPointerUp: _handleHomePointerUp'));
    expect(source, contains('final markerHandled = _tryHandleHomeMarkerTap'));
    expect(source, contains('if (_dismissHomeMarkerModal()) {'));
    expect(source, contains('widget.onUseClassicMap();'));
  });

  test('Home marker tap keeps priority over Civic Map handoff', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    final markerIndex = source.indexOf(
      'final markerHandled = _tryHandleHomeMarkerTap(tapGlobalPosition);',
    );
    final civicIndex = source.indexOf('widget.onUseClassicMap();', markerIndex);

    expect(markerIndex, greaterThanOrEqualTo(0));
    expect(civicIndex, greaterThan(markerIndex));
    expect(
      source.substring(markerIndex, civicIndex),
      contains('if (!markerHandled)'),
    );
  });

  test('Web Home does not lock interaction based on authentication', () {
    final source = _read('web/social_vote_globe.js');

    expect(
      source,
      contains('Home globe interaction is intentionally identical for Guest'),
    );
    expect(
      source,
      contains('''_guestHomeIsReadOnly() {\n    // Home globe interaction'''),
    );
    expect(
      source,
      contains('''    return false;\n  }'''),
    );
    expect(source, contains("'socialvote-marker-tap'"));
    expect(source, contains("'socialvote-surface-tap'"));
  });
}

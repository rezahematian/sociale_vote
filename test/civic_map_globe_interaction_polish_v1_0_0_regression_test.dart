import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('Civic Map enables Radio on the shared Globe surface', () {
    final source = _read(
      'lib/features/map/presentation/pages/civic_map_page.dart',
    );

    expect(source, contains('showHomeRadioControl: true'));
    expect(source, contains('radioVisualStyle: appearance.radioStyle'));
  });

  test('Explore remains centered while narrow Home uses centered presentation geometry', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(source, contains('_exploreMaxViewport = 820.0'));
    expect(
      source,
      contains(
        'alignment: _isHomeProfile && !narrowHome'
        '\n              ? Alignment.topCenter : Alignment.center',
      ),
    );
    expect(source, contains('final inset = _isHomeProfile ? 12.0 : 8.0'));
  });

  test('bare Explore globe tap no longer activates country identification', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      source,
      contains('static const bool _enableCountrySurfaceSelection = false'),
    );
    expect(
      source,
      contains('if (_enableCountrySurfaceSelection) {\n      _resolveCountryFromTap'),
    );
    expect(
      source,
      contains('if (_enableCountrySurfaceSelection) {\n      final coordinates ='),
    );
  });

  test('marker tap receives the former focus animation on Web and native', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      source,
      contains('_focusNotifier.value = WebGlobeFocus(\n      latitude: item.latitude'),
    );
    expect(source, contains('distance: _countryFocusDistance'));
    expect(
      source,
      contains('GlobeCoordinates(item.latitude, item.longitude)'),
    );
    expect(source, contains('duration: _countryFocusDuration'));
  });

  test('native Social Vote markers have expanded touch targets only', () {
    final source = _read(
      'third_party/flutter_earth_globe_social_vote/lib/rotating_globe.dart',
    );

    expect(
      source,
      contains("point.id.startsWith('social-vote:') ? 34.0 : 18.0"),
    );
    expect(source, contains('width: scaledSize * 2 + markerHitPadding'));
    expect(source, contains('height: scaledSize * 2 + markerHitPadding'));
  });

  test('Web Explore markers are slightly larger without changing Home marker scale', () {
    final source = _read('web/social_vote_globe.js');

    expect(
      source,
      contains("this._config.profile === 'home' ? 0.118 : 0.132"),
    );
    expect(source, contains('const scale = markerScaleBase * sizeFactor'));
    expect(
      source,
      contains('Math.min(window.devicePixelRatio || 1, 2.0)'),
      reason: 'keep the approved Web renderer DPR contract',
    );
    expect(source, contains("powerPreference: 'default'"));
  });
}

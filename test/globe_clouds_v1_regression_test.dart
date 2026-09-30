import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';

void main() {
  test('Globe Clouds V2 keeps Earth exact and uses independent cloud layer',
      () {
    for (final style in WorldAppearanceService.selectableGlobeStyles) {
      final preset = GlobePresetVisual.forStyle(style);

      // V2 must never replace the approved Earth texture.
      expect(preset.assetForClouds(enabled: false), preset.asset);
      expect(preset.assetForClouds(enabled: true), preset.asset);

      final webOff = preset.webAppearance(style.name);
      final webOn = preset.webAppearance(
        style.name,
        cloudsEnabled: true,
        cloudDensity: 0.42,
        cloudSpeed: 0.22,
        cloudDirection: -1,
      );

      expect(webOff['textureUrl'], 'assets/${preset.asset}');
      expect(webOn['textureUrl'], 'assets/${preset.asset}');

      final offClouds = webOff['clouds']! as Map<String, Object?>;
      final onClouds = webOn['clouds']! as Map<String, Object?>;
      expect(offClouds['enabled'], isFalse);
      expect(onClouds['enabled'], isTrue);
      expect(
        onClouds['textureUrl'],
        'assets/${GlobePresetVisual.cloudLayerAsset}',
      );
      expect(onClouds['density'], 0.42);
      expect(onClouds['speed'], 0.22);
      expect(onClouds['direction'], -1);
    }

    expect(File(GlobePresetVisual.cloudLayerAsset).existsSync(), isTrue);
  });

  test('Globe Clouds V2 remains backend-authoritative and independently moving',
      () {
    final service = File('lib/shared/services/globe_clouds_service.dart')
        .readAsStringSync();
    final globe = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();
    final webGlobe = File('web/social_vote_globe.js').readAsStringSync();
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(
      service,
      contains(
        "static const String _adminSetRpc = 'admin_set_globe_clouds_enabled'",
      ),
    );
    expect(
      service,
      contains(
        "static const String _adminSetProfileRpc = 'admin_set_globe_cloud_profile'",
      ),
    );
    expect(service, contains('bool _enabled = false;'));
    expect(service, contains('int _densityPercent = 42;'));
    expect(service, contains('int _speedPercent = 22;'));
    expect(service, contains('int _direction = 1;'));

    // Public surfaces remain backend-authoritative by default. Admin preview
    // overrides are nullable/local-only and fall back to GlobeCloudsService.
    expect(
        globe,
        contains(
            'final GlobeCloudsService _clouds = GlobeCloudsService.instance;'));
    expect(globe, contains('widget.cloudsEnabledOverride ?? _clouds.enabled'));
    expect(globe, contains('widget.cloudDensityOverride ?? _clouds.density'));
    expect(globe, contains('widget.cloudSpeedOverride ?? _clouds.speed'));
    expect(
        globe, contains('widget.cloudDirectionOverride ?? _clouds.direction'));
    expect(globe, contains('cloudsEnabled: _effectiveCloudsEnabled'));
    expect(globe, contains('cloudDensity: _effectiveCloudDensity'));
    expect(globe, contains('_cloudRotationOffset'));

    expect(webGlobe, contains('_createCloudLayer()'));
    expect(webGlobe, contains('_loadCloudTexture()'));
    expect(webGlobe, contains('this._cloudLayer.rotation.y +='));

    expect(admin, contains('buildGlobeCloudsControl()'));
    expect(admin, contains("it: 'Nuvole Globe'"));
    expect(admin, contains("it: 'Copertura nuvole'"));
    expect(admin, contains("it: 'Velocità nuvole'"));
    expect(admin, contains("it: 'Direzione nuvole'"));
  });
}

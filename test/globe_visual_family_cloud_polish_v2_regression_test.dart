import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';

void main() {
  test('six Globe presets keep stable IDs and distinct Earth visual profiles',
      () {
    const styles = WorldAppearanceService.selectableGlobeStyles;
    expect(styles, hasLength(6));

    final earthSignatures = <String>{};
    for (final style in styles) {
      final preset = GlobePresetVisual.forStyle(style);
      earthSignatures.add([
        preset.asset,
        preset.atmosphereRgb,
        preset.atmosphereOpacity,
        preset.lightAngle,
        preset.lightIntensity,
        preset.ambientLight,
        preset.webEmissiveIntensity,
        preset.webShininess,
        preset.webAmbientIntensity,
        preset.webHemisphereIntensity,
        preset.webSunIntensity,
        preset.webSunRgb,
      ].join('|'));
    }

    expect(earthSignatures, hasLength(6));
    expect(styles.map((style) => GlobePresetVisual.forStyle(style).code),
        ['A', 'B', 'C', 'D', 'E', 'F']);
    expect(styles.map((style) => GlobePresetVisual.forStyle(style).name), [
      'Natural',
      'Relief',
      'Civic Blue',
      'Elias',
      'Elena',
      'Satellite',
    ]);
  });

  test('all six presets use one neutral Natural cloud profile', () {
    const styles = WorldAppearanceService.selectableGlobeStyles;
    final natural = GlobePresetVisual.forStyle(GlobeVisualStyle.classic);

    expect(natural.cloudTintRgb, 0xF7FBFF);
    expect(natural.cloudEmissiveRgb, 0xF7FBFF);
    expect(natural.cloudEmissiveIntensity, 0.18);
    expect(natural.cloudOpacityMin, 0.42);
    expect(natural.cloudOpacityMax, 0.82);
    expect(natural.cloudThresholdSparse, 0.82);
    expect(natural.cloudThresholdDense, 0.12);
    expect(natural.cloudShellScale, 1.008);

    final signature = [
      natural.cloudTintRgb,
      natural.cloudEmissiveRgb,
      natural.cloudEmissiveIntensity,
      natural.cloudOpacityMin,
      natural.cloudOpacityMax,
      natural.cloudThresholdSparse,
      natural.cloudThresholdDense,
      natural.cloudShellScale,
    ].join('|');

    for (final style in styles) {
      final preset = GlobePresetVisual.forStyle(style);
      expect(
          [
            preset.cloudTintRgb,
            preset.cloudEmissiveRgb,
            preset.cloudEmissiveIntensity,
            preset.cloudOpacityMin,
            preset.cloudOpacityMax,
            preset.cloudThresholdSparse,
            preset.cloudThresholdDense,
            preset.cloudShellScale,
          ].join('|'),
          signature);
    }
  });

  test('Elena keeps violet only in atmosphere while clouds stay Natural', () {
    final preset = GlobePresetVisual.forStyle(GlobeVisualStyle.techNeon);
    final appearance = preset.webAppearance(
      GlobeVisualStyle.techNeon.name,
      cloudsEnabled: true,
      cloudDensity: 1.0,
      cloudSpeed: 0.35,
      cloudDirection: -1,
    );
    final material = appearance['material']! as Map<String, Object?>;
    final clouds = appearance['clouds']! as Map<String, Object?>;

    expect(material['color'], 0xFFFFFF);
    expect(material['atmosphereColor'], 0x9B7BFF);
    expect(clouds['tintColor'], 0xF7FBFF);
    expect(clouds['emissiveColor'], 0xF7FBFF);
    expect(clouds['emissiveIntensity'], 0.18);
    expect(clouds['opacityMin'], 0.42);
    expect(clouds['opacityMax'], 0.82);
    expect(clouds['thresholdSparse'], 0.82);
    expect(clouds['thresholdDense'], 0.12);

    // Admin/backend values remain authoritative. The shared profile controls
    // only how coverage is rendered, not the saved coverage/speed/direction.
    expect(clouds['density'], 1.0);
    expect(clouds['speed'], 0.35);
    expect(clouds['direction'], -1);
  });

  test('Web and native coverage endpoints stay aligned', () {
    final web = File('web/social_vote_globe.js').readAsStringSync();
    final shader = File(
      'third_party/flutter_earth_globe_social_vote/shaders/sphere.frag',
    ).readAsStringSync();

    expect(web, contains("profileNumber('opacityMin', 0.42"));
    expect(web, contains("profileNumber('opacityMax', 0.82"));
    expect(web, contains("profileNumber('thresholdSparse', 0.82"));
    expect(web, contains("profileNumber('thresholdDense', 0.12"));

    expect(shader, contains('mix(0.82, 0.12, clamp(uCloudDensity'));
    expect(shader, contains('mix(0.42, 0.82, clamp(uCloudDensity'));
  });
}

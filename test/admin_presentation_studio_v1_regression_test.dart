import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Admin Presentation Studio groups live preview with visual controls',
      () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('Widget buildPresentationStudio(double width)'));
    expect(admin, contains("it: 'Anteprima live'"));
    expect(admin, contains("it: 'Studio presentazione'"));
    expect(admin, contains('SocialVoteHeaderBrand('));
    expect(admin, contains('buildMarkerDensityControl()'));
    expect(admin, contains('buildHeaderBrandModeControl()'));
    expect(admin, contains('buildGlobeCloudsControl()'));
    expect(admin, contains('cloudDensityOverride: cloudDensity'));
    expect(admin, contains('cloudSpeedOverride: cloudSpeed'));
    expect(admin, contains('cloudDirectionOverride: cloudDirection'));
  });

  test('Globe admin preview overrides do not replace public cloud defaults',
      () {
    final globe = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(globe, contains('final bool? cloudsEnabledOverride;'));
    expect(globe, contains('final double? cloudDensityOverride;'));
    expect(globe, contains('final double? cloudSpeedOverride;'));
    expect(globe, contains('final int? cloudDirectionOverride;'));
    expect(
      globe,
      contains('widget.cloudsEnabledOverride ?? _clouds.enabled'),
    );
    expect(
      globe,
      contains('widget.cloudDensityOverride ?? _clouds.density'),
    );
  });

  test('Header preview supports local flicker tuning without changing service',
      () {
    final brand = File(
      'lib/shared/widgets/social_vote_brand_lockup.dart',
    ).readAsStringSync();

    expect(brand, contains('final double? flickerIntensityOverride;'));
    expect(brand, contains('final double? flickerSpeedMultiplierOverride;'));
    expect(brand, contains('_effectiveFlickerIntensity'));
    expect(brand, contains('_effectiveFlickerSpeed'));
  });
}

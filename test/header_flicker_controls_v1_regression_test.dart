import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Header slider changes preserve the ongoing flicker cycle', () {
    final source = File(
      'lib/shared/widgets/social_vote_brand_lockup.dart',
    ).readAsStringSync();

    expect(source, contains('void _syncEffect({bool rebuild = false})'));
    expect(
        source, contains('final effectChanged = _configuredEffect != effect;'));
    expect(
        source,
        contains(
            'final intensityChanged = _lastFlickerIntensity != intensity;'));
    expect(
        source, contains('final speedChanged = _lastFlickerSpeed != speed;'));
    expect(source, contains('if (effectChanged) {'));
    expect(source, contains('_configureEffect(rebuild: rebuild);'));
    expect(source, contains('if (intensityChanged) {'));
    expect(source, contains('(_rawFlickerIntensity * intensity)'));
    expect(source, contains('if (speedChanged) {'));
    expect(source, contains('_scheduleNextFlicker();'));
    expect(source, contains('_rawFlickerIntensity = 1.0;'));
    expect(source, contains('_glowIntensity = _effectiveFlickerIntensity;'));
    expect(source, contains('step.delay.inMilliseconds / speed'));
    expect(
        source,
        contains(
            '_brandHeaderMode.addListener(_handleBrandHeaderModeChanged)'));
    expect(
        source,
        contains(
            '_brandHeaderMode.removeListener(_handleBrandHeaderModeChanged)'));
  });

  test('Admin slider profile remains backend-authoritative', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();
    final service = File(
      'lib/shared/services/brand_header_mode_service.dart',
    ).readAsStringSync();
    expect(admin, contains('_headerFlickerIntensityDraft = value;'));
    expect(admin, contains('_headerFlickerSpeedDraft = value;'));
    expect(admin, contains('setFlickerProfileFromAdmin('));
    expect(admin, contains('flickerIntensityOverride: headerIntensity / 100'));
    expect(
        admin, contains('flickerSpeedMultiplierOverride: headerSpeed / 100'));
    expect(service,
        contains("_adminSetProfileRpc = 'admin_set_header_flicker_profile'"));
    expect(service, contains('header_flicker_intensity'));
    expect(service, contains('header_flicker_speed'));
  });

  test('Web glow changes perceptibly while the base image stays mounted', () {
    final source = File(
      'lib/shared/widgets/social_vote_header_web_image_web.dart',
    ).readAsStringSync();
    expect(source,
        contains('if (oldWidget.glowIntensity != widget.glowIntensity)'));
    expect(source, contains("style.setProperty('filter', 'none')"));
    expect(source, contains('(0.46 * intensity)'));
    expect(source, contains('(0.30 * intensity)'));
    expect(source, contains('(1.0 + (0.34 * intensity))'));
    expect(source, contains('HtmlElementView.fromTagName('));
    expect(source, isNot(contains("display = 'none'")));
  });
}

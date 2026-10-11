import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Presentation Studio keeps three deliberate responsive modes', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('final ultraWide = width >= 1080;'));
    expect(admin, contains('final sideBySide = width >= 700;'));
    expect(admin, contains('final compact = width < 620;'));
    expect(admin, contains('? 280.0'));
    expect(admin, contains(': 330.0;'));
    expect(admin, contains('height: previewHeight'));
    expect(admin, contains('height: compact ? 42 : 50'));
    expect(admin, contains('height: compact ? 27 : 34'));
  });

  test('Wide cockpit keeps preview controls and operations together', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('Expanded(flex: 10, child: previewPanel())'));
    expect(admin, contains('Expanded(flex: 10, child: controlsPanel())'));
    expect(admin, contains('buildOperationalPanel(width * 0.27)'));
    expect(admin, contains('buildEgressModeControl()'));
    expect(admin, contains("it: 'Anteprima live'"));
    expect(admin, contains("it: 'Studio presentazione'"));
  });

  test('Presentation functionality remains intact in every mode', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('buildMarkerDensityControl()'));
    expect(admin, contains('buildHeaderBrandModeControl()'));
    expect(admin, contains('buildGlobeCloudsControl()'));
    expect(admin, contains('cloudDensityOverride: cloudDensity'));
    expect(admin, contains('cloudSpeedOverride: cloudSpeed'));
    expect(admin, contains('cloudDirectionOverride: cloudDirection'));
    expect(admin, contains('onChangeEnd:'));
    expect(admin, contains('_saveMarkerDensity'));
    expect(admin, contains('setProfileFromAdmin'));
  });
}

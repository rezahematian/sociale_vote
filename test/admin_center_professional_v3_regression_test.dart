import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('V3 moves medium screens into useful two-column workspace earlier', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('ADMIN_CENTER_PRO_V3'));
    expect(admin, contains('final ultraWide = width >= 1080;'));
    expect(admin, contains('final sideBySide = width >= 700;'));
    expect(admin, contains('final compact = width < 620;'));
    expect(admin, contains('final stageWidth = math.min('));
    expect(admin, contains('? 245.0'));
    expect(admin, contains('? 500.0'));
  });

  test('V3 compact preview recovers vertical space without removing preview',
      () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('? 280.0'));
    expect(admin, contains('height: compact ? 42 : 50'));
    expect(admin, contains('height: compact ? 27 : 34'));
    expect(admin, contains('mainAxisExtent: dense ? 54 : 64'));
    expect(admin, contains('vertical: compact ? 8 : 13'));
  });

  test('V3 compact studio exposes one control family at a time', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('int _adminPresentationCompactSection = 0;'));
    expect(admin, contains('SegmentedButton<int>'));
    expect(admin, contains("it: 'Marker'"));
    expect(admin, contains("it: 'Logo'"));
    expect(admin, contains("it: 'Nuvole'"));
    expect(admin, contains('switch (_adminPresentationCompactSection)'));
    expect(admin, contains('0 => buildMarkerDensityControl()'));
    expect(admin, contains('1 => buildHeaderBrandModeControl()'));
    expect(admin, contains('_ => buildGlobeCloudsControl()'));
  });

  test('V3 keeps module launcher extensible while compacting narrow cards', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('final destinations = _destinationsFor(context)'));
    expect(admin,
        contains('final compact = MediaQuery.sizeOf(context).width < 620;'));
    expect(admin, contains('mainAxisExtent: compact ? 62 : 76'));
    expect(admin, contains('itemCount: destinations.length'));
  });
}

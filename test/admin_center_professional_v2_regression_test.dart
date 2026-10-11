import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('V2 marker budget contract remains direct and backend compatible', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('WorldMarkerPolicyService.maxHomeMarkerBudget'));
    expect(admin, contains('int densityForBudget(int budget)'));
    expect(admin, contains('value: effectiveBudget.toDouble()'));
    expect(admin, contains('max: maxBudget.toDouble()'));
    expect(admin, contains('divisions: maxBudget'));
    expect(admin, contains('densityForBudget(value.round())'));
    expect(admin, contains(r"'$effectiveBudget / $maxBudget'"));
  });

  test('Professional Admin keeps wide canvas and data driven module policy',
      () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(
        admin, contains('constraints: const BoxConstraints(maxWidth: 1760)'));
    expect(
      admin,
      contains('showModuleGrid = constraints.maxWidth < _desktopBreakpoint'),
    );
    expect(admin, contains('final destinations = _destinationsFor(context)'));
    expect(admin, contains('final ultraWide = width >= 1080;'));
  });

  test('Professional controls preserve presentation backend hooks', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('showRotationControl: false'));
    expect(admin, contains('VisualDensity.compact'));
    expect(admin, contains('trackHeight: 2.5'));
    expect(admin, contains('_worldMarkerPolicy.setMarkerDensityFromAdmin'));
    expect(admin, contains('service.setFlickerProfileFromAdmin'));
    expect(admin, contains('service.setProfileFromAdmin'));
    expect(admin, contains('_saveEgressMode'));
  });
}

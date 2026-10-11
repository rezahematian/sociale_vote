import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Admin Center Professional keeps preview controls out of the globe', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();
    final globe = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(admin, contains('showRotationControl: false'));
    expect(admin, contains('Icons.refresh_rounded'));
    expect(globe, contains('final bool showRotationControl;'));
    expect(globe, contains('this.showRotationControl = true'));
    expect(globe, contains('widget.showRotationControl &&'));
  });

  test('Admin Center Professional uses a dense professional hierarchy', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('colors.surfaceContainerLowest'));
    expect(admin, contains("it: 'Panoramica'"));
    expect(admin, contains("it: 'Workspace visuale'"));
    expect(admin, contains("it: 'Operazioni e salute'"));
    expect(admin, contains("it: 'Moduli amministrativi'"));
    expect(
        admin, contains('constraints: const BoxConstraints(maxWidth: 1760)'));
    expect(
      admin,
      contains('showModuleGrid = constraints.maxWidth < _desktopBreakpoint'),
    );
  });

  test('Admin module launcher remains data driven and extendable', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('final destinations = _destinationsFor(context)'));
    expect(
      admin,
      contains('destination.section != AdminCenterSection.dashboard'),
    );
    expect(admin, contains('itemCount: destinations.length'));
    expect(admin, contains('final destination = destinations[index];'));
    expect(admin, contains('_selectSection(destination.section)'));
  });

  test('Presentation Studio persistence and backend hooks stay unchanged', () {
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(admin, contains('cloudDensityOverride: cloudDensity'));
    expect(admin, contains('cloudSpeedOverride: cloudSpeed'));
    expect(admin, contains('cloudDirectionOverride: cloudDirection'));
    expect(admin, contains('_saveMarkerDensity'));
    expect(admin, contains('setProfileFromAdmin'));
    expect(admin, contains('_saveEgressMode'));
  });
}

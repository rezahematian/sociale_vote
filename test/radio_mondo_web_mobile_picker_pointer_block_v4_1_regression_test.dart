import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio picker blocks Home Web Globe pointer events', () {
    final radio = File(
      'lib/shared/widgets/radio_mondo_dock.dart',
    ).readAsStringSync();

    final globe = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    final stub = File(
      'lib/features/map/presentation/widgets/web_world_globe_surface_stub.dart',
    ).readAsStringSync();

    final web = File(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    ).readAsStringSync();

    expect(radio, contains('final VoidCallback? onPickerOpened;'));
    expect(radio, contains('final VoidCallback? onPickerDismissed;'));
    expect(radio, contains('onPickerOpened?.call();'));
    expect(radio, contains('onPickerDismissed?.call();'));

    final opened = radio.indexOf('onPickerOpened?.call();');
    final modal = radio.indexOf(
      'showModalBottomSheet<RadioMondoStation>',
    );
    final dismissed = radio.indexOf('onPickerDismissed?.call();');

    expect(opened, greaterThanOrEqualTo(0));
    expect(modal, greaterThan(opened));
    expect(dismissed, greaterThan(modal));

    expect(globe, contains('bool _radioPickerOpen = false;'));
    expect(
      globe,
      contains('interactionEnabled: !_radioPickerOpen'),
    );
    expect(globe, contains('onPickerOpened: () {'));
    expect(globe, contains('onPickerDismissed: () {'));

    // Both conditional implementations must expose the same API.
    expect(stub, contains('final bool interactionEnabled;'));
    expect(stub, contains('this.interactionEnabled = true'));

    expect(web, contains('final bool interactionEnabled;'));
    expect(web, contains('this.interactionEnabled = true'));
    expect(web, contains('_applyInteractionEnabled();'));
    expect(web, contains("'pointer-events'"));
    expect(
      web,
      contains("widget.interactionEnabled ? 'auto' : 'none'"),
    );
    expect(
      web,
      contains('PlatformViewHitTestBehavior.transparent'),
    );
  });
}

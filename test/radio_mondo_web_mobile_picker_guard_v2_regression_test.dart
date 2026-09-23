import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo Web picker closes behind a Home surface-tap guard', () {
    final radio =
        File('lib/shared/widgets/radio_mondo_dock.dart').readAsStringSync();
    final globe = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(radio, contains('final VoidCallback? onPickerClosed;'));
    expect(radio, contains('this.onPickerClosed,'));
    expect(radio, contains('onPickerClosed?.call();'));

    // V3: the guard must already be armed BEFORE Navigator.pop removes
    // the station picker, otherwise mobile Web can click through to the
    // HtmlElementView globe and open Civic Map.
    final stationPop = radio.indexOf('Navigator.pop(sheetContext, station)');
    final prePopGuard =
        radio.lastIndexOf('onPickerClosed?.call();', stationPop);
    final postCloseGuard =
        radio.indexOf('onPickerClosed?.call();', stationPop + 1);

    expect(stationPop, greaterThanOrEqualTo(0));
    expect(prePopGuard, greaterThanOrEqualTo(0));
    expect(prePopGuard, lessThan(stationPop));
    expect(postCloseGuard, greaterThan(stationPop));
    expect(
      'onPickerClosed?.call();'.allMatches(radio).length,
      greaterThanOrEqualTo(2),
    );

    final pickerClosed = radio.indexOf('onPickerClosed?.call();');
    final playSelected = radio.indexOf(
      'if (selected != null && context.mounted)',
    );
    expect(pickerClosed, greaterThanOrEqualTo(0));
    expect(playSelected, greaterThan(pickerClosed));

    expect(globe, contains('onPickerClosed: () {'));
    expect(
      globe,
      contains('_suppressHomeSurfaceTapUntil = DateTime.now().add('),
    );
    expect(globe, contains('const Duration(milliseconds: 420)'));

    // Native RadioMondoDock remains unguarded: this fix is intentionally
    // scoped to the Web HtmlElementView click-through path only.
    expect('onPickerClosed: () {'.allMatches(globe).length, 1);
  });
}

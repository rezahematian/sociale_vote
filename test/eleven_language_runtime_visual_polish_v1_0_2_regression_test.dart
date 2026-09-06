import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('desktop Home reserves enough vertical space for dual-line signatures', () {
    final source = File(
      'lib/features/home/presentation/pages/public_home_screen.dart',
    ).readAsStringSync();

    expect(source, contains('height: 600,'));
    expect(source, contains('child: HomeWebWorldPanel('));
    expect(source, isNot(contains('height: 560,')));
  });
}

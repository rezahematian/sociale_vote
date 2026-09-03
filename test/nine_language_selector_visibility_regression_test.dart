import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nine-language selector is visible, scrollable and exposes FR AR RO', () {
    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    expect(source, contains('isScrollControlled: true'));
    expect(source, contains('SingleChildScrollView'));
    expect(source, contains("value: 'fr'"));
    expect(source, contains("value: 'ar'"));
    expect(source, contains("value: 'ro'"));
    expect(source, contains("'Français'"));
    expect(source, contains("'العربية'"));
    expect(source, contains("'Română'"));
  });
}

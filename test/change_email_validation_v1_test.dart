import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/profile/presentation/pages/change_email_page.dart';

void main() {
  test('change email accepts a distinct valid address', () {
    expect(validateAccountEmailChange('old@gmail.com', 'new@hotmail.com'),
        ChangeEmailInputStatus.valid);
  });
  test('change email rejects same email regardless of casing', () {
    expect(validateAccountEmailChange('Old@Gmail.com', ' old@gmail.COM '),
        ChangeEmailInputStatus.unchanged);
  });
  test('change email rejects invalid or missing address', () {
    for (final candidate in ['', 'hello', 'bad@', 'bad @example.com']) {
      expect(validateAccountEmailChange('old@gmail.com', candidate),
          ChangeEmailInputStatus.invalid);
    }
  });
}

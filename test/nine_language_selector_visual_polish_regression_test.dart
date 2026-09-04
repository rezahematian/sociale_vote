import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_profile_page.dart'
    as profile_page;

void main() {
  test('language selector compiles and keeps a stable visual row contract', () {
    const Type pageType = profile_page.MyProfilePage;
    expect(pageType.toString(), 'MyProfilePage');

    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    expect(source, contains('isScrollControlled: true'));
    expect(source, contains('SingleChildScrollView'));
    expect(source, contains('textDirection: TextDirection.ltr'));
    expect(source, contains('controlAffinity: ListTileControlAffinity.leading'));
    expect(source, contains("label: 'Italiano'"));
    expect(source, contains("label: 'English'"));
    expect(source, contains("label: 'Deutsch'"));
    expect(source, contains("label: 'فارسی'"));
    expect(source, contains("label: 'Español'"));
    expect(source, contains("label: 'Português'"));
    expect(source, contains("label: 'Français'"));
    expect(source, contains("label: 'العربية'"));
    expect(source, contains("label: 'Română'"));
    expect(source, contains("label: 'Русский'"));
    expect(source, contains("label: '中文（简体）'"));
    expect(source, contains("code: 'FA'"));
    expect(source, contains("code: 'AR'"));
    expect(source, contains("code: 'RU'"));
    expect(source, contains("code: 'ZH'"));
    expect(source, contains('textAlign: TextAlign.left'));
  });
}

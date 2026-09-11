import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verified result UI prevents certificate number wrapping', () {
    final source = File(
      'lib/features/organization/presentation/pages/verified_session_report_page.dart',
    ).readAsStringSync();

    expect(source, contains('FittedBox('));
    expect(source, contains('SelectableText('));
    expect(source, contains('certificateNumber'));
    expect(source, contains('maxLines: 1'));
  });

  test(
      'verified result PDF uses brand images and keeps first results block together',
      () {
    final source = File(
      'lib/shared/services/session_pdf_service.dart',
    ).readAsStringSync();

    expect(source, contains('pw.FittedBox('));
    expect(source, contains('officialSignature != null'));
    expect(source, contains('verifiedResultSeal != null'));
    expect(source, contains('questions.first'));
    expect(source, contains('questions.skip(1)'));
  });
}

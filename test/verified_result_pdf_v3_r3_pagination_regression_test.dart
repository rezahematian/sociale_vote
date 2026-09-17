import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('V3 R3 keeps the final integrity unit together but compact enough', () {
    final source = File(
      'lib/shared/services/session_pdf_service.dart',
    ).readAsStringSync();

    final resultsStart = source.indexOf('pw.NewPage()');
    final integrityStart = source.indexOf(
      'l10n.verifiedCertificateIntegritySection',
      resultsStart,
    );
    final integrityEnd = source.indexOf(
      'return document.save();',
      integrityStart,
    );

    expect(resultsStart, greaterThanOrEqualTo(0));
    expect(integrityStart, greaterThan(resultsStart));
    expect(integrityEnd, greaterThan(integrityStart));

    final integrity = source.substring(integrityStart - 220, integrityEnd);

    // Preserve the final block as one logical unit so long reports move the
    // whole integrity panel to the next page instead of leaving orphan notes.
    expect(integrity, contains('pw.Inseparable('));

    // R3 only recovers vertical space inside the final integrity unit.
    expect(integrity, contains('padding: const pw.EdgeInsets.all(10)'));
    expect(integrity, contains('pw.SizedBox(height: 6)'));
    expect(integrity, contains('pw.SizedBox(height: 4)'));
    expect(integrity, contains('pw.SizedBox(height: 2)'));

    // Readability invariants: QR and SHA-256 remain at the accepted sizes.
    expect(integrity, contains('width: 98'));
    expect(integrity, contains('height: 98'));
    expect(integrity, contains('fontSize: 7.6'));

    // The legal/integrity notes remain inside the same final unit.
    expect(integrity, contains('l10n.verifiedResultGeneratedBy'));
    expect(integrity, contains('l10n.verifiedResultNotLegalCertificate'));
  });

  test('V3 R3 does not re-compress the accepted question layout or header', () {
    final source = File(
      'lib/shared/services/session_pdf_service.dart',
    ).readAsStringSync();

    final questionStart = source.indexOf('static pw.Widget _questionBlock');
    final questionEnd = source.indexOf(
      'static pw.Widget _integrityLine',
      questionStart,
    );
    final question = source.substring(questionStart, questionEnd);

    expect(question, contains('padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8)'));
    expect(question, contains('pw.SizedBox(height: 12)'));
    expect(question, contains('pw.Inseparable('));

    // Keep the extra breathing room under page 2+ mini-header introduced in R2.
    expect(source, contains('padding: const pw.EdgeInsets.only(bottom: 16)'));

    // Keep the canonical language / Unicode work from R2 intact.
    expect(source, contains("report.snapshot['report_language']"));
    expect(source, contains('PdfGoogleFonts.notoSansSCRegular()'));
    expect(source, contains('PdfGoogleFonts.notoSansArabicRegular()'));
    expect(source, contains('voteCountLabel'));
  });
}

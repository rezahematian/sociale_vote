import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verified Result PDF V3 R2 keeps pagination dynamic and readable', () {
    final source = File(
      'lib/shared/services/session_pdf_service.dart',
    ).readAsStringSync();

    expect(source, contains('static Future<Uint8List> buildVerifiedReportPdf'));
    expect(source, contains('pw.NewPage()'));
    expect(source, contains('pw.Inseparable('));
    expect(source, contains('width: 98'));
    expect(source, contains('height: 98'));
    expect(source, contains('fontSize: 7.6'));
    expect(source, contains('pw.SizedBox(height: 16)'));
    expect(source, contains('height: 112'));
    expect(source, contains('SessionPdfService')); // stable marker for source scan

    final questionStart = source.indexOf('static pw.Widget _questionBlock');
    final questionEnd = source.indexOf(
      'static pw.Widget _integrityLine',
      questionStart,
    );
    final questionBlock = source.substring(questionStart, questionEnd);
    expect(questionBlock, contains('return pw.Column('));
    expect(questionBlock, contains('pw.Inseparable('));
    expect(questionBlock, isNot(contains('return pw.Container(')));
  });

  test('Verified Result supports canonical report language and Unicode fonts', () {
    final source = File(
      'lib/shared/services/session_pdf_service.dart',
    ).readAsStringSync();
    final page = File(
      'lib/features/organization/presentation/pages/verified_session_report_page.dart',
    ).readAsStringSync();

    expect(source, contains("report.snapshot['report_language']"));
    expect(source, contains('lookupAppLocalizations(Locale(code))'));
    expect(source, contains('PdfGoogleFonts.notoSansRegular()'));
    expect(source, contains('PdfGoogleFonts.notoSansSCRegular()'));
    expect(source, contains('PdfGoogleFonts.notoSansArabicRegular()'));
    expect(source, contains('responseCountLabel'));
    expect(source, contains('voteCountLabel'));

    expect(page, contains('_buildCanonicalReport('));
    expect(page, contains('SessionPdfService.reportLocalizations('));
    expect(page, contains('SessionPdfService.reportLanguageCode('));
    expect(page, contains('Localizations.override('));
    expect(page, contains('SessionPdfService.responseCountLabel('));
    expect(page, contains('SessionPdfService.voteCountLabel('));
  });

  test('Session creation persists canonical report language for schema v3', () {
    final page = File(
      'lib/features/organization/presentation/pages/create_live_session_page.dart',
    ).readAsStringSync();
    final domain = File(
      'lib/domain/organization/repositories/organization_repository.dart',
    ).readAsStringSync();
    final repo = File(
      'lib/infrastructure/organization/repositories/organization_repository_impl.dart',
    ).readAsStringSync();
    final sql = File(
      'supabase/migration/20260916090000_verified_result_report_language_v3.sql',
    ).readAsStringSync();

    expect(page, contains('supportedContentLanguages'));
    expect(page, contains('reportLanguage: reportLanguage'));
    expect(domain, contains('required String reportLanguage'));
    expect(repo, contains("'p_report_language': reportLanguage.trim().toLowerCase()"));
    expect(sql, contains('add column if not exists report_language text'));
    expect(sql, contains("'schema_version', 3"));
    expect(sql, contains("'report_language', v_report_language"));
    expect(
      sql,
      contains(
        'public.session_create(text,text,text,text,integer,text)',
      ),
    );
  });

  test('Verified Result screen no longer repeats the large result title in header', () {
    final source = File(
      'lib/features/organization/presentation/pages/verified_session_report_page.dart',
    ).readAsStringSync();
    final headerStart = source.indexOf('class _CertificateHeader');
    final headerEnd = source.indexOf('class _SectionTitle', headerStart);
    final header = source.substring(headerStart, headerEnd);

    expect(header, contains('SocialVoteCertificateBrandAssets.officialSignature'));
    expect(header, contains('SocialVoteCertificateBrandAssets.verifiedResultSeal'));
    expect(header, isNot(contains('l10n.verifiedResultTitle')));
  });
}

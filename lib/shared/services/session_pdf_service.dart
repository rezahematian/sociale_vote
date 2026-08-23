import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/services/pdf_file_delivery.dart';

class SessionPdfService {
  SessionPdfService._();

  static Future<bool> printVerifiedReport({
    required VerifiedSessionReport report,
    required AppLocalizations l10n,
  }) async {
    final snapshot = report.snapshot;
    final certificateNumber = _text(snapshot['certificate_number']).isNotEmpty
        ? _text(snapshot['certificate_number'])
        : 'SVR-${report.reportId.toUpperCase()}';
    final fileName = '${_safeFileName(certificateNumber)}.pdf';

    // Web reliability: build the real A4 PDF bytes, then deliver them through
    // a same-page Blob download. This avoids the browser print-preview path,
    // which can fail before opening its popup. The downloaded PDF can then be
    // opened, saved or printed normally. Native platforms keep the OS print UI.
    final bytes = await _buildVerifiedReportPdf(report: report, l10n: l10n);
    if (kIsWeb) {
      return savePdfFile(bytes: bytes, fileName: fileName);
    }

    return Printing.layoutPdf(
      name: fileName,
      format: PdfPageFormat.a4,
      dynamicLayout: false,
      onLayout: (_) async => bytes,
    );
  }

  static Future<Uint8List> _buildVerifiedReportPdf({
    required VerifiedSessionReport report,
    required AppLocalizations l10n,
  }) async {
    final snapshot = report.snapshot;
    final verifyUrl = AppRouter.publicVerifiedSessionUrl(report.reportId);
    final questions = snapshot['questions'] is List
        ? snapshot['questions'] as List
        : const <dynamic>[];

    final organizationName = _text(snapshot['organization_name']);
    final organizationLegalName = _text(snapshot['organization_legal_name']);
    final organizationType = _organizationTypeLabel(
      l10n,
      _text(snapshot['organization_entity_type']),
    );
    final countryCode = _text(snapshot['organization_country_code']);
    final countryName = Countries.nameForCode(
      countryCode,
      languageCode: l10n.localeName,
      fallback: countryCode,
    );
    final city = _text(snapshot['organization_city']);
    final location = [city, countryName]
        .where((value) => value.trim().isNotEmpty)
        .join(' - ');
    final website = _text(snapshot['organization_website_url']);
    final logoUrl = _text(snapshot['organization_logo_url']);
    final verification = _verificationLabel(
        l10n, _text(snapshot['organization_verification_status']));
    final sessionTitle = _text(snapshot['session_title']);
    final accessMode = _text(snapshot['access_mode']) == 'controlled_token_pool'
        ? l10n.sessionAccessControlled
        : l10n.sessionAccessOpen;
    final resultsVisibility =
        _visibilityLabel(l10n, _text(snapshot['results_visibility']));
    final expectedParticipants = _int(snapshot['expected_participants']);
    final eligibleCredentials = _nullableInt(snapshot['eligible_credentials']);
    final joinedCredentials = _int(snapshot['participant_credentials_joined']);
    final participantsWithRecordedVote =
        _int(snapshot['participants_with_recorded_vote']);
    final ballotsTotal = snapshot.containsKey('ballots_total')
        ? _int(snapshot['ballots_total'])
        : questions.fold<int>(
            0,
            (sum, raw) => sum + _int(raw is Map ? raw['response_count'] : null),
          );
    final questionCount = snapshot.containsKey('question_count')
        ? _int(snapshot['question_count'])
        : questions.length;
    final certificateNumber = _text(snapshot['certificate_number']).isNotEmpty
        ? _text(snapshot['certificate_number'])
        : 'SVR-${report.reportId.toUpperCase()}';
    final schemaVersion = _text(snapshot['schema_version']);
    final algorithm = _text(snapshot['integrity_algorithm']).isNotEmpty
        ? _text(snapshot['integrity_algorithm'])
        : 'SHA-256';
    final openedAt = _prettyDate(snapshot['opened_at']);
    final closedAt = _prettyDate(snapshot['closed_at']);
    final issuedAt = _prettyDate(snapshot['certificate_issued_at']).isNotEmpty
        ? _prettyDate(snapshot['certificate_issued_at'])
        : _prettyDate(report.createdAt);

    pw.ImageProvider? organizationLogo;
    if (logoUrl.isNotEmpty) {
      try {
        organizationLogo = await networkImage(logoUrl);
      } catch (_) {
        organizationLogo = null;
      }
    }

    final document = pw.Document();

    const accent = PdfColor.fromInt(0xFF2467F4);
    const accentSoft = PdfColor.fromInt(0xFFEAF1FF);
    const ink = PdfColor.fromInt(0xFF172033);
    const muted = PdfColor.fromInt(0xFF647084);
    const line = PdfColor.fromInt(0xFFD8DFEA);
    const panel = PdfColor.fromInt(0xFFF8FAFD);

    final baseStyle = pw.TextStyle(
      font: pw.Font.helvetica(),
      fontSize: 9.5,
      color: ink,
    );
    final boldStyle = pw.TextStyle(
      font: pw.Font.helveticaBold(),
      fontSize: 9.5,
      color: ink,
    );

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(34, 34, 34, 32),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        header: (context) => context.pageNumber == 1
            ? pw.SizedBox()
            : pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'SOCIAL VOTE - ${l10n.verifiedResultTitle}',
                      style: boldStyle.copyWith(fontSize: 8, color: muted),
                    ),
                    pw.Text(
                      certificateNumber,
                      style: baseStyle.copyWith(fontSize: 8, color: muted),
                    ),
                  ],
                ),
              ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 12),
          padding: const pw.EdgeInsets.only(top: 7),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: line, width: 0.6)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  verifyUrl,
                  maxLines: 1,
                  style: baseStyle.copyWith(fontSize: 7, color: muted),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                '${context.pageNumber}/${context.pagesCount}',
                style: baseStyle.copyWith(fontSize: 7, color: muted),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: panel,
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: line, width: 0.8),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (organizationLogo != null)
                  pw.Container(
                    width: 54,
                    height: 54,
                    margin: const pw.EdgeInsets.only(right: 13),
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: line, width: 0.8),
                    ),
                    child: pw.Image(organizationLogo, fit: pw.BoxFit.contain),
                  ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SOCIAL VOTE',
                        style: boldStyle.copyWith(
                          fontSize: 10,
                          color: accent,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        l10n.verifiedResultTitle.toUpperCase(),
                        style: boldStyle.copyWith(fontSize: 22),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        organizationName,
                        style: baseStyle.copyWith(fontSize: 10.5, color: muted),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 14),
                pw.Container(
                  width: 190,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: report.hashValid ? accentSoft : PdfColors.red50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(
                      color: report.hashValid ? accent : PdfColors.red700,
                      width: 0.9,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        report.hashValid
                            ? l10n.verifiedCertificateIntegrityVerified
                            : l10n.verifiedCertificateIntegrityFailed,
                        style: boldStyle.copyWith(
                          fontSize: 9,
                          color: report.hashValid ? accent : PdfColors.red700,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${l10n.verifiedCertificateNumber}: $certificateNumber',
                        style: baseStyle.copyWith(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(
              l10n.verifiedCertificateOrganizationSection, accent, line),
          pw.SizedBox(height: 8),
          _fieldTable(
            [
              [l10n.organizationPublicName, organizationName],
              [l10n.verifiedCertificateLegalName, organizationLegalName],
              [l10n.verifiedCertificateOrganizationType, organizationType],
              [l10n.verifiedCertificateLocation, location],
              [l10n.verifiedCertificateWebsite, website],
              [l10n.verifiedCertificateVerification, verification],
            ],
            baseStyle: baseStyle,
            boldStyle: boldStyle,
            line: line,
          ),
          pw.SizedBox(height: 16),
          _sectionTitle(l10n.verifiedCertificateSessionSection, accent, line),
          pw.SizedBox(height: 8),
          _fieldTable(
            [
              [l10n.sessionTitleLabel, sessionTitle],
              [l10n.sessionJoinCode, _text(snapshot['join_code'])],
              [l10n.sessionAccessMode, accessMode],
              [l10n.sessionResultsVisibility, resultsVisibility],
              [l10n.verifiedResultOpenedAt, openedAt],
              [l10n.sessionCloseAction, closedAt],
            ],
            baseStyle: baseStyle,
            boldStyle: boldStyle,
            line: line,
          ),
          pw.SizedBox(height: 16),
          _sectionTitle(
              l10n.verifiedCertificateParticipationSection, accent, line),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metricBox(
                '$expectedParticipants',
                l10n.sessionExpectedParticipants,
                baseStyle,
                boldStyle,
                line,
                panel,
              ),
              if (eligibleCredentials != null)
                _metricBox(
                  '$eligibleCredentials',
                  l10n.verifiedResultEligibleCredentials,
                  baseStyle,
                  boldStyle,
                  line,
                  panel,
                ),
              _metricBox(
                '$joinedCredentials',
                l10n.verifiedCertificateJoinedCredentials,
                baseStyle,
                boldStyle,
                line,
                panel,
              ),
              _metricBox(
                '$participantsWithRecordedVote',
                l10n.sessionAccessesUsed,
                baseStyle,
                boldStyle,
                line,
                panel,
              ),
              _metricBox(
                '$ballotsTotal',
                l10n.verifiedCertificateBallotsTotal,
                baseStyle,
                boldStyle,
                line,
                panel,
              ),
              _metricBox(
                '$questionCount',
                l10n.verifiedCertificateQuestionsTotal,
                baseStyle,
                boldStyle,
                line,
                panel,
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(l10n.verifiedCertificateResultsSection, accent, line),
          pw.SizedBox(height: 8),
          if (questions.isEmpty)
            pw.Text(l10n.sessionNoQuestions, style: baseStyle)
          else
            ...questions.asMap().entries.map(
                  (entry) => _questionBlock(
                    number: entry.key + 1,
                    question: entry.value is Map
                        ? Map<String, dynamic>.from(entry.value as Map)
                        : const <String, dynamic>{},
                    l10n: l10n,
                    baseStyle: baseStyle,
                    boldStyle: boldStyle,
                    accent: accent,
                    line: line,
                    panel: panel,
                  ),
                ),
          pw.SizedBox(height: 14),
          _sectionTitle(l10n.verifiedCertificateIntegritySection, accent, line),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: line, width: 0.8),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        report.hashValid
                            ? l10n.verifiedCertificateIntegrityVerified
                            : l10n.verifiedCertificateIntegrityFailed,
                        style: boldStyle.copyWith(
                          fontSize: 12,
                          color: report.hashValid ? accent : PdfColors.red700,
                        ),
                      ),
                      pw.SizedBox(height: 9),
                      _integrityLine(
                        l10n.verifiedCertificateNumber,
                        certificateNumber,
                        baseStyle,
                        boldStyle,
                      ),
                      _integrityLine(
                        l10n.verifiedResultReportId,
                        report.reportId,
                        baseStyle,
                        boldStyle,
                      ),
                      _integrityLine(
                        l10n.verifiedCertificateIssuedAt,
                        issuedAt,
                        baseStyle,
                        boldStyle,
                      ),
                      _integrityLine(
                        l10n.verifiedCertificateAlgorithm,
                        algorithm,
                        baseStyle,
                        boldStyle,
                      ),
                      _integrityLine(
                        l10n.verifiedCertificateSchema,
                        schemaVersion,
                        baseStyle,
                        boldStyle,
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(l10n.verifiedResultHash, style: boldStyle),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        report.sha256,
                        style: baseStyle.copyWith(fontSize: 7.6),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        verifyUrl,
                        style: baseStyle.copyWith(fontSize: 7.6, color: muted),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Column(
                  children: [
                    pw.BarcodeWidget(
                      data: verifyUrl,
                      barcode: pw.Barcode.qrCode(),
                      width: 98,
                      height: 98,
                    ),
                    pw.SizedBox(height: 6),
                    pw.SizedBox(
                      width: 116,
                      child: pw.Text(
                        l10n.verifiedCertificateVerifyQr,
                        textAlign: pw.TextAlign.center,
                        style: baseStyle.copyWith(fontSize: 7.4, color: muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: panel,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: line, width: 0.7),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(l10n.verifiedCertificatePrivacyModel, style: boldStyle),
                pw.SizedBox(height: 4),
                pw.Text(l10n.verifiedCertificatePrivacyText, style: baseStyle),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(l10n.verifiedResultGeneratedBy, style: boldStyle),
          pw.SizedBox(height: 3),
          pw.Text(l10n.verifiedResultNotLegalCertificate, style: baseStyle),
        ],
      ),
    );

    return document.save();
  }

  static Future<bool> printAccessPasses({
    required LiveSessionSummary session,
    required List<String> tokens,
    required AppLocalizations l10n,
  }) async {
    final fileName = '${_safeFileName(session.title)}_access_passes.pdf';
    final bytes = await _buildAccessPassesPdf(
      session: session,
      tokens: tokens,
      l10n: l10n,
    );

    if (kIsWeb) {
      return savePdfFile(bytes: bytes, fileName: fileName);
    }

    return Printing.layoutPdf(
      name: fileName,
      format: PdfPageFormat.a4,
      dynamicLayout: false,
      onLayout: (_) async => bytes,
    );
  }

  static Future<Uint8List> _buildAccessPassesPdf({
    required LiveSessionSummary session,
    required List<String> tokens,
    required AppLocalizations l10n,
  }) async {
    final document = pw.Document();
    const line = PdfColor.fromInt(0xFFD8DFEA);
    const panel = PdfColor.fromInt(0xFFF8FAFD);
    const ink = PdfColor.fromInt(0xFF172033);
    const muted = PdfColor.fromInt(0xFF647084);
    const accent = PdfColor.fromInt(0xFF2467F4);

    final baseStyle = pw.TextStyle(
      font: pw.Font.helvetica(),
      fontSize: 9,
      color: ink,
    );
    final boldStyle = pw.TextStyle(
      font: pw.Font.helveticaBold(),
      fontSize: 9,
      color: ink,
    );

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Social Vote',
                  style: baseStyle.copyWith(fontSize: 7, color: muted)),
              pw.Text('${context.pageNumber}/${context.pagesCount}',
                  style: baseStyle.copyWith(fontSize: 7, color: muted)),
            ],
          ),
        ),
        build: (context) => [
          pw.Text(
            'SOCIAL VOTE',
            style: boldStyle.copyWith(
                fontSize: 10, color: accent, letterSpacing: 1.4),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            l10n.sessionAccessPassesTitle,
            style: boldStyle.copyWith(fontSize: 20),
          ),
          pw.SizedBox(height: 4),
          pw.Text(session.title, style: baseStyle.copyWith(fontSize: 11)),
          pw.SizedBox(height: 3),
          pw.Text(
            '${session.organizationName ?? 'Social Vote'} - ${l10n.sessionJoinCode}: ${session.joinCode}',
            style: baseStyle.copyWith(color: muted),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: panel,
              border: pw.Border.all(color: line, width: 0.7),
              borderRadius: pw.BorderRadius.circular(7),
            ),
            child:
                pw.Text(l10n.sessionAccessPassPrintWarning, style: baseStyle),
          ),
          pw.SizedBox(height: 16),
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List<pw.Widget>.generate(tokens.length, (index) {
              final token = tokens[index];
              final passUrl = _passUrl(session, token);
              return pw.Container(
                width: 252,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: line, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(9),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Text(
                      '${l10n.sessionAccessPass} #${index + 1}',
                      style: boldStyle.copyWith(fontSize: 11),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      session.title,
                      maxLines: 2,
                      style: boldStyle.copyWith(fontSize: 10),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Center(
                      child: pw.BarcodeWidget(
                        data: passUrl,
                        barcode: pw.Barcode.qrCode(),
                        width: 135,
                        height: 135,
                      ),
                    ),
                    pw.SizedBox(height: 9),
                    pw.Text(
                      l10n.sessionNoAccountRequired,
                      textAlign: pw.TextAlign.center,
                      style: boldStyle.copyWith(fontSize: 8.5),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(color: line, height: 1),
                    pw.SizedBox(height: 7),
                    pw.Text(l10n.sessionAccessPassFallback,
                        style: baseStyle.copyWith(fontSize: 7.8, color: muted)),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      token,
                      textAlign: pw.TextAlign.center,
                      style: boldStyle.copyWith(fontSize: 9.5),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${l10n.sessionJoinCode}: ${session.joinCode}',
                      textAlign: pw.TextAlign.center,
                      style: baseStyle.copyWith(fontSize: 8),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _sectionTitle(
    String title,
    PdfColor accent,
    PdfColor line,
  ) {
    return pw.Row(
      children: [
        pw.Container(width: 5, height: 18, color: accent),
        pw.SizedBox(width: 8),
        pw.Text(
          title,
          style: pw.TextStyle(
            font: pw.Font.helveticaBold(),
            fontSize: 12,
            color: const PdfColor.fromInt(0xFF172033),
          ),
        ),
        pw.SizedBox(width: 9),
        pw.Expanded(child: pw.Divider(color: line, thickness: 0.7)),
      ],
    );
  }

  static pw.Widget _fieldTable(
    List<List<String>> rows, {
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    required PdfColor line,
  }) {
    final visible = rows
        .where((row) => row.length >= 2 && row[1].trim().isNotEmpty)
        .toList(growable: false);
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: line, width: 0.5),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.05),
        1: pw.FlexColumnWidth(1.45),
      },
      children: visible
          .map(
            (row) => pw.TableRow(
              children: [
                pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 3),
                  child: pw.Text(row[0],
                      style: baseStyle.copyWith(
                          color: const PdfColor.fromInt(0xFF647084))),
                ),
                pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 3),
                  child: pw.Text(row[1], style: boldStyle),
                ),
              ],
            ),
          )
          .toList(growable: false),
    );
  }

  static pw.Widget _metricBox(
    String value,
    String label,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
    PdfColor line,
    PdfColor panel,
  ) {
    return pw.Container(
      width: 164,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: panel,
        border: pw.Border.all(color: line, width: 0.7),
        borderRadius: pw.BorderRadius.circular(7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(value, style: boldStyle.copyWith(fontSize: 15)),
          pw.SizedBox(height: 2),
          pw.Text(label, style: baseStyle.copyWith(fontSize: 8.2)),
        ],
      ),
    );
  }

  static pw.Widget _questionBlock({
    required int number,
    required Map<String, dynamic> question,
    required AppLocalizations l10n,
    required pw.TextStyle baseStyle,
    required pw.TextStyle boldStyle,
    required PdfColor accent,
    required PdfColor line,
    required PdfColor panel,
  }) {
    final title = _text(question['title']);
    final responses = _int(question['response_count']);
    final options = question['options'] is List
        ? question['options'] as List
        : const <dynamic>[];

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: panel,
        border: pw.Border.all(color: line, width: 0.7),
        borderRadius: pw.BorderRadius.circular(7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 22,
                height: 22,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: accent,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Text(
                  '$number',
                  style:
                      boldStyle.copyWith(fontSize: 9, color: PdfColors.white),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                  child: pw.Text(title,
                      style: boldStyle.copyWith(fontSize: 10.5))),
              pw.SizedBox(width: 8),
              pw.Text(l10n.sessionResponses(responses),
                  style: baseStyle.copyWith(fontSize: 8)),
            ],
          ),
          pw.SizedBox(height: 10),
          ...options.map((raw) {
            final option = raw is Map
                ? Map<String, dynamic>.from(raw)
                : const <String, dynamic>{};
            final key = _text(option['option_key']);
            final label = switch (key) {
              'yes' => l10n.sessionOptionYes,
              'no' => l10n.sessionOptionNo,
              _ => _text(option['label']),
            };
            final votes = _int(option['votes']);
            final ratio = responses == 0 ? 0.0 : votes / responses;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 7),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text(label, style: baseStyle)),
                      pw.Text(
                        '${l10n.sessionResultVotes(votes)} - ${(ratio * 100).toStringAsFixed(1)}%',
                        style: boldStyle.copyWith(fontSize: 8.5),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Container(height: 2, color: votes > 0 ? accent : line),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _integrityLine(
    String label,
    String value,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    if (value.trim().isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 108, child: pw.Text(label, style: boldStyle)),
          pw.Expanded(child: pw.Text(value, style: baseStyle)),
        ],
      ),
    );
  }

  static String _passUrl(LiveSessionSummary session, String token) {
    final base = Uri.parse(AppRouter.publicSessionJoinUrl(session.joinCode));
    return base
        .replace(fragment: 'pass=${Uri.encodeComponent(token)}')
        .toString();
  }

  static String _organizationTypeLabel(AppLocalizations l10n, String type) {
    return switch (type) {
      'association' => l10n.organizationTypeAssociation,
      'nonprofit' => l10n.organizationTypeNonprofit,
      'company' => l10n.organizationTypeCompany,
      'cooperative' => l10n.organizationTypeCooperative,
      'sports' => l10n.organizationTypeSports,
      'public_body' => l10n.organizationTypePublicBody,
      'committee' => l10n.organizationTypeCommittee,
      'other' => l10n.organizationTypeOther,
      '' => l10n.organizationTypeOther,
      _ => type,
    };
  }

  static String _verificationLabel(AppLocalizations l10n, String value) {
    return switch (value.toLowerCase()) {
      'verified' => l10n.organizationVerifiedLabel,
      _ => value,
    };
  }

  static String _visibilityLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'live' => l10n.sessionResultsLive,
      'after_vote' => l10n.sessionResultsAfterVote,
      'organizer_only' => l10n.sessionResultsOrganizerOnly,
      _ => l10n.sessionResultsAfterClose,
    };
  }

  static String _text(dynamic value) => value?.toString().trim() ?? '';

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String _prettyDate(dynamic raw) {
    if (raw == null) return '';
    final parsed = raw is DateTime
        ? raw.toLocal()
        : DateTime.tryParse(raw.toString())?.toLocal();
    if (parsed == null) return raw.toString();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} '
        '${two(parsed.hour)}:${two(parsed.minute)}';
  }

  static String _safeFileName(String input) {
    final normalized =
        input.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return normalized.isEmpty ? 'social_vote' : normalized;
  }
}

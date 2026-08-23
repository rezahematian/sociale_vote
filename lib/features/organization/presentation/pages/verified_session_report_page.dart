import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/services/session_pdf_service.dart';

class VerifiedSessionReportPage extends StatefulWidget {
  final String reportId;

  const VerifiedSessionReportPage({
    super.key,
    required this.reportId,
  });

  @override
  State<VerifiedSessionReportPage> createState() =>
      _VerifiedSessionReportPageState();
}

class _VerifiedSessionReportPageState extends State<VerifiedSessionReportPage> {
  VerifiedSessionReport? _report;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final report = await AppDI.instance.organizationRepository
          .getVerifiedReport(widget.reportId);
      if (!mounted) return;
      setState(() {
        _report = report;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _printReport(
    VerifiedSessionReport report,
    AppLocalizations l10n,
  ) async {
    try {
      await SessionPdfService.printVerifiedReport(
        report: report,
        l10n: l10n,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.verifiedResultPdfError)),
      );
    }
  }

  String _friendlyLoadError(AppLocalizations l10n, Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('42501') ||
        raw.contains('permission denied') ||
        raw.contains('organizer only') ||
        raw.contains('organizer_only')) {
      return l10n.verifiedResultRestrictedBody;
    }
    return l10n.publicProfileLoadError;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final report = _report;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifiedResultTitle),
        actions: [
          if (report != null)
            IconButton(
              onPressed: () => _printReport(report, l10n),
              tooltip: l10n.verifiedResultPrintPdf,
              icon: const Icon(Icons.print_outlined),
            ),
        ],
      ),
      body: report == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : _RestrictedReportNotice(
                      message: _friendlyLoadError(l10n, _error!),
                    ),
            )
          : _buildReport(context, l10n, report),
    );
  }

  Widget _buildReport(
    BuildContext context,
    AppLocalizations l10n,
    VerifiedSessionReport report,
  ) {
    final snapshot = report.snapshot;
    final organizerOnly =
        _text(snapshot['results_visibility']) == 'organizer_only';
    final verifyUrl = organizerOnly
        ? ''
        : AppRouter.publicVerifiedSessionUrl(report.reportId);
    final questions = snapshot['questions'] is List
        ? snapshot['questions'] as List
        : const <dynamic>[];
    final orgName = _text(snapshot['organization_name']);
    final legalName = _text(snapshot['organization_legal_name']);
    final orgType = _organizationTypeLabel(
        l10n, _text(snapshot['organization_entity_type']));
    final countryCode = _text(snapshot['organization_country_code']);
    final country = Countries.nameForCode(
      countryCode,
      languageCode: l10n.localeName,
      fallback: countryCode,
    );
    final city = _text(snapshot['organization_city']);
    final website = _text(snapshot['organization_website_url']);
    final logo = _text(snapshot['organization_logo_url']);
    final verification = _verificationLabel(
      l10n,
      _text(snapshot['organization_verification_status']),
    );
    final sessionTitle = _text(snapshot['session_title']);
    final openedAt = _prettyDate(snapshot['opened_at']);
    final closedAt = _prettyDate(snapshot['closed_at']);
    final accessMode = _text(snapshot['access_mode']);
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
    final location =
        [city, country].where((value) => value.isNotEmpty).join(' · ');

    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 42),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 24,
                      offset: Offset(0, 8),
                      color: Color(0x14000000),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CertificateHeader(
                        organizationName: orgName,
                        organizationLogoUrl: logo,
                        certificateNumber: certificateNumber,
                        valid: report.hashValid,
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        icon: Icons.apartment_rounded,
                        text: l10n.verifiedCertificateOrganizationSection,
                      ),
                      const SizedBox(height: 10),
                      _FieldGrid(
                        fields: [
                          _FieldData(l10n.organizationPublicName, orgName),
                          _FieldData(
                              l10n.verifiedCertificateLegalName, legalName),
                          _FieldData(l10n.verifiedCertificateOrganizationType,
                              orgType),
                          _FieldData(
                              l10n.verifiedCertificateLocation, location),
                          _FieldData(l10n.verifiedCertificateWebsite, website),
                          _FieldData(
                            l10n.verifiedCertificateVerification,
                            verification.isEmpty
                                ? l10n.organizationVerifiedLabel
                                : verification,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        icon: Icons.meeting_room_outlined,
                        text: l10n.verifiedCertificateSessionSection,
                      ),
                      const SizedBox(height: 10),
                      _FieldGrid(
                        fields: [
                          _FieldData(l10n.sessionTitleLabel, sessionTitle),
                          _FieldData(l10n.sessionJoinCode,
                              _text(snapshot['join_code'])),
                          _FieldData(
                            l10n.sessionAccessMode,
                            accessMode == 'controlled_token_pool'
                                ? l10n.sessionAccessControlled
                                : l10n.sessionAccessOpen,
                          ),
                          _FieldData(
                            l10n.sessionResultsVisibility,
                            _visibilityLabel(
                                l10n, _text(snapshot['results_visibility'])),
                          ),
                          _FieldData(l10n.verifiedResultOpenedAt, openedAt),
                          _FieldData(l10n.sessionCloseAction, closedAt),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        icon: Icons.analytics_outlined,
                        text: l10n.verifiedCertificateParticipationSection,
                      ),
                      const SizedBox(height: 10),
                      _MetricGrid(
                        items: [
                          _MetricData(
                            Icons.people_alt_outlined,
                            '$expectedParticipants',
                            l10n.sessionExpectedParticipants,
                          ),
                          if (eligibleCredentials != null)
                            _MetricData(
                              Icons.badge_outlined,
                              '$eligibleCredentials',
                              l10n.verifiedResultEligibleCredentials,
                            ),
                          _MetricData(
                            Icons.login_rounded,
                            '$joinedCredentials',
                            l10n.verifiedCertificateJoinedCredentials,
                          ),
                          _MetricData(
                            Icons.how_to_reg_outlined,
                            '$participantsWithRecordedVote',
                            l10n.sessionAccessesUsed,
                          ),
                          _MetricData(
                            Icons.ballot_outlined,
                            '$ballotsTotal',
                            l10n.verifiedCertificateBallotsTotal,
                          ),
                          _MetricData(
                            Icons.quiz_outlined,
                            '$questionCount',
                            l10n.verifiedCertificateQuestionsTotal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(
                        icon: Icons.fact_check_outlined,
                        text: l10n.verifiedCertificateResultsSection,
                      ),
                      const SizedBox(height: 12),
                      if (questions.isEmpty)
                        Text(l10n.sessionNoQuestions)
                      else
                        ...questions.asMap().entries.map(
                              (entry) => _QuestionResultBlock(
                                number: entry.key + 1,
                                question: entry.value is Map
                                    ? Map<String, dynamic>.from(
                                        entry.value as Map)
                                    : const <String, dynamic>{},
                              ),
                            ),
                      const SizedBox(height: 8),
                      _SectionTitle(
                        icon: Icons.verified_user_outlined,
                        text: l10n.verifiedCertificateIntegritySection,
                      ),
                      const SizedBox(height: 12),
                      _IntegrityPanel(
                        reportId: report.reportId,
                        certificateNumber: certificateNumber,
                        sha256: report.sha256,
                        valid: report.hashValid,
                        verifyUrl: verifyUrl,
                        publicVerification: !organizerOnly,
                        algorithm: algorithm,
                        schemaVersion: schemaVersion,
                        issuedAt: _prettyDate(snapshot['certificate_issued_at'])
                                .isNotEmpty
                            ? _prettyDate(snapshot['certificate_issued_at'])
                            : _prettyDate(report.createdAt),
                      ),
                      const SizedBox(height: 18),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.privacy_tip_outlined),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.verifiedCertificatePrivacyModel,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(l10n.verifiedCertificatePrivacyText),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Divider(
                          color: Theme.of(context).colorScheme.outlineVariant),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified_rounded, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.verifiedResultGeneratedBy,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.verifiedResultNotLegalCertificate),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (!organizerOnly)
                            FilledButton.icon(
                              onPressed: () => Share.share(verifyUrl),
                              icon: const Icon(Icons.share_outlined),
                              label: Text(l10n.verifiedResultShare),
                            ),
                          OutlinedButton.icon(
                            onPressed: () => _printReport(report, l10n),
                            icon: const Icon(Icons.print_outlined),
                            label: Text(l10n.verifiedResultPrintPdf),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _organizationTypeLabel(AppLocalizations l10n, String type) {
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

  String _verificationLabel(AppLocalizations l10n, String value) {
    return switch (value.toLowerCase()) {
      'verified' => l10n.organizationVerifiedLabel,
      _ => value,
    };
  }

  String _visibilityLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'live' => l10n.sessionResultsLive,
      'after_vote' => l10n.sessionResultsAfterVote,
      'organizer_only' => l10n.sessionResultsOrganizerOnly,
      _ => l10n.sessionResultsAfterClose,
    };
  }
}

class _CertificateHeader extends StatelessWidget {
  final String organizationName;
  final String organizationLogoUrl;
  final String certificateNumber;
  final bool valid;

  const _CertificateHeader({
    required this.organizationName,
    required this.organizationLogoUrl,
    required this.certificateNumber,
    required this.valid,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final identity = Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: organizationLogoUrl.isNotEmpty
                  ? NetworkImage(organizationLogoUrl)
                  : null,
              child: organizationLogoUrl.isEmpty
                  ? const Icon(Icons.apartment_rounded, size: 28)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOCIAL VOTE',
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.verifiedResultTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (organizationName.isNotEmpty) Text(organizationName),
                ],
              ),
            ),
          ],
        );
        final seal = DecoratedBox(
          decoration: BoxDecoration(
            color: valid
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.65)
                : theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  valid ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      valid
                          ? Icons.verified_rounded
                          : Icons.error_outline_rounded,
                      color: valid
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      valid
                          ? l10n.verifiedCertificateIntegrityVerified
                          : l10n.verifiedCertificateIntegrityFailed,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: valid
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text('${l10n.verifiedCertificateNumber}: $certificateNumber'),
              ],
            ),
          ),
        );

        if (constraints.maxWidth < 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [identity, const SizedBox(height: 14), seal],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: identity),
            const SizedBox(width: 18),
            seal
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SectionTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 21, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
      ],
    );
  }
}

class _FieldData {
  final String label;
  final String value;

  const _FieldData(this.label, this.value);
}

class _FieldGrid extends StatelessWidget {
  final List<_FieldData> fields;

  const _FieldGrid({required this.fields});

  @override
  Widget build(BuildContext context) {
    final visible =
        fields.where((field) => field.value.trim().isNotEmpty).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680 ? 2 : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 16)) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          children: visible
              .map(
                (field) => SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(field.label,
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 2),
                      SelectableText(
                        field.value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricData {
  final IconData icon;
  final String value;
  final String label;

  const _MetricData(this.icon, this.value, this.label);
}

class _MetricGrid extends StatelessWidget {
  final List<_MetricData> items;

  const _MetricGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720
            ? 3
            : constraints.maxWidth >= 460
                ? 2
                : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(item.icon,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.value,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                Text(item.label,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _QuestionResultBlock extends StatelessWidget {
  final int number;
  final Map<String, dynamic> question;

  const _QuestionResultBlock({required this.number, required this.question});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = _text(question['title']);
    final responses = _int(question['response_count']);
    final options = question['options'] is List
        ? question['options'] as List
        : const <dynamic>[];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 16, child: Text('$number')),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(l10n.sessionResponses(responses)),
              ],
            ),
            const SizedBox(height: 14),
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(label)),
                        Text(
                          '${l10n.sessionResultVotes(votes)} · ${(ratio * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0).toDouble()),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RestrictedReportNotice extends StatelessWidget {
  final String message;

  const _RestrictedReportNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 42,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.verifiedResultRestrictedTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntegrityPanel extends StatelessWidget {
  final String reportId;
  final String certificateNumber;
  final String sha256;
  final bool valid;
  final String verifyUrl;
  final bool publicVerification;
  final String algorithm;
  final String schemaVersion;
  final String issuedAt;

  const _IntegrityPanel({
    required this.reportId,
    required this.certificateNumber,
    required this.sha256,
    required this.valid,
    required this.verifyUrl,
    required this.publicVerification,
    required this.algorithm,
    required this.schemaVersion,
    required this.issuedAt,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final verificationPanel = publicVerification
                ? Column(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(9),
                          child: QrImageView(data: verifyUrl, size: 145),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 180,
                        child: Text(
                          l10n.verifiedCertificateVerifyQr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: 210,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              l10n.verifiedResultPrivateVerificationTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              l10n.verifiedResultPrivateVerificationBody,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
            final data = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      valid
                          ? Icons.verified_rounded
                          : Icons.error_outline_rounded,
                      color: valid
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        valid
                            ? l10n.verifiedCertificateIntegrityVerified
                            : l10n.verifiedCertificateIntegrityFailed,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _IntegrityLine(
                    l10n.verifiedCertificateNumber, certificateNumber),
                _IntegrityLine(l10n.verifiedResultReportId, reportId),
                _IntegrityLine(l10n.verifiedCertificateIssuedAt, issuedAt),
                _IntegrityLine(l10n.verifiedCertificateAlgorithm, algorithm),
                if (schemaVersion.isNotEmpty)
                  _IntegrityLine(l10n.verifiedCertificateSchema, schemaVersion),
                const SizedBox(height: 8),
                Text(l10n.verifiedResultHash,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                SelectableText(
                  sha256,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.35,
                  ),
                ),
                if (publicVerification) ...[
                  const SizedBox(height: 8),
                  SelectableText(verifyUrl, style: theme.textTheme.bodySmall),
                ],
              ],
            );
            if (constraints.maxWidth < 650) {
              return Column(
                children: [
                  data,
                  const SizedBox(height: 16),
                  verificationPanel,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: data),
                const SizedBox(width: 20),
                verificationPanel,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IntegrityLine extends StatelessWidget {
  final String label;
  final String value;

  const _IntegrityLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

String _text(dynamic value) => value?.toString().trim() ?? '';

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(dynamic value) => value == null ? null : _int(value);

String _prettyDate(dynamic value) {
  if (value == null) return '';
  final date = value is DateTime
      ? value.toLocal()
      : DateTime.tryParse(value.toString())?.toLocal();
  if (date == null) return value.toString();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/report_print.dart';

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

class _VerifiedSessionReportPageState
    extends State<VerifiedSessionReportPage> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final report = _report;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifiedResultTitle)),
      body: report == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Text(_error.toString()),
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
    final verifyUrl = AppRouter.publicVerifiedSessionUrl(report.reportId);
    final questions = snapshot['questions'] is List
        ? snapshot['questions'] as List
        : const <dynamic>[];
    final orgName = snapshot['organization_name']?.toString() ?? '';
    final sessionTitle = snapshot['session_title']?.toString() ?? '';
    final openedAt = snapshot['opened_at']?.toString() ?? '';
    final closedAt = snapshot['closed_at']?.toString() ?? '';
    final accessMode = snapshot['access_mode']?.toString() ?? '';
    final expectedParticipants = snapshot['expected_participants']?.toString() ?? '0';
    final eligibleCredentials = snapshot['eligible_credentials']?.toString();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_rounded, size: 42),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.verifiedResultTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.verifiedResultIntegritySeal,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                report.hashValid
                                    ? l10n.verifiedResultValid
                                    : l10n.verifiedResultInvalid,
                                style: TextStyle(
                                  color: report.hashValid
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        QrImageView(data: verifyUrl, size: 110),
                      ],
                    ),
                    const Divider(height: 32),
                    _field(l10n.organizationPublicName, orgName),
                    _field(l10n.sessionTitleLabel, sessionTitle),
                    _field(
                      l10n.sessionAccessMode,
                      accessMode == 'controlled_token_pool'
                          ? l10n.sessionAccessControlled
                          : l10n.sessionAccessOpen,
                    ),
                    _field(l10n.sessionExpectedParticipants, expectedParticipants),
                    if (eligibleCredentials != null)
                      _field(l10n.verifiedResultEligibleCredentials, eligibleCredentials),
                    _field(l10n.verifiedResultOpenedAt, openedAt),
                    _field(l10n.sessionCloseAction, closedAt),
                    _field(l10n.verifiedResultReportId, report.reportId),
                    _field(l10n.verifiedResultHash, report.sha256),
                    const Divider(height: 32),
                    ...questions.map(
                      (raw) => _questionBlock(
                        context,
                        l10n,
                        raw is Map
                            ? Map<String, dynamic>.from(raw)
                            : const <String, dynamic>{},
                      ),
                    ),
                    const Divider(height: 32),
                    Text(
                      l10n.verifiedResultGeneratedBy,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.verifiedResultNotLegalCertificate),
                    const SizedBox(height: 14),
                    SelectableText(verifyUrl),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () => Share.share(verifyUrl),
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l10n.verifiedResultShare),
                        ),
                        if (canPrintReport)
                          OutlinedButton.icon(
                            onPressed: printReport,
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
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 180, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  Widget _questionBlock(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, dynamic> question,
  ) {
    final options = question['options'] is List
        ? question['options'] as List
        : const <dynamic>[];
    final title = question['title']?.toString() ?? '';
    final responses = question['response_count']?.toString() ?? '0';
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(l10n.sessionResponses(int.tryParse(responses) ?? 0)),
          const SizedBox(height: 10),
          ...options.map((raw) {
            final option = raw is Map
                ? Map<String, dynamic>.from(raw)
                : const <String, dynamic>{};
            final key = option['option_key']?.toString();
            final label = switch (key) {
              'yes' => l10n.sessionOptionYes,
              'no' => l10n.sessionOptionNo,
              _ => option['label']?.toString() ?? '',
            };
            final voteCount = int.tryParse(option['votes']?.toString() ?? '0') ?? 0;
            final responseCount = int.tryParse(responses) ?? 0;
            final percent = responseCount == 0
                ? 0.0
                : (voteCount * 100.0 / responseCount);
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Expanded(child: Text(label)),
                  Text(
                    '${l10n.sessionResultVotes(voteCount)} · ${percent.toStringAsFixed(1)}%',
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

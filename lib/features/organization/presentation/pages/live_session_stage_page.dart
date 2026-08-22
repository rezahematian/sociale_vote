import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/domain/organization/repositories/organization_repository.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class LiveSessionStagePage extends StatefulWidget {
  final String sessionId;
  final OrganizationRepository repository;

  const LiveSessionStagePage({
    super.key,
    required this.sessionId,
    required this.repository,
  });

  @override
  State<LiveSessionStagePage> createState() => _LiveSessionStagePageState();
}

class _LiveSessionStagePageState extends State<LiveSessionStagePage> {
  LiveSessionDetail? _detail;
  Object? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    try {
      final detail = await widget.repository.getOrganizerSession(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _error = null;
      });
    } catch (e) {
      if (!mounted || silent) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: detail == null
            ? Center(
                child: _error == null
                    ? const CircularProgressIndicator()
                    : Text(_error.toString()),
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.surface,
                            theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
                            theme.colorScheme.surface,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 24, 28, 30),
                      child: _StageContent(detail: detail),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StageContent extends StatelessWidget {
  final LiveSessionDetail detail;

  const _StageContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final session = detail.session;
    final question = detail.openQuestion;
    final joinUrl = AppRouter.publicSessionJoinUrl(session.joinCode);
    final controlled =
        session.accessMode == LiveSessionAccessMode.controlledTokenPool;

    return Column(
      children: [
        Row(
          children: [
            _Logo(url: session.organizationLogoUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          session.organizationName ?? 'Social Vote',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Icon(Icons.verified_rounded,
                          size: 21, color: theme.colorScheme.primary),
                    ],
                  ),
                  Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            _StatusPill(status: session.status),
          ],
        ),
        const SizedBox(height: 26),
        Expanded(
          child: question == null
              ? _WaitingStage(
                  detail: detail,
                  joinUrl: joinUrl,
                  controlled: controlled,
                )
              : _QuestionStage(question: question, detail: detail),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 8,
          children: [
            _StageMetric(
              icon: Icons.people_alt_outlined,
              value: '${session.participantCount}',
              label: l10n.sessionJoinedParticipants,
            ),
            _StageMetric(
              icon: Icons.ballot_outlined,
              value: '${session.responseCount}',
              label: l10n.sessionBallotsRecorded,
            ),
            _StageMetric(
              icon: Icons.tag_rounded,
              value: session.joinCode,
              label: l10n.sessionJoinCode,
            ),
          ],
        ),
      ],
    );
  }
}

class _WaitingStage extends StatelessWidget {
  final LiveSessionDetail detail;
  final String joinUrl;
  final bool controlled;

  const _WaitingStage({
    required this.detail,
    required this.joinUrl,
    required this.controlled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final session = detail.session;

    return LayoutBuilder(
      builder: (context, constraints) {
        final qr = DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: QrImageView(data: joinUrl, size: 230),
          ),
        );
        final text = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.sensors_rounded, size: 44, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              session.status == 'draft'
                  ? l10n.sessionNotStartedTitle
                  : l10n.sessionStageWaiting,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controlled
                  ? l10n.sessionControlledAccessInstructions
                  : l10n.sessionOpenAccessInstructions,
              style: theme.textTheme.titleLarge?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 20),
            Text(
              '${l10n.sessionJoinCode}: ${session.joinCode}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 760) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              qr,
              const SizedBox(height: 24),
              Flexible(child: text),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            qr,
            const SizedBox(width: 48),
            Flexible(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: text)),
          ],
        );
      },
    );
  }
}

class _QuestionStage extends StatelessWidget {
  final LiveQuestion question;
  final LiveSessionDetail detail;

  const _QuestionStage({required this.question, required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final index = (detail.indexOfQuestion(question.id) ?? 0) + 1;
    final total = detail.questions.length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${l10n.sessionCurrentQuestion} · $index/$total',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              question.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: question.options
                  .map(
                    (option) => Chip(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      label: Text(
                        _optionLabel(l10n, option),
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 34),
            Text(
              '${question.responseCount}',
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(l10n.sessionResponses(question.responseCount), style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  String _optionLabel(AppLocalizations l10n, LiveOption option) {
    return switch (option.optionKey) {
      'yes' => l10n.sessionOptionYes,
      'no' => l10n.sessionOptionNo,
      _ => option.label ?? '',
    };
  }
}

class _Logo extends StatelessWidget {
  final String? url;

  const _Logo({required this.url});

  @override
  Widget build(BuildContext context) {
    final normalized = url?.trim() ?? '';
    return CircleAvatar(
      radius: 28,
      backgroundImage: normalized.isEmpty ? null : NetworkImage(normalized),
      child: normalized.isEmpty ? const Icon(Icons.apartment_rounded, size: 28) : null,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (status) {
      'open' => l10n.sessionStatusOpen,
      'closed' => l10n.sessionStatusClosed,
      _ => l10n.sessionStatusDraft,
    };
    return Chip(
      avatar: Icon(
        status == 'open' ? Icons.sensors_rounded : Icons.circle_outlined,
        size: 18,
      ),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _StageMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StageMetric({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(width: 5),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

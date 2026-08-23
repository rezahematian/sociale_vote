import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/domain/organization/repositories/organization_repository.dart';
import 'package:sociale_vote/features/organization/presentation/pages/live_session_access_passes_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/live_session_stage_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class LiveSessionPresenterPage extends StatefulWidget {
  final String sessionId;

  const LiveSessionPresenterPage({
    super.key,
    required this.sessionId,
  });

  @override
  State<LiveSessionPresenterPage> createState() =>
      _LiveSessionPresenterPageState();
}

class _LiveSessionPresenterPageState extends State<LiveSessionPresenterPage> {
  late final OrganizationRepository _repository;
  LiveSessionDetail? _detail;
  bool _loading = true;
  bool _busy = false;
  Object? _error;
  Timer? _timer;
  int _section = 0;

  @override
  void initState() {
    super.initState();
    _repository = AppDI.instance.organizationRepository;
    _load();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_detail?.session.status == 'open' && !_busy) {
        _load(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => _loading = true);
    }
    try {
      final detail = await _repository.getOrganizerSession(widget.sessionId);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await action();
      await _load(silent: true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _openSession() async {
    final detail = _detail;
    if (detail == null || _busy) {
      return;
    }
    final session = detail.session;
    final controlled =
        session.accessMode == LiveSessionAccessMode.controlledTokenPool;
    final l10n = AppLocalizations.of(context)!;

    if (controlled && session.tokenCount < 1) {
      setState(() => _section = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sessionControlledNeedsAccessPass)),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await _repository.openSession(widget.sessionId);
      await _load(silent: true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      final raw = e.toString().toLowerCase();
      final message = controlled &&
              (raw.contains('22023') ||
                  raw.contains('participant token') ||
                  raw.contains('access pass'))
          ? l10n.sessionControlledNeedsAccessPass
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _addQuestion() async {
    final result = await showDialog<_QuestionDraft>(
      context: context,
      builder: (_) => const _AddQuestionDialog(),
    );
    if (result == null) {
      return;
    }
    await _run(() async {
      await _repository.addQuestion(
        sessionId: widget.sessionId,
        title: result.title,
        type: result.type,
        options: result.options,
        minSelections: result.minSelections,
        maxSelections: result.maxSelections,
      );
    });
  }

  Future<void> _generatePasses() async {
    final detail = _detail!;
    final l10n = AppLocalizations.of(context)!;
    final remaining =
        detail.session.expectedParticipants - detail.session.tokenCount;
    final controller =
        TextEditingController(text: '${remaining > 0 ? remaining : 1}');
    final count = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sessionAccessPassesTitle),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.sessionControlledAccessInstructions),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.sessionGenerateTokensCount,
                  helperText: l10n.sessionPilotLimit,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancelButton),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(
              int.tryParse(controller.text.trim()),
            ),
            icon: const Icon(Icons.qr_code_2_rounded),
            label: Text(l10n.sessionGenerateTokens),
          ),
        ],
      ),
    );
    controller.dispose();
    if (count == null || count < 1) {
      return;
    }

    setState(() => _busy = true);
    try {
      final tokens = await _repository.generateTokens(
        sessionId: widget.sessionId,
        count: count,
      );
      await _load(silent: true);
      if (!mounted || tokens.isEmpty) {
        return;
      }
      final session = _detail!.session;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => LiveSessionAccessPassesPage(
            session: session,
            tokens: tokens,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _closeSession() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sessionCloseAction),
        content: Text(l10n.sessionCloseConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.sessionCloseAction),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    setState(() => _busy = true);
    try {
      final reportId = await _repository.closeSession(widget.sessionId);
      await _load(silent: true);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamed(
        AppRouter.publicVerifiedSessionPath(reportId),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _openStage() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LiveSessionStagePage(
          sessionId: widget.sessionId,
          repository: _repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detail = _detail;
    if (_loading && detail == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionControlRoomTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionControlRoomTitle)),
        body: Center(
          child: Text(_error?.toString() ?? l10n.publicProfileLoadError),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionControlRoomTitle),
        actions: [
          IconButton(
            onPressed: _busy ? null : _load,
            tooltip:
                MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                _ControlRoomHeader(
                  detail: detail,
                  busy: _busy,
                  onStage: _openStage,
                  onOpenSession: _openSession,
                  onCloseSession: _closeSession,
                  onReport: detail.session.reportId == null
                      ? null
                      : () => Navigator.of(context).pushNamed(
                            AppRouter.publicVerifiedSessionPath(
                              detail.session.reportId!,
                            ),
                          ),
                ),
                const SizedBox(height: 14),
                _KpiGrid(detail: detail),
                const SizedBox(height: 16),
                _SectionSelector(
                  selected: _section,
                  onChanged: (value) => setState(() => _section = value),
                ),
                const SizedBox(height: 14),
                switch (_section) {
                  0 => _buildLiveSection(detail),
                  1 => _buildQuestionsSection(detail),
                  2 => _buildAccessSection(detail),
                  _ => _buildSettingsSection(detail),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveSection(LiveSessionDetail detail) {
    final l10n = AppLocalizations.of(context)!;
    final current = detail.openQuestion;
    final candidates =
        detail.questions.where((q) => q.status == 'draft').toList();
    final next = candidates.isEmpty ? null : candidates.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (current == null)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.pause_circle_outline_rounded,
                      size: 34, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 10),
                  Text(
                    l10n.sessionNoOpenQuestionTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(l10n.sessionNoOpenQuestionBody),
                  if (detail.session.status == 'open' && next != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _run(() => _repository.openQuestion(next.id)),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text('${l10n.sessionOpenQuestion}: ${next.title}'),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          _QuestionCard(
            question: current,
            sessionStatus: detail.session.status,
            busy: _busy,
            featured: true,
            onOpen: () => _run(() => _repository.openQuestion(current.id)),
            onClose: () => _run(() => _repository.closeQuestion(current.id)),
            onDelete: () => _run(() => _repository.deleteQuestion(current.id)),
          ),
        const SizedBox(height: 14),
        _QuickJoinCard(session: detail.session),
      ],
    );
  }

  Widget _buildQuestionsSection(LiveSessionDetail detail) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.sessionQuestionsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            if (detail.session.status == 'draft')
              FilledButton.icon(
                onPressed: _busy ? null : _addQuestion,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.sessionAddQuestion),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (detail.questions.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(l10n.sessionNoQuestions),
            ),
          )
        else
          ...detail.questions.map(
            (question) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _QuestionCard(
                question: question,
                sessionStatus: detail.session.status,
                busy: _busy,
                onOpen: () => _run(() => _repository.openQuestion(question.id)),
                onClose: () =>
                    _run(() => _repository.closeQuestion(question.id)),
                onDelete: () =>
                    _run(() => _repository.deleteQuestion(question.id)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAccessSection(LiveSessionDetail detail) {
    final l10n = AppLocalizations.of(context)!;
    final session = detail.session;
    final controlled =
        session.accessMode == LiveSessionAccessMode.controlledTokenPool;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuickJoinCard(session: session),
        const SizedBox(height: 14),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controlled
                      ? l10n.sessionAccessPassesTitle
                      : l10n.sessionAccessOpen,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  controlled
                      ? l10n.sessionControlledAccessInstructions
                      : l10n.sessionOpenAccessInstructions,
                ),
                const SizedBox(height: 14),
                if (controlled) ...[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _SmallMetric(
                        label: l10n.sessionAccessPassesTitle,
                        value: '${session.tokenCount}',
                      ),
                      _SmallMetric(
                        label: l10n.sessionJoinedParticipants,
                        value: '${session.participantCount}',
                      ),
                      _SmallMetric(
                        label: l10n.sessionAccessesUsed,
                        value: '${session.usedAccessCount}',
                      ),
                    ],
                  ),
                  if (session.tokenCount > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.sessionExistingPassesHidden,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (session.status == 'draft' || session.status == 'open')
                    FilledButton.icon(
                      onPressed: _busy ? null : _generatePasses,
                      icon: const Icon(Icons.qr_code_2_rounded),
                      label: Text(l10n.sessionGenerateTokens),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(LiveSessionDetail detail) {
    final l10n = AppLocalizations.of(context)!;
    final session = detail.session;
    final access =
        session.accessMode == LiveSessionAccessMode.controlledTokenPool
            ? l10n.sessionAccessControlled
            : l10n.sessionAccessOpen;
    final visibility = switch (session.resultsVisibility) {
      LiveSessionResultsVisibility.live => l10n.sessionResultsLive,
      LiveSessionResultsVisibility.afterVote => l10n.sessionResultsAfterVote,
      LiveSessionResultsVisibility.afterClose => l10n.sessionResultsAfterClose,
      LiveSessionResultsVisibility.organizerOnly =>
        l10n.sessionResultsOrganizerOnly,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.sessionConfigurationTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 14),
            _SettingRow(label: l10n.sessionAccessMode, value: access),
            _SettingRow(
                label: l10n.sessionResultsVisibility, value: visibility),
            _SettingRow(
              label: l10n.sessionExpectedParticipants,
              value: '${session.expectedParticipants}',
            ),
            _SettingRow(
              label: l10n.sessionRetentionLabel,
              value: l10n.sessionRetentionValue(session.rawRetention),
            ),
            const Divider(height: 28),
            Text(l10n.sessionNonBindingNotice),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (session.status == 'draft')
                  FilledButton.icon(
                    onPressed: _busy ? null : _openSession,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.sessionOpenAction),
                  ),
                if (session.status == 'open')
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : _closeSession,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text(l10n.sessionCloseAction),
                  ),
                if (session.reportId != null)
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRouter.publicVerifiedSessionPath(session.reportId!),
                    ),
                    icon: const Icon(Icons.verified_outlined),
                    label: Text(l10n.verifiedResultTitle),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlRoomHeader extends StatelessWidget {
  final LiveSessionDetail detail;
  final bool busy;
  final VoidCallback onStage;
  final VoidCallback onOpenSession;
  final VoidCallback onCloseSession;
  final VoidCallback? onReport;

  const _ControlRoomHeader({
    required this.detail,
    required this.busy,
    required this.onStage,
    required this.onOpenSession,
    required this.onCloseSession,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = detail.session;
    final theme = Theme.of(context);
    final logo = session.organizationLogoUrl?.trim() ?? '';
    final status = switch (session.status) {
      'open' => l10n.sessionStatusOpen,
      'closed' => l10n.sessionStatusClosed,
      _ => l10n.sessionStatusDraft,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
                  child:
                      logo.isEmpty ? const Icon(Icons.apartment_rounded) : null,
                ),
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
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(Icons.verified_rounded,
                              size: 17, color: theme.colorScheme.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(l10n.sessionControlRoomHint),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    session.status == 'open'
                        ? Icons.sensors_rounded
                        : Icons.circle_outlined,
                    size: 18,
                  ),
                  label: Text(status,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : onStage,
                  icon: const Icon(Icons.present_to_all_rounded),
                  label: Text(l10n.sessionStageAction),
                ),
                if (session.status == 'draft')
                  FilledButton.icon(
                    onPressed: busy ? null : onOpenSession,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.sessionOpenAction),
                  ),
                if (session.status == 'open')
                  FilledButton.tonalIcon(
                    onPressed: busy ? null : onCloseSession,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text(l10n.sessionCloseAction),
                  ),
                if (onReport != null)
                  FilledButton.icon(
                    onPressed: onReport,
                    icon: const Icon(Icons.verified_rounded),
                    label: Text(l10n.verifiedResultTitle),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final LiveSessionDetail detail;

  const _KpiGrid({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = detail.session;
    final closed = detail.closedQuestionCount;
    final total = detail.questions.length;
    final items = <_KpiData>[
      _KpiData(Icons.people_alt_outlined, '${session.participantCount}',
          l10n.sessionJoinedParticipants),
      _KpiData(Icons.how_to_reg_outlined, '${session.usedAccessCount}',
          l10n.sessionAccessesUsed),
      _KpiData(Icons.ballot_outlined, '${session.responseCount}',
          l10n.sessionBallotsRecorded),
      _KpiData(Icons.checklist_rounded, '$closed/$total',
          l10n.sessionQuestionsCompleted),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 880
            ? 4
            : constraints.maxWidth >= 520
                ? 2
                : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map(
                  (item) => SizedBox(width: width, child: _KpiCard(data: item)))
              .toList(),
        );
      },
    );
  }
}

class _KpiData {
  final IconData icon;
  final String value;
  final String label;

  const _KpiData(this.icon, this.value, this.label);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(data.icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.value,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  Text(data.label, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _SectionSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = <(IconData, String)>[
      (Icons.sensors_rounded, l10n.sessionSectionLive),
      (Icons.quiz_outlined, l10n.sessionSectionQuestions),
      (Icons.qr_code_2_rounded, l10n.sessionSectionAccess),
      (Icons.tune_rounded, l10n.sessionSectionSettings),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(entries.length, (index) {
          final entry = entries[index];
          return Padding(
            padding:
                EdgeInsets.only(right: index == entries.length - 1 ? 0 : 8),
            child: ChoiceChip(
              selected: selected == index,
              onSelected: (_) => onChanged(index),
              avatar: Icon(entry.$1, size: 18),
              label: Text(entry.$2),
            ),
          );
        }),
      ),
    );
  }
}

class _QuickJoinCard extends StatelessWidget {
  final LiveSessionSummary session;

  const _QuickJoinCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final joinUrl = AppRouter.publicSessionJoinUrl(session.joinCode);
    final controlled =
        session.accessMode == LiveSessionAccessMode.controlledTokenPool;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final qr = DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: QrImageView(data: joinUrl, size: 150),
              ),
            );
            final info = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controlled
                      ? l10n.sessionAccessControlled
                      : l10n.sessionAccessOpen,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  controlled
                      ? l10n.sessionControlledAccessInstructions
                      : l10n.sessionOpenAccessInstructions,
                ),
                const SizedBox(height: 12),
                Text(l10n.sessionJoinCode),
                SelectableText(
                  session.joinCode,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 8),
                SelectableText(joinUrl),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Share.share(joinUrl),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.sessionShareJoin),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: joinUrl),
                      ),
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(l10n.sessionCopyJoinLink),
                    ),
                  ],
                ),
              ],
            );
            if (constraints.maxWidth < 620) {
              return Column(
                children: [
                  qr,
                  const SizedBox(height: 16),
                  Align(alignment: Alignment.centerLeft, child: info),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [qr, const SizedBox(width: 24), Expanded(child: info)],
            );
          },
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final LiveQuestion question;
  final String sessionStatus;
  final bool busy;
  final bool featured;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.sessionStatus,
    required this.busy,
    required this.onOpen,
    required this.onClose,
    required this.onDelete,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = question.responseCount;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(featured ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (question.isOpen) ...[
                  Icon(Icons.sensors_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    question.title,
                    style: (featured
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 10),
                Chip(label: Text(l10n.sessionResponses(total))),
              ],
            ),
            const SizedBox(height: 12),
            ...question.options.map((option) {
              final label = _optionLabel(l10n, option);
              final ratio = total == 0 ? 0.0 : option.votes / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(label)),
                        Text(
                            '${option.votes} · ${(ratio * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0).toDouble()),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (sessionStatus == 'open' && !question.isOpen)
                  OutlinedButton.icon(
                    onPressed: busy ? null : onOpen,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.sessionOpenQuestion),
                  ),
                if (question.isOpen)
                  FilledButton.tonalIcon(
                    onPressed: busy ? null : onClose,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text(l10n.sessionCloseQuestion),
                  ),
                if (sessionStatus == 'draft')
                  TextButton.icon(
                    onPressed: busy ? null : onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.commonDeleteButton),
                  ),
              ],
            ),
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

class _SmallMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SmallMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(child: Text(value)),
      label: Text(label),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _QuestionDraft {
  final String title;
  final LiveQuestionType type;
  final List<String> options;
  final int minSelections;
  final int maxSelections;

  const _QuestionDraft({
    required this.title,
    required this.type,
    required this.options,
    required this.minSelections,
    required this.maxSelections,
  });
}

class _AddQuestionDialog extends StatefulWidget {
  const _AddQuestionDialog();

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  final _title = TextEditingController();
  final _options = TextEditingController();
  final _min = TextEditingController(text: '1');
  final _max = TextEditingController(text: '2');
  LiveQuestionType _type = LiveQuestionType.yesNo;

  @override
  void dispose() {
    _title.dispose();
    _options.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final choices = _type != LiveQuestionType.yesNo;
    return AlertDialog(
      title: Text(l10n.sessionAddQuestion),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration:
                    InputDecoration(labelText: l10n.sessionQuestionTitle),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LiveQuestionType>(
                initialValue: _type,
                decoration:
                    InputDecoration(labelText: l10n.sessionQuestionType),
                items: [
                  DropdownMenuItem(
                    value: LiveQuestionType.yesNo,
                    child: Text(l10n.sessionTypeYesNo),
                  ),
                  DropdownMenuItem(
                    value: LiveQuestionType.singleChoice,
                    child: Text(l10n.sessionTypeSingle),
                  ),
                  DropdownMenuItem(
                    value: LiveQuestionType.multipleChoice,
                    child: Text(l10n.sessionTypeMultiple),
                  ),
                ],
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
              if (choices) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _options,
                  minLines: 3,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: l10n.sessionOptions,
                    helperText: l10n.sessionOptionHint,
                  ),
                ),
              ],
              if (_type == LiveQuestionType.multipleChoice) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _min,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: l10n.sessionMinSelections),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _max,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: l10n.sessionMaxSelections),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancelButton),
        ),
        FilledButton(
          onPressed: () {
            final title = _title.text.trim();
            final options = _options.text
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            if (title.isEmpty || (choices && options.length < 2)) {
              return;
            }
            final min = _type == LiveQuestionType.multipleChoice
                ? int.tryParse(_min.text) ?? 1
                : 1;
            final max = _type == LiveQuestionType.multipleChoice
                ? int.tryParse(_max.text) ?? 1
                : 1;
            if (min < 1 || max < min || (choices && max > options.length)) {
              return;
            }
            Navigator.of(context).pop(
              _QuestionDraft(
                title: title,
                type: _type,
                options: options,
                minSelections: min,
                maxSelections: max,
              ),
            );
          },
          child: Text(l10n.sessionAddAction),
        ),
      ],
    );
  }
}

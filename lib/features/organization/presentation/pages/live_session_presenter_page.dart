import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/domain/organization/repositories/organization_repository.dart';
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
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final detail = await _repository.getOrganizerSession(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      await _load(silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addQuestion() async {
    final result = await showDialog<_QuestionDraft>(
      context: context,
      builder: (_) => const _AddQuestionDialog(),
    );
    if (result == null) return;
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

  Future<void> _generateTokens() async {
    final detail = _detail!;
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: detail.session.expectedParticipants.toString(),
    );
    final count = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sessionGenerateTokens),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration:
              InputDecoration(labelText: l10n.sessionGenerateTokensCount),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              int.tryParse(controller.text.trim()),
            ),
            child: Text(l10n.sessionGenerateTokens),
          ),
        ],
      ),
    );
    controller.dispose();
    if (count == null || count < 1) return;

    setState(() => _busy = true);
    try {
      final tokens = await _repository.generateTokens(
        sessionId: widget.sessionId,
        count: count,
      );
      if (!mounted) return;
      final text = tokens.join('\n');
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.sessionTokensOneTimeTitle),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.sessionTokensOneTimeBody),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: SingleChildScrollView(
                    child: SelectableText(text),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(l10n.sessionCopyTokens),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.sessionTokensSavedAction),
            ),
          ],
        ),
      );
      await _load(silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
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
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final reportId = await _repository.closeSession(widget.sessionId);
      await _load(silent: true);
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRouter.publicVerifiedSessionPath(reportId),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detail = _detail;
    if (_loading && detail == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionPresenterTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionPresenterTitle)),
        body: Center(
            child: Text(_error?.toString() ?? l10n.publicProfileLoadError)),
      );
    }

    final session = detail.session;
    final joinUrl = AppRouter.publicSessionJoinUrl(session.joinCode);
    final statusLabel = switch (session.status) {
      'open' => l10n.sessionStatusOpen,
      'closed' => l10n.sessionStatusClosed,
      _ => l10n.sessionStatusDraft,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionPresenterTitle),
        actions: [
          IconButton(
              onPressed: _busy ? null : _load,
              icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        children: [
          Text(session.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
              '$statusLabel · ${l10n.sessionResponses(session.responseCount)}'),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final qr = QrImageView(data: joinUrl, size: 170);
                  final info = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.sessionJoinCode,
                          style: Theme.of(context).textTheme.labelLarge),
                      SelectableText(
                        session.joinCode,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(joinUrl),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () => Share.share(joinUrl),
                        icon: const Icon(Icons.share_outlined),
                        label: Text(l10n.sessionShareJoin),
                      ),
                    ],
                  );
                  if (constraints.maxWidth < 520) {
                    return Column(
                        children: [qr, const SizedBox(height: 12), info]);
                  }
                  return Row(children: [
                    qr,
                    const SizedBox(width: 24),
                    Expanded(child: info)
                  ]);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if ((session.status == 'draft' || session.status == 'open') &&
                  session.accessMode ==
                      LiveSessionAccessMode.controlledTokenPool)
                OutlinedButton.icon(
                  onPressed: _busy ? null : _generateTokens,
                  icon: const Icon(Icons.key_rounded),
                  label: Text(
                      '${l10n.sessionGenerateTokens} (${session.tokenCount})'),
                ),
              if (session.status == 'draft')
                FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () =>
                          _run(() => _repository.openSession(widget.sessionId)),
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
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(l10n.sessionQuestionsTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              if (session.status == 'draft')
                OutlinedButton.icon(
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
                    padding: const EdgeInsets.all(18),
                    child: Text(l10n.sessionNoQuestions)))
          else
            ...detail.questions.map(
              (question) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuestionCard(
                  question: question,
                  sessionStatus: session.status,
                  busy: _busy,
                  onOpen: () =>
                      _run(() => _repository.openQuestion(question.id)),
                  onClose: () =>
                      _run(() => _repository.closeQuestion(question.id)),
                  onDelete: () =>
                      _run(() => _repository.deleteQuestion(question.id)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(l10n.sessionNonBindingNotice),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final LiveQuestion question;
  final String sessionStatus;
  final bool busy;
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
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = question.responseCount;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(question.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700))),
                Text(l10n.sessionResponses(total)),
              ],
            ),
            const SizedBox(height: 10),
            ...question.options.map((option) {
              final label = _optionLabel(l10n, option);
              final ratio = total == 0 ? 0.0 : option.votes / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(label)),
                      Text('${option.votes}')
                    ]),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0).toDouble()),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (sessionStatus == 'open' && !question.isOpen)
                  OutlinedButton(
                      onPressed: busy ? null : onOpen,
                      child: Text(l10n.sessionOpenQuestion)),
                if (question.isOpen)
                  FilledButton.tonal(
                      onPressed: busy ? null : onClose,
                      child: Text(l10n.sessionCloseQuestion)),
                if (sessionStatus == 'draft')
                  TextButton.icon(
                      onPressed: busy ? null : onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.commonDeleteButton)),
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
                      InputDecoration(labelText: l10n.sessionQuestionTitle)),
              const SizedBox(height: 12),
              DropdownButtonFormField<LiveQuestionType>(
                initialValue: _type,
                decoration:
                    InputDecoration(labelText: l10n.sessionQuestionType),
                items: [
                  DropdownMenuItem(
                      value: LiveQuestionType.yesNo,
                      child: Text(l10n.sessionTypeYesNo)),
                  DropdownMenuItem(
                      value: LiveQuestionType.singleChoice,
                      child: Text(l10n.sessionTypeSingle)),
                  DropdownMenuItem(
                      value: LiveQuestionType.multipleChoice,
                      child: Text(l10n.sessionTypeMultiple)),
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
                      helperText: l10n.sessionOptionHint),
                ),
              ],
              if (_type == LiveQuestionType.multipleChoice) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _min,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: l10n.sessionMinSelections))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: TextField(
                          controller: _max,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: l10n.sessionMaxSelections))),
                ]),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancelButton)),
        FilledButton(
          onPressed: () {
            final title = _title.text.trim();
            final options = _options.text
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            if (title.isEmpty || (choices && options.length < 2)) return;
            Navigator.of(context).pop(
              _QuestionDraft(
                title: title,
                type: _type,
                options: options,
                minSelections: _type == LiveQuestionType.multipleChoice
                    ? int.tryParse(_min.text) ?? 1
                    : 1,
                maxSelections: _type == LiveQuestionType.multipleChoice
                    ? int.tryParse(_max.text) ?? 1
                    : 1,
              ),
            );
          },
          child: Text(l10n.sessionAddAction),
        ),
      ],
    );
  }
}

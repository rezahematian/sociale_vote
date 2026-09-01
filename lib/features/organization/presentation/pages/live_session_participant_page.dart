import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/domain/organization/repositories/organization_repository.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/current_location_uri.dart';
import 'package:sociale_vote/shared/services/egress_policy_service.dart';

class LiveSessionParticipantPage extends StatefulWidget {
  final String joinCode;

  const LiveSessionParticipantPage({
    super.key,
    required this.joinCode,
  });

  @override
  State<LiveSessionParticipantPage> createState() =>
      _LiveSessionParticipantPageState();
}

class _LiveSessionParticipantPageState extends State<LiveSessionParticipantPage>
    with WidgetsBindingObserver {
  late final OrganizationRepository _repository;
  final EgressPolicyService _egressPolicy = EgressPolicyService.instance;
  final _tokenController = TextEditingController();
  LiveSessionDetail? _detail;
  String? _participantSecret;
  String? _receipt;
  String? _detectedPass;
  String? _joinError;
  LiveQuestion? _visibleResults;
  final Set<String> _selected = <String>{};
  bool _loading = true;
  bool _joining = false;
  bool _voting = false;
  bool _hasVotedOpenQuestion = false;
  bool _autoJoinAttempted = false;
  bool _showManualPass = false;
  Object? _error;
  Timer? _timer;
  bool _refreshInFlight = false;
  bool _appVisible = true;

  @override
  void initState() {
    super.initState();
    _repository = AppDI.instance.organizationRepository;
    final currentUri = currentLocationUri();
    final queryPass = currentUri.queryParameters['pass'];
    final fragmentPass = _passFromFragment(currentUri.fragment);
    final pass = (queryPass ?? fragmentPass)?.trim().toUpperCase();
    if (pass != null && pass.isNotEmpty) {
      _detectedPass = pass;
      _tokenController.text = pass;
    }
    WidgetsBinding.instance.addObserver(this);
    _egressPolicy.addListener(_handleEgressPolicyChanged);
    unawaited(_egressPolicy.initialize());
    unawaited(
      _restoreParticipantSession().whenComplete(_scheduleNextRefresh),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _egressPolicy.removeListener(_handleEgressPolicyChanged);
    WidgetsBinding.instance.removeObserver(this);
    _tokenController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appVisible = state == AppLifecycleState.resumed;
    if (_appVisible) {
      _scheduleNextRefresh();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _handleEgressPolicyChanged() {
    if (mounted) _scheduleNextRefresh();
  }

  EgressSessionActivity _sessionActivity() {
    final detail = _detail;
    if (detail == null || detail.session.status == 'draft') {
      return EgressSessionActivity.idle;
    }
    if (detail.openQuestion != null &&
        _participantSecret != null &&
        !_hasVotedOpenQuestion) {
      return EgressSessionActivity.active;
    }
    return EgressSessionActivity.waiting;
  }

  void _scheduleNextRefresh() {
    _timer?.cancel();
    _timer = null;
    if (!mounted || !_appVisible || _detail?.session.status == 'closed') {
      return;
    }

    final delay = EgressPolicyService.sessionRefreshDelayFor(
      mode: _egressPolicy.mode,
      activity: _sessionActivity(),
    );
    if (delay == null) return;
    _timer = Timer(delay, _runAutomaticRefresh);
  }

  Future<void> _runAutomaticRefresh() async {
    if (!mounted) return;
    final routeVisible = ModalRoute.of(context)?.isCurrent ?? true;
    if (!_appVisible || !routeVisible || _loading || _joining || _voting) {
      _scheduleNextRefresh();
      return;
    }

    final allowed = await _egressPolicy.tryConsumeAutomatic(
      EgressAutomaticTraffic.sessionParticipant,
    );
    if (allowed && mounted) {
      await _refreshState(silent: true);
    }
    _scheduleNextRefresh();
  }

  String? _passFromFragment(String fragment) {
    if (fragment.trim().isEmpty) return null;
    try {
      return Uri.splitQueryString(fragment)['pass'];
    } catch (_) {
      return null;
    }
  }

  String get _participantStorageKey =>
      'social_vote_session_participant_${widget.joinCode.trim().toUpperCase()}';

  Future<void> _restoreParticipantSession() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_participantStorageKey)?.trim();
      if (saved != null && saved.isNotEmpty) {
        _participantSecret = saved;
      }
    } catch (_) {
      // Local persistence is convenience only. Server rules remain authoritative.
    }
    await _refreshState();
  }

  Future<void> _persistParticipantSecret(String secret) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_participantStorageKey, secret);
    } catch (_) {
      // Safe to continue without local persistence.
    }
  }

  Future<void> _refreshState({bool silent = false}) async {
    if (_refreshInFlight) {
      return;
    }
    _refreshInFlight = true;

    if (!silent && mounted) setState(() => _loading = true);
    try {
      final raw = await _repository.getPublicSessionState(
        joinCode: widget.joinCode,
        participantSecret: _participantSecret,
      );
      if (!mounted) return;
      final previousOpen = _detail?.openQuestion?.id;
      final nextOpen = raw.openQuestion?.id;
      setState(() {
        _detail = raw;
        _loading = false;
        _error = null;
        if (previousOpen != nextOpen) {
          _selected.clear();
          _receipt = null;
          _visibleResults = null;
        }
        _hasVotedOpenQuestion = raw.hasVotedOpenQuestion;
      });

      if (_participantSecret != null && nextOpen != null) {
        await _refreshResults(raw.openQuestion!);
      }

      final shouldAutoJoin = _participantSecret == null &&
          _detectedPass != null &&
          !_autoJoinAttempted &&
          raw.session.status == 'open' &&
          raw.session.accessMode == LiveSessionAccessMode.controlledTokenPool;
      if (shouldAutoJoin) {
        _autoJoinAttempted = true;
        await _join();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    } finally {
      _refreshInFlight = false;
      if (mounted) _scheduleNextRefresh();
    }
  }

  String _friendlyError(AppLocalizations l10n, Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('open session not found') ||
        raw.contains('session not available') ||
        raw.contains('p0002')) {
      return l10n.sessionNotStartedBody;
    }
    if (raw.contains('participant token') ||
        raw.contains('42501') ||
        raw.contains('already voted')) {
      return l10n.sessionAccessPassInvalid;
    }
    if (raw.contains('participant limit')) {
      return l10n.sessionPilotLimit;
    }
    return l10n.publicProfileLoadError;
  }

  Future<void> _join() async {
    if (_joining) return;
    final detail = _detail;
    if (detail == null || detail.session.status != 'open') return;
    final controlled =
        detail.session.accessMode == LiveSessionAccessMode.controlledTokenPool;
    final normalizedPass = _tokenController.text.trim().toUpperCase();
    if (controlled && normalizedPass.isEmpty) return;

    setState(() {
      _joining = true;
      _joinError = null;
    });
    try {
      final joined = await _repository.joinPublicSession(
        joinCode: widget.joinCode,
        token: controlled ? normalizedPass : null,
      );
      if (!mounted) return;
      setState(() {
        _participantSecret = joined.participantSecret;
        _detail = joined.detail;
        _error = null;
        _joinError = null;
        _hasVotedOpenQuestion = joined.detail.hasVotedOpenQuestion;
      });
      await _persistParticipantSecret(joined.participantSecret);
      final question = joined.detail.openQuestion;
      if (question != null) await _refreshResults(question);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _joinError = _friendlyError(l10n, e);
        _showManualPass = true;
      });
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _vote(LiveQuestion question) async {
    if (_participantSecret == null || _voting || _selected.isEmpty) return;
    if (_selected.length < question.minSelections ||
        _selected.length > question.maxSelections) {
      return;
    }
    setState(() => _voting = true);
    try {
      final receipt = await _repository.submitPublicVote(
        joinCode: widget.joinCode,
        participantSecret: _participantSecret!,
        questionId: question.id,
        optionIds: _selected.toList(growable: false),
      );
      if (!mounted) return;
      setState(() {
        _receipt = receipt;
        _hasVotedOpenQuestion = true;
      });
      await _refreshResults(question);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(l10n, e))),
      );
    } finally {
      if (mounted) setState(() => _voting = false);
    }
  }

  Future<void> _refreshResults(LiveQuestion question) async {
    final secret = _participantSecret;
    if (secret == null) return;
    try {
      final results = await _repository.getPublicResults(
        joinCode: widget.joinCode,
        participantSecret: secret,
        questionId: question.id,
      );
      if (!mounted) return;
      setState(() => _visibleResults = results);
    } catch (_) {
      // Results may intentionally be unavailable under the Session policy.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detail = _detail;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionParticipantTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: _loading && detail == null
              ? const Center(child: CircularProgressIndicator())
              : detail == null
                  ? _ParticipantErrorState(
                      message: _error == null
                          ? l10n.publicProfileLoadError
                          : _friendlyError(l10n, _error!),
                      onRetry: _refreshState,
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshState,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                        children: [
                          _ParticipantBrandHeader(session: detail.session),
                          const SizedBox(height: 16),
                          _SessionIntroCard(session: detail.session),
                          const SizedBox(height: 14),
                          if (detail.session.status == 'draft')
                            _NotStartedCard()
                          else if (detail.session.status == 'closed')
                            _buildClosedState(detail, l10n)
                          else if (_participantSecret == null)
                            _buildJoinCard(detail, l10n)
                          else
                            _buildVoteArea(detail, l10n),
                          const SizedBox(height: 16),
                          Text(
                            l10n.sessionNonBindingNotice,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildClosedState(
    LiveSessionDetail detail,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.task_alt_rounded, size: 44),
            const SizedBox(height: 10),
            Text(
              l10n.sessionStatusClosed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            if (detail.session.reportId != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRouter.publicVerifiedSessionPath(detail.session.reportId!),
                ),
                icon: const Icon(Icons.verified_outlined),
                label: Text(l10n.verifiedResultTitle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJoinCard(LiveSessionDetail detail, AppLocalizations l10n) {
    final controlled =
        detail.session.accessMode == LiveSessionAccessMode.controlledTokenPool;
    final detected = controlled && _detectedPass != null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  controlled ? Icons.key_rounded : Icons.public_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controlled
                        ? l10n.sessionAccessControlled
                        : l10n.sessionAccessOpen,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              detected
                  ? l10n.sessionAccessPassAutomatic
                  : controlled
                      ? l10n.sessionAccessControlledHint
                      : l10n.sessionAccessOpenHint,
            ),
            if (detected) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.qr_code_2_rounded),
                title: Text(l10n.sessionAccessPassDetected),
                subtitle: Text(l10n.sessionNoAccountRequired),
              ),
            ],
            if (controlled && (!detected || _showManualPass)) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _tokenController,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.sessionAccessPass,
                  hintText: l10n.sessionTokenHint,
                  prefixIcon: const Icon(Icons.key_outlined),
                ),
              ),
            ],
            if (_joinError != null) ...[
              const SizedBox(height: 10),
              Text(
                _joinError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _joining ? null : _join,
              icon: _joining
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(l10n.sessionJoinAction),
            ),
            if (controlled && detected && !_showManualPass)
              TextButton(
                onPressed: () => setState(() => _showManualPass = true),
                child: Text(l10n.sessionAccessPassFallback),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteArea(LiveSessionDetail detail, AppLocalizations l10n) {
    final question = detail.openQuestion;
    if (question == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 40),
              const SizedBox(height: 12),
              Text(
                l10n.sessionNoOpenQuestionTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(l10n.sessionNoOpenQuestionBody, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final alreadyVoted = _receipt != null || _hasVotedOpenQuestion;
    final index = (detail.indexOfQuestion(question.id) ?? 0) + 1;
    final total = detail.questions.length;
    final canSubmit = _selected.length >= question.minSelections &&
        _selected.length <= question.maxSelections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l10n.sessionCurrentQuestion} · $index/$total',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (question.type == LiveQuestionType.multipleChoice)
                      Text(
                          '${question.minSelections}–${question.maxSelections}'),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  question.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                ),
                const SizedBox(height: 16),
                if (question.type == LiveQuestionType.multipleChoice)
                  ...question.options.map(
                    (option) => _multipleOptionTile(
                      question,
                      option,
                      alreadyVoted,
                      l10n,
                    ),
                  )
                else
                  RadioGroup<String>(
                    groupValue: _selected.isEmpty ? null : _selected.first,
                    onChanged: (value) {
                      if (alreadyVoted || value == null) return;
                      setState(() {
                        _selected
                          ..clear()
                          ..add(value);
                      });
                    },
                    child: Column(
                      children: question.options
                          .map(
                            (option) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: RadioListTile<String>(
                                value: option.id,
                                enabled: !alreadyVoted,
                                title: Text(
                                  _optionLabel(l10n, option),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                const SizedBox(height: 12),
                if (alreadyVoted)
                  _VoteReceivedCard(receipt: _receipt)
                else
                  FilledButton.icon(
                    onPressed:
                        _voting || !canSubmit ? null : () => _vote(question),
                    icon: _voting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.how_to_vote_rounded),
                    label: Text(l10n.sessionVoteAction),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_visibleResults != null)
          _ParticipantResults(question: _visibleResults!)
        else if (alreadyVoted)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(l10n.sessionResultsUnavailable),
            ),
          ),
      ],
    );
  }

  Widget _multipleOptionTile(
    LiveQuestion question,
    LiveOption option,
    bool disabled,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: _selected.contains(option.id),
        onChanged: disabled
            ? null
            : (checked) {
                setState(() {
                  if (checked == true) {
                    if (_selected.length < question.maxSelections) {
                      _selected.add(option.id);
                    }
                  } else {
                    _selected.remove(option.id);
                  }
                });
              },
        title: Text(
          _optionLabel(l10n, option),
          style: const TextStyle(fontWeight: FontWeight.w700),
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

class _ParticipantBrandHeader extends StatelessWidget {
  final LiveSessionSummary session;

  const _ParticipantBrandHeader({required this.session});

  @override
  Widget build(BuildContext context) {
    final name = session.organizationName?.trim() ?? '';
    final logo = session.organizationLogoUrl?.trim() ?? '';
    final cover = session.organizationCoverUrl?.trim() ?? '';
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cover.isNotEmpty)
            SizedBox(
              height: 96,
              child: Image.network(cover, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
                  child:
                      logo.isEmpty ? const Icon(Icons.apartment_rounded) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Social Vote' : name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 17, color: theme.colorScheme.primary),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context)!
                                .organizationVerifiedLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionIntroCard extends StatelessWidget {
  final LiveSessionSummary session;

  const _SessionIntroCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.lock_open_rounded, size: 17),
                  label: Text(l10n.sessionNoAccountRequired),
                ),
                Chip(
                  avatar: const Icon(Icons.shield_outlined, size: 17),
                  label: Text(
                    session.accessMode ==
                            LiveSessionAccessMode.controlledTokenPool
                        ? l10n.sessionAccessControlled
                        : l10n.sessionAccessOpen,
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.schedule_outlined, size: 17),
                  label: Text(l10n.sessionRetentionValue(session.rawRetention)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(l10n.sessionPrivacyNotice),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.privacy),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: Text(l10n.sessionPrivacyPolicyAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotStartedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(Icons.schedule_rounded, size: 42),
            const SizedBox(height: 12),
            Text(
              l10n.sessionNotStartedTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(l10n.sessionNotStartedBody, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _VoteReceivedCard extends StatelessWidget {
  final String? receipt;

  const _VoteReceivedCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 38, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              l10n.sessionVoteReceived,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            if (receipt != null) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(l10n.sessionReceiptDetails),
                children: [SelectableText(receipt!)],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ParticipantResults extends StatelessWidget {
  final LiveQuestion question;

  const _ParticipantResults({required this.question});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = question.responseCount;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.verifiedCertificateResultsSection,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            ...question.options.map((option) {
              final label = switch (option.optionKey) {
                'yes' => l10n.sessionOptionYes,
                'no' => l10n.sessionOptionNo,
                _ => option.label ?? '',
              };
              final ratio = total == 0 ? 0.0 : option.votes / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
          ],
        ),
      ),
    );
  }
}

class _ParticipantErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ParticipantErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(MaterialLocalizations.of(context)
                  .refreshIndicatorSemanticLabel),
            ),
          ],
        ),
      ),
    );
  }
}

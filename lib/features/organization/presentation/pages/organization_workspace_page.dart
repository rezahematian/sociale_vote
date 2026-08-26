import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/features/organization/application/organization_workspace_controller.dart';
import 'package:sociale_vote/features/organization/presentation/pages/create_live_session_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/live_session_presenter_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/organization_profile_editor_page.dart';
import 'package:sociale_vote/features/organization/presentation/widgets/organization_cover_header.dart';
import 'package:sociale_vote/features/poll/presentation/pages/create_poll_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/create_post_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/public_user_profile_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class OrganizationWorkspacePage extends StatefulWidget {
  const OrganizationWorkspacePage({super.key});

  @override
  State<OrganizationWorkspacePage> createState() =>
      _OrganizationWorkspacePageState();
}

class _OrganizationWorkspacePageState extends State<OrganizationWorkspacePage> {
  late final OrganizationWorkspaceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppDI.instance.createOrganizationWorkspaceController();
    _controller.addListener(_onChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _editProfile() async {
    final contextData = _controller.context;
    if (contextData == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => OrganizationProfileEditorPage(controller: _controller),
      ),
    );
    if (changed == true) await _controller.load(bootstrapIfNeeded: false);
  }

  Future<void> _createSession() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => CreateLiveSessionPage(
          repository: AppDI.instance.organizationRepository,
        ),
      ),
    );
    if (!mounted || id == null) return;
    await _controller.refreshSessions();
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LiveSessionPresenterPage(sessionId: id),
      ),
    );
    await _controller.refreshSessions();
  }

  Future<void> _createVoice() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const CreatePostPage(
          preferOrganizationPublisher: true,
        ),
      ),
    );
  }

  Future<void> _createVote() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const CreatePollPage(
          preferOrganizationPublisher: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = _controller.context;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.organizationWorkspaceTitle),
        actions: [
          IconButton(
            tooltip: Localizations.localeOf(context).languageCode == 'it'
                ? 'Come funziona Social Vote'
                : Localizations.localeOf(context).languageCode == 'de'
                    ? 'So funktioniert Social Vote'
                    : 'How Social Vote works',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.howItWorks),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: RefreshIndicator(
            onRefresh: () => _controller.load(bootstrapIfNeeded: false),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              children: [
                if (_controller.isLoading && data == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (data == null)
                  _UnavailableState(
                    title: l10n.organizationRequiresVerificationTitle,
                    body: l10n.organizationRequiresVerificationBody,
                    onRetry: () => _controller.load(),
                  )
                else ...[
                  OrganizationCoverHeader(
                    organization: data.organization,
                    verifiedLabel: l10n.organizationVerifiedLabel,
                    compact: true,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          final userId = AppDI.instance.currentUserId?.trim();
                          if (userId == null || userId.isEmpty) return;
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  PublicUserProfilePage(userId: userId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined),
                        label: Text(l10n.organizationViewPublicProfileAction),
                      ),
                      if (data.canManageProfile)
                        FilledButton.tonalIcon(
                          onPressed: _editProfile,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(l10n.organizationEditProfile),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _BusinessWorkspaceExperience(
                    organizationName: data.organization.publicName,
                    verified: data.organization.isVerified,
                    workspaceActive: data.isWorkspaceActive,
                    isFreePilot: data.isFreePilot,
                    canPublish: data.canPublishOfficial,
                    canCreateSession: data.canOperateSessions,
                    membershipRole: data.membershipRole,
                    onCreateVoice: _createVoice,
                    onCreateVote: _createVote,
                    onCreateSession: _createSession,
                  ),
                  const SizedBox(height: 18),
                  _OrganizationDashboard(sessions: _controller.sessions),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.organizationSessionsTitle,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_controller.sessions.isEmpty)
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.meeting_room_outlined, size: 44),
                            const SizedBox(height: 10),
                            Text(
                              l10n.organizationNoSessions,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._controller.sessions.map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SessionTile(
                          session: session,
                          onTap: () async {
                            await Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => LiveSessionPresenterPage(
                                  sessionId: session.id,
                                ),
                              ),
                            );
                            await _controller.refreshSessions();
                          },
                          onReport: session.reportId == null
                              ? null
                              : () => Navigator.of(context).pushNamed(
                                    AppRouter.publicVerifiedSessionPath(
                                      session.reportId!,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BusinessWorkspaceExperience extends StatelessWidget {
  final String organizationName;
  final bool verified;
  final bool workspaceActive;
  final bool isFreePilot;
  final bool canPublish;
  final bool canCreateSession;
  final String membershipRole;
  final VoidCallback onCreateVoice;
  final VoidCallback onCreateVote;
  final VoidCallback onCreateSession;

  const _BusinessWorkspaceExperience({
    required this.organizationName,
    required this.verified,
    required this.workspaceActive,
    required this.isFreePilot,
    required this.canPublish,
    required this.canCreateSession,
    required this.membershipRole,
    required this.onCreateVoice,
    required this.onCreateVote,
    required this.onCreateSession,
  });

  String _text(
    BuildContext context, {
    required String it,
    required String en,
    required String de,
  }) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    if (language == 'it') return it;
    if (language == 'de') return de;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.72),
            colors.surfaceContainerHighest.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded, color: colors.primary),
              Text(
                'Social Vote Business',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Chip(
                avatar: Icon(
                  verified ? Icons.verified_rounded : Icons.gpp_bad_outlined,
                  size: 17,
                ),
                label: Text(organizationName),
              ),
              Chip(
                avatar: Icon(
                  workspaceActive
                      ? Icons.check_circle_outline_rounded
                      : Icons.pause_circle_outline_rounded,
                  size: 17,
                ),
                label: Text(
                  workspaceActive
                      ? _text(context,
                          it: 'Workspace attivo',
                          en: 'Workspace active',
                          de: 'Workspace aktiv')
                      : _text(context,
                          it: 'Workspace non attivo',
                          en: 'Workspace inactive',
                          de: 'Workspace inaktiv'),
                ),
              ),
              Chip(
                avatar: const Icon(Icons.workspace_premium_outlined, size: 17),
                label: Text(
                  isFreePilot
                      ? _text(context,
                          it: 'Business Pilot · gratuito',
                          en: 'Business Pilot · free',
                          de: 'Business Pilot · kostenlos')
                      : 'Business',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _text(
              context,
              it: 'Dalla domanda al risultato verificabile: scegli lo strumento giusto per coinvolgere la tua comunità.',
              en: 'From a question to a verifiable result: choose the right tool to involve your community.',
              de: 'Von der Frage zum überprüfbaren Ergebnis: Wähle das passende Werkzeug für deine Community.',
            ),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    verified && workspaceActive
                        ? Icons.verified_user_rounded
                        : Icons.lock_outline_rounded,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      verified && workspaceActive
                          ? _text(
                              context,
                              it: 'Servizi Business abilitati: l’Organization è verificata e il Workspace è attivo. Il backend resta l’autorità finale.',
                              en: 'Business services enabled: the Organization is verified and the Workspace is active. The backend remains the final authority.',
                              de: 'Business-Dienste aktiviert: Die Organisation ist verifiziert und der Workspace aktiv. Das Backend bleibt maßgeblich.',
                            )
                          : _text(
                              context,
                              it: 'I servizi Business restano bloccati finché l’Organization non è verificata e il Workspace non è attivo.',
                              en: 'Business services stay locked until the Organization is verified and the Workspace is active.',
                              de: 'Business-Dienste bleiben gesperrt, bis die Organisation verifiziert und der Workspace aktiv ist.',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _text(context,
                              it: 'Uso corretto e limiti tecnici',
                              en: 'Fair use and technical limits',
                              de: 'Faire Nutzung und technische Limits'),
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _text(
                            context,
                            it: 'Per sicurezza, stabilità e qualità Social Vote può applicare limiti ragionevoli a creazione account, pubblicazioni, Sessions, partecipazione e richieste simultanee. Durante il pilot i limiti possono essere adeguati; flood, automazione abusiva e tentativi di aggiramento non sono consentiti.',
                            en: 'For security, stability and quality, Social Vote may apply reasonable limits to account creation, publishing, Sessions, participation and concurrent requests. Limits may be adjusted during the pilot; flooding, abusive automation and bypass attempts are not allowed.',
                            de: 'Für Sicherheit, Stabilität und Qualität kann Social Vote angemessene Limits für Kontoerstellung, Veröffentlichungen, Sessions, Teilnahme und gleichzeitige Anfragen anwenden. Im Pilot können Limits angepasst werden; Flooding, missbräuchliche Automatisierung und Umgehungsversuche sind nicht erlaubt.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _BusinessFlowStrip(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 580
                      ? 2
                      : 1;
              const spacing = 12.0;
              final width =
                  (constraints.maxWidth - ((columns - 1) * spacing)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: width,
                    child: _BusinessActionCard(
                      icon: Icons.forum_outlined,
                      title: 'Voce',
                      body: _text(
                        context,
                        it: 'Pubblica un aggiornamento, una proposta o una domanda come Organization.',
                        en: 'Publish an update, proposal or question as the Organization.',
                        de: 'Veröffentliche ein Update, einen Vorschlag oder eine Frage als Organisation.',
                      ),
                      actionLabel: _text(
                        context,
                        it: 'Crea Voce',
                        en: 'Create Voce',
                        de: 'Voce erstellen',
                      ),
                      enabled: canPublish,
                      onPressed: onCreateVoice,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _BusinessActionCard(
                      icon: Icons.how_to_vote_outlined,
                      title: 'Vote',
                      body: _text(
                        context,
                        it: 'Raccogli opinioni dalla community in modo asincrono e pubblico.',
                        en: 'Collect community opinions asynchronously and publicly.',
                        de: 'Sammle Meinungen der Community asynchron und öffentlich.',
                      ),
                      actionLabel: _text(
                        context,
                        it: 'Crea Vote',
                        en: 'Create Vote',
                        de: 'Vote erstellen',
                      ),
                      enabled: canPublish,
                      onPressed: onCreateVote,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _BusinessActionCard(
                      icon: Icons.groups_2_outlined,
                      title: 'Session',
                      body: _text(
                        context,
                        it: 'Conduci una consultazione live con QR, Stage e Verified Result.',
                        en: 'Run a live consultation with QR, Stage and Verified Result.',
                        de: 'Führe eine Live-Konsultation mit QR, Stage und Verified Result durch.',
                      ),
                      actionLabel: _text(
                        context,
                        it: 'Crea Session',
                        en: 'Create Session',
                        de: 'Session erstellen',
                      ),
                      enabled: canCreateSession,
                      onPressed: onCreateSession,
                    ),
                  ),
                ],
              );
            },
          ),
          if (!canPublish || !canCreateSession) ...[
            const SizedBox(height: 12),
            Text(
              _text(
                context,
                it: 'Azioni disponibili in base a verifica, stato Workspace e ruolo ($membershipRole).',
                en: 'Actions are available according to verification, Workspace status and role ($membershipRole).',
                de: 'Aktionen sind je nach Verifizierung, Workspace-Status und Rolle ($membershipRole) verfügbar.',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BusinessActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final bool enabled;
  final VoidCallback onPressed;

  const _BusinessActionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface.withValues(alpha: 0.88),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: Icon(icon),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(body),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: enabled ? onPressed : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessFlowStrip extends StatefulWidget {
  const _BusinessFlowStrip();

  @override
  State<_BusinessFlowStrip> createState() => _BusinessFlowStripState();
}

class _BusinessFlowStripState extends State<_BusinessFlowStrip> {
  Timer? _timer;
  int _activeIndex = 0;

  static const _icons = <IconData>[
    Icons.apartment_rounded,
    Icons.help_outline_rounded,
    Icons.qr_code_2_rounded,
    Icons.touch_app_rounded,
    Icons.bar_chart_rounded,
    Icons.verified_rounded,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!disableAnimations) {
      _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        if (!mounted) return;
        setState(() {
          _activeIndex = (_activeIndex + 1) % _icons.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _label(BuildContext context, int index) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    const it = [
      'Organization',
      'Domanda',
      'QR',
      'Partecipa',
      'Risultati',
      'Verified'
    ];
    const en = [
      'Organization',
      'Question',
      'QR',
      'Participate',
      'Results',
      'Verified'
    ];
    const de = [
      'Organisation',
      'Frage',
      'QR',
      'Teilnahme',
      'Ergebnisse',
      'Verified'
    ];
    if (language == 'it') return it[index];
    if (language == 'de') return de[index];
    return en[index];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_icons.length, (index) {
              final active = index == _activeIndex;
              return Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    width: compact ? 88 : 112,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? colors.primaryContainer
                          : colors.surface.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active
                            ? colors.primary.withValues(alpha: 0.65)
                            : colors.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _icons[index],
                          color:
                              active ? colors.primary : colors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _label(context, index),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontWeight:
                                    active ? FontWeight.w800 : FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (index != _icons.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _OrganizationDashboard extends StatelessWidget {
  final List<LiveSessionSummary> sessions;

  const _OrganizationDashboard({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final live = sessions.where((session) => session.status == 'open').length;
    final reports =
        sessions.where((session) => session.reportId != null).length;
    final items = [
      (
        Icons.dashboard_outlined,
        '${sessions.length}',
        l10n.organizationTotalSessions
      ),
      (Icons.sensors_rounded, '$live', l10n.organizationActiveSessions),
      (Icons.verified_outlined, '$reports', l10n.organizationVerifiedReports),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.organizationDashboardTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 3 : 1;
            final width =
                (constraints.maxWidth - ((columns - 1) * 10)) / columns;
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
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(item.$1,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                item.$2,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item.$3)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final LiveSessionSummary session;
  final VoidCallback onTap;
  final VoidCallback? onReport;

  const _SessionTile({
    required this.session,
    required this.onTap,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final status = switch (session.status) {
      'open' => l10n.sessionStatusOpen,
      'closed' => l10n.sessionStatusClosed,
      _ => l10n.sessionStatusDraft,
    };

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                child: Icon(
                  session.status == 'open'
                      ? Icons.sensors_rounded
                      : session.status == 'closed'
                          ? Icons.task_alt_rounded
                          : Icons.edit_calendar_outlined,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(label: Text(status)),
                        Chip(
                            label: Text(
                                '${l10n.sessionJoinCode}: ${session.joinCode}')),
                        Chip(
                            label: Text(
                                '${session.participantCount} · ${l10n.sessionJoinedParticipants}')),
                        Chip(
                            label: Text(
                                '${session.responseCount} · ${l10n.sessionBallotsRecorded}')),
                      ],
                    ),
                  ],
                ),
              ),
              if (onReport != null)
                IconButton(
                  onPressed: onReport,
                  tooltip: l10n.verifiedResultTitle,
                  icon: const Icon(Icons.verified_rounded),
                )
              else
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableState extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onRetry;

  const _UnavailableState({
    required this.title,
    required this.body,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.apartment_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

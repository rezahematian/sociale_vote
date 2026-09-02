import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/domain/organization/entities/organization_models.dart';
import 'package:sociale_vote/features/organization/application/organization_workspace_controller.dart';
import 'package:sociale_vote/features/organization/presentation/pages/create_live_session_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/live_session_presenter_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/organization_profile_editor_page.dart';
import 'package:sociale_vote/features/organization/presentation/widgets/organization_cover_header.dart';
import 'package:sociale_vote/features/organization/presentation/widgets/organization_external_channel_icon.dart';
import 'package:sociale_vote/features/poll/presentation/pages/create_poll_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/public_user_profile_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/create_post_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

enum _WorkspaceSection {
  overview,
  publish,
  sessions,
  results,
  team,
  organization,
}

String _tr(
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

class OrganizationWorkspacePage extends StatefulWidget {
  const OrganizationWorkspacePage({super.key});

  @override
  State<OrganizationWorkspacePage> createState() =>
      _OrganizationWorkspacePageState();
}

class _OrganizationWorkspacePageState extends State<OrganizationWorkspacePage> {
  late final OrganizationWorkspaceController _controller;
  _WorkspaceSection _section = _WorkspaceSection.overview;

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

  void _openPublicProfile(OrganizationContext data) {
    final userId = AppDI.instance.currentUserId?.trim();
    if (userId == null || userId.isEmpty) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PublicUserProfilePage(
          userId: userId,
          organizationId: data.organization.id,
        ),
      ),
    );
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

  Future<void> _openSession(LiveSessionSummary session) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LiveSessionPresenterPage(sessionId: session.id),
      ),
    );
    await _controller.refreshSessions();
  }

  void _openReport(LiveSessionSummary session) {
    final reportId = session.reportId;
    if (reportId == null || reportId.trim().isEmpty) return;
    Navigator.of(context).pushNamed(
      AppRouter.publicVerifiedSessionPath(reportId),
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
            tooltip: _tr(
              context,
              it: 'Come funziona Social Vote',
              en: 'How Social Vote works',
              de: 'So funktioniert Social Vote',
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.howItWorks),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
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
                  _WorkspaceHeaderActions(
                    data: data,
                    onViewPublicProfile: () => _openPublicProfile(data),
                    onEditProfile: data.canManageProfile ? _editProfile : null,
                  ),
                  const SizedBox(height: 18),
                  _EnterpriseWorkspaceShell(
                    data: data,
                    sessions: _controller.sessions,
                    externalLinks: _controller.externalLinks,
                    selectedSection: _section,
                    onSectionChanged: (section) {
                      setState(() => _section = section);
                    },
                    onCreateVoice: _createVoice,
                    onCreateVote: _createVote,
                    onCreateSession: _createSession,
                    onOpenSession: _openSession,
                    onOpenReport: _openReport,
                    onEditProfile: _editProfile,
                    onViewPublicProfile: () => _openPublicProfile(data),
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

class _WorkspaceHeaderActions extends StatelessWidget {
  final OrganizationContext data;
  final VoidCallback onViewPublicProfile;
  final VoidCallback? onEditProfile;

  const _WorkspaceHeaderActions({
    required this.data,
    required this.onViewPublicProfile,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusPill(
                icon: data.organization.isVerified
                    ? Icons.verified_rounded
                    : Icons.gpp_bad_outlined,
                label: data.organization.isVerified
                    ? _tr(
                        context,
                        it: 'Organization verificata',
                        en: 'Verified organization',
                        de: 'Verifizierte Organisation',
                      )
                    : _tr(
                        context,
                        it: 'Verifica richiesta',
                        en: 'Verification required',
                        de: 'Verifizierung erforderlich',
                      ),
                emphasized: data.organization.isVerified,
              ),
              _StatusPill(
                icon: data.isWorkspaceActive
                    ? Icons.check_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
                label: _workspaceEntitlementLabel(
                  context,
                  data.workspace.entitlementStatus,
                ),
                emphasized: data.isWorkspaceActive,
              ),
              _StatusPill(
                icon: Icons.admin_panel_settings_outlined,
                label: _roleLabel(context, data.membershipRole),
              ),
              if (data.isFreePilot)
                _StatusPill(
                  icon: Icons.science_outlined,
                  label: _tr(
                    context,
                    it: 'Business Pilot',
                    en: 'Business Pilot',
                    de: 'Business Pilot',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        PopupMenuButton<String>(
          tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
          onSelected: (value) {
            if (value == 'public') onViewPublicProfile();
            if (value == 'edit') onEditProfile?.call();
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'public',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.visibility_outlined),
                title: Text(_tr(
                  context,
                  it: 'Profilo pubblico',
                  en: 'Public profile',
                  de: 'Öffentliches Profil',
                )),
              ),
            ),
            if (onEditProfile != null)
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(_tr(
                    context,
                    it: 'Modifica Organization',
                    en: 'Edit organization',
                    de: 'Organisation bearbeiten',
                  )),
                ),
              ),
          ],
          icon: Icon(Icons.more_horiz_rounded, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _EnterpriseWorkspaceShell extends StatelessWidget {
  final OrganizationContext data;
  final List<LiveSessionSummary> sessions;
  final List<OrganizationExternalLink> externalLinks;
  final _WorkspaceSection selectedSection;
  final ValueChanged<_WorkspaceSection> onSectionChanged;
  final VoidCallback onCreateVoice;
  final VoidCallback onCreateVote;
  final VoidCallback onCreateSession;
  final Future<void> Function(LiveSessionSummary session) onOpenSession;
  final void Function(LiveSessionSummary session) onOpenReport;
  final VoidCallback onEditProfile;
  final VoidCallback onViewPublicProfile;

  const _EnterpriseWorkspaceShell({
    required this.data,
    required this.sessions,
    required this.externalLinks,
    required this.selectedSection,
    required this.onSectionChanged,
    required this.onCreateVoice,
    required this.onCreateVote,
    required this.onCreateSession,
    required this.onOpenSession,
    required this.onOpenReport,
    required this.onEditProfile,
    required this.onViewPublicProfile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 920;
        final content = _WorkspaceSectionContent(
          data: data,
          sessions: sessions,
          externalLinks: externalLinks,
          section: selectedSection,
          onCreateVoice: onCreateVoice,
          onCreateVote: onCreateVote,
          onCreateSession: onCreateSession,
          onOpenSession: onOpenSession,
          onOpenReport: onOpenReport,
          onEditProfile: onEditProfile,
          onViewPublicProfile: onViewPublicProfile,
        );

        if (!desktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WorkspaceMobileNavigation(
                selected: selectedSection,
                onChanged: onSectionChanged,
              ),
              const SizedBox(height: 14),
              content,
            ],
          );
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            border:
                Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 232,
                child: _WorkspaceDesktopNavigation(
                  selected: selectedSection,
                  onChanged: onSectionChanged,
                  data: data,
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: content,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkspaceDesktopNavigation extends StatelessWidget {
  final _WorkspaceSection selected;
  final ValueChanged<_WorkspaceSection> onChanged;
  final OrganizationContext data;

  const _WorkspaceDesktopNavigation({
    required this.selected,
    required this.onChanged,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Social Vote Business',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.organization.publicName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ..._WorkspaceSection.values.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: _WorkspaceNavButton(
                section: section,
                selected: selected == section,
                onPressed: () => onChanged(section),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: colors.outlineVariant),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _tr(
                context,
                it: 'Accesso e fiducia',
                en: 'Access & trust',
                de: 'Zugriff & Vertrauen',
              ),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SideStatusLine(
            icon: Icons.verified_user_outlined,
            label: data.organization.isVerified
                ? _tr(
                    context,
                    it: 'Identità verificata',
                    en: 'Verified identity',
                    de: 'Verifizierte Identität',
                  )
                : _tr(
                    context,
                    it: 'Verifica richiesta',
                    en: 'Verification required',
                    de: 'Verifizierung erforderlich',
                  ),
          ),
          _SideStatusLine(
            icon: Icons.shield_outlined,
            label: _roleLabel(context, data.membershipRole),
          ),
          _SideStatusLine(
            icon: Icons.workspace_premium_outlined,
            label: data.isFreePilot
                ? _tr(
                    context,
                    it: 'Pilot gratuito',
                    en: 'Free pilot',
                    de: 'Kostenloser Pilot',
                  )
                : 'Business',
          ),
        ],
      ),
    );
  }
}

class _WorkspaceMobileNavigation extends StatelessWidget {
  final _WorkspaceSection selected;
  final ValueChanged<_WorkspaceSection> onChanged;

  const _WorkspaceMobileNavigation({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _WorkspaceSection.values
            .map(
              (section) => Padding(
                padding: const EdgeInsets.only(right: 7),
                child: ChoiceChip(
                  selected: selected == section,
                  onSelected: (_) => onChanged(section),
                  avatar: Icon(_sectionIcon(section), size: 18),
                  label: Text(_sectionLabel(context, section)),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _WorkspaceNavButton extends StatelessWidget {
  final _WorkspaceSection section;
  final bool selected;
  final VoidCallback onPressed;

  const _WorkspaceNavButton({
    required this.section,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.secondaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(
                _sectionIcon(section),
                size: 20,
                color: selected
                    ? colors.onSecondaryContainer
                    : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _sectionLabel(context, section),
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideStatusLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SideStatusLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceSectionContent extends StatelessWidget {
  final OrganizationContext data;
  final List<LiveSessionSummary> sessions;
  final List<OrganizationExternalLink> externalLinks;
  final _WorkspaceSection section;
  final VoidCallback onCreateVoice;
  final VoidCallback onCreateVote;
  final VoidCallback onCreateSession;
  final Future<void> Function(LiveSessionSummary session) onOpenSession;
  final void Function(LiveSessionSummary session) onOpenReport;
  final VoidCallback onEditProfile;
  final VoidCallback onViewPublicProfile;

  const _WorkspaceSectionContent({
    required this.data,
    required this.sessions,
    required this.externalLinks,
    required this.section,
    required this.onCreateVoice,
    required this.onCreateVote,
    required this.onCreateSession,
    required this.onOpenSession,
    required this.onOpenReport,
    required this.onEditProfile,
    required this.onViewPublicProfile,
  });

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      _WorkspaceSection.overview => _OverviewSection(
          data: data,
          sessions: sessions,
          onCreateVoice: onCreateVoice,
          onCreateVote: onCreateVote,
          onCreateSession: onCreateSession,
          onOpenSession: onOpenSession,
          onOpenReport: onOpenReport,
        ),
      _WorkspaceSection.publish => _PublishSection(
          data: data,
          onCreateVoice: onCreateVoice,
          onCreateVote: onCreateVote,
          onCreateSession: onCreateSession,
        ),
      _WorkspaceSection.sessions => _SessionsSection(
          data: data,
          sessions: sessions,
          onCreateSession: onCreateSession,
          onOpenSession: onOpenSession,
          onOpenReport: onOpenReport,
        ),
      _WorkspaceSection.results => _ResultsSection(
          sessions: sessions,
          onOpenReport: onOpenReport,
        ),
      _WorkspaceSection.team => _TeamSection(data: data),
      _WorkspaceSection.organization => _OrganizationSection(
          data: data,
          externalLinks: externalLinks,
          onEditProfile: onEditProfile,
          onViewPublicProfile: onViewPublicProfile,
        ),
    };
  }
}

class _OverviewSection extends StatelessWidget {
  final OrganizationContext data;
  final List<LiveSessionSummary> sessions;
  final VoidCallback onCreateVoice;
  final VoidCallback onCreateVote;
  final VoidCallback onCreateSession;
  final Future<void> Function(LiveSessionSummary session) onOpenSession;
  final void Function(LiveSessionSummary session) onOpenReport;

  const _OverviewSection({
    required this.data,
    required this.sessions,
    required this.onCreateVoice,
    required this.onCreateVote,
    required this.onCreateSession,
    required this.onOpenSession,
    required this.onOpenReport,
  });

  @override
  Widget build(BuildContext context) {
    final active = sessions.where((session) => session.isOpen).length;
    final reports =
        sessions.where((session) => session.reportId != null).length;
    final participants = sessions.fold<int>(
      0,
      (total, session) => total + session.participantCount,
    );
    final ballots = sessions.fold<int>(
      0,
      (total, session) => total + session.responseCount,
    );
    final recent = sessions.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WorkspaceSectionHeading(
          eyebrow: _tr(
            context,
            it: 'PANORAMICA OPERATIVA',
            en: 'OPERATIONS OVERVIEW',
            de: 'BETRIEBSÜBERSICHT',
          ),
          title: data.organization.publicName,
          body: _tr(
            context,
            it: 'Pubblicazione ufficiale, consultazioni live e risultati verificabili in un unico Workspace.',
            en: 'Official publishing, live consultations and verifiable results in one workspace.',
            de: 'Offizielle Veröffentlichungen, Live-Konsultationen und überprüfbare Ergebnisse in einem Workspace.',
          ),
        ),
        const SizedBox(height: 18),
        _OperationalReadiness(data: data),
        const SizedBox(height: 18),
        _MetricGrid(
          metrics: [
            _MetricData(
              icon: Icons.sensors_rounded,
              value: '$active',
              label: _tr(
                context,
                it: 'Sessions live',
                en: 'Live sessions',
                de: 'Live-Sessions',
              ),
            ),
            _MetricData(
              icon: Icons.groups_outlined,
              value: '$participants',
              label: _tr(
                context,
                it: 'Partecipanti',
                en: 'Participants',
                de: 'Teilnehmende',
              ),
            ),
            _MetricData(
              icon: Icons.how_to_vote_outlined,
              value: '$ballots',
              label: _tr(
                context,
                it: 'Risposte registrate',
                en: 'Recorded responses',
                de: 'Erfasste Antworten',
              ),
            ),
            _MetricData(
              icon: Icons.verified_outlined,
              value: '$reports',
              label: _tr(
                context,
                it: 'Verified Results',
                en: 'Verified Results',
                de: 'Verified Results',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _SubsectionHeader(
          title: _tr(
            context,
            it: 'Azioni rapide',
            en: 'Quick actions',
            de: 'Schnellaktionen',
          ),
        ),
        const SizedBox(height: 10),
        _ActionGrid(
          data: data,
          onCreateVoice: onCreateVoice,
          onCreateVote: onCreateVote,
          onCreateSession: onCreateSession,
        ),
        const SizedBox(height: 24),
        _SubsectionHeader(
          title: _tr(
            context,
            it: 'Attività recente',
            en: 'Recent activity',
            de: 'Letzte Aktivität',
          ),
          trailing: '${sessions.length}',
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          _EmptyPanel(
            icon: Icons.inbox_outlined,
            title: _tr(
              context,
              it: 'Nessuna Session ancora',
              en: 'No sessions yet',
              de: 'Noch keine Sessions',
            ),
            body: _tr(
              context,
              it: 'Crea una Session per iniziare a raccogliere partecipazione e risultati.',
              en: 'Create a session to start collecting participation and results.',
              de: 'Erstelle eine Session, um Teilnahme und Ergebnisse zu erfassen.',
            ),
          )
        else
          ...recent.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _SessionTile(
                session: session,
                onTap: () => onOpenSession(session),
                onReport: session.reportId == null
                    ? null
                    : () => onOpenReport(session),
              ),
            ),
          ),
      ],
    );
  }
}

class _PublishSection extends StatelessWidget {
  final OrganizationContext data;
  final VoidCallback onCreateVoice;
  final VoidCallback onCreateVote;
  final VoidCallback onCreateSession;

  const _PublishSection({
    required this.data,
    required this.onCreateVoice,
    required this.onCreateVote,
    required this.onCreateSession,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WorkspaceSectionHeading(
          eyebrow: _tr(
            context,
            it: 'PUBBLICAZIONE UFFICIALE',
            en: 'OFFICIAL PUBLISHING',
            de: 'OFFIZIELLE VERÖFFENTLICHUNG',
          ),
          title: _tr(
            context,
            it: 'Scegli lo strumento giusto',
            en: 'Choose the right instrument',
            de: 'Wähle das passende Instrument',
          ),
          body: _tr(
            context,
            it: 'Voce per comunicare, Vote per consultare, Session per partecipazione live e risultati verificabili.',
            en: 'Voce to communicate, Vote to consult, Session for live participation and verifiable results.',
            de: 'Voce für Kommunikation, Vote für Konsultationen, Session für Live-Teilnahme und überprüfbare Ergebnisse.',
          ),
        ),
        const SizedBox(height: 18),
        _ActionGrid(
          data: data,
          onCreateVoice: onCreateVoice,
          onCreateVote: onCreateVote,
          onCreateSession: onCreateSession,
          expandedCopy: true,
        ),
        const SizedBox(height: 18),
        _TrustPanel(data: data),
      ],
    );
  }
}

class _SessionsSection extends StatelessWidget {
  final OrganizationContext data;
  final List<LiveSessionSummary> sessions;
  final VoidCallback onCreateSession;
  final Future<void> Function(LiveSessionSummary session) onOpenSession;
  final void Function(LiveSessionSummary session) onOpenReport;

  const _SessionsSection({
    required this.data,
    required this.sessions,
    required this.onCreateSession,
    required this.onOpenSession,
    required this.onOpenReport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WorkspaceSectionHeading(
          eyebrow: 'SESSIONS',
          title: _tr(
            context,
            it: 'Consultazioni live',
            en: 'Live consultations',
            de: 'Live-Konsultationen',
          ),
          body: _tr(
            context,
            it: 'Gestisci accesso, QR, domande, stage, partecipazione e chiusura della Session.',
            en: 'Manage access, QR, questions, stage, participation and session closure.',
            de: 'Verwalte Zugriff, QR, Fragen, Stage, Teilnahme und Session-Abschluss.',
          ),
          action: FilledButton.icon(
            onPressed: data.canOperateSessions ? onCreateSession : null,
            icon: const Icon(Icons.add_rounded),
            label: Text(_tr(
              context,
              it: 'Nuova Session',
              en: 'New session',
              de: 'Neue Session',
            )),
          ),
        ),
        const SizedBox(height: 18),
        if (sessions.isEmpty)
          _EmptyPanel(
            icon: Icons.meeting_room_outlined,
            title: _tr(
              context,
              it: 'Nessuna Session',
              en: 'No sessions',
              de: 'Keine Sessions',
            ),
            body: _tr(
              context,
              it: 'Le Sessions create dall’Organization appariranno qui.',
              en: 'Sessions created by the organization will appear here.',
              de: 'Von der Organisation erstellte Sessions erscheinen hier.',
            ),
          )
        else
          ...sessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _SessionTile(
                session: session,
                onTap: () => onOpenSession(session),
                onReport: session.reportId == null
                    ? null
                    : () => onOpenReport(session),
              ),
            ),
          ),
      ],
    );
  }
}

class _ResultsSection extends StatelessWidget {
  final List<LiveSessionSummary> sessions;
  final void Function(LiveSessionSummary session) onOpenReport;

  const _ResultsSection({
    required this.sessions,
    required this.onOpenReport,
  });

  @override
  Widget build(BuildContext context) {
    final reports = sessions
        .where((session) => session.reportId != null)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WorkspaceSectionHeading(
          eyebrow: 'VERIFIED RESULTS',
          title: _tr(
            context,
            it: 'Risultati verificabili',
            en: 'Verifiable results',
            de: 'Überprüfbare Ergebnisse',
          ),
          body: _tr(
            context,
            it: 'Report conclusivi con identificativo, hash SHA-256, QR e documento verificabile quando disponibili.',
            en: 'Final reports with report ID, SHA-256 hash, QR and verifiable document when available.',
            de: 'Abschlussberichte mit Report-ID, SHA-256-Hash, QR und überprüfbarem Dokument, sofern verfügbar.',
          ),
        ),
        const SizedBox(height: 18),
        if (reports.isEmpty)
          _EmptyPanel(
            icon: Icons.verified_outlined,
            title: _tr(
              context,
              it: 'Nessun Verified Result ancora',
              en: 'No Verified Results yet',
              de: 'Noch keine Verified Results',
            ),
            body: _tr(
              context,
              it: 'Quando una Session viene chiusa con report verificato, il risultato apparirà qui.',
              en: 'When a session closes with a verified report, the result will appear here.',
              de: 'Wenn eine Session mit verifiziertem Bericht abgeschlossen wird, erscheint das Ergebnis hier.',
            ),
          )
        else
          ...reports.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ResultTile(
                session: session,
                onOpen: () => onOpenReport(session),
              ),
            ),
          ),
      ],
    );
  }
}

class _TeamSection extends StatefulWidget {
  final OrganizationContext data;

  const _TeamSection({required this.data});

  @override
  State<_TeamSection> createState() => _TeamSectionState();
}

class _TeamSectionState extends State<_TeamSection> {
  bool _loading = true;
  bool _saving = false;
  Object? _error;
  List<OrganizationTeamMember> _members = const [];

  bool get _canManage {
    final role = widget.data.membershipRole.trim().toLowerCase();
    return widget.data.isWorkspaceActive &&
        (role == 'owner' || role == 'manager');
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final members =
          await AppDI.instance.organizationRepository.listTeamMembers();
      if (!mounted) return;
      setState(() => _members = members);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addMember() async {
    if (!_canManage || _saving) return;
    final identifier = TextEditingController();
    String role = 'viewer';

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(_tr(
            context,
            it: 'Aggiungi account Social Vote',
            en: 'Add Social Vote account',
            de: 'Social-Vote-Konto hinzufügen',
          )),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_tr(
                  context,
                  it: 'Aggiunge un account già registrato tramite username o email. Non invia email esterne.',
                  en: 'Adds an existing registered account by username or email. It does not send external email invitations.',
                  de: 'Fügt ein bereits registriertes Konto per Benutzername oder E-Mail hinzu. Es werden keine externen Einladungen gesendet.',
                )),
                const SizedBox(height: 14),
                TextField(
                  controller: identifier,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: _tr(
                      context,
                      it: 'Username o email',
                      en: 'Username or email',
                      de: 'Benutzername oder E-Mail',
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: InputDecoration(
                    labelText: _tr(
                      context,
                      it: 'Ruolo',
                      en: 'Role',
                      de: 'Rolle',
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                    DropdownMenuItem(
                        value: 'operator', child: Text('Operator')),
                    DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => role = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () {
                final value = identifier.text.trim();
                if (value.isEmpty) return;
                Navigator.of(dialogContext).pop((value, role));
              },
              child: Text(_tr(
                context,
                it: 'Aggiungi',
                en: 'Add',
                de: 'Hinzufügen',
              )),
            ),
          ],
        ),
      ),
    );

    identifier.dispose();
    if (result == null) return;

    setState(() => _saving = true);
    try {
      await AppDI.instance.organizationRepository.addExistingTeamMember(
        identifier: result.$1,
        role: result.$2,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeRole(OrganizationTeamMember member) async {
    if (!_canManage || member.membershipRole == 'owner' || _saving) return;
    var role = member.membershipRole;

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(member.label),
          content: DropdownButtonFormField<String>(
            initialValue: role,
            decoration: InputDecoration(
              labelText: _tr(
                context,
                it: 'Ruolo',
                en: 'Role',
                de: 'Rolle',
              ),
              border: const OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'manager', child: Text('Manager')),
              DropdownMenuItem(value: 'operator', child: Text('Operator')),
              DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
            ],
            onChanged: (value) {
              if (value != null) setDialogState(() => role = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(role),
              child: Text(_tr(
                context,
                it: 'Salva',
                en: 'Save',
                de: 'Speichern',
              )),
            ),
          ],
        ),
      ),
    );
    if (selected == null || selected == member.membershipRole) return;

    setState(() => _saving = true);
    try {
      await AppDI.instance.organizationRepository.setTeamMemberRole(
        userId: member.userId,
        role: selected,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _revoke(OrganizationTeamMember member) async {
    if (!_canManage || member.membershipRole == 'owner' || _saving) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_tr(
          context,
          it: 'Revoca accesso',
          en: 'Revoke access',
          de: 'Zugriff widerrufen',
        )),
        content: Text(member.label),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_tr(
              context,
              it: 'Revoca',
              en: 'Revoke',
              de: 'Widerrufen',
            )),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      await AppDI.instance.organizationRepository
          .revokeTeamMember(userId: member.userId);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final role = data.membershipRole.trim().toLowerCase();

    final capabilities = <_CapabilityRow>[
      _CapabilityRow(
        label: _tr(
          context,
          it: 'Gestire il profilo Organization',
          en: 'Manage organization profile',
          de: 'Organisationsprofil verwalten',
        ),
        allowed: data.canManageProfile,
      ),
      _CapabilityRow(
        label: _tr(
          context,
          it: 'Pubblicare Voce e Vote ufficiali',
          en: 'Publish official Voce and Vote',
          de: 'Offizielle Voce und Vote veröffentlichen',
        ),
        allowed: data.canPublishOfficial,
      ),
      _CapabilityRow(
        label: _tr(
          context,
          it: 'Gestire Sessions',
          en: 'Operate sessions',
          de: 'Sessions verwalten',
        ),
        allowed: data.canOperateSessions,
      ),
      _CapabilityRow(
        label: _tr(
          context,
          it: 'Gestire membri',
          en: 'Manage members',
          de: 'Mitglieder verwalten',
        ),
        allowed: _canManage,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WorkspaceSectionHeading(
          eyebrow: _tr(
            context,
            it: 'ACCESSO ORGANIZZATIVO',
            en: 'ORGANIZATIONAL ACCESS',
            de: 'ORGANISATIONSZUGRIFF',
          ),
          title: _tr(
            context,
            it: 'Team e ruoli',
            en: 'Team and roles',
            de: 'Team und Rollen',
          ),
          body: _tr(
            context,
            it: 'Ruoli, aggiunte, modifiche e revoche sono enforce lato server e registrate nell’audit Organization.',
            en: 'Roles, additions, changes and revocations are enforced server-side and recorded in the Organization audit.',
            de: 'Rollen, Hinzufügungen, Änderungen und Widerrufe werden serverseitig erzwungen und im Organisationsaudit protokolliert.',
          ),
        ),
        const SizedBox(height: 18),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.admin_panel_settings_outlined),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr(
                          context,
                          it: 'Il tuo accesso',
                          en: 'Your access',
                          de: 'Dein Zugriff',
                        ),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _roleLabel(context, role),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
                if (_canManage)
                  FilledButton.tonalIcon(
                    onPressed: _saving ? null : _addMember,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: Text(_tr(
                      context,
                      it: 'Aggiungi',
                      en: 'Add',
                      de: 'Hinzufügen',
                    )),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: capabilities
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Icon(
                            item.allowed
                                ? Icons.check_circle_rounded
                                : Icons.remove_circle_outline_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item.label)),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ))
        else if (_error != null)
          _InformationPanel(
            icon: Icons.error_outline,
            title: _tr(
              context,
              it: 'Team non disponibile',
              en: 'Team unavailable',
              de: 'Team nicht verfügbar',
            ),
            body: _error.toString(),
          )
        else if (_members.isEmpty)
          _InformationPanel(
            icon: Icons.groups_2_outlined,
            title: _tr(
              context,
              it: 'Nessun membro',
              en: 'No members',
              de: 'Keine Mitglieder',
            ),
            body: _tr(
              context,
              it: 'Non risultano membership attive per questa Organization.',
              en: 'No active memberships are currently available for this Organization.',
              de: 'Für diese Organisation sind derzeit keine aktiven Mitgliedschaften verfügbar.',
            ),
          )
        else
          ..._members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      member.label.trim().isEmpty
                          ? '?'
                          : member.label.trim().substring(0, 1).toUpperCase(),
                    ),
                  ),
                  title: Text(member.label),
                  subtitle: Text(_roleLabel(context, member.membershipRole)),
                  trailing: member.membershipRole == 'owner' || !_canManage
                      ? null
                      : PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'role') {
                              _changeRole(member);
                            } else if (value == 'revoke') {
                              _revoke(member);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'role',
                              child: Text(_tr(
                                context,
                                it: 'Cambia ruolo',
                                en: 'Change role',
                                de: 'Rolle ändern',
                              )),
                            ),
                            PopupMenuItem(
                              value: 'revoke',
                              child: Text(_tr(
                                context,
                                it: 'Revoca accesso',
                                en: 'Revoke access',
                                de: 'Zugriff widerrufen',
                              )),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        _InformationPanel(
          icon: Icons.info_outline,
          title: _tr(
            context,
            it: 'Inviti esterni non ancora attivi',
            en: 'External invitations are not active yet',
            de: 'Externe Einladungen sind noch nicht aktiv',
          ),
          body: _tr(
            context,
            it: 'Questa versione gestisce account Social Vote già registrati. Email di invito esterne, accettazione via link e trasferimento Owner restano fuori finché il relativo workflow non è completo.',
            en: 'This version manages already registered Social Vote accounts. External email invitations, link acceptance and Owner transfer remain unavailable until that workflow is complete.',
            de: 'Diese Version verwaltet bereits registrierte Social-Vote-Konten. Externe E-Mail-Einladungen, Link-Annahme und Owner-Übertragung bleiben deaktiviert, bis der Workflow vollständig ist.',
          ),
        ),
      ],
    );
  }
}

class _OrganizationSection extends StatelessWidget {
  final OrganizationContext data;
  final List<OrganizationExternalLink> externalLinks;
  final VoidCallback onEditProfile;
  final VoidCallback onViewPublicProfile;

  const _OrganizationSection({
    required this.data,
    required this.externalLinks,
    required this.onEditProfile,
    required this.onViewPublicProfile,
  });

  @override
  Widget build(BuildContext context) {
    final organization = data.organization;
    final rows = <(String, String)>[
      (
        _tr(context,
            it: 'Nome pubblico', en: 'Public name', de: 'Öffentlicher Name'),
        organization.publicName,
      ),
      (
        _tr(context,
            it: 'Nome legale', en: 'Legal name', de: 'Rechtlicher Name'),
        organization.legalName,
      ),
      (
        _tr(context, it: 'Tipo', en: 'Type', de: 'Typ'),
        _entityTypeLabel(context, organization.entityType),
      ),
      if (organization.countryCode != null)
        (
          _tr(context, it: 'Paese', en: 'Country', de: 'Land'),
          organization.countryCode!,
        ),
      if (organization.city != null)
        (
          _tr(context, it: 'Città', en: 'City', de: 'Stadt'),
          organization.city!,
        ),
    ];
    final website = organization.websiteUrl?.trim();
    final publicExternalLinks = externalLinks
        .where((link) => link.isPublic && link.canonicalUrl.trim().isNotEmpty)
        .toList(growable: false);
    final hasOfficialChannels =
        (website != null && website.isNotEmpty) || publicExternalLinks.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WorkspaceSectionHeading(
          eyebrow: 'ORGANIZATION',
          title: _tr(
            context,
            it: 'Identità e profilo',
            en: 'Identity and profile',
            de: 'Identität und Profil',
          ),
          body: _tr(
            context,
            it: 'I dati ufficiali dell’Organization alimentano firma pubblica, Workspace e servizi Business.',
            en: 'Official organization data powers the public signature, workspace and Business services.',
            de: 'Offizielle Organisationsdaten speisen öffentliche Signatur, Workspace und Business-Dienste.',
          ),
          action: Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onViewPublicProfile,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(_tr(
                  context,
                  it: 'Profilo pubblico',
                  en: 'Public profile',
                  de: 'Öffentliches Profil',
                )),
              ),
              if (data.canManageProfile)
                FilledButton.tonalIcon(
                  onPressed: onEditProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(_tr(
                    context,
                    it: 'Modifica',
                    en: 'Edit',
                    de: 'Bearbeiten',
                  )),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: rows
                  .map(
                    (row) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              row.$1,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(row.$2)),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
        if (hasOfficialChannels) ...[
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _tr(
                      context,
                      it: 'Canali ufficiali',
                      en: 'Official channels',
                      de: 'Offizielle Kanäle',
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (website != null && website.isNotEmpty)
                        _OfficialChannelCard(
                          icon: const OrganizationWebsiteIcon(size: 30),
                          label: _tr(
                            context,
                            it: 'Sito ufficiale',
                            en: 'Official website',
                            de: 'Offizielle Website',
                          ),
                          url: website,
                        ),
                      ...publicExternalLinks.map(
                        (link) => _OfficialChannelCard(
                          icon: OrganizationExternalChannelIcon(
                            provider: link.provider,
                            size: 30,
                          ),
                          label: link.provider.label,
                          url: link.canonicalUrl,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        if (organization.description != null) ...[
          const SizedBox(height: 12),
          _InformationPanel(
            icon: Icons.notes_rounded,
            title: _tr(
              context,
              it: 'Descrizione pubblica',
              en: 'Public description',
              de: 'Öffentliche Beschreibung',
            ),
            body: organization.description!,
          ),
        ],
      ],
    );
  }
}

class _OfficialChannelCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final String url;

  const _OfficialChannelCard({
    required this.icon,
    required this.label,
    required this.url,
  });

  Future<void> _open() async {
    final raw = url.trim();
    final normalized = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'https://$raw';
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 190, maxWidth: 360),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OperationalReadiness extends StatelessWidget {
  final OrganizationContext data;

  const _OperationalReadiness({required this.data});

  @override
  Widget build(BuildContext context) {
    final ready = data.organization.isVerified && data.isWorkspaceActive;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ready
            ? colors.primaryContainer.withValues(alpha: 0.45)
            : colors.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ready
              ? colors.primary.withValues(alpha: 0.25)
              : colors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ready ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ready
                      ? _tr(
                          context,
                          it: 'Workspace operativo',
                          en: 'Workspace operational',
                          de: 'Workspace betriebsbereit',
                        )
                      : _tr(
                          context,
                          it: 'Workspace con limitazioni',
                          en: 'Workspace restricted',
                          de: 'Workspace eingeschränkt',
                        ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  ready
                      ? _tr(
                          context,
                          it: 'Organization verificata e Workspace attivo. Le azioni restano comunque soggette ai controlli backend/RLS.',
                          en: 'Organization verified and workspace active. Actions remain subject to backend/RLS enforcement.',
                          de: 'Organisation verifiziert und Workspace aktiv. Aktionen unterliegen weiterhin Backend-/RLS-Prüfungen.',
                        )
                      : _tr(
                          context,
                          it: 'I servizi Business restano limitati finché identità e Workspace non soddisfano i requisiti server-side.',
                          en: 'Business services remain limited until identity and workspace satisfy server-side requirements.',
                          de: 'Business-Dienste bleiben eingeschränkt, bis Identität und Workspace die serverseitigen Anforderungen erfüllen.',
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

class _TrustPanel extends StatelessWidget {
  final OrganizationContext data;

  const _TrustPanel({required this.data});

  @override
  Widget build(BuildContext context) {
    return _InformationPanel(
      icon: Icons.security_rounded,
      title: _tr(
        context,
        it: 'Trust & governance',
        en: 'Trust & governance',
        de: 'Trust & Governance',
      ),
      body: _tr(
        context,
        it: 'Identità Organization, ruoli, stato Workspace e permessi vengono verificati lato server. Il Pilot non vende verifica, ranking o visibilità. Verified Results restano separati dalla semplice pubblicazione.',
        en: 'Organization identity, roles, workspace status and permissions are verified server-side. The pilot does not sell verification, ranking or visibility. Verified Results remain separate from ordinary publishing.',
        de: 'Organisationsidentität, Rollen, Workspace-Status und Berechtigungen werden serverseitig geprüft. Der Pilot verkauft keine Verifizierung, Rankings oder Sichtbarkeit. Verified Results bleiben von normaler Veröffentlichung getrennt.',
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final OrganizationContext data;
  final VoidCallback onCreateVoice;
  final VoidCallback onCreateVote;
  final VoidCallback onCreateSession;
  final bool expandedCopy;

  const _ActionGrid({
    required this.data,
    required this.onCreateVoice,
    required this.onCreateVote,
    required this.onCreateSession,
    this.expandedCopy = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: width,
              child: _EnterpriseActionCard(
                icon: Icons.forum_outlined,
                title: 'Voce',
                subtitle: _tr(
                  context,
                  it: 'Comunicazione ufficiale',
                  en: 'Official communication',
                  de: 'Offizielle Kommunikation',
                ),
                body: expandedCopy
                    ? _tr(
                        context,
                        it: 'Pubblica aggiornamenti, proposte e messaggi con identità Organization.',
                        en: 'Publish updates, proposals and messages with organization identity.',
                        de: 'Veröffentliche Updates, Vorschläge und Mitteilungen mit Organisationsidentität.',
                      )
                    : _tr(
                        context,
                        it: 'Pubblica come Organization.',
                        en: 'Publish as the organization.',
                        de: 'Als Organisation veröffentlichen.',
                      ),
                actionLabel: _tr(
                  context,
                  it: 'Crea Voce',
                  en: 'Create Voce',
                  de: 'Voce erstellen',
                ),
                enabled: data.canPublishOfficial,
                onPressed: onCreateVoice,
              ),
            ),
            SizedBox(
              width: width,
              child: _EnterpriseActionCard(
                icon: Icons.how_to_vote_outlined,
                title: 'Vote',
                subtitle: _tr(
                  context,
                  it: 'Consultazione pubblica',
                  en: 'Public consultation',
                  de: 'Öffentliche Konsultation',
                ),
                body: expandedCopy
                    ? _tr(
                        context,
                        it: 'Raccogli opinioni della community con una consultazione asincrona.',
                        en: 'Collect community opinions with an asynchronous consultation.',
                        de: 'Sammle Meinungen der Community mit einer asynchronen Konsultation.',
                      )
                    : _tr(
                        context,
                        it: 'Raccogli opinioni.',
                        en: 'Collect opinions.',
                        de: 'Meinungen sammeln.',
                      ),
                actionLabel: _tr(
                  context,
                  it: 'Crea Vote',
                  en: 'Create Vote',
                  de: 'Vote erstellen',
                ),
                enabled: data.canPublishOfficial,
                onPressed: onCreateVote,
              ),
            ),
            SizedBox(
              width: width,
              child: _EnterpriseActionCard(
                icon: Icons.groups_2_outlined,
                title: 'Session',
                subtitle: _tr(
                  context,
                  it: 'Partecipazione live',
                  en: 'Live participation',
                  de: 'Live-Teilnahme',
                ),
                body: expandedCopy
                    ? _tr(
                        context,
                        it: 'Conduci una consultazione con QR, Stage, controllo accessi e Verified Result.',
                        en: 'Run a consultation with QR, Stage, access control and Verified Result.',
                        de: 'Führe eine Konsultation mit QR, Stage, Zugriffskontrolle und Verified Result durch.',
                      )
                    : _tr(
                        context,
                        it: 'QR, Stage e Verified Result.',
                        en: 'QR, Stage and Verified Result.',
                        de: 'QR, Stage und Verified Result.',
                      ),
                actionLabel: _tr(
                  context,
                  it: 'Crea Session',
                  en: 'Create Session',
                  de: 'Session erstellen',
                ),
                enabled: data.canOperateSessions,
                onPressed: onCreateSession,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EnterpriseActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String body;
  final String actionLabel;
  final bool enabled;
  final VoidCallback onPressed;

  const _EnterpriseActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.onPrimaryContainer),
                ),
                const Spacer(),
                Icon(
                  enabled
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(body),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
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

class _MetricGrid extends StatelessWidget {
  final List<_MetricData> metrics;

  const _MetricGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 880
            ? 4
            : constraints.maxWidth >= 520
                ? 2
                : 1;
        const gap = 10.0;
        final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: _MetricCard(metric: metric),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _MetricData metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(metric.icon, color: theme.colorScheme.primary),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    metric.label,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final LiveSessionSummary session;
  final VoidCallback onOpen;

  const _ResultTile({required this.session, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        leading: const CircleAvatar(child: Icon(Icons.verified_rounded)),
        title: Text(
          session.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            _tr(
              context,
              it: '${session.participantCount} partecipanti · ${session.responseCount} risposte · Report ${session.reportId}',
              en: '${session.participantCount} participants · ${session.responseCount} responses · Report ${session.reportId}',
              de: '${session.participantCount} Teilnehmende · ${session.responseCount} Antworten · Report ${session.reportId}',
            ),
          ),
        ),
        trailing: FilledButton.tonalIcon(
          onPressed: onOpen,
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text(_tr(
            context,
            it: 'Apri',
            en: 'Open',
            de: 'Öffnen',
          )),
        ),
      ),
    );
  }
}

class _WorkspaceSectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String body;
  final Widget? action;

  const _WorkspaceSectionHeading({
    required this.eyebrow,
    required this.title,
    required this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Wrap(
      spacing: 18,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _SubsectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SubsectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(context).textTheme.labelLarge,
          ),
      ],
    );
  }
}

class _InformationPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InformationPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool emphasized;

  const _StatusPill({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: emphasized
            ? colors.primaryContainer.withValues(alpha: 0.62)
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
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
                            '${l10n.sessionJoinCode}: ${session.joinCode}',
                          ),
                        ),
                        Chip(
                          label: Text(
                            '${session.participantCount} · ${l10n.sessionJoinedParticipants}',
                          ),
                        ),
                        Chip(
                          label: Text(
                            '${session.responseCount} · ${l10n.sessionBallotsRecorded}',
                          ),
                        ),
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

class _MetricData {
  final IconData icon;
  final String value;
  final String label;

  const _MetricData({
    required this.icon,
    required this.value,
    required this.label,
  });
}

class _CapabilityRow {
  final String label;
  final bool allowed;

  const _CapabilityRow({required this.label, required this.allowed});
}

IconData _sectionIcon(_WorkspaceSection section) => switch (section) {
      _WorkspaceSection.overview => Icons.dashboard_outlined,
      _WorkspaceSection.publish => Icons.campaign_outlined,
      _WorkspaceSection.sessions => Icons.groups_2_outlined,
      _WorkspaceSection.results => Icons.verified_outlined,
      _WorkspaceSection.team => Icons.group_outlined,
      _WorkspaceSection.organization => Icons.apartment_outlined,
    };

String _sectionLabel(BuildContext context, _WorkspaceSection section) {
  return switch (section) {
    _WorkspaceSection.overview => _tr(
        context,
        it: 'Panoramica',
        en: 'Overview',
        de: 'Übersicht',
      ),
    _WorkspaceSection.publish => _tr(
        context,
        it: 'Pubblica',
        en: 'Publish',
        de: 'Veröffentlichen',
      ),
    _WorkspaceSection.sessions => 'Sessions',
    _WorkspaceSection.results => _tr(
        context,
        it: 'Risultati',
        en: 'Results',
        de: 'Ergebnisse',
      ),
    _WorkspaceSection.team => 'Team',
    _WorkspaceSection.organization => 'Organization',
  };
}

String _workspaceEntitlementLabel(
  BuildContext context,
  WorkspaceEntitlementStatus status,
) {
  return switch (status) {
    WorkspaceEntitlementStatus.none => _tr(
        context,
        it: 'Workspace non attivo',
        en: 'Workspace not active',
        de: 'Workspace nicht aktiv',
      ),
    WorkspaceEntitlementStatus.pilot => _tr(
        context,
        it: 'Workspace Pilot',
        en: 'Workspace Pilot',
        de: 'Workspace Pilot',
      ),
    WorkspaceEntitlementStatus.active => _tr(
        context,
        it: 'Workspace attivo',
        en: 'Workspace active',
        de: 'Workspace aktiv',
      ),
    WorkspaceEntitlementStatus.suspended => _tr(
        context,
        it: 'Workspace sospeso',
        en: 'Workspace suspended',
        de: 'Workspace gesperrt',
      ),
    WorkspaceEntitlementStatus.expired => _tr(
        context,
        it: 'Workspace scaduto',
        en: 'Workspace expired',
        de: 'Workspace abgelaufen',
      ),
  };
}

String _roleLabel(BuildContext context, String rawRole) {
  return switch (rawRole.trim().toLowerCase()) {
    'owner' => _tr(context, it: 'Owner', en: 'Owner', de: 'Owner'),
    'manager' => _tr(context, it: 'Manager', en: 'Manager', de: 'Manager'),
    'operator' => _tr(context, it: 'Operator', en: 'Operator', de: 'Operator'),
    _ => _tr(context, it: 'Viewer', en: 'Viewer', de: 'Viewer'),
  };
}

String _entityTypeLabel(BuildContext context, OrganizationEntityType type) {
  return switch (type) {
    OrganizationEntityType.association => _tr(
        context,
        it: 'Associazione',
        en: 'Association',
        de: 'Verein',
      ),
    OrganizationEntityType.nonprofit => _tr(
        context,
        it: 'Nonprofit',
        en: 'Nonprofit',
        de: 'Nonprofit',
      ),
    OrganizationEntityType.company => _tr(
        context,
        it: 'Azienda',
        en: 'Company',
        de: 'Unternehmen',
      ),
    OrganizationEntityType.cooperative => _tr(
        context,
        it: 'Cooperativa',
        en: 'Cooperative',
        de: 'Genossenschaft',
      ),
    OrganizationEntityType.sports => _tr(
        context,
        it: 'Sport',
        en: 'Sports',
        de: 'Sport',
      ),
    OrganizationEntityType.publicBody => _tr(
        context,
        it: 'Ente pubblico',
        en: 'Public body',
        de: 'Öffentliche Stelle',
      ),
    OrganizationEntityType.committee => _tr(
        context,
        it: 'Comitato',
        en: 'Committee',
        de: 'Komitee',
      ),
    OrganizationEntityType.other => _tr(
        context,
        it: 'Altro',
        en: 'Other',
        de: 'Andere',
      ),
  };
}

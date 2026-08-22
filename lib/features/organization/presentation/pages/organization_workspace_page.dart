import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/features/organization/application/organization_workspace_controller.dart';
import 'package:sociale_vote/features/organization/presentation/pages/create_live_session_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/live_session_presenter_page.dart';
import 'package:sociale_vote/features/organization/presentation/pages/organization_profile_editor_page.dart';
import 'package:sociale_vote/features/organization/presentation/widgets/organization_cover_header.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = _controller.context;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.organizationWorkspaceTitle)),
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
                              builder: (_) => PublicUserProfilePage(userId: userId),
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
                  _OrganizationDashboard(sessions: _controller.sessions),
                  const SizedBox(height: 14),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.science_outlined),
                      title: Text(l10n.organizationPilotBannerTitle),
                      subtitle: Text(l10n.organizationPilotBannerBody),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.organizationSessionsTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      if (data.canOperateSessions)
                        FilledButton.icon(
                          onPressed: _createSession,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.organizationCreateSession),
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

class _OrganizationDashboard extends StatelessWidget {
  final List<LiveSessionSummary> sessions;

  const _OrganizationDashboard({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final live = sessions.where((session) => session.status == 'open').length;
    final reports = sessions.where((session) => session.reportId != null).length;
    final items = [
      (Icons.dashboard_outlined, '${sessions.length}', l10n.organizationTotalSessions),
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
                        Chip(label: Text('${l10n.sessionJoinCode}: ${session.joinCode}')),
                        Chip(label: Text('${session.participantCount} · ${l10n.sessionJoinedParticipants}')),
                        Chip(label: Text('${session.responseCount} · ${l10n.sessionBallotsRecorded}')),
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

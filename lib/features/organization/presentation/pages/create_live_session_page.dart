import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/domain/organization/repositories/organization_repository.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class CreateLiveSessionPage extends StatefulWidget {
  final OrganizationRepository repository;

  const CreateLiveSessionPage({
    super.key,
    required this.repository,
  });

  @override
  State<CreateLiveSessionPage> createState() => _CreateLiveSessionPageState();
}

class _CreateLiveSessionPageState extends State<CreateLiveSessionPage> {
  final _title = TextEditingController();
  final _expected = TextEditingController(text: '25');
  LiveSessionAccessMode _accessMode = LiveSessionAccessMode.controlledTokenPool;
  LiveSessionResultsVisibility _visibility =
      LiveSessionResultsVisibility.afterClose;
  String _retention = '7d';
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _expected.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final expected = int.tryParse(_expected.text.trim()) ?? 0;
    if (_title.text.trim().isEmpty || expected < 1 || expected > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sessionPilotLimit)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final id = await widget.repository.createSession(
        title: _title.text,
        accessMode: _accessMode,
        resultsVisibility: _visibility,
        rawRetention: _retention,
        expectedParticipants: expected,
      );
      if (!mounted) return;
      Navigator.of(context).pop(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionCreateTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.meeting_room_outlined,
                          size: 32, color: theme.colorScheme.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sessionCreateIntroTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(l10n.sessionCreateIntroBody),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: l10n.sessionTitleLabel,
                icon: Icons.title_rounded,
                child: Column(
                  children: [
                    TextField(
                      controller: _title,
                      maxLength: 180,
                      decoration: InputDecoration(
                        labelText: l10n.sessionTitleLabel,
                        prefixIcon: const Icon(Icons.how_to_vote_outlined),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _expected,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.sessionExpectedParticipants,
                        helperText: l10n.sessionPilotLimit,
                        prefixIcon: const Icon(Icons.people_alt_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: l10n.sessionAccessMode,
                icon: Icons.badge_outlined,
                child: RadioGroup<LiveSessionAccessMode>(
                  groupValue: _accessMode,
                  onChanged: (value) {
                    if (_saving || value == null) return;
                    setState(() => _accessMode = value);
                  },
                  child: Column(
                    children: [
                      _ModeTile(
                        value: LiveSessionAccessMode.controlledTokenPool,
                        current: _accessMode,
                        enabled: !_saving,
                        icon: Icons.qr_code_2_rounded,
                        title: l10n.sessionAccessControlled,
                        subtitle: l10n.sessionAccessControlledHint,
                        badge: l10n.sessionAccessRecommended,
                      ),
                      const SizedBox(height: 10),
                      _ModeTile(
                        value: LiveSessionAccessMode.openAnonymous,
                        current: _accessMode,
                        enabled: !_saving,
                        icon: Icons.public_rounded,
                        title: l10n.sessionAccessOpen,
                        subtitle: l10n.sessionAccessOpenHint,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: l10n.sessionConfigurationTitle,
                icon: Icons.tune_rounded,
                child: Column(
                  children: [
                    DropdownButtonFormField<LiveSessionResultsVisibility>(
                      initialValue: _visibility,
                      decoration: InputDecoration(
                        labelText: l10n.sessionResultsVisibility,
                        prefixIcon: const Icon(Icons.visibility_outlined),
                      ),
                      items: LiveSessionResultsVisibility.values
                          .map(
                            (visibility) => DropdownMenuItem(
                              value: visibility,
                              child: Text(_visibilityLabel(l10n, visibility)),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (value) => setState(
                                () => _visibility = value ?? _visibility,
                              ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _retention,
                      decoration: InputDecoration(
                        labelText: l10n.sessionRetentionLabel,
                        prefixIcon: const Icon(Icons.schedule_outlined),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: '24h',
                          child: Text(l10n.sessionRetention24h),
                        ),
                        DropdownMenuItem(
                          value: '7d',
                          child: Text(l10n.sessionRetention7d),
                        ),
                        DropdownMenuItem(
                          value: '30d',
                          child: Text(l10n.sessionRetention30d),
                        ),
                      ],
                      onChanged: _saving
                          ? null
                          : (value) => setState(
                                () => _retention = value ?? _retention,
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(l10n.organizationPilotBannerTitle),
                  subtitle: Text(
                    '${l10n.organizationPilotBannerBody}\n\n${l10n.sessionNonBindingNotice}',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _create,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(l10n.sessionCreateAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _visibilityLabel(
    AppLocalizations l10n,
    LiveSessionResultsVisibility visibility,
  ) {
    return switch (visibility) {
      LiveSessionResultsVisibility.live => l10n.sessionResultsLive,
      LiveSessionResultsVisibility.afterVote => l10n.sessionResultsAfterVote,
      LiveSessionResultsVisibility.afterClose => l10n.sessionResultsAfterClose,
      LiveSessionResultsVisibility.organizerOnly =>
        l10n.sessionResultsOrganizerOnly,
    };
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final LiveSessionAccessMode value;
  final LiveSessionAccessMode current;
  final bool enabled;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;

  const _ModeTile({
    required this.value,
    required this.current,
    required this.enabled,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value == current;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: RadioListTile<LiveSessionAccessMode>(
        value: value,
        enabled: enabled,
        secondary: Icon(icon),
        title: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Flexible(child: Chip(label: Text(badge!))),
            ],
          ],
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}

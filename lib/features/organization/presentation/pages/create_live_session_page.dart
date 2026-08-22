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
  LiveSessionAccessMode _accessMode =
      LiveSessionAccessMode.controlledTokenPool;
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionCreateTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(l10n.organizationPilotBannerTitle),
              subtitle: Text(l10n.organizationPilotBannerBody),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            maxLength: 180,
            decoration: InputDecoration(labelText: l10n.sessionTitleLabel),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _expected,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.sessionExpectedParticipants,
              helperText: l10n.sessionPilotLimit,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.sessionAccessMode,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RadioGroup<LiveSessionAccessMode>(
            groupValue: _accessMode,
            onChanged: (value) {
              if (_saving || value == null) return;
              setState(() => _accessMode = value);
            },
            child: Column(
              children: [
                RadioListTile<LiveSessionAccessMode>(
                  value: LiveSessionAccessMode.controlledTokenPool,
                  enabled: !_saving,
                  title: Text(l10n.sessionAccessControlled),
                  subtitle: Text(l10n.sessionAccessControlledHint),
                ),
                RadioListTile<LiveSessionAccessMode>(
                  value: LiveSessionAccessMode.openAnonymous,
                  enabled: !_saving,
                  title: Text(l10n.sessionAccessOpen),
                  subtitle: Text(l10n.sessionAccessOpenHint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<LiveSessionResultsVisibility>(
            initialValue: _visibility,
            decoration: InputDecoration(labelText: l10n.sessionResultsVisibility),
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
                : (value) => setState(() => _visibility = value ?? _visibility),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _retention,
            decoration: InputDecoration(labelText: l10n.sessionRetentionLabel),
            items: [
              DropdownMenuItem(value: '24h', child: Text(l10n.sessionRetention24h)),
              DropdownMenuItem(value: '7d', child: Text(l10n.sessionRetention7d)),
              DropdownMenuItem(value: '30d', child: Text(l10n.sessionRetention30d)),
            ],
            onChanged: _saving ? null : (value) => setState(() => _retention = value ?? _retention),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(l10n.sessionNonBindingNotice),
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
                : const Icon(Icons.add_rounded),
            label: Text(l10n.sessionCreateAction),
          ),
        ],
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
      LiveSessionResultsVisibility.organizerOnly => l10n.sessionResultsOrganizerOnly,
    };
  }
}

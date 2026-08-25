import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/content/news/entities/world_brief.dart';
import 'package:sociale_vote/domain/content/news/repositories/world_brief_repository.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/social_vote_hud_service.dart';

class WorldBriefEditorPage extends StatefulWidget {
  const WorldBriefEditorPage({super.key});

  @override
  State<WorldBriefEditorPage> createState() => _WorldBriefEditorPageState();
}

class _WorldBriefEditorPageState extends State<WorldBriefEditorPage> {
  late final WorldBriefRepository _repository;
  List<WorldBrief> _briefs = const <WorldBrief>[];
  WorldBriefStatus? _statusFilter;
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _actionInProgress = false;

  @override
  void initState() {
    super.initState();
    _repository = AppDI.instance.worldBriefRepository;
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadFailed = false;
      });
    }

    try {
      final briefs = await _repository.listForAdmin(status: _statusFilter);
      if (!mounted) return;
      setState(() {
        _briefs = briefs;
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _briefs = const <WorldBrief>[];
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _openCreate() async {
    final draft = await showDialog<WorldBriefDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _WorldBriefFormDialog(),
    );
    if (!mounted || draft == null) return;
    await _save(draft, publish: false);
  }

  Future<void> _openEdit(WorldBrief brief) async {
    if (brief.status != WorldBriefStatus.draft) return;
    final draft = await showDialog<WorldBriefDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WorldBriefFormDialog(brief: brief),
    );
    if (!mounted || draft == null) return;
    await _save(draft, publish: false);
  }

  Future<void> _save(WorldBriefDraft draft, {required bool publish}) async {
    final l10n = AppLocalizations.of(context)!;
    if (_actionInProgress) return;
    setState(() => _actionInProgress = true);

    try {
      final saved = await _repository.saveDraft(draft);
      if (publish) {
        await _repository.publish(saved.id);
      }
      if (!mounted) return;
      SocialVoteHud.showSuccess(
        publish ? l10n.worldBriefPublished : l10n.worldBriefDraftSaved,
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      SocialVoteHud.showError(
        l10n.worldBriefSaveError,
        detail: error.toString(),
      );
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _publish(WorldBrief brief) async {
    final l10n = AppLocalizations.of(context)!;
    if (_actionInProgress) return;
    setState(() => _actionInProgress = true);
    try {
      await _repository.publish(brief.id);
      if (!mounted) return;
      SocialVoteHud.showSuccess(l10n.worldBriefPublished);
      await _load();
    } catch (error) {
      if (!mounted) return;
      SocialVoteHud.showError(
        l10n.worldBriefPublishError,
        detail: error.toString(),
      );
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _withdraw(WorldBrief brief) async {
    final l10n = AppLocalizations.of(context)!;
    if (_actionInProgress) return;
    setState(() => _actionInProgress = true);
    try {
      await _repository.withdraw(brief.id);
      if (!mounted) return;
      SocialVoteHud.showWarning(l10n.worldBriefWithdrawn);
      await _load();
    } catch (error) {
      if (!mounted) return;
      SocialVoteHud.showError(
        l10n.worldBriefSaveError,
        detail: error.toString(),
      );
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _deleteDraft(WorldBrief brief) async {
    final l10n = AppLocalizations.of(context)!;
    if (_actionInProgress || brief.status != WorldBriefStatus.draft) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.worldBriefDeleteDraft),
        content: Text(l10n.worldBriefDeleteDraftConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.worldBriefDeleteDraft),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() => _actionInProgress = true);
    try {
      await _repository.deleteDraft(brief.id);
      if (!mounted) return;
      SocialVoteHud.showInfo(l10n.worldBriefDraftDeleted);
      await _load();
    } catch (error) {
      if (!mounted) return;
      SocialVoteHud.showError(
        l10n.worldBriefSaveError,
        detail: error.toString(),
      );
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      key: const ValueKey<String>('world-brief-editor'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.worldBriefEditorTitle,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.worldBriefEditorDescription),
                  ],
                ),
              ),
              DropdownButton<WorldBriefStatus?>(
                value: _statusFilter,
                hint: Text(l10n.worldBriefAllStatuses),
                items: [
                  DropdownMenuItem<WorldBriefStatus?>(
                    value: null,
                    child: Text(l10n.worldBriefAllStatuses),
                  ),
                  for (final status in WorldBriefStatus.values)
                    DropdownMenuItem<WorldBriefStatus?>(
                      value: status,
                      child: Text(_statusLabel(l10n, status)),
                    ),
                ],
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _statusFilter = value);
                        _load();
                      },
              ),
              FilledButton.icon(
                key: const ValueKey<String>('world-brief-create'),
                onPressed: _actionInProgress ? null : _openCreate,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.worldBriefCreateAction),
              ),
            ],
          ),
        ),
        if (_isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(child: _buildBody(context, l10n)),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_isLoading && _briefs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadFailed) {
      return _WorldBriefState(
        icon: Icons.storage_outlined,
        title: l10n.worldBriefSetupRequired,
        message: l10n.worldBriefSetupRequiredBody,
        actionLabel: l10n.worldBriefRetry,
        onAction: _load,
      );
    }
    if (_briefs.isEmpty) {
      return _WorldBriefState(
        icon: Icons.newspaper_outlined,
        title: l10n.worldBriefEmptyTitle,
        message: l10n.worldBriefEmptyBody,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _briefs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final brief = _briefs[index];
        return _WorldBriefCard(
          brief: brief,
          actionInProgress: _actionInProgress,
          onEdit: () => _openEdit(brief),
          onPublish: () => _publish(brief),
          onWithdraw: () => _withdraw(brief),
          onDeleteDraft: () => _deleteDraft(brief),
        );
      },
    );
  }

  String _statusLabel(AppLocalizations l10n, WorldBriefStatus status) {
    return switch (status) {
      WorldBriefStatus.draft => l10n.worldBriefStatusDraft,
      WorldBriefStatus.published => l10n.worldBriefStatusPublished,
      WorldBriefStatus.withdrawn => l10n.worldBriefStatusWithdrawn,
    };
  }
}

class _WorldBriefCard extends StatelessWidget {
  final WorldBrief brief;
  final bool actionInProgress;
  final VoidCallback onEdit;
  final VoidCallback onPublish;
  final VoidCallback onWithdraw;
  final VoidCallback onDeleteDraft;

  const _WorldBriefCard({
    required this.brief,
    required this.actionInProgress,
    required this.onEdit,
    required this.onPublish,
    required this.onWithdraw,
    required this.onDeleteDraft,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusLabel = switch (brief.status) {
      WorldBriefStatus.draft => l10n.worldBriefStatusDraft,
      WorldBriefStatus.published => l10n.worldBriefStatusPublished,
      WorldBriefStatus.withdrawn => l10n.worldBriefStatusWithdrawn,
    };

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(statusLabel)),
                Chip(label: Text(brief.languageCode.toUpperCase())),
                if (brief.featured)
                  Chip(
                    avatar: const Icon(Icons.star_rounded, size: 16),
                    label: Text(l10n.worldBriefFeatured),
                  ),
                if (brief.mapVisible)
                  Chip(
                    avatar: const Icon(Icons.public_rounded, size: 16),
                    label: Text(l10n.worldBriefOnGlobe),
                  ),
                Chip(
                    label:
                        Text('${l10n.worldBriefPriority}: ${brief.priority}')),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              brief.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              brief.whatHappened,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (brief.status == WorldBriefStatus.draft) ...[
                  OutlinedButton.icon(
                    onPressed: actionInProgress ? null : onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.worldBriefEditAction),
                  ),
                  FilledButton.icon(
                    onPressed: actionInProgress ? null : onPublish,
                    icon: const Icon(Icons.publish_rounded),
                    label: Text(l10n.worldBriefPublishAction),
                  ),
                  TextButton.icon(
                    onPressed: actionInProgress ? null : onDeleteDraft,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l10n.worldBriefDeleteDraft),
                  ),
                ],
                if (brief.status == WorldBriefStatus.published)
                  OutlinedButton.icon(
                    onPressed: actionInProgress ? null : onWithdraw,
                    icon: const Icon(Icons.visibility_off_outlined),
                    label: Text(l10n.worldBriefWithdrawAction),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldBriefFormDialog extends StatefulWidget {
  final WorldBrief? brief;

  const _WorldBriefFormDialog({this.brief});

  @override
  State<_WorldBriefFormDialog> createState() => _WorldBriefFormDialogState();
}

class _WorldBriefFormDialogState extends State<_WorldBriefFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _whatHappened;
  late final TextEditingController _whyItMatters;
  late final TextEditingController _uncertain;
  late final TextEditingController _sources;
  late final TextEditingController _country;
  late final TextEditingController _cityId;
  late final TextEditingController _location;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late String _language;
  late bool _mapVisible;
  late bool _featured;
  late bool _breaking;
  late double _priority;
  int _expiryDays = 7;

  @override
  void initState() {
    super.initState();
    final brief = widget.brief;
    _title = TextEditingController(text: brief?.title);
    _whatHappened = TextEditingController(text: brief?.whatHappened);
    _whyItMatters = TextEditingController(text: brief?.whyItMatters);
    _uncertain = TextEditingController(text: brief?.whatIsUncertain);
    _sources = TextEditingController(text: brief?.sourceUrls.join('\n'));
    _country = TextEditingController(text: brief?.countryCode);
    _cityId = TextEditingController(text: brief?.cityId);
    _location = TextEditingController(text: brief?.locationLabel);
    _latitude = TextEditingController(text: brief?.latitude?.toString());
    _longitude = TextEditingController(text: brief?.longitude?.toString());
    _language = brief?.languageCode ?? 'it';
    _mapVisible = brief?.mapVisible ?? false;
    _featured = brief?.featured ?? false;
    _breaking = brief?.breaking ?? false;
    _priority = (brief?.priority ?? 50).toDouble();
  }

  @override
  void dispose() {
    _title.dispose();
    _whatHappened.dispose();
    _whyItMatters.dispose();
    _uncertain.dispose();
    _sources.dispose();
    _country.dispose();
    _cityId.dispose();
    _location.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          title: Text(
            widget.brief == null
                ? l10n.worldBriefCreateAction
                : l10n.worldBriefEditAction,
          ),
          actions: [
            TextButton(
              onPressed: _submit,
              child: Text(l10n.worldBriefSaveDraftAction),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: InputDecoration(
                  labelText: l10n.worldBriefLanguage,
                  border: const OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'it', child: Text('Italiano')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                  DropdownMenuItem(value: 'fa', child: Text('فارسی')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _language = value);
                },
              ),
              const SizedBox(height: 14),
              _requiredField(_title, l10n.worldBriefTitleField, maxLines: 2),
              const SizedBox(height: 14),
              _requiredField(
                _whatHappened,
                l10n.worldBriefWhatHappened,
                maxLines: 6,
              ),
              const SizedBox(height: 14),
              _requiredField(
                _whyItMatters,
                l10n.worldBriefWhyItMatters,
                maxLines: 6,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _uncertain,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.worldBriefWhatIsUncertain,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _sources,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.worldBriefSources,
                  helperText: l10n.worldBriefSourcesHint,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final urls = _sourceUrls(value);
                  if (urls.toSet().length < 2) {
                    return l10n.worldBriefTwoSourcesRequired;
                  }
                  if (urls.any((url) => !url.startsWith('https://'))) {
                    return l10n.worldBriefHttpsSourcesRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                l10n.worldBriefGlobeSection,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.worldBriefOnGlobe),
                subtitle: Text(l10n.worldBriefGlobeRequiresPoint),
                value: _mapVisible,
                onChanged: (value) => setState(() => _mapVisible = value),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      controller: _country,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: l10n.worldBriefCountryCode,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _cityId,
                      decoration: InputDecoration(
                        labelText: l10n.worldBriefCityId,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: TextFormField(
                      controller: _location,
                      decoration: InputDecoration(
                        labelText: l10n.worldBriefLocationLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      controller: _latitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.worldBriefLatitude,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => _mapCoordinateValidator(
                        value,
                        minimum: -90,
                        maximum: 90,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      controller: _longitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.worldBriefLongitude,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => _mapCoordinateValidator(
                        value,
                        minimum: -180,
                        maximum: 180,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _featured,
                onChanged: (value) =>
                    setState(() => _featured = value ?? false),
                title: Text(l10n.worldBriefFeatured),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _breaking,
                onChanged: (value) =>
                    setState(() => _breaking = value ?? false),
                title: Text(l10n.worldBriefBreaking),
              ),
              Text('${l10n.worldBriefPriority}: ${_priority.round()}'),
              Slider(
                value: _priority,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) => setState(() => _priority = value),
              ),
              DropdownButtonFormField<int>(
                initialValue: _expiryDays,
                decoration: InputDecoration(
                  labelText: l10n.worldBriefExpiry,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final days in const <int>[1, 3, 7, 14, 30])
                    DropdownMenuItem(
                      value: days,
                      child: Text(l10n.worldBriefExpiryDays(days)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _expiryDays = value);
                },
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.worldBriefSaveDraftAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _requiredField(
    TextEditingController controller,
    String label, {
    required int maxLines,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? l10n.worldBriefRequiredField
          : null,
    );
  }

  String? _mapCoordinateValidator(
    String? value, {
    required double minimum,
    required double maximum,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (!_mapVisible && (value == null || value.trim().isEmpty)) return null;
    final coordinate = double.tryParse(value?.trim() ?? '');
    if (coordinate == null ||
        !coordinate.isFinite ||
        coordinate < minimum ||
        coordinate > maximum) {
      return l10n.worldBriefCoordinatesRequired;
    }
    return null;
  }

  List<String> _sourceUrls(String? value) {
    return (value ?? '')
        .split(RegExp(r'[\r\n]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final latitude = double.tryParse(_latitude.text.trim());
    final longitude = double.tryParse(_longitude.text.trim());
    if (_mapVisible && (latitude == null || longitude == null)) return;

    Navigator.of(context).pop(
      WorldBriefDraft(
        id: widget.brief?.id,
        languageCode: _language,
        title: _title.text,
        whatHappened: _whatHappened.text,
        whyItMatters: _whyItMatters.text,
        whatIsUncertain: _uncertain.text,
        sourceUrls: _sourceUrls(_sources.text),
        countryCode: _country.text,
        cityId: _cityId.text,
        locationLabel: _location.text,
        latitude: latitude,
        longitude: longitude,
        mapVisible: _mapVisible,
        featured: _featured,
        breaking: _breaking,
        priority: _priority.round(),
        expiresAt: DateTime.now().toUtc().add(Duration(days: _expiryDays)),
      ),
    );
  }
}

class _WorldBriefState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _WorldBriefState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

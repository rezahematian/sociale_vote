import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/content/news/entities/world_brief.dart';
import 'package:sociale_vote/domain/content/news/repositories/world_brief_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';
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
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WorldBriefFormDialog(
        onSave: _saveDraftFromDialog,
      ),
    );
  }

  Future<void> _openEdit(WorldBrief brief) async {
    if (brief.status != WorldBriefStatus.draft) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WorldBriefFormDialog(
        brief: brief,
        onSave: _saveDraftFromDialog,
      ),
    );
  }

  Future<bool> _saveDraftFromDialog(WorldBriefDraft draft) async {
    final l10n = AppLocalizations.of(context)!;
    if (_actionInProgress) return false;
    setState(() => _actionInProgress = true);

    try {
      await _repository.saveDraft(draft);
      if (!mounted) return false;
      SocialVoteHud.showSuccess(l10n.worldBriefDraftSaved);
      await _load();
      return true;
    } catch (error) {
      if (!mounted) return false;
      SocialVoteHud.showError(
        l10n.worldBriefSaveError,
        detail: error.toString(),
      );
      return false;
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _publish(WorldBrief brief) async {
    final l10n = AppLocalizations.of(context)!;
    if (_actionInProgress) return;

    final issue = _publicationIssue(brief, l10n);
    if (issue != null) {
      SocialVoteHud.showWarning(issue);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.worldBriefPublishConfirmTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brief.title,
                  style: Theme.of(dialogContext)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.worldBriefWhatHappened}: ${brief.whatHappened}',
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.worldBriefWhyItMatters}: ${brief.whyItMatters}',
                ),
                if (brief.whatIsUncertain?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.worldBriefWhatIsUncertain}: '
                    '${brief.whatIsUncertain!.trim()}',
                  ),
                ],
                if (brief.socialVoteView?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.worldBriefSocialVoteView}: '
                    '${brief.socialVoteView!.trim()}',
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  l10n.worldBriefPublishConfirmSources(
                    brief.sourceUrls.length,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              MaterialLocalizations.of(dialogContext).cancelButtonLabel,
            ),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.publish_rounded),
            label: Text(l10n.worldBriefPublishAction),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

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

  String? _publicationIssue(WorldBrief brief, AppLocalizations l10n) {
    final validUris = brief.sourceUrls
        .map(Uri.tryParse)
        .whereType<Uri>()
        .where((uri) => uri.scheme == 'https' && uri.host.trim().isNotEmpty)
        .toList(growable: false);
    final hosts = validUris.map((uri) => uri.host.toLowerCase()).toSet();

    if (validUris.length != brief.sourceUrls.length) {
      return l10n.worldBriefHttpsSourcesRequired;
    }
    if (hosts.length < 2) {
      return l10n.worldBriefIndependentSourcesRequired;
    }
    if (brief.mapVisible && !brief.hasMapPoint) {
      return l10n.worldBriefGlobeRequiresPoint;
    }
    return null;
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

enum _WorldBriefPlacementMode {
  city,
  country,
}

class _WorldBriefFormDialog extends StatefulWidget {
  final WorldBrief? brief;
  final Future<bool> Function(WorldBriefDraft draft) onSave;

  const _WorldBriefFormDialog({
    this.brief,
    required this.onSave,
  });

  @override
  State<_WorldBriefFormDialog> createState() => _WorldBriefFormDialogState();
}

class _WorldBriefFormDialogState extends State<_WorldBriefFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _whatHappened;
  late final TextEditingController _whyItMatters;
  late final TextEditingController _uncertain;
  late final TextEditingController _socialVoteView;
  late final TextEditingController _sources;
  late final TextEditingController _city;
  late String _language;
  String? _countryCode;
  late _WorldBriefPlacementMode _placementMode;
  late bool _mapVisible;
  late bool _featured;
  late bool _breaking;
  late double _priority;
  int _expiryDays = 7;
  bool _isResolvingLocation = false;
  bool _isSaving = false;
  ContentLocation? _resolvedLocation;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    final brief = widget.brief;
    _title = TextEditingController(text: brief?.title);
    _whatHappened = TextEditingController(text: brief?.whatHappened);
    _whyItMatters = TextEditingController(text: brief?.whyItMatters);
    _uncertain = TextEditingController(text: brief?.whatIsUncertain);
    _socialVoteView = TextEditingController(text: brief?.socialVoteView);
    _sources = TextEditingController(text: brief?.sourceUrls.join('\n'));
    _city = TextEditingController(text: brief?.cityId);
    _language = brief?.languageCode ?? 'it';
    _countryCode = brief?.countryCode;
    _placementMode = brief?.cityId?.trim().isNotEmpty == true
        ? _WorldBriefPlacementMode.city
        : _WorldBriefPlacementMode.country;
    _mapVisible = brief?.mapVisible ?? false;
    _featured = brief?.featured ?? false;
    _breaking = brief?.breaking ?? false;
    _priority = (brief?.priority ?? 50).toDouble();

    if (brief?.hasMapPoint == true) {
      _resolvedLocation = ContentLocation(
        source: ContentLocationSource.manual,
        countryCode: brief!.countryCode,
        cityId: brief.cityId,
        cityName: brief.cityId,
        latitude: brief.latitude,
        longitude: brief.longitude,
        centerLat: brief.latitude,
        centerLng: brief.longitude,
      );
    }

    if (brief?.expiresAt != null) {
      final remainingDays = brief!.expiresAt!.difference(DateTime.now()).inDays;
      const options = <int>[1, 3, 7, 14, 30];
      _expiryDays = options.reduce(
        (a, b) =>
            (a - remainingDays).abs() <= (b - remainingDays).abs() ? a : b,
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _whatHappened.dispose();
    _whyItMatters.dispose();
    _uncertain.dispose();
    _socialVoteView.dispose();
    _sources.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 980;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          title: Text(
            widget.brief == null
                ? l10n.worldBriefCreateAction
                : l10n.worldBriefEditAction,
          ),
          actions: [
            TextButton.icon(
              onPressed: _isResolvingLocation || _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.worldBriefSaveDraftAction),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final content = ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _editorIntro(theme, l10n),
                  const SizedBox(height: 16),
                  _sectionCard(
                    context,
                    icon: Icons.article_outlined,
                    title: l10n.worldBriefEditorialContentSection,
                    subtitle: l10n.worldBriefEditorialContentHelp,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _language,
                          decoration: InputDecoration(
                            labelText: l10n.worldBriefLanguage,
                            border: const OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'it',
                              child: Text('Italiano'),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: 'de',
                              child: Text('Deutsch'),
                            ),
                            DropdownMenuItem(
                              value: 'fa',
                              child: Text('فارسی'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _language = value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        _requiredField(
                          _title,
                          l10n.worldBriefTitleField,
                          maxLines: 2,
                        ),
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
                          controller: _socialVoteView,
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: l10n.worldBriefSocialVoteView,
                            helperText: l10n.worldBriefSocialVoteViewHint,
                            border: const OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    context,
                    icon: Icons.fact_check_outlined,
                    title: l10n.worldBriefSourcesSection,
                    subtitle: l10n.worldBriefSourcesSectionHelp,
                    child: TextFormField(
                      controller: _sources,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: l10n.worldBriefSources,
                        helperText: l10n.worldBriefSourcesHint,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        final urls = _sourceUrls(value);
                        for (final url in urls) {
                          final uri = Uri.tryParse(url);
                          if (uri == null ||
                              uri.scheme != 'https' ||
                              uri.host.trim().isEmpty) {
                            return l10n.worldBriefHttpsSourcesRequired;
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    context,
                    icon: Icons.public_rounded,
                    title: l10n.worldBriefDistributionSection,
                    subtitle: l10n.worldBriefDistributionHelp,
                    child: Column(
                      children: [
                        _distributionRow(
                          context,
                          icon: Icons.newspaper_outlined,
                          title: l10n.worldBriefNewsDestination,
                          subtitle: l10n.worldBriefNewsDestinationHelp,
                          trailing: const Icon(Icons.lock_outline_rounded),
                        ),
                        const Divider(height: 24),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.public_rounded),
                          title: Text(l10n.worldBriefOnGlobe),
                          subtitle: Text(l10n.worldBriefGlobeAutomaticHelp),
                          value: _mapVisible,
                          onChanged: (value) {
                            setState(() {
                              _mapVisible = value;
                              _locationError = null;
                            });
                          },
                        ),
                        if (_mapVisible) ...[
                          const SizedBox(height: 10),
                          _globePlacementEditor(context, l10n),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    context,
                    icon: Icons.tune_rounded,
                    title: l10n.worldBriefVisibilitySection,
                    subtitle: l10n.worldBriefVisibilityHelp,
                    child: Column(
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _featured,
                          onChanged: (value) =>
                              setState(() => _featured = value ?? false),
                          secondary: const Icon(Icons.star_outline_rounded),
                          title: Text(l10n.worldBriefFeatured),
                          subtitle: Text(l10n.worldBriefFeaturedHelp),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _breaking,
                          onChanged: (value) =>
                              setState(() => _breaking = value ?? false),
                          secondary:
                              const Icon(Icons.notification_important_outlined),
                          title: Text(l10n.worldBriefBreaking),
                          subtitle: Text(l10n.worldBriefBreakingHelp),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '${l10n.worldBriefPriority}: ${_priority.round()}',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Slider(
                          value: _priority,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: _priority.round().toString(),
                          onChanged: (value) =>
                              setState(() => _priority = value),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            l10n.worldBriefPriorityHelp,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          initialValue: _expiryDays,
                          decoration: InputDecoration(
                            labelText: l10n.worldBriefExpiry,
                            helperText: l10n.worldBriefExpiryHelp,
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
                            if (value != null) {
                              setState(() => _expiryDays = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed:
                        _isResolvingLocation || _isSaving ? null : _submit,
                    icon: _isResolvingLocation || _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(l10n.worldBriefSaveDraftAction),
                  ),
                ],
              );

              if (!isWide) return content;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: content,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _editorIntro(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.worldBriefEnterpriseEditorTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(l10n.worldBriefEnterpriseEditorHelp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  Widget _distributionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );
  }

  Widget _globePlacementEditor(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final countryName = _countryCode == null
        ? null
        : Countries.nameForCode(
            _countryCode!,
            languageCode: languageCode,
            fallback: _countryCode!,
          );
    final city = _city.text.trim();
    final resolved = _resolvedLocation;
    final resolvedLabel = resolved == null
        ? null
        : _placementMode == _WorldBriefPlacementMode.city && city.isNotEmpty
            ? '$city, ${countryName ?? _countryCode ?? ''}'
            : countryName ?? _countryCode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.worldBriefPlacementMode,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SegmentedButton<_WorldBriefPlacementMode>(
            segments: [
              ButtonSegment<_WorldBriefPlacementMode>(
                value: _WorldBriefPlacementMode.city,
                icon: const Icon(Icons.location_city_outlined),
                label: Text(l10n.worldBriefPlacementCity),
              ),
              ButtonSegment<_WorldBriefPlacementMode>(
                value: _WorldBriefPlacementMode.country,
                icon: const Icon(Icons.flag_outlined),
                label: Text(l10n.worldBriefPlacementCountry),
              ),
            ],
            selected: <_WorldBriefPlacementMode>{_placementMode},
            onSelectionChanged: (selection) {
              setState(() {
                _placementMode = selection.first;
                _resolvedLocation = null;
                _locationError = null;
              });
            },
          ),
          const SizedBox(height: 16),
          CountrySelectorField(
            selectedCountryCode: _countryCode,
            label: l10n.worldBriefCountry,
            required: true,
            onCountrySelected: (code) {
              setState(() {
                _countryCode = code;
                _resolvedLocation = null;
                _locationError = null;
              });
            },
          ),
          if (_placementMode == _WorldBriefPlacementMode.city) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _city,
              decoration: InputDecoration(
                labelText: l10n.worldBriefCity,
                helperText: l10n.worldBriefCityHelp,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_resolvedLocation != null || _locationError != null) {
                  setState(() {
                    _resolvedLocation = null;
                    _locationError = null;
                  });
                }
              },
              validator: (value) {
                if (_mapVisible &&
                    _placementMode == _WorldBriefPlacementMode.city &&
                    (value == null || value.trim().isEmpty)) {
                  return l10n.worldBriefRequiredField;
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: _isResolvingLocation ? null : _resolveLocation,
                icon: _isResolvingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
                label: Text(l10n.worldBriefResolveLocation),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.worldBriefCoordinatesAutomatic,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (_locationError != null) ...[
            const SizedBox(height: 12),
            _locationStatus(
              context,
              icon: Icons.error_outline_rounded,
              text: _locationError!,
              isError: true,
            ),
          ] else if (resolved != null) ...[
            const SizedBox(height: 12),
            _locationStatus(
              context,
              icon: Icons.check_circle_outline_rounded,
              text: l10n.worldBriefLocationResolved(
                resolvedLabel ?? l10n.worldBriefGlobeSection,
              ),
              isError: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _locationStatus(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool isError,
  }) {
    final theme = Theme.of(context);
    final color = isError ? theme.colorScheme.error : theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
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

  List<String> _sourceUrls(String? value) {
    return (value ?? '')
        .split(RegExp(r'[\r\n]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  Future<ContentLocation?> _resolveLocation() async {
    final l10n = AppLocalizations.of(context)!;
    final countryCode = _countryCode?.trim().toUpperCase();
    final city = _city.text.trim();

    if (countryCode == null || countryCode.isEmpty) {
      setState(() => _locationError = l10n.worldBriefChooseCountryFirst);
      return null;
    }
    if (_placementMode == _WorldBriefPlacementMode.city && city.isEmpty) {
      setState(() => _locationError = l10n.worldBriefChooseCityFirst);
      return null;
    }

    setState(() {
      _isResolvingLocation = true;
      _locationError = null;
    });

    try {
      final seed = ContentLocation(
        source: ContentLocationSource.manual,
        countryCode: countryCode,
        cityId: _placementMode == _WorldBriefPlacementMode.city ? city : null,
        cityName: _placementMode == _WorldBriefPlacementMode.city ? city : null,
      );
      final resolved =
          await AppDI.instance.geocodingRepository.geocodeContentLocation(seed);
      if (!mounted) return null;
      if (resolved == null || !resolved.hasExactPoint) {
        setState(() {
          _resolvedLocation = null;
          _locationError = l10n.worldBriefLocationNotResolved;
        });
        return null;
      }
      setState(() {
        _resolvedLocation = resolved;
        _locationError = null;
      });
      return resolved;
    } catch (_) {
      if (!mounted) return null;
      setState(() {
        _resolvedLocation = null;
        _locationError = l10n.worldBriefLocationNotResolved;
      });
      return null;
    } finally {
      if (mounted) setState(() => _isResolvingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    ContentLocation? location = _resolvedLocation;
    if (_mapVisible) {
      location ??= await _resolveLocation();
      if (!mounted || location == null) return;
    }

    final countryCode = _countryCode?.trim().toUpperCase();
    final city = _city.text.trim();
    final languageCode = Localizations.localeOf(context).languageCode;
    final countryName = countryCode == null
        ? null
        : Countries.nameForCode(
            countryCode,
            languageCode: languageCode,
            fallback: countryCode,
          );
    final locationLabel = !_mapVisible
        ? null
        : _placementMode == _WorldBriefPlacementMode.city && city.isNotEmpty
            ? '$city, ${countryName ?? countryCode ?? ''}'
            : countryName ?? countryCode;

    final draft = WorldBriefDraft(
      id: widget.brief?.id,
      languageCode: _language,
      title: _title.text,
      whatHappened: _whatHappened.text,
      whyItMatters: _whyItMatters.text,
      whatIsUncertain: _uncertain.text,
      socialVoteView: _socialVoteView.text,
      sourceUrls: _sourceUrls(_sources.text),
      countryCode: _mapVisible ? countryCode : null,
      cityId: _mapVisible && _placementMode == _WorldBriefPlacementMode.city
          ? city
          : null,
      locationLabel: locationLabel,
      latitude: _mapVisible ? location?.latitude : null,
      longitude: _mapVisible ? location?.longitude : null,
      mapVisible: _mapVisible,
      featured: _featured,
      breaking: _breaking,
      priority: _priority.round(),
      expiresAt: widget.brief?.expiresAt ??
          DateTime.now().toUtc().add(Duration(days: _expiryDays)),
    );

    setState(() => _isSaving = true);
    final saved = await widget.onSave(draft);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSaving = false);
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

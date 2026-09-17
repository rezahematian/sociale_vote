import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/content/news/entities/world_brief.dart';
import 'package:sociale_vote/domain/content/news/repositories/world_brief_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';
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

  Future<void> _openTranslations(WorldBrief brief) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WorldBriefTranslationsDialog(
        brief: brief,
        repository: _repository,
      ),
    );
  }

  Future<void> _openRadio(WorldBrief brief) async {
    try {
      final tracks = await AppDI.instance.adminRepository.getRadioMondoTracks();
      if (!mounted) return;
      final linked = tracks
          .where((track) => track.worldBriefId == brief.id)
          .toList(growable: false)
        ..sort((a, b) {
          final liveOrder = (b.isLive ? 1 : 0).compareTo(a.isLive ? 1 : 0);
          if (liveOrder != 0) return liveOrder;
          final defaultOrder =
              (b.isDefault ? 1 : 0).compareTo(a.isDefault ? 1 : 0);
          if (defaultOrder != 0) return defaultOrder;
          return a.sortOrder.compareTo(b.sortOrder);
        });
      await showDialog<void>(
        context: context,
        builder: (_) => _WorldBriefRadioDialog(
          brief: brief,
          tracks: linked,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      SocialVoteHud.showError(
        _worldBriefV3Text(
          context,
          it: 'Radio Mondo non disponibile',
          en: 'World Radio unavailable',
        ),
        detail: error.toString(),
      );
    }
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
                if (brief.whatHappened.trim().isNotEmpty) ...[
                  Text(
                    '${l10n.worldBriefWhatHappened}: ${brief.whatHappened.trim()}',
                  ),
                ],
                if (brief.whyItMatters.trim().isNotEmpty) ...[
                  if (brief.whatHappened.trim().isNotEmpty)
                    const SizedBox(height: 8),
                  Text(
                    '${l10n.worldBriefWhyItMatters}: ${brief.whyItMatters.trim()}',
                  ),
                ],
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
                  brief.contentKind.requiresIndependentSources
                      ? l10n.worldBriefPublishConfirmSources(brief.sourceUrls.length)
                      : _worldBriefV3Text(
                          dialogContext,
                          it: brief.sourceUrls.isEmpty
                              ? 'Articolo originale Social Vote · fonti esterne facoltative'
                              : 'Articolo originale Social Vote · ${brief.sourceUrls.length} fonti facoltative',
                          en: brief.sourceUrls.isEmpty
                              ? 'Social Vote original · external sources optional'
                              : 'Social Vote original · ${brief.sourceUrls.length} optional sources',
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
    if (brief.contentKind.requiresIndependentSources && hosts.length < 2) {
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
          onTranslations: () => _openTranslations(brief),
          onRadio: () => _openRadio(brief),
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
  final VoidCallback onTranslations;
  final VoidCallback onRadio;

  const _WorldBriefCard({
    required this.brief,
    required this.actionInProgress,
    required this.onEdit,
    required this.onPublish,
    required this.onWithdraw,
    required this.onDeleteDraft,
    required this.onTranslations,
    required this.onRadio,
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
                Chip(
                  avatar: Icon(
                    brief.contentKind == WorldBriefContentKind.socialVoteOriginal
                        ? Icons.edit_note_rounded
                        : Icons.fact_check_outlined,
                    size: 16,
                  ),
                  label: Text(
                    brief.contentKind == WorldBriefContentKind.socialVoteOriginal
                        ? _worldBriefV3Text(context, it: 'Originale Social Vote', en: 'Social Vote original')
                        : _worldBriefV3Text(context, it: 'Brief con fonti', en: 'Sourced brief'),
                  ),
                ),
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
            if (brief.whatHappened.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                brief.whatHappened.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: actionInProgress ? null : onTranslations,
                  icon: const Icon(Icons.translate_rounded),
                  label: Text(_worldBriefV3Text(context, it: 'Lingue', en: 'Languages')),
                ),
                OutlinedButton.icon(
                  onPressed: actionInProgress ? null : onRadio,
                  icon: const Icon(Icons.radio_rounded),
                  label: Text(_worldBriefV3Text(
                    context,
                    it: 'Radio',
                    en: 'Radio',
                  )),
                ),
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

class _WorldBriefRadioDialog extends StatelessWidget {
  final WorldBrief brief;
  final List<AdminRadioMondoTrack> tracks;

  const _WorldBriefRadioDialog({
    required this.brief,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_worldBriefV3Text(
        context,
        it: 'Radio Mondo · ${brief.title}',
        en: 'World Radio · ${brief.title}',
      )),
      content: SizedBox(
        width: 680,
        child: tracks.isEmpty
            ? Text(_worldBriefV3Text(
                context,
                it: 'Nessun audio o live collegato. Vai in Admin Center → Radio Mondo e scegli questo World Brief per titolo nel campo “World Brief collegato”.',
                en: 'No linked audio or live item. Open Admin Center → World Radio and choose this World Brief by title in the “Linked World Brief” field.',
              ))
            : ListView.separated(
                shrinkWrap: true,
                itemCount: tracks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  final flags = <String>[
                    track.channelType.storageKey.replaceAll('_', ' ').toUpperCase(),
                    track.sourceType.storageKey.toUpperCase(),
                    if (track.languageCode != null)
                      track.languageCode!.toUpperCase(),
                    if (track.isDefault) 'DEFAULT',
                    if (track.isLive) 'LIVE',
                    if (!track.isEnabled) 'OFF',
                  ];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      track.isLive
                          ? Icons.podcasts_rounded
                          : Icons.radio_rounded,
                    ),
                    title: Text(track.title),
                    subtitle: Text(flags.join(' · ')),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
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
  late WorldBriefContentKind _contentKind;
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
    for (final controller in <TextEditingController>[
      _title,
      _whatHappened,
      _whyItMatters,
      _uncertain,
      _socialVoteView,
      _city,
    ]) {
      controller.addListener(_refreshEditableDirection);
    }
    _language = brief?.languageCode ?? 'it';
    _contentKind = brief?.contentKind ?? WorldBriefContentKind.reported;
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

  void _refreshEditableDirection() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _title,
      _whatHappened,
      _whyItMatters,
      _uncertain,
      _socialVoteView,
      _city,
    ]) {
      controller.removeListener(_refreshEditableDirection);
    }
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
                        _optionalField(
                          _whatHappened,
                          l10n.worldBriefWhatHappened,
                          maxLines: 6,
                        ),
                        const SizedBox(height: 14),
                        _optionalField(
                          _whyItMatters,
                          l10n.worldBriefWhyItMatters,
                          maxLines: 6,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _uncertain,
                          textDirection: socialVoteEditableTextDirection(
                            context,
                            _uncertain.text,
                          ),
                          textAlign: socialVoteEditableTextAlign(
                            context,
                            _uncertain.text,
                          ),
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
                          textDirection: socialVoteEditableTextDirection(
                            context,
                            _socialVoteView.text,
                          ),
                          textAlign: socialVoteEditableTextAlign(
                            context,
                            _socialVoteView.text,
                          ),
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
                    icon: Icons.article_outlined,
                    title: _worldBriefV3Text(context, it: 'Tipo di contenuto', en: 'Content type'),
                    subtitle: _worldBriefV3Text(
                      context,
                      it: 'Scegli se il contenuto riporta fatti da fonti esterne oppure è un articolo originale prodotto da Social Vote.',
                      en: 'Choose whether this reports externally sourced facts or is original content produced by Social Vote.',
                    ),
                    child: DropdownButtonFormField<WorldBriefContentKind>(
                      initialValue: _contentKind,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: [
                        DropdownMenuItem(
                          value: WorldBriefContentKind.reported,
                          child: Text(_worldBriefV3Text(context, it: 'Brief con fonti', en: 'Sourced brief')),
                        ),
                        DropdownMenuItem(
                          value: WorldBriefContentKind.socialVoteOriginal,
                          child: Text(_worldBriefV3Text(context, it: 'Originale Social Vote', en: 'Social Vote original')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _contentKind = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    context,
                    icon: Icons.fact_check_outlined,
                    title: l10n.worldBriefSourcesSection,
                    subtitle: _contentKind.requiresIndependentSources
                        ? l10n.worldBriefSourcesSectionHelp
                        : _worldBriefV3Text(
                            context,
                            it: 'Per un Originale Social Vote le fonti esterne sono facoltative. Se le aggiungi devono essere URL HTTPS validi.',
                            en: 'External sources are optional for a Social Vote original. If provided, they must be valid HTTPS URLs.',
                          ),
                    child: TextFormField(
                      controller: _sources,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: l10n.worldBriefSources,
                        helperText: _contentKind.requiresIndependentSources
                            ? l10n.worldBriefSourcesHint
                            : _worldBriefV3Text(context, it: 'Facoltative per Originale Social Vote', en: 'Optional for Social Vote original'),
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
              textDirection: socialVoteEditableTextDirection(
                context,
                _city.text,
              ),
              textAlign: socialVoteEditableTextAlign(
                context,
                _city.text,
              ),
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
      textDirection: socialVoteEditableTextDirection(
        context,
        controller.text,
      ),
      textAlign: socialVoteEditableTextAlign(
        context,
        controller.text,
      ),
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

  Widget _optionalField(
    TextEditingController controller,
    String label, {
    required int maxLines,
  }) {
    return TextFormField(
      controller: controller,
      textDirection: socialVoteEditableTextDirection(
        context,
        controller.text,
      ),
      textAlign: socialVoteEditableTextAlign(
        context,
        controller.text,
      ),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
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
      contentKind: _contentKind,
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

const _worldBriefV3Languages = <String>['en', 'it', 'de', 'fa', 'es', 'pt', 'fr', 'ar', 'ro', 'ru', 'zh'];

String _worldBriefV3Text(
  BuildContext context, {
  required String it,
  required String en,
}) {
  return Localizations.localeOf(context).languageCode.toLowerCase() == 'it' ? it : en;
}

class _WorldBriefTranslationsDialog extends StatefulWidget {
  final WorldBrief brief;
  final WorldBriefRepository repository;

  const _WorldBriefTranslationsDialog({
    required this.brief,
    required this.repository,
  });

  @override
  State<_WorldBriefTranslationsDialog> createState() =>
      _WorldBriefTranslationsDialogState();
}

class _WorldBriefTranslationsDialogState
    extends State<_WorldBriefTranslationsDialog> {
  List<WorldBriefTranslation> _items = const <WorldBriefTranslation>[];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await widget.repository
          .listTranslationsForAdmin(widget.brief.id);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      SocialVoteHud.showError('World Brief translations', detail: error.toString());
    }
  }

  WorldBriefTranslation? _forLanguage(String code) {
    for (final item in _items) {
      if (item.languageCode == code) return item;
    }
    return null;
  }

  Future<void> _edit(String languageCode) async {
    final existing = _forLanguage(languageCode);
    final draft = await showDialog<WorldBriefTranslationDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WorldBriefTranslationFormDialog(
        brief: widget.brief,
        languageCode: languageCode,
        existing: existing,
      ),
    );
    if (!mounted || draft == null) return;
    setState(() => _saving = true);
    try {
      await widget.repository.saveTranslation(draft);
      await _load();
    } catch (error) {
      if (!mounted) return;
      SocialVoteHud.showError('World Brief translation', detail: error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(WorldBriefTranslation item) async {
    setState(() => _saving = true);
    try {
      await widget.repository.deleteTranslation(
        widget.brief.id,
        item.languageCode,
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      SocialVoteHud.showError('World Brief translation', detail: error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languages = _worldBriefV3Languages
        .where((code) => code != widget.brief.primaryLanguageCode)
        .toList(growable: false);
    return AlertDialog(
      title: Text(_worldBriefV3Text(
        context,
        it: 'Versioni linguistiche',
        en: 'Language versions',
      )),
      content: SizedBox(
        width: 720,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _worldBriefV3Text(
                        context,
                        it: 'Lingua principale: ${widget.brief.primaryLanguageCode.toUpperCase()}. Aggiungi solo le lingue che vuoi pubblicare; le altre useranno la lingua principale.',
                        en: 'Primary language: ${widget.brief.primaryLanguageCode.toUpperCase()}. Add only the languages you want to publish; the others fall back to the primary language.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final code in languages)
                      Builder(builder: (context) {
                        final item = _forLanguage(code);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text(code.toUpperCase())),
                          title: Text(code.toUpperCase()),
                          subtitle: Text(
                            item == null
                                ? _worldBriefV3Text(context, it: 'Non aggiunta', en: 'Not added')
                                : item.isEnabled
                                    ? _worldBriefV3Text(context, it: 'Attiva', en: 'Active')
                                    : _worldBriefV3Text(context, it: 'Salvata ma nascosta', en: 'Saved but hidden'),
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                tooltip: _worldBriefV3Text(context, it: 'Modifica', en: 'Edit'),
                                onPressed: _saving ? null : () => _edit(code),
                                icon: Icon(item == null ? Icons.add_rounded : Icons.edit_outlined),
                              ),
                              if (item != null)
                                IconButton(
                                  tooltip: _worldBriefV3Text(context, it: 'Elimina', en: 'Delete'),
                                  onPressed: _saving ? null : () => _delete(item),
                                  icon: const Icon(Icons.delete_outline_rounded),
                                ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}

class _WorldBriefTranslationFormDialog extends StatefulWidget {
  final WorldBrief brief;
  final String languageCode;
  final WorldBriefTranslation? existing;

  const _WorldBriefTranslationFormDialog({
    required this.brief,
    required this.languageCode,
    required this.existing,
  });

  @override
  State<_WorldBriefTranslationFormDialog> createState() =>
      _WorldBriefTranslationFormDialogState();
}

class _WorldBriefTranslationFormDialogState
    extends State<_WorldBriefTranslationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _what;
  late final TextEditingController _why;
  late final TextEditingController _uncertain;
  late final TextEditingController _view;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final item = widget.existing;
    _title = TextEditingController(text: item?.title);
    _what = TextEditingController(text: item?.whatHappened);
    _why = TextEditingController(text: item?.whyItMatters);
    _uncertain = TextEditingController(text: item?.whatIsUncertain);
    _view = TextEditingController(text: item?.socialVoteView);
    _enabled = item?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _what.dispose();
    _why.dispose();
    _uncertain.dispose();
    _view.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? _worldBriefV3Text(context, it: 'Campo obbligatorio', en: 'Required field')
      : null;

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      WorldBriefTranslationDraft(
        briefId: widget.brief.id,
        languageCode: widget.languageCode,
        title: _title.text,
        whatHappened: _what.text,
        whyItMatters: _why.text,
        whatIsUncertain: _uncertain.text,
        socialVoteView: _view.text,
        isEnabled: _enabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.languageCode.toUpperCase()} · ${widget.brief.title}'),
      content: SizedBox(
        width: 700,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  maxLength: 240,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _what,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'What happened',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _why,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Why it matters',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _uncertain,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'What is still uncertain',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _view,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Social Vote view',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                  title: Text(_worldBriefV3Text(
                    context,
                    it: 'Versione attiva',
                    en: 'Version active',
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(_worldBriefV3Text(context, it: 'Salva', en: 'Save')),
        ),
      ],
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

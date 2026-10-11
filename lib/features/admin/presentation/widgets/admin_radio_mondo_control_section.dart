import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';

import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';
import 'package:sociale_vote/domain/content/news/entities/world_brief.dart';
import 'package:sociale_vote/shared/services/radio_mondo_admin_storage_service.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';

class AdminRadioMondoControlSection extends StatefulWidget {
  final AdminRepository repository;
  final int refreshRevision;

  const AdminRadioMondoControlSection({
    super.key,
    required this.repository,
    required this.refreshRevision,
  });

  @override
  State<AdminRadioMondoControlSection> createState() =>
      _AdminRadioMondoControlSectionState();
}

class _AdminRadioMondoControlSectionState
    extends State<AdminRadioMondoControlSection> {
  List<AdminRadioMondoTrack> _tracks = const [];
  bool _loading = true;
  bool _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AdminRadioMondoControlSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshRevision != widget.refreshRevision) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tracks = await widget.repository.getRadioMondoTracks();
      if (!mounted) return;
      setState(() => _tracks = tracks);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _manageJahan() async {
    final draft = await showDialog<_RadioJahanDraft>(
      context: context,
      builder: (_) => _RadioJahanDialog(tracks: _tracks),
    );
    if (draft == null || _saving) return;

    setState(() => _saving = true);
    try {
      await widget.repository.setRadioJahanPlaylist(
        items: draft.items,
        reason: draft.reason,
      );
      await _load();
      await RadioMondoService.instance.reloadCatalog();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _radioText(
              context,
              'Radio Jahan aggiornata',
              'Radio Jahan updated',
              'Radio Jahan aktualisiert',
              'رادیو جهان به‌روزرسانی شد',
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit([AdminRadioMondoTrack? existing]) async {
    List<WorldBrief> worldBriefs = const <WorldBrief>[];
    try {
      worldBriefs = await AppDI.instance.worldBriefRepository.listForAdmin(
        limit: 200,
      );
    } catch (_) {
      // Radio Mondo remains editable even if World Brief lookup is unavailable.
    }
    if (!mounted) return;

    final draft = await showDialog<_RadioTrackDraft>(
      context: context,
      builder: (_) => _RadioTrackDialog(
        existing: existing,
        worldBriefs: worldBriefs,
      ),
    );
    if (draft == null || _saving) return;

    setState(() => _saving = true);
    RadioMondoUploadedAudio? uploaded;
    try {
      var audioUrl = draft.audioUrl;
      final pickedAudio = draft.pickedAudio;
      if (pickedAudio != null) {
        uploaded = await RadioMondoAdminStorageService.instance.upload(
          pickedAudio,
        );
        audioUrl = uploaded.publicUrl;
      }

      await widget.repository.upsertRadioMondoTrack(
        trackId: existing?.id,
        title: draft.title,
        audioUrl: audioUrl,
        sortOrder: draft.sortOrder,
        isEnabled: draft.isEnabled,
        attribution: draft.attribution,
        licenseUrl: draft.licenseUrl,
        sourceType: draft.sourceType,
        channelType: draft.channelType,
        category: draft.category,
        languageCode: draft.languageCode,
        worldBriefId: draft.worldBriefId,
        isDefault: draft.isDefault,
        isLive: draft.isLive,
        rightsConfirmed: draft.rightsConfirmed,
        reason: draft.reason,
      );

      if (uploaded != null &&
          existing != null &&
          existing.audioUrl != audioUrl) {
        await RadioMondoAdminStorageService.instance
            .removeManagedUrlBestEffort(existing.audioUrl);
      }

      await _load();
      await RadioMondoService.instance.reloadCatalog();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_radioText(
              context,
              'Catalogo aggiornato',
              'Catalog updated',
              'Katalog aktualisiert',
              'فهرست به‌روزرسانی شد')),
        ),
      );
    } catch (error) {
      if (uploaded != null) {
        await RadioMondoAdminStorageService.instance
            .removeManagedUrlBestEffort(uploaded.publicUrl);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${_radioText(context, 'Salvataggio non riuscito', 'Could not save', 'Speichern fehlgeschlagen', 'ذخیره نشد')}: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _setEnabled(AdminRadioMondoTrack track, bool enabled) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _RadioEnabledReasonDialog(
        track: track,
        enabled: enabled,
      ),
    );
    if (reason == null || _saving) return;

    setState(() => _saving = true);
    try {
      await widget.repository.setRadioMondoTrackEnabled(
        trackId: track.id,
        isEnabled: enabled,
        reason: reason,
      );
      await _load();
      await RadioMondoService.instance.reloadCatalog();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${_radioText(context, 'Modifica non riuscita', 'Could not update', 'Aktualisierung fehlgeschlagen', 'تغییر انجام نشد')}: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(AdminRadioMondoTrack track) async {
    if (_saving) return;

    if (track.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _radioText(
              context,
              'Imposta prima un’altra stazione come predefinita.',
              'Set another station as default first.',
              'Lege zuerst eine andere Station als Standard fest.',
              'ابتدا یک ایستگاه دیگر را به‌عنوان پیش‌فرض انتخاب کنید.',
            ),
          ),
        ),
      );
      return;
    }

    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _RadioDeleteReasonDialog(track: track),
    );
    if (reason == null || _saving) return;

    setState(() => _saving = true);
    try {
      await widget.repository.deleteRadioMondoTrack(
        trackId: track.id,
        reason: reason,
      );

      final storage = RadioMondoAdminStorageService.instance;
      final managedAudio = storage.isManagedPublicUrl(track.audioUrl);
      final managedAudioRemoved =
          await storage.removeManagedUrlBestEffort(track.audioUrl);

      await _load();
      await RadioMondoService.instance.reloadCatalog();
      if (!mounted) return;

      final message = managedAudio && !managedAudioRemoved
          ? _radioText(
              context,
              'Traccia eliminata. Il file audio gestito non è stato rimosso: controlla Storage.',
              'Track deleted. The managed audio file was not removed; check Storage.',
              'Titel gelöscht. Die verwaltete Audiodatei wurde nicht entfernt; prüfe Storage.',
              'قطعه حذف شد. فایل صوتی مدیریت‌شده حذف نشد؛ Storage را بررسی کنید.',
            )
          : _radioText(
              context,
              'Traccia eliminata',
              'Track deleted',
              'Titel gelöscht',
              'قطعه حذف شد',
            );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_radioText(context, 'Eliminazione non riuscita', 'Could not delete', 'Löschen fehlgeschlagen', 'حذف انجام نشد')}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _preview(AdminRadioMondoTrack track) async {
    if (_saving) return;
    final radio = RadioMondoService.instance;
    final previewId = 'admin-preview-${track.id}';
    if (radio.currentStation?.id == previewId) {
      await radio.stop();
      return;
    }

    final station = RadioMondoStation(
      id: previewId,
      title: track.title,
      sortOrder: track.sortOrder,
      audioUrl: track.audioUrl,
      attribution: track.attribution,
      licenseUrl: track.licenseUrl,
      sourceType: track.sourceType == AdminRadioMondoSourceType.stream
          ? RadioMondoSourceType.stream
          : RadioMondoSourceType.audio,
      channelType: switch (track.channelType) {
        AdminRadioMondoChannelType.worldLive => RadioMondoChannelType.worldLive,
        AdminRadioMondoChannelType.nature => RadioMondoChannelType.nature,
        AdminRadioMondoChannelType.worldBrief =>
          RadioMondoChannelType.worldBrief,
        AdminRadioMondoChannelType.liveEvent => RadioMondoChannelType.liveEvent,
        AdminRadioMondoChannelType.special => RadioMondoChannelType.special,
      },
      category: switch (track.category) {
        AdminRadioMondoCategory.reggae => RadioMondoCategory.reggae,
        AdminRadioMondoCategory.classical => RadioMondoCategory.classical,
        AdminRadioMondoCategory.house => RadioMondoCategory.house,
        AdminRadioMondoCategory.jazzSoul => RadioMondoCategory.jazzSoul,
        AdminRadioMondoCategory.worldMusic => RadioMondoCategory.worldMusic,
        AdminRadioMondoCategory.soundsAtmospheres =>
          RadioMondoCategory.soundsAtmospheres,
      },
      languageCode: track.languageCode,
      worldBriefId: track.worldBriefId,
      isDefault: track.isDefault,
      isLive: track.isLive,
    );

    final success = await radio.playPreviewStation(station);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? _radioText(context, 'Anteprima avviata', 'Preview started',
                  'Vorschau gestartet', 'پیش‌نمایش شروع شد')
              : _radioText(context, 'Anteprima non riuscita', 'Preview failed',
                  'Vorschau fehlgeschlagen', 'پیش‌نمایش اجرا نشد'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      key: const ValueKey('admin-radio-mondo-control'),
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colors.tertiaryContainer,
                  foregroundColor: colors.onTertiaryContainer,
                  child: const Icon(Icons.radio_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Radio Mondo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _radioText(
                          context,
                          'Carica direttamente un file audio oppure usa un URL HTTPS. Formati supportati: MP3, WAV, M4A/MP4, AAC, OGG/OPUS, FLAC e WEBM. Assegna ogni traccia a una categoria: la playlist continuerà solo dentro quella categoria. Le tracce pubblicate compaiono su Web e Android. Pubblica solo contenuti per cui possiedi i diritti.',
                          'Upload an audio file directly, or use an HTTPS URL. Supported formats: MP3, WAV, M4A/MP4, AAC, OGG/OPUS, FLAC and WEBM. Assign every track to a category: the playlist continues only inside that category. Published tracks appear on Web and Android. Publish only audio you have rights to use.',
                          'Lade eine Audiodatei direkt hoch oder verwende eine HTTPS-URL. Unterstützt werden MP3, WAV, M4A/MP4, AAC, OGG/OPUS, FLAC und WEBM. Ordne jeden Titel einer Kategorie zu: Die Playlist läuft nur innerhalb dieser Kategorie weiter. Veröffentlichte Titel erscheinen im Web und auf Android. Veröffentliche nur Audio mit Nutzungsrechten.',
                          'فایل صوتی را مستقیم بارگذاری کنید یا از نشانی HTTPS استفاده کنید. فرمت‌های MP3، WAV، M4A/MP4، AAC، OGG/OPUS، FLAC و WEBM پشتیبانی می‌شوند. هر قطعه را به یک دسته اختصاص دهید؛ فهرست پخش فقط در همان دسته ادامه پیدا می‌کند. قطعات منتشرشده در وب و اندروید نمایش داده می‌شوند. فقط محتوایی را منتشر کنید که حق استفاده از آن را دارید.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed:
                          _saving || _tracks.isEmpty ? null : _manageJahan,
                      icon: const Icon(Icons.public_rounded),
                      label: const Text('Radio Jahan'),
                    ),
                    FilledButton.icon(
                      onPressed: _saving ? null : () => _edit(),
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(_radioText(
                          context, 'Aggiungi', 'Add', 'Hinzufügen', 'افزودن')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _radioText(
                            context,
                            'Catalogo amministrato',
                            'Managed catalog',
                            'Verwalteter Katalog',
                            'فهرست مدیریت‌شده'),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .refreshIndicatorSemanticLabel,
                      onPressed: _loading ? null : _load,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const Divider(),
                if (_loading && _tracks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(36),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null && _tracks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 40),
                        const SizedBox(height: 10),
                        Text(_error.toString(), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: Text(_radioText(context, 'Riprova', 'Retry',
                              'Erneut versuchen', 'تلاش دوباره')),
                        ),
                      ],
                    ),
                  )
                else if (_tracks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 34),
                    child: Text(
                      _radioText(
                        context,
                        'Nessuna stazione gestita. Aggiungi un audio o uno stream live HTTPS.',
                        'No managed stations yet. Add an audio item or HTTPS live stream.',
                        'Noch keine verwaltete Station. Audio oder HTTPS-Livestream hinzufügen.',
                        'هنوز ایستگاه مدیریت‌شده‌ای وجود ندارد. صدا یا پخش زنده HTTPS اضافه کنید.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  for (final category in AdminRadioMondoCategory.values)
                    if (_tracks.any((track) => track.category == category))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: colors.surfaceContainerLow,
                          clipBehavior: Clip.antiAlias,
                          child: ExpansionTile(
                            key: PageStorageKey<String>(
                              'radio-category-${category.name}',
                            ),
                            leading: CircleAvatar(
                              backgroundColor: colors.primaryContainer,
                              foregroundColor: colors.onPrimaryContainer,
                              child: Icon(_adminCategoryIcon(category)),
                            ),
                            title: Text(
                              _categoryTypeLabel(context, category),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              _radioText(
                                context,
                                '${_tracks.where((track) => track.category == category).length} elementi',
                                '${_tracks.where((track) => track.category == category).length} items',
                                '${_tracks.where((track) => track.category == category).length} Einträge',
                                '${_tracks.where((track) => track.category == category).length} مورد',
                              ),
                            ),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(10, 0, 10, 8),
                            children: [
                              for (final track in _tracks.where(
                                (track) => track.category == category,
                              ))
                                _RadioTrackTile(
                                  track: track,
                                  saving: _saving,
                                  onEdit: () => _edit(track),
                                  onPreview: () => _preview(track),
                                  onDelete: () => _delete(track),
                                  onEnabledChanged: (value) =>
                                      _setEnabled(track, value),
                                ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          color: colors.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _radioText(
                      context,
                      'Audio gestiti e stream HTTPS condividono un unico catalogo Radio Mondo. Puoi impostare una sola stazione predefinita; LIVE è solo un indicatore editoriale e non avvia mai l’audio automaticamente. World Brief Audio può essere collegato a un World Brief canonico.',
                      'Managed audio and HTTPS streams share one World Radio catalog. Mark one station as default; LIVE is an editorial indicator and never starts playback automatically. World Brief Audio can be linked to a canonical World Brief ID.',
                      'Verwaltete Audios und HTTPS-Streams teilen einen World-Radio-Katalog. Eine Station kann Standard sein; LIVE ist nur ein redaktioneller Hinweis und startet nie automatisch. World Brief Audio kann mit einer kanonischen World-Brief-ID verknüpft werden.',
                      'صداهای مدیریت‌شده و پخش‌های HTTPS در یک فهرست World Radio قرار می‌گیرند. فقط یک ایستگاه پیش‌فرض است؛ LIVE فقط نشانگر ویرایشی است و هرگز پخش خودکار ایجاد نمی‌کند. World Brief Audio می‌تواند به شناسه World Brief متصل شود.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RadioTrackTile extends StatelessWidget {
  final AdminRadioMondoTrack track;
  final bool saving;
  final VoidCallback onEdit;
  final VoidCallback onPreview;
  final VoidCallback onDelete;
  final ValueChanged<bool> onEnabledChanged;

  const _RadioTrackTile({
    required this.track,
    required this.saving,
    required this.onEdit,
    required this.onPreview,
    required this.onDelete,
    required this.onEnabledChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: track.isLive
            ? colors.errorContainer
            : track.isEnabled
                ? colors.primaryContainer
                : colors.surfaceContainerHighest,
        foregroundColor: track.isLive
            ? colors.onErrorContainer
            : track.isEnabled
                ? colors.onPrimaryContainer
                : colors.onSurfaceVariant,
        child: Icon(
          track.sourceType == AdminRadioMondoSourceType.stream
              ? Icons.cell_tower_rounded
              : Icons.library_music_outlined,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child:
                Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (track.isLive) ...[
            const SizedBox(width: 6),
            const Chip(
              visualDensity: VisualDensity.compact,
              label: Text('LIVE'),
            ),
          ],
          if (track.isDefault) ...[
            const SizedBox(width: 6),
            const Chip(
              visualDensity: VisualDensity.compact,
              label: Text('DEFAULT'),
            ),
          ],
          const SizedBox(width: 6),
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(
              _radioText(
                context,
                'Ordine ${track.sortOrder}',
                'Order ${track.sortOrder}',
                'Reihenfolge ${track.sortOrder}',
                'ترتیب ${track.sortOrder}',
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_channelTypeLabel(context, track.channelType)} · '
            '${track.sourceType == AdminRadioMondoSourceType.stream ? 'STREAM' : 'AUDIO'}'
            '${track.languageCode == null ? '' : ' · ${track.languageCode!.toUpperCase()}'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (track.attribution.trim().isNotEmpty)
            Text(
              track.attribution,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: _radioText(
                context, 'Anteprima', 'Preview', 'Vorschau', 'پیش‌نمایش'),
            onPressed: saving ? null : onPreview,
            icon: const Icon(Icons.play_circle_outline_rounded),
          ),
          IconButton(
            tooltip:
                _radioText(context, 'Modifica', 'Edit', 'Bearbeiten', 'ویرایش'),
            onPressed: saving ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: track.isDefault
                ? _radioText(
                    context,
                    'Imposta prima un’altra stazione come predefinita',
                    'Set another station as default first',
                    'Lege zuerst eine andere Station als Standard fest',
                    'ابتدا یک ایستگاه دیگر را به‌عنوان پیش‌فرض انتخاب کنید',
                  )
                : _radioText(
                    context,
                    'Elimina',
                    'Delete',
                    'Löschen',
                    'حذف',
                  ),
            onPressed: saving ? null : onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: track.isDefault ? colors.outline : colors.error,
            ),
          ),
          Switch(
            value: track.isEnabled,
            onChanged: saving ? null : onEnabledChanged,
          ),
        ],
      ),
    );
  }
}

class _RadioTrackDraft {
  final String title;
  final String audioUrl;
  final int sortOrder;
  final bool isEnabled;
  final String attribution;
  final String? licenseUrl;
  final AdminRadioMondoSourceType sourceType;
  final AdminRadioMondoChannelType channelType;
  final AdminRadioMondoCategory category;
  final String? languageCode;
  final String? worldBriefId;
  final bool isDefault;
  final bool isLive;
  final bool rightsConfirmed;
  final String reason;
  final RadioMondoPickedAudio? pickedAudio;

  const _RadioTrackDraft({
    required this.title,
    required this.audioUrl,
    required this.sortOrder,
    required this.isEnabled,
    required this.attribution,
    required this.licenseUrl,
    required this.sourceType,
    required this.channelType,
    required this.category,
    required this.languageCode,
    required this.worldBriefId,
    required this.isDefault,
    required this.isLive,
    required this.rightsConfirmed,
    required this.reason,
    required this.pickedAudio,
  });
}

class _RadioTrackDialog extends StatefulWidget {
  final AdminRadioMondoTrack? existing;
  final List<WorldBrief> worldBriefs;

  const _RadioTrackDialog({
    this.existing,
    required this.worldBriefs,
  });

  @override
  State<_RadioTrackDialog> createState() => _RadioTrackDialogState();
}

class _RadioTrackDialogState extends State<_RadioTrackDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _audioUrl;
  late final TextEditingController _sortOrder;
  late final TextEditingController _attribution;
  late final TextEditingController _licenseUrl;
  late String _worldBriefId;
  final _reason = TextEditingController();
  late bool _enabled;
  late bool _isDefault;
  late bool _isLive;
  late AdminRadioMondoSourceType _sourceType;
  late AdminRadioMondoChannelType _channelType;
  late AdminRadioMondoCategory _category;
  late String _languageCode;
  bool _rightsConfirmed = false;
  bool _pickingAudio = false;
  bool _previewing = false;
  RadioMondoPickedAudio? _pickedAudio;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _title = TextEditingController(text: existing?.title);
    _audioUrl = TextEditingController(text: existing?.audioUrl);
    _sortOrder = TextEditingController(
      text: (existing?.sortOrder ?? 100).toString(),
    );
    _attribution = TextEditingController(text: existing?.attribution);
    _licenseUrl = TextEditingController(text: existing?.licenseUrl);
    _worldBriefId = existing?.worldBriefId ?? '';
    _enabled = existing?.isEnabled ?? false;
    _isDefault = existing?.isDefault ?? false;
    _isLive = existing?.isLive ?? false;
    _sourceType = existing?.sourceType ?? AdminRadioMondoSourceType.audio;
    _channelType =
        existing?.channelType ?? AdminRadioMondoChannelType.worldLive;
    _category = existing?.category ?? AdminRadioMondoCategory.worldMusic;
    _languageCode = existing?.languageCode ?? '';
  }

  @override
  void dispose() {
    if (_previewing) {
      unawaited(RadioMondoService.instance.stop());
    }
    _title.dispose();
    _audioUrl.dispose();
    _sortOrder.dispose();
    _attribution.dispose();
    _licenseUrl.dispose();
    _reason.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? _radioText(context, 'Campo obbligatorio', 'Required field',
            'Pflichtfeld', 'اجباری')
        : null;
  }

  String? _https(String? value, {bool optional = false}) {
    final normalized = value?.trim() ?? '';
    if (optional && normalized.isEmpty) return null;
    if (!normalized.startsWith('https://')) {
      return _radioText(context, 'Serve un URL HTTPS', 'HTTPS URL required',
          'HTTPS-URL erforderlich', 'نشانی HTTPS لازم است');
    }
    return null;
  }

  Future<void> _pickAudio() async {
    if (_pickingAudio) return;
    setState(() => _pickingAudio = true);
    try {
      final picked = await RadioMondoAdminStorageService.instance.pickAudio();
      if (picked == null || !mounted) return;
      setState(() {
        _pickedAudio = picked;
        if (_title.text.trim().isEmpty) {
          _title.text = picked.suggestedTitle;
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_radioText(context, 'File audio non valido', 'Invalid audio file', 'Ungültige Audiodatei', 'فایل صوتی نامعتبر')}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _pickingAudio = false);
    }
  }

  String? get _previewUrl {
    if (_pickedAudio != null) {
      final saved = widget.existing?.audioUrl.trim() ?? '';
      return saved.startsWith('https://') ? saved : null;
    }

    final entered = _audioUrl.text.trim();
    return entered.startsWith('https://') ? entered : null;
  }

  Future<void> _stopPreview() async {
    final radio = RadioMondoService.instance;
    final previewId = 'admin-form-preview-${widget.existing?.id ?? 'draft'}';
    if (_previewing || radio.currentStation?.id == previewId) {
      await radio.stop();
    }
    if (mounted && _previewing) {
      setState(() => _previewing = false);
    } else {
      _previewing = false;
    }
  }

  Future<void> _togglePreview() async {
    final previewUrl = _previewUrl;
    if (previewUrl == null) return;

    final radio = RadioMondoService.instance;
    final previewId = 'admin-form-preview-${widget.existing?.id ?? 'draft'}';
    if (radio.currentStation?.id == previewId) {
      await _stopPreview();
      return;
    }

    final title = _title.text.trim();
    final station = RadioMondoStation(
      id: previewId,
      title: title.isEmpty
          ? _radioText(context, 'Anteprima Admin', 'Admin preview',
              'Admin-Vorschau', 'پیش‌نمایش مدیریت')
          : title,
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 100,
      audioUrl: previewUrl,
      attribution: _attribution.text.trim(),
      licenseUrl:
          _licenseUrl.text.trim().isEmpty ? null : _licenseUrl.text.trim(),
      sourceType: _sourceType == AdminRadioMondoSourceType.stream
          ? RadioMondoSourceType.stream
          : RadioMondoSourceType.audio,
      channelType: switch (_channelType) {
        AdminRadioMondoChannelType.worldLive => RadioMondoChannelType.worldLive,
        AdminRadioMondoChannelType.nature => RadioMondoChannelType.nature,
        AdminRadioMondoChannelType.worldBrief =>
          RadioMondoChannelType.worldBrief,
        AdminRadioMondoChannelType.liveEvent => RadioMondoChannelType.liveEvent,
        AdminRadioMondoChannelType.special => RadioMondoChannelType.special,
      },
      category: switch (_category) {
        AdminRadioMondoCategory.reggae => RadioMondoCategory.reggae,
        AdminRadioMondoCategory.classical => RadioMondoCategory.classical,
        AdminRadioMondoCategory.house => RadioMondoCategory.house,
        AdminRadioMondoCategory.jazzSoul => RadioMondoCategory.jazzSoul,
        AdminRadioMondoCategory.worldMusic => RadioMondoCategory.worldMusic,
        AdminRadioMondoCategory.soundsAtmospheres =>
          RadioMondoCategory.soundsAtmospheres,
      },
      languageCode: _languageCode.isEmpty ? null : _languageCode,
      worldBriefId: _worldBriefId.trim().isEmpty ? null : _worldBriefId.trim(),
      isDefault: _isDefault,
      isLive: _isLive,
    );

    final success = await radio.playPreviewStation(station);
    if (!mounted) return;
    setState(() => _previewing = success);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? _radioText(context, 'Anteprima avviata', 'Preview started',
                  'Vorschau gestartet', 'پیش‌نمایش شروع شد')
              : _radioText(
                  context,
                  'Anteprima non disponibile',
                  'Preview unavailable',
                  'Vorschau nicht verfügbar',
                  'پیش‌نمایش در دسترس نیست'),
        ),
      ),
    );
  }

  String _previewDescription(BuildContext context) {
    if (_pickedAudio != null) {
      if (widget.existing != null && _previewUrl != null) {
        return _radioText(
          context,
          'Riproduce l’audio attualmente salvato. Il nuovo file selezionato sarà disponibile dopo Salva.',
          'Plays the currently saved audio. The newly selected file will be available after Save.',
          'Spielt das aktuell gespeicherte Audio. Die neu ausgewählte Datei ist nach dem Speichern verfügbar.',
          'صدای ذخیره‌شده فعلی پخش می‌شود. فایل جدید پس از ذخیره قابل پخش خواهد بود.',
        );
      }
      return _radioText(
        context,
        'Il file selezionato verrà caricato con Salva. Dopo il salvataggio potrai ascoltarlo qui.',
        'The selected file will be uploaded with Save. After saving, you can preview it here.',
        'Die ausgewählte Datei wird mit Speichern hochgeladen. Danach kannst du sie hier anhören.',
        'فایل انتخاب‌شده با ذخیره بارگذاری می‌شود. پس از ذخیره می‌توانید آن را اینجا گوش کنید.',
      );
    }

    if (_previewUrl != null) {
      return _radioText(
        context,
        'Riproduce l’URL HTTPS indicato senza modificare il catalogo.',
        'Plays the configured HTTPS URL without changing the catalog.',
        'Spielt die angegebene HTTPS-URL ab, ohne den Katalog zu ändern.',
        'نشانی HTTPS واردشده را بدون تغییر فهرست پخش می‌کند.',
      );
    }

    return _radioText(
      context,
      'Inserisci un URL HTTPS valido oppure salva prima il file caricato.',
      'Enter a valid HTTPS URL or save the uploaded file first.',
      'Gib eine gültige HTTPS-URL ein oder speichere zuerst die hochgeladene Datei.',
      'یک نشانی HTTPS معتبر وارد کنید یا ابتدا فایل بارگذاری‌شده را ذخیره کنید.',
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String it,
    String en,
    String de,
    String fa,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          _radioText(context, it, en, de, fa),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _worldBriefItems(BuildContext context) {
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: '',
        child: Text(_radioText(
          context,
          'Nessun World Brief',
          'No World Brief',
          'Kein World Brief',
          'بدون World Brief',
        )),
      ),
      for (final brief in widget.worldBriefs)
        DropdownMenuItem<String>(
          value: brief.id,
          child: Text(
            '${brief.title} · ${brief.primaryLanguageCode.toUpperCase()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ];

    final current = _worldBriefId.trim();
    if (current.isNotEmpty &&
        !widget.worldBriefs.any((brief) => brief.id == current)) {
      items.add(
        DropdownMenuItem<String>(
          value: current,
          child: Text(
            _radioText(
              context,
              'Brief collegato non presente nell’elenco · $current',
              'Linked Brief not present in the list · $current',
              'Verknüpfter Brief nicht in der Liste · $current',
              'Brief مرتبط در فهرست نیست · $current',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    return items;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_rightsConfirmed) {
      setState(() {});
      return;
    }
    final order = int.tryParse(_sortOrder.text.trim());
    if (order == null || order < 0 || order > 1000) return;

    await _stopPreview();
    if (!mounted) return;

    Navigator.of(context).pop(
      _RadioTrackDraft(
        title: _title.text.trim(),
        audioUrl: _audioUrl.text.trim(),
        sortOrder: order,
        isEnabled: _enabled,
        attribution: _attribution.text.trim(),
        licenseUrl:
            _licenseUrl.text.trim().isEmpty ? null : _licenseUrl.text.trim(),
        sourceType: _sourceType,
        channelType: _channelType,
        category: _category,
        languageCode: _languageCode.isEmpty ? null : _languageCode,
        worldBriefId:
            _worldBriefId.trim().isEmpty ? null : _worldBriefId.trim(),
        isDefault: _isDefault,
        isLive: _isLive,
        rightsConfirmed: _rightsConfirmed,
        reason: _reason.text.trim(),
        pickedAudio: _pickedAudio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final advancedInitiallyOpen =
        _sourceType == AdminRadioMondoSourceType.stream ||
            _channelType != AdminRadioMondoChannelType.worldLive ||
            _languageCode.isNotEmpty ||
            _worldBriefId.trim().isNotEmpty ||
            _isDefault ||
            _isLive ||
            _licenseUrl.text.trim().isNotEmpty;

    final categoryField = DropdownButtonFormField<AdminRadioMondoCategory>(
      initialValue: _category,
      decoration: InputDecoration(
        labelText: _radioText(
          context,
          'Categoria musicale',
          'Music category',
          'Musikkategorie',
          'دسته موسیقی',
        ),
      ),
      items: AdminRadioMondoCategory.values
          .map(
            (value) => DropdownMenuItem<AdminRadioMondoCategory>(
              value: value,
              child: Text(_categoryTypeLabel(context, value)),
            ),
          )
          .toList(growable: false),
      onChanged: (value) => setState(() => _category = value ?? _category),
    );

    final orderField = TextFormField(
      controller: _sortOrder,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: _radioText(
          context,
          'Ordine categoria',
          'Category order',
          'Kategorie-Reihenfolge',
          'ترتیب دسته',
        ),
        helperText: _radioText(
          context,
          '10, 20, 30…',
          '10, 20, 30…',
          '10, 20, 30…',
          '۱۰، ۲۰، ۳۰…',
        ),
      ),
      validator: (value) {
        final parsed = int.tryParse(value?.trim() ?? '');
        return parsed == null || parsed < 0 || parsed > 1000
            ? _radioText(
                context,
                'Ordine non valido',
                'Invalid order',
                'Ungültige Reihenfolge',
                'ترتیب نامعتبر',
              )
            : null;
      },
    );

    final sourceField = DropdownButtonFormField<AdminRadioMondoSourceType>(
      initialValue: _sourceType,
      decoration: InputDecoration(
        labelText: _radioText(
          context,
          'Sorgente audio',
          'Audio source',
          'Audioquelle',
          'منبع صدا',
        ),
      ),
      items: AdminRadioMondoSourceType.values
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(
                value == AdminRadioMondoSourceType.stream
                    ? _radioText(
                        context,
                        'Stream live HTTPS',
                        'HTTPS live stream',
                        'HTTPS-Livestream',
                        'پخش زنده HTTPS',
                      )
                    : _radioText(
                        context,
                        'Audio / traccia',
                        'Audio / track',
                        'Audio / Titel',
                        'صدا / قطعه',
                      ),
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _sourceType = value;
          if (value == AdminRadioMondoSourceType.stream) {
            _pickedAudio = null;
          }
        });
      },
    );

    final channelField = DropdownButtonFormField<AdminRadioMondoChannelType>(
      initialValue: _channelType,
      decoration: InputDecoration(
        labelText: _radioText(
          context,
          'Tipo canale',
          'Channel type',
          'Kanaltyp',
          'نوع کانال',
        ),
        helperText: _radioText(
          context,
          'Separato dalla categoria musicale.',
          'Separate from the music category.',
          'Getrennt von der Musikkategorie.',
          'جدا از دسته موسیقی.',
        ),
      ),
      items: AdminRadioMondoChannelType.values
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(_channelTypeLabel(context, value)),
            ),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value != null) setState(() => _channelType = value);
      },
    );

    return AlertDialog(
      title: Text(
        editing
            ? _radioText(
                context,
                'Modifica traccia',
                'Edit track',
                'Titel bearbeiten',
                'ویرایش قطعه',
              )
            : _radioText(
                context,
                'Aggiungi traccia',
                'Add track',
                'Titel hinzufügen',
                'افزودن قطعه',
              ),
      ),
      content: SizedBox(
        width: 640,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.music_note_rounded, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _radioText(
                            context,
                            'Per una normale traccia musicale: titolo, categoria, audio, ordine, attribuzione e visibilità. Il resto è nelle Opzioni avanzate.',
                            'For a normal music track: title, category, audio, order, attribution and visibility. Everything else is under Advanced options.',
                            'Für einen normalen Musiktitel: Titel, Kategorie, Audio, Reihenfolge, Attribution und Sichtbarkeit. Alles Weitere steht unter Erweiterte Optionen.',
                            'برای یک قطعه موسیقی معمولی: عنوان، دسته، صدا، ترتیب، منبع و نمایش. بقیه در گزینه‌های پیشرفته است.',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                _sectionTitle(
                  context,
                  'Campi essenziali',
                  'Essential fields',
                  'Wesentliche Felder',
                  'فیلدهای اصلی',
                ),
                TextFormField(
                  controller: _title,
                  maxLength: 120,
                  decoration: InputDecoration(
                    labelText: _radioText(
                      context,
                      'Titolo pubblico',
                      'Public title',
                      'Öffentlicher Titel',
                      'عنوان عمومی',
                    ),
                  ),
                  validator: _required,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 520) {
                      return Column(
                        children: [
                          categoryField,
                          const SizedBox(height: 8),
                          orderField,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: categoryField),
                        const SizedBox(width: 12),
                        Expanded(child: orderField),
                      ],
                    );
                  },
                ),
                _sectionTitle(
                  context,
                  'Audio e anteprima',
                  'Audio and preview',
                  'Audio und Vorschau',
                  'صدا و پیش‌نمایش',
                ),
                if (_sourceType == AdminRadioMondoSourceType.audio)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: _pickingAudio ? null : _pickAudio,
                            icon: _pickingAudio
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file_rounded),
                            label: Text(
                              _radioText(
                                context,
                                'Carica / sostituisci file audio',
                                'Upload / replace audio file',
                                'Audiodatei hochladen / ersetzen',
                                'بارگذاری / جایگزینی فایل صوتی',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _radioText(
                              context,
                              'MP3, WAV, M4A/MP4, AAC, OGG/OPUS, FLAC, WEBM · massimo 200 MB',
                              'MP3, WAV, M4A/MP4, AAC, OGG/OPUS, FLAC, WEBM · maximum 200 MB',
                              'MP3, WAV, M4A/MP4, AAC, OGG/OPUS, FLAC, WEBM · maximal 200 MB',
                              'MP3، WAV، M4A/MP4، AAC، OGG/OPUS، FLAC، WEBM · حداکثر ۲۰۰ مگابایت',
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (_pickedAudio != null) ...[
                            const SizedBox(height: 10),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.audio_file_rounded),
                              title: Text(_pickedAudio!.originalName),
                              subtitle: Text(
                                '${(_pickedAudio!.sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB',
                              ),
                              trailing: IconButton(
                                tooltip: MaterialLocalizations.of(context)
                                    .deleteButtonTooltip,
                                onPressed: () =>
                                    setState(() => _pickedAudio = null),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                if (_sourceType == AdminRadioMondoSourceType.stream ||
                    _pickedAudio == null)
                  TextFormField(
                    controller: _audioUrl,
                    maxLength: 2048,
                    decoration: InputDecoration(
                      labelText: _sourceType == AdminRadioMondoSourceType.stream
                          ? _radioText(
                              context,
                              'URL HTTPS dello stream',
                              'HTTPS stream URL',
                              'HTTPS-Stream-URL',
                              'نشانی HTTPS پخش زنده',
                            )
                          : _radioText(
                              context,
                              'Oppure URL HTTPS audio',
                              'Or HTTPS audio URL',
                              'Oder HTTPS-Audio-URL',
                              'یا نشانی HTTPS صدا',
                            ),
                      helperText: _radioText(
                        context,
                        'Usalo solo se non carichi un file.',
                        'Use it only when no file is uploaded.',
                        'Nur verwenden, wenn keine Datei hochgeladen wird.',
                        'فقط وقتی فایل بارگذاری نمی‌کنید استفاده کنید.',
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) =>
                        _pickedAudio != null ? null : _https(value),
                  ),
                Card(
                  margin: const EdgeInsets.only(top: 4, bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.headphones_rounded),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _radioText(
                                  context,
                                  'Anteprima audio',
                                  'Audio preview',
                                  'Audio-Vorschau',
                                  'پیش‌نمایش صدا',
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _previewDescription(context),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        FilledButton.tonalIcon(
                          onPressed:
                              _previewUrl == null ? null : _togglePreview,
                          icon: Icon(
                            _previewing
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline_rounded,
                          ),
                          label: Text(
                            _previewing
                                ? _radioText(
                                    context,
                                    'Ferma anteprima',
                                    'Stop preview',
                                    'Vorschau stoppen',
                                    'توقف پیش‌نمایش',
                                  )
                                : _radioText(
                                    context,
                                    'Riproduci anteprima',
                                    'Play preview',
                                    'Vorschau abspielen',
                                    'پخش پیش‌نمایش',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _sectionTitle(
                  context,
                  'Pubblicazione',
                  'Publishing',
                  'Veröffentlichung',
                  'انتشار',
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                  title: Text(
                    _radioText(
                      context,
                      'Visibile / abilitata nella Radio Mondo',
                      'Visible / enabled in World Radio',
                      'Im Weltradio sichtbar / aktiviert',
                      'نمایش / فعال در رادیوی جهان',
                    ),
                  ),
                  subtitle: Text(
                    _radioText(
                      context,
                      'ON = appare nel catalogo pubblico.',
                      'ON = appears in the public catalog.',
                      'EIN = erscheint im öffentlichen Katalog.',
                      'روشن = در فهرست عمومی نمایش داده می‌شود.',
                    ),
                  ),
                ),
                TextFormField(
                  controller: _attribution,
                  maxLength: 300,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: _radioText(
                      context,
                      'Diritti / attribuzione',
                      'Rights / attribution',
                      'Rechte / Attribution',
                      'حقوق / منبع',
                    ),
                    helperText: _radioText(
                      context,
                      'Esempio: Made with ElevenMusic',
                      'Example: Made with ElevenMusic',
                      'Beispiel: Made with ElevenMusic',
                      'نمونه: Made with ElevenMusic',
                    ),
                  ),
                  validator: _required,
                ),
                TextFormField(
                  controller: _reason,
                  maxLength: 1000,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: _radioText(
                      context,
                      'Motivo amministrativo',
                      'Administrative reason',
                      'Administrativer Grund',
                      'دلیل مدیریتی',
                    ),
                  ),
                  validator: _required,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _rightsConfirmed,
                  onChanged: (value) =>
                      setState(() => _rightsConfirmed = value == true),
                  title: Text(
                    _radioText(
                      context,
                      'Confermo i diritti necessari alla pubblicazione.',
                      'I confirm the rights required for publication.',
                      'Ich bestätige die erforderlichen Veröffentlichungsrechte.',
                      'حقوق لازم برای انتشار را تأیید می‌کنم.',
                    ),
                  ),
                  subtitle: _rightsConfirmed
                      ? null
                      : Text(
                          _radioText(
                            context,
                            'Conferma obbligatoria',
                            'Confirmation required',
                            'Bestätigung erforderlich',
                            'تأیید اجباری',
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    initiallyExpanded: advancedInitiallyOpen,
                    leading: const Icon(Icons.tune_rounded),
                    title: Text(
                      _radioText(
                        context,
                        'Opzioni avanzate',
                        'Advanced options',
                        'Erweiterte Optionen',
                        'گزینه‌های پیشرفته',
                      ),
                    ),
                    subtitle: Text(
                      _radioText(
                        context,
                        'Stream, tipo canale, lingua, World Brief, licenza, default e LIVE.',
                        'Stream, channel type, language, World Brief, license, default and LIVE.',
                        'Stream, Kanaltyp, Sprache, World Brief, Lizenz, Standard und LIVE.',
                        'پخش زنده، نوع کانال، زبان، World Brief، مجوز، پیش‌فرض و LIVE.',
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 520) {
                            return Column(
                              children: [
                                sourceField,
                                const SizedBox(height: 8),
                                channelField,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: sourceField),
                              const SizedBox(width: 12),
                              Expanded(child: channelField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _languageCode,
                        decoration: InputDecoration(
                          labelText: _radioText(
                            context,
                            'Lingua (opzionale)',
                            'Language (optional)',
                            'Sprache (optional)',
                            'زبان (اختیاری)',
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('—')),
                          DropdownMenuItem(value: 'en', child: Text('EN')),
                          DropdownMenuItem(value: 'it', child: Text('IT')),
                          DropdownMenuItem(value: 'de', child: Text('DE')),
                          DropdownMenuItem(value: 'fa', child: Text('FA')),
                          DropdownMenuItem(value: 'es', child: Text('ES')),
                          DropdownMenuItem(value: 'pt', child: Text('PT')),
                          DropdownMenuItem(value: 'fr', child: Text('FR')),
                          DropdownMenuItem(value: 'ar', child: Text('AR')),
                          DropdownMenuItem(value: 'ro', child: Text('RO')),
                          DropdownMenuItem(value: 'ru', child: Text('RU')),
                          DropdownMenuItem(value: 'zh', child: Text('ZH')),
                        ],
                        onChanged: (value) =>
                            setState(() => _languageCode = value ?? ''),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _worldBriefId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _radioText(
                            context,
                            'World Brief collegato (opzionale)',
                            'Linked World Brief (optional)',
                            'Verknüpfter World Brief (optional)',
                            'World Brief مرتبط (اختیاری)',
                          ),
                          helperText: _radioText(
                            context,
                            'Scegli per titolo; nessun UUID da copiare.',
                            'Choose by title; no UUID copy is required.',
                            'Nach Titel wählen; keine UUID muss kopiert werden.',
                            'با عنوان انتخاب کنید؛ نیازی به کپی UUID نیست.',
                          ),
                        ),
                        items: _worldBriefItems(context),
                        onChanged: (value) =>
                            setState(() => _worldBriefId = value ?? ''),
                      ),
                      TextFormField(
                        controller: _licenseUrl,
                        maxLength: 2048,
                        decoration: InputDecoration(
                          labelText: _radioText(
                            context,
                            'URL licenza (opzionale)',
                            'License URL (optional)',
                            'Lizenz-URL (optional)',
                            'نشانی مجوز (اختیاری)',
                          ),
                        ),
                        validator: (value) => _https(value, optional: true),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _isDefault,
                        onChanged: (value) =>
                            setState(() => _isDefault = value),
                        title: Text(
                          _radioText(
                            context,
                            'Stazione predefinita World Live',
                            'Default World Live station',
                            'Standardstation World Live',
                            'ایستگاه پیش‌فرض World Live',
                          ),
                        ),
                        subtitle: Text(
                          _radioText(
                            context,
                            'Una sola stazione può essere predefinita.',
                            'Only one station can be the default.',
                            'Nur eine Station kann Standard sein.',
                            'فقط یک ایستگاه می‌تواند پیش‌فرض باشد.',
                          ),
                        ),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _isLive,
                        onChanged: (value) => setState(() => _isLive = value),
                        title: Text(
                          _radioText(
                            context,
                            'LIVE adesso',
                            'LIVE now',
                            'JETZT LIVE',
                            'اکنون زنده',
                          ),
                        ),
                        subtitle: Text(
                          _radioText(
                            context,
                            'Solo indicatore editoriale; non avvia automaticamente l’audio.',
                            'Editorial indicator only; audio never autoplays.',
                            'Nur redaktioneller Hinweis; Audio startet nie automatisch.',
                            'فقط نشانگر ویرایشی است؛ صدا خودکار پخش نمی‌شود.',
                          ),
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
      actions: [
        TextButton(
          onPressed: () async {
            await _stopPreview();
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(
            _radioText(
              context,
              'Salva e ricarica',
              'Save and reload',
              'Speichern und neu laden',
              'ذخیره و بارگذاری مجدد',
            ),
          ),
        ),
      ],
    );
  }
}

class _RadioJahanDraft {
  final List<AdminRadioJahanPlaylistItem> items;
  final String reason;

  const _RadioJahanDraft({
    required this.items,
    required this.reason,
  });
}

class _RadioJahanEditorItem {
  final AdminRadioMondoTrack track;
  bool included;

  _RadioJahanEditorItem({
    required this.track,
    required this.included,
  });
}

class _RadioJahanDialog extends StatefulWidget {
  final List<AdminRadioMondoTrack> tracks;

  const _RadioJahanDialog({required this.tracks});

  @override
  State<_RadioJahanDialog> createState() => _RadioJahanDialogState();
}

class _RadioJahanDialogState extends State<_RadioJahanDialog> {
  late final List<_RadioJahanEditorItem> _items;
  late final TextEditingController _reason;

  @override
  void initState() {
    super.initState();
    final eligible = widget.tracks
        .where(
          (track) =>
              track.sourceType == AdminRadioMondoSourceType.audio &&
              !track.isLive,
        )
        .toList(growable: false)
      ..sort((a, b) {
        final order = a.jahanOrder.compareTo(b.jahanOrder);
        if (order != 0) return order;
        final categoryOrder = a.category.index.compareTo(b.category.index);
        if (categoryOrder != 0) return categoryOrder;
        final trackOrder = a.sortOrder.compareTo(b.sortOrder);
        if (trackOrder != 0) return trackOrder;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

    _items = eligible
        .map(
          (track) => _RadioJahanEditorItem(
            track: track,
            included: track.jahanEnabled,
          ),
        )
        .toList(growable: true);

    _reason = TextEditingController(
      text: 'Aggiornamento playlist Radio Jahan',
    );
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  bool _categoryIncluded(AdminRadioMondoCategory category) {
    final matches = _items.where((item) => item.track.category == category);
    if (matches.isEmpty) return false;
    return matches.every((item) => item.included);
  }

  bool _categoryHasItems(AdminRadioMondoCategory category) =>
      _items.any((item) => item.track.category == category);

  void _setCategory(
    AdminRadioMondoCategory category,
    bool included,
  ) {
    setState(() {
      for (final item in _items) {
        if (item.track.category == category) {
          item.included = included;
        }
      }
    });
  }

  void _submit() {
    final reason = _reason.text.trim();
    if (reason.isEmpty) return;

    Navigator.pop(
      context,
      _RadioJahanDraft(
        items: <AdminRadioJahanPlaylistItem>[
          for (var i = 0; i < _items.length; i += 1)
            AdminRadioJahanPlaylistItem(
              trackId: _items[i].track.id,
              isEnabled: _items[i].included,
              sortOrder: (i + 1) * 10,
            ),
        ],
        reason: reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final viewport = MediaQuery.sizeOf(context);
    final width = (viewport.width - 48).clamp(320.0, 720.0).toDouble();
    final height = (viewport.height - 160).clamp(420.0, 650.0).toDouble();

    return AlertDialog(
      title: Row(
        children: [
          SizedBox.square(
            dimension: 24,
            child: CustomPaint(
              painter: _JahanInfinityGlyphPainter(color: colors.primary),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Text('Radio Jahan')),
        ],
      ),
      content: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.square(
                    dimension: 24,
                    child: CustomPaint(
                      painter: _JahanDragHandlePainter(color: colors.primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _radioText(
                        context,
                        'Attiva o disattiva i brani. Per cambiare ordine, trascina la maniglia a destra di ogni brano. Stream e contenuti LIVE restano esclusi.',
                        'Enable or disable tracks. To change the order, drag the handle on the right of each track. Streams and LIVE items stay excluded.',
                        'Aktiviere oder deaktiviere Titel. Zum Sortieren ziehe den Griff rechts am jeweiligen Titel. Streams und LIVE-Inhalte bleiben ausgeschlossen.',
                        'قطعه‌ها را فعال یا غیرفعال کنید. برای تغییر ترتیب، دستگیره سمت راست هر قطعه را بکشید. استریم‌ها و موارد LIVE خارج می‌مانند.',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in AdminRadioMondoCategory.values)
                  if (_categoryHasItems(category))
                    FilterChip(
                      selected: _categoryIncluded(category),
                      showCheckmark: true,
                      label: Text(_categoryTypeLabel(context, category)),
                      onSelected: (value) => _setCategory(category, value),
                    ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        _radioText(
                          context,
                          'Nessuna traccia audio disponibile.',
                          'No audio tracks available.',
                          'Keine Audiotitel verfügbar.',
                          'هیچ قطعه صوتی موجود نیست.',
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: _items.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          final item = _items.removeAt(oldIndex);
                          _items.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final track = item.track;
                        return Card(
                          key: ValueKey('jahan-${track.id}'),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: SizedBox(
                              width: 88,
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: colors.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Switch(
                                    value: item.included,
                                    onChanged: (value) {
                                      setState(() => item.included = value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${_categoryTypeLabel(context, track.category)} · '
                              '${track.isEnabled ? _radioText(context, 'Pubblicata', 'Published', 'Veröffentlicht', 'منتشرشده') : _radioText(context, 'Non pubblicata', 'Not published', 'Nicht veröffentlicht', 'منتشرنشده')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Tooltip(
                              message: _radioText(
                                context,
                                'Trascina per riordinare',
                                'Drag to reorder',
                                'Zum Sortieren ziehen',
                                'برای تغییر ترتیب بکشید',
                              ),
                              child: ReorderableDragStartListener(
                                index: index,
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SizedBox.square(
                                    dimension: 24,
                                    child: CustomPaint(
                                      painter: _JahanDragHandlePainter(
                                        color: colors.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reason,
              onChanged: (_) => setState(() {}),
              maxLength: 1000,
              decoration: InputDecoration(
                labelText: _radioText(
                  context,
                  'Motivo amministrativo',
                  'Administrative reason',
                  'Administrativer Grund',
                  'دلیل مدیریتی',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton.icon(
          onPressed:
              _items.isEmpty || _reason.text.trim().isEmpty ? null : _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(
            _radioText(
              context,
              'Salva Radio Jahan',
              'Save Radio Jahan',
              'Radio Jahan speichern',
              'ذخیره رادیو جهان',
            ),
          ),
        ),
      ],
    );
  }
}

class _RadioDeleteReasonDialog extends StatefulWidget {
  final AdminRadioMondoTrack track;

  const _RadioDeleteReasonDialog({required this.track});

  @override
  State<_RadioDeleteReasonDialog> createState() =>
      _RadioDeleteReasonDialogState();
}

class _JahanDragHandlePainter extends CustomPainter {
  final Color color;

  const _JahanDragHandlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.shortestSide * 0.11
      ..strokeCap = StrokeCap.round;

    final left = size.width * 0.20;
    final right = size.width * 0.80;

    for (final y in <double>[0.28, 0.50, 0.72]) {
      canvas.drawLine(
        Offset(left, size.height * y),
        Offset(right, size.height * y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _JahanDragHandlePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _JahanInfinityGlyphPainter extends CustomPainter {
  final Color color;

  const _JahanInfinityGlyphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.50)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.18,
        size.width * 0.40,
        size.height * 0.18,
        size.width * 0.50,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.60,
        size.height * 0.82,
        size.width * 0.75,
        size.height * 0.82,
        size.width * 0.88,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.18,
        size.width * 0.60,
        size.height * 0.18,
        size.width * 0.50,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.40,
        size.height * 0.82,
        size.width * 0.25,
        size.height * 0.82,
        size.width * 0.12,
        size.height * 0.50,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _JahanInfinityGlyphPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RadioDeleteReasonDialogState extends State<_RadioDeleteReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final valid = _reason.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(
        _radioText(
          context,
          'Elimina traccia',
          'Delete track',
          'Titel löschen',
          'حذف قطعه',
        ),
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.track.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              _radioText(
                context,
                'L’eliminazione è definitiva. Se l’audio è stato caricato in Radio Mondo, verrà rimosso anche dallo Storage. Gli URL esterni non vengono toccati.',
                'Deletion is permanent. If the audio was uploaded to World Radio, it will also be removed from Storage. External URLs are not touched.',
                'Das Löschen ist endgültig. Hochgeladene World-Radio-Audiodateien werden auch aus Storage entfernt. Externe URLs bleiben unverändert.',
                'حذف دائمی است. اگر فایل صوتی در World Radio بارگذاری شده باشد، از Storage نیز حذف می‌شود. نشانی‌های خارجی تغییر نمی‌کنند.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reason,
              maxLength: 1000,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: _radioText(
                  context,
                  'Motivo obbligatorio',
                  'Reason required',
                  'Grund erforderlich',
                  'دلیل اجباری',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          onPressed: valid
              ? () => Navigator.of(context).pop(_reason.text.trim())
              : null,
          icon: const Icon(Icons.delete_outline),
          label: Text(
            _radioText(context, 'Elimina', 'Delete', 'Löschen', 'حذف'),
          ),
        ),
      ],
    );
  }
}

class _RadioEnabledReasonDialog extends StatefulWidget {
  final AdminRadioMondoTrack track;
  final bool enabled;

  const _RadioEnabledReasonDialog({
    required this.track,
    required this.enabled,
  });

  @override
  State<_RadioEnabledReasonDialog> createState() =>
      _RadioEnabledReasonDialogState();
}

class _RadioEnabledReasonDialogState extends State<_RadioEnabledReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _reason.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(
        widget.enabled
            ? _radioText(context, 'Attiva traccia', 'Enable track',
                'Titel aktivieren', 'فعال‌سازی قطعه')
            : _radioText(context, 'Disattiva traccia', 'Disable track',
                'Titel deaktivieren', 'غیرفعال‌سازی قطعه'),
      ),
      content: SizedBox(
        width: 460,
        child: TextField(
          controller: _reason,
          maxLength: 1000,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: _radioText(context, 'Motivo obbligatorio',
                'Reason required', 'Grund erforderlich', 'دلیل اجباری'),
            helperText: widget.track.title,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: valid
              ? () => Navigator.of(context).pop(_reason.text.trim())
              : null,
          child: Text(_radioText(
              context, 'Conferma', 'Confirm', 'Bestätigen', 'تأیید')),
        ),
      ],
    );
  }
}

IconData _adminCategoryIcon(AdminRadioMondoCategory category) {
  return switch (category) {
    AdminRadioMondoCategory.reggae => Icons.waves_rounded,
    AdminRadioMondoCategory.classical => Icons.music_note_rounded,
    AdminRadioMondoCategory.house => Icons.graphic_eq_rounded,
    AdminRadioMondoCategory.jazzSoul => Icons.queue_music_rounded,
    AdminRadioMondoCategory.worldMusic => Icons.public_rounded,
    AdminRadioMondoCategory.soundsAtmospheres => Icons.spa_rounded,
  };
}

String _categoryTypeLabel(
  BuildContext context,
  AdminRadioMondoCategory category,
) {
  return switch (category) {
    AdminRadioMondoCategory.reggae => 'Reggae',
    AdminRadioMondoCategory.classical =>
      _radioText(context, 'Classica', 'Classical', 'Klassik', 'کلاسیک'),
    AdminRadioMondoCategory.house => 'House',
    AdminRadioMondoCategory.jazzSoul => 'Jazz & Soul',
    AdminRadioMondoCategory.worldMusic => _radioText(context,
        'Musiche del mondo', 'World music', 'Weltmusik', 'موسیقی جهان'),
    AdminRadioMondoCategory.soundsAtmospheres => _radioText(
        context,
        'Suoni & Atmosfere',
        'Sounds & Atmospheres',
        'Klänge & Atmosphären',
        'صداها و فضاها',
      ),
  };
}

String _channelTypeLabel(
  BuildContext context,
  AdminRadioMondoChannelType type,
) {
  return switch (type) {
    AdminRadioMondoChannelType.worldLive => 'World Live',
    AdminRadioMondoChannelType.nature => _radioText(
        context,
        'Natura / atmosfera',
        'Nature / atmosphere',
        'Natur / Atmosphäre',
        'طبیعت / فضا'),
    AdminRadioMondoChannelType.worldBrief => 'World Brief Audio',
    AdminRadioMondoChannelType.liveEvent => _radioText(
        context, 'Evento live', 'Live event', 'Live-Ereignis', 'رویداد زنده'),
    AdminRadioMondoChannelType.special =>
      _radioText(context, 'Speciale', 'Special', 'Spezial', 'ویژه'),
  };
}

String _radioText(
  BuildContext context,
  String it,
  String en,
  String de,
  String fa,
) {
  final language = Localizations.localeOf(context).languageCode.toLowerCase();
  if (language == 'it') return it;
  if (language == 'fa') return fa;
  return deOrEnglish(context, english: en, german: de);
}

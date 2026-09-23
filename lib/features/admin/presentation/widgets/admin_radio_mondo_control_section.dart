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
                          'Carica direttamente un file audio oppure usa un URL HTTPS. Formati supportati: MP3, WAV, M4A/MP4, AAC, OGG/OPUS, FLAC e WEBM. Le tracce pubblicate compaiono su Web e Android. Pubblica solo contenuti per cui possiedi i diritti.',
                          'Upload an audio file directly, or use an HTTPS URL. Supported formats: MP3, WAV, M4A/MP4, AAC, OGG/OPUS, FLAC and WEBM. Published tracks appear on Web and Android. Publish only audio you have rights to use.',
                          'Lade eine Audiodatei direkt hoch oder verwende eine HTTPS-URL. Unterstützt werden MP3, WAV, M4A/MP4, AAC, OGG/OPUS, FLAC und WEBM. Veröffentlichte Titel erscheinen im Web und auf Android. Veröffentliche nur Audio mit Nutzungsrechten.',
                          'فایل صوتی را مستقیم بارگذاری کنید یا از نشانی HTTPS استفاده کنید. فرمت‌های MP3، WAV، M4A/MP4، AAC، OGG/OPUS، FLAC و WEBM پشتیبانی می‌شوند. قطعات منتشرشده در وب و اندروید نمایش داده می‌شوند. فقط محتوایی را منتشر کنید که حق استفاده از آن را دارید.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
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
                  for (final track in _tracks) ...[
                    _RadioTrackTile(
                      track: track,
                      saving: _saving,
                      onEdit: () => _edit(track),
                      onDelete: () => _delete(track),
                      onEnabledChanged: (value) => _setEnabled(track, value),
                    ),
                    if (track != _tracks.last) const Divider(height: 1),
                  ],
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
  final VoidCallback onDelete;
  final ValueChanged<bool> onEnabledChanged;

  const _RadioTrackTile({
    required this.track,
    required this.saving,
    required this.onEdit,
    required this.onDelete,
    required this.onEnabledChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
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
            label: Text('#${track.sortOrder}'),
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
          Text(track.attribution, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (track.worldBriefId != null)
            Text(
              'World Brief: ${track.worldBriefId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          Text(
            track.audioUrl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
  late String _languageCode;
  bool _rightsConfirmed = false;
  bool _pickingAudio = false;
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
    _languageCode = existing?.languageCode ?? '';
  }

  @override
  void dispose() {
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

  void _submit() {
    if (!_formKey.currentState!.validate() || !_rightsConfirmed) {
      setState(() {});
      return;
    }
    final order = int.tryParse(_sortOrder.text.trim());
    if (order == null || order < 0 || order > 1000) return;

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
    return AlertDialog(
      title: Text(
        editing
            ? _radioText(context, 'Modifica traccia', 'Edit track',
                'Titel bearbeiten', 'ویرایش قطعه')
            : _radioText(context, 'Aggiungi traccia', 'Add track',
                'Titel hinzufügen', 'افزودن قطعه'),
      ),
      content: SizedBox(
        width: 580,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  maxLength: 120,
                  decoration: InputDecoration(
                      labelText: _radioText(context, 'Titolo pubblico',
                          'Public title', 'Öffentlicher Titel', 'عنوان عمومی')),
                  validator: _required,
                ),
                DropdownButtonFormField<AdminRadioMondoSourceType>(
                  initialValue: _sourceType,
                  decoration: InputDecoration(
                    labelText: _radioText(
                      context,
                      'Sorgente',
                      'Source',
                      'Quelle',
                      'منبع',
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
                                    'پخش زنده HTTPS')
                                : _radioText(
                                    context,
                                    'Audio / traccia',
                                    'Audio / track',
                                    'Audio / Titel',
                                    'صدا / قطعه'),
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
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AdminRadioMondoChannelType>(
                  initialValue: _channelType,
                  decoration: InputDecoration(
                    labelText: _radioText(
                      context,
                      'Tipo canale',
                      'Channel type',
                      'Kanaltyp',
                      'نوع کانال',
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
                      'Scegli il Brief per titolo: non serve più copiare UUID.',
                      'Choose the Brief by title; no UUID copy is required.',
                      'Wähle den Brief nach Titel; keine UUID muss kopiert werden.',
                      'Brief را با عنوان انتخاب کنید؛ نیازی به کپی UUID نیست.',
                    ),
                  ),
                  items: _worldBriefItems(context),
                  onChanged: (value) =>
                      setState(() => _worldBriefId = value ?? ''),
                ),
                if (_sourceType == AdminRadioMondoSourceType.audio)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
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
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.upload_file_rounded),
                            label: Text(
                              _radioText(
                                context,
                                'Carica file audio',
                                'Upload audio file',
                                'Audiodatei hochladen',
                                'بارگذاری فایل صوتی',
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
                TextFormField(
                  controller: _audioUrl,
                  maxLength: 2048,
                  decoration: InputDecoration(
                    labelText: _radioText(
                      context,
                      'URL HTTPS alternativo',
                      'Alternative HTTPS URL',
                      'Alternative HTTPS-URL',
                      'نشانی HTTPS جایگزین',
                    ),
                    helperText: _pickedAudio == null
                        ? _radioText(
                            context,
                            'Obbligatorio solo se non carichi un file',
                            'Required only when no file is uploaded',
                            'Nur erforderlich, wenn keine Datei hochgeladen wird',
                            'فقط وقتی فایل بارگذاری نمی‌شود اجباری است',
                          )
                        : _radioText(
                            context,
                            'Il file caricato verrà usato al salvataggio',
                            'The uploaded file will be used when saving',
                            'Die hochgeladene Datei wird beim Speichern verwendet',
                            'فایل بارگذاری‌شده هنگام ذخیره استفاده می‌شود',
                          ),
                  ),
                  validator: (value) =>
                      _pickedAudio != null ? null : _https(value),
                ),
                TextFormField(
                  controller: _sortOrder,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: _radioText(
                          context,
                          'Ordine 0–1000',
                          'Order 0–1000',
                          'Reihenfolge 0–1000',
                          'ترتیب ۰ تا ۱۰۰۰')),
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    return parsed == null || parsed < 0 || parsed > 1000
                        ? _radioText(
                            context,
                            'Ordine non valido',
                            'Invalid order',
                            'Ungültige Reihenfolge',
                            'ترتیب نامعتبر')
                        : null;
                  },
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
                          'حقوق / منبع')),
                  validator: _required,
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
                          'نشانی مجوز (اختیاری)')),
                  validator: (value) => _https(value, optional: true),
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
                          'دلیل مدیریتی')),
                  validator: _required,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                  title: Text(_radioText(
                      context,
                      'Visibile nella Radio Mondo',
                      'Visible in World Radio',
                      'Im Weltradio sichtbar',
                      'نمایش در رادیوی جهان')),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _isDefault,
                  onChanged: (value) => setState(() => _isDefault = value),
                  title: Text(_radioText(
                    context,
                    'Stazione predefinita World Live',
                    'Default World Live station',
                    'Standardstation World Live',
                    'ایستگاه پیش‌فرض World Live',
                  )),
                  subtitle: Text(_radioText(
                    context,
                    'Una sola stazione può essere predefinita.',
                    'Only one station can be the default.',
                    'Nur eine Station kann Standard sein.',
                    'فقط یک ایستگاه می‌تواند پیش‌فرض باشد.',
                  )),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _isLive,
                  onChanged: (value) => setState(() => _isLive = value),
                  title: Text(_radioText(
                    context,
                    'LIVE adesso',
                    'LIVE now',
                    'JETZT LIVE',
                    'اکنون زنده',
                  )),
                  subtitle: Text(_radioText(
                    context,
                    'Mostra un indicatore LIVE agli utenti; non avvia automaticamente l’audio.',
                    'Shows a LIVE indicator to users; audio never autoplays.',
                    'Zeigt LIVE an; Audio startet niemals automatisch.',
                    'نشان LIVE نمایش داده می‌شود؛ صدا هرگز خودکار پخش نمی‌شود.',
                  )),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _rightsConfirmed,
                  onChanged: (value) =>
                      setState(() => _rightsConfirmed = value == true),
                  title: Text(
                    _radioText(
                      context,
                      'Confermo che Social Vote possiede o ha ottenuto i diritti necessari per pubblicare questo audio.',
                      'I confirm that Social Vote owns or has obtained the rights required to publish this audio.',
                      'Ich bestätige, dass Social Vote die erforderlichen Rechte zur Veröffentlichung dieses Audios besitzt.',
                      'تأیید می‌کنم که Social Vote حق لازم برای انتشار این صدا را دارد.',
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
                              'تأیید اجباری'),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
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
        FilledButton(
          onPressed: _submit,
          child:
              Text(_radioText(context, 'Salva', 'Save', 'Speichern', 'ذخیره')),
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

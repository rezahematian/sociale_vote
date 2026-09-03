import 'package:flutter/material.dart';

import 'package:sociale_vote/app/localization/de_fallback.dart';

import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';
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
    final draft = await showDialog<_RadioTrackDraft>(
      context: context,
      builder: (_) => _RadioTrackDialog(existing: existing),
    );
    if (draft == null || _saving) return;

    setState(() => _saving = true);
    try {
      await widget.repository.upsertRadioMondoTrack(
        trackId: existing?.id,
        title: draft.title,
        audioUrl: draft.audioUrl,
        sortOrder: draft.sortOrder,
        isEnabled: draft.isEnabled,
        attribution: draft.attribution,
        licenseUrl: draft.licenseUrl,
        rightsConfirmed: draft.rightsConfirmed,
        reason: draft.reason,
      );
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
                          'Aggiungi audio remoto tramite URL HTTPS. Le tre tracce originali integrate restano sempre disponibili. Pubblica solo contenuti per cui possiedi i diritti.',
                          'Add remote audio through an HTTPS URL. The three original built-in tracks remain available. Publish only audio you have rights to use.',
                          'Füge Remote-Audio über eine HTTPS-URL hinzu. Die drei integrierten Originaltitel bleiben verfügbar. Veröffentliche nur Audio mit Nutzungsrechten.',
                          'صدا را با نشانی HTTPS اضافه کنید. سه قطعه اصلی همیشه باقی می‌مانند. فقط محتوایی را منتشر کنید که حق استفاده از آن را دارید.',
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
                        'Nessuna traccia remota. La Radio Mondo usa le tre tracce integrate.',
                        'No remote tracks. World Radio uses the three built-in tracks.',
                        'Keine Remote-Titel. Weltradio nutzt die drei integrierten Titel.',
                        'قطعه راه دوری ثبت نشده؛ رادیو از سه قطعه داخلی استفاده می‌کند.',
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
                      'V1 non carica file dal dispositivo: usa un URL HTTPS pubblico stabile, per esempio un oggetto audio pubblicato nello Storage. Disattivare una traccia la rimuove subito dal catalogo pubblico senza cancellare l’audit.',
                      'V1 does not upload files from the device: use a stable public HTTPS URL, such as an audio object published in Storage. Disabling a track removes it from the public catalog without deleting its audit trail.',
                      'V1 lädt keine Dateien vom Gerät hoch: Verwende eine stabile öffentliche HTTPS-URL, etwa ein Audioobjekt im Storage. Deaktivieren entfernt den Titel aus dem öffentlichen Katalog, ohne die Auditspur zu löschen.',
                      'نسخه اول فایل را از دستگاه بارگذاری نمی‌کند؛ از یک نشانی عمومی و پایدار HTTPS استفاده کنید. غیرفعال‌سازی قطعه را از فهرست عمومی حذف می‌کند، بدون حذف سابقه.',
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
  final ValueChanged<bool> onEnabledChanged;

  const _RadioTrackTile({
    required this.track,
    required this.saving,
    required this.onEdit,
    required this.onEnabledChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: track.isEnabled
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        foregroundColor: track.isEnabled
            ? colors.onPrimaryContainer
            : colors.onSurfaceVariant,
        child: const Icon(Icons.library_music_outlined),
      ),
      title: Row(
        children: [
          Expanded(
            child:
                Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text('#${track.sortOrder}'),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(track.attribution, maxLines: 1, overflow: TextOverflow.ellipsis),
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
  final bool rightsConfirmed;
  final String reason;

  const _RadioTrackDraft({
    required this.title,
    required this.audioUrl,
    required this.sortOrder,
    required this.isEnabled,
    required this.attribution,
    required this.licenseUrl,
    required this.rightsConfirmed,
    required this.reason,
  });
}

class _RadioTrackDialog extends StatefulWidget {
  final AdminRadioMondoTrack? existing;

  const _RadioTrackDialog({this.existing});

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
  final _reason = TextEditingController();
  late bool _enabled;
  bool _rightsConfirmed = false;

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
    _enabled = existing?.isEnabled ?? false;
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
        rightsConfirmed: _rightsConfirmed,
        reason: _reason.text.trim(),
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
                TextFormField(
                  controller: _audioUrl,
                  maxLength: 2048,
                  decoration:
                      const InputDecoration(labelText: 'Audio URL HTTPS'),
                  validator: _https,
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

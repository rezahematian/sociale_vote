import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class AdminFinanceControlSection extends StatefulWidget {
  final AdminRepository repository;
  final int refreshRevision;

  const AdminFinanceControlSection({
    super.key,
    required this.repository,
    required this.refreshRevision,
  });

  @override
  State<AdminFinanceControlSection> createState() =>
      _AdminFinanceControlSectionState();
}

class _AdminFinanceControlSectionState
    extends State<AdminFinanceControlSection> {
  AdminFinanceSnapshot? _snapshot;
  bool _loading = true;
  bool _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AdminFinanceControlSection oldWidget) {
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
      final snapshot = await widget.repository.getFinanceSnapshot();
      if (!mounted) return;
      setState(() => _snapshot = snapshot);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addEntry() async {
    final draft = await showDialog<_FinanceEntryDraft>(
      context: context,
      builder: (_) => const _FinanceEntryDialog(),
    );
    if (draft == null || _saving) return;

    setState(() => _saving = true);
    try {
      await widget.repository.addFinanceEntry(
        occurredOn: draft.occurredOn,
        direction: draft.direction,
        amountCents: draft.amountCents,
        category: draft.category,
        counterparty: draft.counterparty,
        note: draft.note,
        reason: draft.reason,
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_financeText(context, 'Movimento registrato',
                'Entry recorded', 'Eintrag erfasst', 'ثبت شد'))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${_financeText(context, 'Salvataggio non riuscito', 'Could not save', 'Speichern fehlgeschlagen', 'ذخیره نشد')}: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _voidEntry(AdminFinanceEntry entry) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _FinanceVoidDialog(entry: entry),
    );
    if (reason == null || _saving) return;

    setState(() => _saving = true);
    try {
      await widget.repository.voidFinanceEntry(
        entryId: entry.id,
        reason: reason,
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${_financeText(context, 'Annullamento non riuscito', 'Could not void entry', 'Stornierung fehlgeschlagen', 'لغو نشد')}: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final colors = Theme.of(context).colorScheme;

    return ListView(
      key: const ValueKey('admin-finance-control'),
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
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: const Icon(Icons.account_balance_wallet_outlined),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _financeText(
                            context, 'Finanze', 'Finance', 'Finanzen', 'مالی'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _financeText(
                          context,
                          'Situazione reale inserita manualmente. EUR V1, senza collegamento a conti bancari o billing.',
                          'Real manually entered position. EUR V1, without bank-account or billing integration.',
                          'Manuell erfasste Ist-Situation. EUR V1, ohne Bank- oder Billing-Anbindung.',
                          'وضعیت واقعی ثبت‌شده به‌صورت دستی؛ نسخه اول فقط یورو و بدون اتصال بانکی.',
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
                  onPressed: _saving ? null : _addEntry,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                      _financeText(context, 'Nuovo', 'New', 'Neu', 'جدید')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_loading && snapshot == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(36),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null && snapshot == null)
          _FinanceStateCard(
            title: _financeText(
                context,
                'Dati non disponibili',
                'Data unavailable',
                'Daten nicht verfügbar',
                'اطلاعات در دسترس نیست'),
            message: _error.toString(),
            onRetry: _load,
          )
        else if (snapshot != null) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cardWidth = width >= 1100
                  ? (width - 36) / 4
                  : width >= 620
                      ? (width - 12) / 2
                      : width;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FinanceMetricCard(
                    width: cardWidth,
                    icon: Icons.south_west_rounded,
                    color: Colors.green.shade700,
                    label: _financeText(context, 'Entrate mese', 'Month income',
                        'Einnahmen Monat', 'درآمد ماه'),
                    value: _money(context, snapshot.monthIncomeCents),
                  ),
                  _FinanceMetricCard(
                    width: cardWidth,
                    icon: Icons.north_east_rounded,
                    color: colors.error,
                    label: _financeText(context, 'Spese mese', 'Month expenses',
                        'Ausgaben Monat', 'هزینه ماه'),
                    value: _money(context, snapshot.monthExpenseCents),
                  ),
                  _FinanceMetricCard(
                    width: cardWidth,
                    icon: Icons.balance_rounded,
                    color: snapshot.monthBalanceCents >= 0
                        ? Colors.green.shade700
                        : colors.error,
                    label: _financeText(context, 'Saldo mese', 'Month balance',
                        'Monatssaldo', 'تراز ماه'),
                    value: _money(context, snapshot.monthBalanceCents),
                  ),
                  _FinanceMetricCard(
                    width: cardWidth,
                    icon: Icons.account_balance_outlined,
                    color: snapshot.totalBalanceCents >= 0
                        ? colors.primary
                        : colors.error,
                    label: _financeText(context, 'Saldo totale',
                        'Total balance', 'Gesamtsaldo', 'تراز کل'),
                    value: _money(context, snapshot.totalBalanceCents),
                  ),
                ],
              );
            },
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
                          _financeText(
                              context,
                              'Movimenti recenti',
                              'Recent entries',
                              'Letzte Einträge',
                              'ثبت‌های اخیر'),
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
                  if (snapshot.entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        _financeText(
                            context,
                            'Nessun movimento registrato.',
                            'No entries recorded.',
                            'Keine Einträge vorhanden.',
                            'هنوز موردی ثبت نشده است.'),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    for (final entry in snapshot.entries) ...[
                      _FinanceEntryTile(
                        entry: entry,
                        amount: _money(context, entry.amountCents),
                        onVoid: _saving ? null : () => _voidEntry(entry),
                      ),
                      if (entry != snapshot.entries.last)
                        const Divider(height: 1),
                    ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _money(BuildContext context, int cents) {
    return NumberFormat.currency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: '€',
      decimalDigits: 2,
    ).format(cents / 100);
  }
}

class _FinanceEntryTile extends StatelessWidget {
  final AdminFinanceEntry entry;
  final String amount;
  final VoidCallback? onVoid;

  const _FinanceEntryTile({
    required this.entry,
    required this.amount,
    required this.onVoid,
  });

  @override
  Widget build(BuildContext context) {
    final income = entry.direction == AdminFinanceDirection.income;
    final color =
        income ? Colors.green.shade700 : Theme.of(context).colorScheme.error;
    final date =
        DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
            .format(entry.occurredOn);
    final details = <String>[
      date,
      if (entry.counterparty != null) entry.counterparty!,
      if (entry.note != null) entry.note!,
    ].join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        child:
            Icon(income ? Icons.south_west_rounded : Icons.north_east_rounded),
      ),
      title: Text(entry.category, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(details, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${income ? '+' : '-'}$amount',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          IconButton(
            tooltip: _financeText(context, 'Annulla movimento', 'Void entry',
                'Eintrag stornieren', 'لغو ثبت'),
            onPressed: onVoid,
            icon: const Icon(Icons.block_outlined),
          ),
        ],
      ),
    );
  }
}

class _FinanceMetricCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _FinanceMetricCard({
    required this.width,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceStateCard extends StatelessWidget {
  final String title;
  final String message;
  final Future<void> Function() onRetry;

  const _FinanceStateCard({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(_financeText(context, 'Riprova', 'Retry',
                  'Erneut versuchen', 'تلاش دوباره')),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceEntryDraft {
  final DateTime occurredOn;
  final AdminFinanceDirection direction;
  final int amountCents;
  final String category;
  final String? counterparty;
  final String? note;
  final String reason;

  const _FinanceEntryDraft({
    required this.occurredOn,
    required this.direction,
    required this.amountCents,
    required this.category,
    required this.counterparty,
    required this.note,
    required this.reason,
  });
}

class _FinanceEntryDialog extends StatefulWidget {
  const _FinanceEntryDialog();

  @override
  State<_FinanceEntryDialog> createState() => _FinanceEntryDialogState();
}

class _FinanceEntryDialogState extends State<_FinanceEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _category = TextEditingController();
  final _counterparty = TextEditingController();
  final _note = TextEditingController();
  final _reason = TextEditingController();
  DateTime _date = DateTime.now();
  AdminFinanceDirection _direction = AdminFinanceDirection.expense;

  @override
  void dispose() {
    _amount.dispose();
    _category.dispose();
    _counterparty.dispose();
    _note.dispose();
    _reason.dispose();
    super.dispose();
  }

  int? _amountCents() {
    final normalized = _amount.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || !parsed.isFinite || parsed <= 0) return null;
    final cents = (parsed * 100).round();
    return cents > 0 ? cents : null;
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? _financeText(context, 'Campo obbligatorio', 'Required field',
            'Pflichtfeld', 'اجباری')
        : null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cents = _amountCents();
    if (cents == null) return;
    Navigator.of(context).pop(
      _FinanceEntryDraft(
        occurredOn: _date,
        direction: _direction,
        amountCents: cents,
        category: _category.text.trim(),
        counterparty: _counterparty.text.trim().isEmpty
            ? null
            : _counterparty.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        reason: _reason.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_financeText(context, 'Nuovo movimento', 'New entry',
          'Neuer Eintrag', 'ثبت جدید')),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AdminFinanceDirection>(
                  initialValue: _direction,
                  decoration: InputDecoration(
                      labelText:
                          _financeText(context, 'Tipo', 'Type', 'Typ', 'نوع')),
                  items: [
                    DropdownMenuItem(
                      value: AdminFinanceDirection.income,
                      child: Text(_financeText(
                          context, 'Entrata', 'Income', 'Einnahme', 'درآمد')),
                    ),
                    DropdownMenuItem(
                      value: AdminFinanceDirection.expense,
                      child: Text(_financeText(
                          context, 'Spesa', 'Expense', 'Ausgabe', 'هزینه')),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _direction = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Importo EUR', prefixText: '€ '),
                  validator: (_) => _amountCents() == null
                      ? _financeText(context, 'Importo non valido',
                          'Invalid amount', 'Ungültiger Betrag', 'مبلغ نامعتبر')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _category,
                  maxLength: 80,
                  decoration: InputDecoration(
                      labelText: _financeText(context, 'Categoria', 'Category',
                          'Kategorie', 'دسته')),
                  validator: _required,
                ),
                TextFormField(
                  controller: _counterparty,
                  maxLength: 160,
                  decoration: InputDecoration(
                      labelText: _financeText(
                          context,
                          'Cliente / fornitore (opzionale)',
                          'Customer / supplier (optional)',
                          'Kunde / Lieferant (optional)',
                          'مشتری / تأمین‌کننده (اختیاری)')),
                ),
                TextFormField(
                  controller: _note,
                  maxLength: 500,
                  maxLines: 2,
                  decoration: InputDecoration(
                      labelText: _financeText(
                          context,
                          'Nota (opzionale)',
                          'Note (optional)',
                          'Notiz (optional)',
                          'یادداشت (اختیاری)')),
                ),
                TextFormField(
                  controller: _reason,
                  maxLength: 1000,
                  maxLines: 2,
                  decoration: InputDecoration(
                      labelText: _financeText(
                          context,
                          'Motivo amministrativo',
                          'Administrative reason',
                          'Administrativer Grund',
                          'دلیل مدیریتی')),
                  validator: _required,
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(DateFormat.yMMMd(
                            Localizations.localeOf(context).toLanguageTag())
                        .format(_date)),
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
          child: Text(
              _financeText(context, 'Registra', 'Record', 'Erfassen', 'ثبت')),
        ),
      ],
    );
  }
}

class _FinanceVoidDialog extends StatefulWidget {
  final AdminFinanceEntry entry;

  const _FinanceVoidDialog({required this.entry});

  @override
  State<_FinanceVoidDialog> createState() => _FinanceVoidDialogState();
}

class _FinanceVoidDialogState extends State<_FinanceVoidDialog> {
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
      title: Text(_financeText(context, 'Annulla movimento', 'Void entry',
          'Eintrag stornieren', 'لغو ثبت')),
      content: SizedBox(
        width: 460,
        child: TextField(
          controller: _reason,
          maxLength: 1000,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: _financeText(context, 'Motivo obbligatorio',
                'Reason required', 'Grund erforderlich', 'دلیل اجباری'),
            helperText: widget.entry.category,
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
          child: Text(_financeText(
              context, 'Annulla movimento', 'Void entry', 'Stornieren', 'لغو')),
        ),
      ],
    );
  }
}

String _financeText(
  BuildContext context,
  String it,
  String en,
  String de,
  String fa,
) {
  return switch (Localizations.localeOf(context).languageCode.toLowerCase()) {
    'it' => it,
    'de' => de,
    'fa' => fa,
    _ => en,
  };
}

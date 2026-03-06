/// Opzione di voto di un poll.
///
/// Nel dominio teniamo le cose semplici:
/// - id (string)
/// - label (testo mostrato all'utente)
/// - descrizione opzionale.
class PollOption {
  final String id;
  final String label;
  final String? description;

  const PollOption({
    required this.id,
    required this.label,
    this.description,
  });

  PollOption copyWith({
    String? id,
    String? label,
    String? description,
  }) {
    return PollOption(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'PollOption(id: $id, label: $label)';
}
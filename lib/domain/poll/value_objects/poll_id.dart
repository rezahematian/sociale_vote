/// Value object per l'identificatore univoco di un poll.
///
/// Nel dominio usiamo PollId invece di una semplice String
/// per evitare confusione con altri tipi di ID.
class PollId {
  final String value;

  const PollId(this.value) : assert(value != '');

  factory PollId.fromString(String raw) {
    return PollId(raw);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollId && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
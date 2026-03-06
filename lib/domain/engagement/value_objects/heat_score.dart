/// Valore aggregato di “temperatura” di un contenuto.
///
/// v1: usiamo semplicemente (likeCount - dislikeCount).
/// In futuro potrai aggiungere:
/// - normalizzazione
/// - decay temporale
/// - pesi per tipo di utente
class HeatScore {
  final int value;

  const HeatScore(this.value);

  /// Heat calcolato a partire da conteggi grezzi.
  factory HeatScore.fromCounts({
    required int likeCount,
    required int dislikeCount,
  }) {
    return HeatScore(likeCount - dislikeCount);
  }

  /// True se il contenuto è percepito come “caldo”.
  bool get isHot => value > 0;

  /// True se il contenuto è percepito come “freddo”.
  bool get isCold => value < 0;

  /// True se il contenuto è neutro.
  bool get isNeutral => value == 0;

  @override
  String toString() => 'HeatScore($value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeatScore && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
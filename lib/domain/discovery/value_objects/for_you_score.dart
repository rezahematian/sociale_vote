import 'dart:math' as math;
import 'package:meta/meta.dart';

/// Value object che rappresenta lo "score For You"
/// di un contenuto (poll, news, post, ecc.).
///
/// Obiettivo:
/// - combinare "heat" (like - dislike) e "recency"
///   in un singolo punteggio per il feed personalizzato.
///
/// Definizione v1:
///   score = heat * 0.7 + recency * 0.3
///
/// dove:
/// - [heat] è un intero (può essere negativo)
/// - [recency] è un double normalizzato tra 0.0 e 1.0,
///   calcolato in base all'età del contenuto rispetto a "now".
@immutable
class ForYouScore {
  /// like - dislike (può essere negativo).
  final int heat;

  /// Valore normalizzato 0..1 che rappresenta quanto il
  /// contenuto è "recente":
  /// - 1.0 ≈ appena creato
  /// - 0.5 ≈ età pari a [halfLifeHours]
  /// - tende a 0 col passare del tempo
  final double recency;

  const ForYouScore({
    required this.heat,
    required this.recency,
  });

  /// Score aggregato v1:
  ///
  ///   value = heat * 0.7 + recency * 0.3
  ///
  /// Pesi facilmente aggiustabili in futuro.
  double get value {
    return heat * 0.7 + recency * 0.3;
  }

  /// Factory base: quando hai già calcolato [heat] e [recency].
  ///
  /// [recency] dovrebbe essere normalizzato tra 0.0 e 1.0,
  /// ma qui non imponiamo vincoli rigidi per lasciare libertà
  /// al chiamante (use case).
  factory ForYouScore.fromMetrics({
    required int heat,
    required double recency,
  }) {
    return ForYouScore(
      heat: heat,
      recency: recency,
    );
  }

  /// Factory v1 che calcola internamente [recency] come funzione
  /// di decadimento esponenziale rispetto al tempo.
  ///
  /// Parametri:
  /// - [heat]: like - dislike
  /// - [createdAt]: timestamp di creazione del contenuto
  /// - [now]: istante corrente (idealmente fornito da un Clock
  ///   nell'application layer)
  /// - [halfLifeHours]: dopo queste ore, il valore di recency
  ///   è circa 0.5
  ///
  /// Formula:
  ///   ageHours = ore trascorse da createdAt a now
  ///   recency = exp( - ln(2) * ageHours / halfLifeHours )
  ///
  /// Quindi:
  /// - appena creato → recency ≈ 1.0
  /// - dopo halfLifeHours → recency ≈ 0.5
  /// - col tempo → recency → 0.0
  factory ForYouScore.fromTimeBasedMetrics({
    required int heat,
    required DateTime createdAt,
    required DateTime now,
    double halfLifeHours = 24.0,
  }) {
    final recency = _computeRecency(
      createdAt: createdAt,
      now: now,
      halfLifeHours: halfLifeHours,
    );

    return ForYouScore(
      heat: heat,
      recency: recency,
    );
  }

  /// Confronto discendente per ordinare una lista di
  /// ForYouScore (più alto → prima posizione).
  static int compareDesc(ForYouScore a, ForYouScore b) {
    return b.value.compareTo(a.value);
  }

  @override
  String toString() {
    return 'ForYouScore(value: $value, heat: $heat, recency: $recency)';
  }
}

/// Calcola il valore di recency normalizzato 0..1
/// in base all'età del contenuto.
///
/// - [createdAt]: momento di creazione del contenuto.
/// - [now]: "adesso".
/// - [halfLifeHours]: dopo queste ore, la recency è ~0.5.
///
/// Restituisce:
/// - 1.0 per contenuti futuri o appena creati
/// - decrescente verso 0 al crescere di [ageHours]
double _computeRecency({
  required DateTime createdAt,
  required DateTime now,
  double halfLifeHours = 24.0,
}) {
  if (halfLifeHours <= 0) {
    return 1.0;
  }

  final effectiveNow = now.isBefore(createdAt) ? createdAt : now;
  final age = effectiveNow.difference(createdAt);
  final ageHours = age.inMinutes / 60.0;

  if (ageHours <= 0) {
    return 1.0;
  }

  const ln2 = 0.6931471805599453;
  final decay = -ln2 * (ageHours / halfLifeHours);

  final recency = math.exp(decay);

  // clamp difensivo 0..1 per sicurezza
  if (recency < 0.0) return 0.0;
  if (recency > 1.0) return 1.0;
  return recency;
}
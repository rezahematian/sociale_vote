import 'dart:math' as math;
import 'package:meta/meta.dart';

/// Value object che rappresenta lo "score di trending"
/// di un contenuto (poll, news, post, ecc.).
///
/// Componenti:
/// - [heat]: like - dislike (può essere negativo)
/// - [commentCount]: numero di commenti associati
/// - [recencyBoost]: fattore di boost legato alla freschezza
///   (0 = nessun boost, >0 = contenuto più recente/da spingere)
///
/// [value] è lo score aggregato finale usato per ordinare
/// i contenuti in "Trending".
///
/// Formula canonica v1.1 (deterministica):
///
///   baseScore = heat * 1.0 + commentCount * 0.5
///
///   recencyMultiplier = exp( - ln(2) * ageHours / halfLifeHours )
///   // con halfLifeHours ≈ 24.0 di default
///
///   recencyBoost = baseScore * (recencyMultiplier - 1.0)
///
///   value = baseScore + recencyBoost
///         = baseScore * recencyMultiplier
///
/// In questo modo:
/// - [heat] è il segnale principale
/// - [commentCount] ha un peso minore ma stabile (0.5 per commento)
/// - la recency agisce come moltiplicatore che decresce nel tempo
@immutable
class TrendingScore {
  /// like - dislike
  final int heat;

  /// Numero di commenti.
  final int commentCount;

  /// Boost di recency.
  ///
  /// Viene calcolato a partire da [createdAt] e dall'istante
  /// corrente (passato dal use case), usando una funzione di
  /// decadimento temporale.
  ///
  /// L'oggetto rimane comunque agnostico rispetto alla sorgente
  /// del "tempo" (Clock, DateTime.now, ecc.): qui riceviamo
  /// solo il risultato numerico.
  ///
  /// Esempi:
  /// - 0.0 → nessun boost rispetto al base score
  /// - >0 → contenuto spinto dalla recency
  final double recencyBoost;

  const TrendingScore({
    required this.heat,
    required this.commentCount,
    required this.recencyBoost,
  });

  /// Score aggregato usato per ordinare i contenuti.
  ///
  /// v1.1: usa la formula canonica:
  ///   value = baseScore + recencyBoost
  ///         = baseScore * recencyMultiplier
  /// dove:
  ///   baseScore = heat * 1.0 + commentCount * 0.5
  double get value {
    final baseScore = _computeBaseScore(
      heat: heat,
      commentCount: commentCount,
    );
    return baseScore + recencyBoost;
  }

  /// Factory di comodo per creare un [TrendingScore]
  /// quando hai già calcolato [heat] e [commentCount],
  /// e una [recencyBoost] normalizzata (0..1 o 0..N).
  ///
  /// Manteniamo questa factory per retro-compatibilità
  /// e per i casi in cui la recency venga gestita fuori
  /// da questo value object.
  factory TrendingScore.fromMetrics({
    required int heat,
    required int commentCount,
    required double recencyBoost,
  }) {
    return TrendingScore(
      heat: heat,
      commentCount: commentCount,
      recencyBoost: recencyBoost,
    );
  }

  /// Factory che calcola internamente un [TrendingScore] v1.1
  /// usando:
  /// - [heat] (like - dislike)
  /// - [commentCount]
  /// - [createdAt] (timestamp del contenuto)
  /// - [now] (istante corrente, idealmente da Clock)
  ///
  /// Strategia (formula canonica):
  /// - baseScore = heat * 1.0 + commentCount * 0.5
  /// - ageHours = ore trascorse da createdAt a now
  /// - recencyMultiplier = exp( - ln(2) * ageHours / halfLifeHours )
  ///   → a [halfLifeHours] l'effetto è dimezzato
  /// - recencyBoost = baseScore * (recencyMultiplier - 1)
  ///
  /// In questo modo:
  ///   value = baseScore + recencyBoost
  ///         = baseScore * recencyMultiplier
  ///
  /// NB:
  /// - [heatWeight] e [commentWeight] sono lasciati come parametri
  ///   opzionali per compatibilità, ma la formula canonica usa
  ///   i pesi interni (1.0 e 0.5) tramite [_computeBaseScore].
  factory TrendingScore.fromTimeBasedMetrics({
    required int heat,
    required int commentCount,
    required DateTime createdAt,
    required DateTime now,
    double heatWeight = _kHeatWeight,
    double commentWeight = _kCommentWeight,
    double halfLifeHours = _kDefaultHalfLifeHours,
  }) {
    // Usiamo sempre la formula canonica per il baseScore,
    // così [value] e [recencyBoost] restano coerenti.
    final baseScore = _computeBaseScore(
      heat: heat,
      commentCount: commentCount,
    );

    final recencyMultiplier = _computeRecencyMultiplier(
      createdAt: createdAt,
      now: now,
      halfLifeHours: halfLifeHours,
    );

    // Trasformiamo il moltiplicatore in un "boost" additivo
    // coerente con la formula di [value]:
    final recencyBoost = baseScore * (recencyMultiplier - 1.0);

    return TrendingScore(
      heat: heat,
      commentCount: commentCount,
      recencyBoost: recencyBoost,
    );
  }

  /// Confronto discendente per ordinare una lista di
  /// TrendingScore (più alto → prima posizione).
  static int compareDesc(TrendingScore a, TrendingScore b) {
    return b.value.compareTo(a.value);
  }

  @override
  String toString() {
    return 'TrendingScore(value: $value, heat: $heat, commentCount: $commentCount, recencyBoost: $recencyBoost)';
  }
}

/// Peso principale per il segnale di heat.
/// Modificare questo valore cambia la formula globale
/// in modo deterministico.
const double _kHeatWeight = 1.0;

/// Peso del contributo dei commenti.
/// Ogni commento vale [0.5] punti di baseScore.
const double _kCommentWeight = 0.5;

/// Half-life di default in ore per il decadimento di recency.
/// Dopo ~24h il contributo si dimezza.
const double _kDefaultHalfLifeHours = 24.0;

/// Calcola il punteggio di base a partire dai segnali
/// "statici" (heat + commentCount).
///
/// Formula canonica:
///   baseScore = heat * _kHeatWeight + commentCount * _kCommentWeight
double _computeBaseScore({
  required int heat,
  required int commentCount,
}) {
  return heat * _kHeatWeight + commentCount * _kCommentWeight;
}

/// Calcola il moltiplicatore di recency in base all'età del contenuto.
///
/// - [createdAt]: momento di creazione del contenuto.
/// - [now]: "adesso" (idealmente fornito da un Clock nell'application layer).
/// - [halfLifeHours]: dopo queste ore, il contributo del contenuto
///   è circa dimezzato.
///
/// Restituisce un valore >0:
/// - 1.0 per contenuti appena creati
/// - decrescente verso 0 al crescere di [ageHours]
double _computeRecencyMultiplier({
  required DateTime createdAt,
  required DateTime now,
  double halfLifeHours = _kDefaultHalfLifeHours,
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

  return math.exp(decay);
}
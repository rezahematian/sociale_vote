import 'anonymity_rules.dart';
import 'participation_rules.dart';
import 'visibility_rules.dart';
import 'quorum_rules.dart';

/// Configurazione di base di un poll.
///
/// Qui mettiamo le regole più dirette sul voto:
/// - minSelections
/// - maxSelections
/// - allowVoteChange
///
/// Estesa con:
/// - participationRules: chi può votare
/// - anonymityRules: anonimato dei voti
/// - visibilityRules: quando mostrare i risultati
/// - quorumRules: condizioni di validità
class PollConfiguration {
  /// Numero minimo di opzioni che l'utente deve selezionare.
  final int minSelections;

  /// Numero massimo di opzioni che l'utente può selezionare.
  final int maxSelections;

  /// Se il voto può essere modificato dopo l'invio.
  final bool allowVoteChange;

  /// Regole su chi può partecipare alla votazione.
  final ParticipationRules participationRules;

  /// Regole di anonimato del voto.
  final AnonymityRules anonymityRules;

  /// Regole di visibilità dei risultati.
  final VisibilityRules visibilityRules;

  /// Regole di quorum / validità.
  final QuorumRules quorumRules;

  const PollConfiguration({
    this.minSelections = 1,
    this.maxSelections = 1,
    this.allowVoteChange = false,
    this.participationRules = const ParticipationRules(),
    this.anonymityRules = const AnonymityRules(),
    this.visibilityRules = const VisibilityRules(),
    this.quorumRules = const QuorumRules(),
  })  : assert(minSelections >= 0),
        assert(maxSelections >= minSelections);

  PollConfiguration copyWith({
    int? minSelections,
    int? maxSelections,
    bool? allowVoteChange,
    ParticipationRules? participationRules,
    AnonymityRules? anonymityRules,
    VisibilityRules? visibilityRules,
    QuorumRules? quorumRules,
  }) {
    return PollConfiguration(
      minSelections: minSelections ?? this.minSelections,
      maxSelections: maxSelections ?? this.maxSelections,
      allowVoteChange: allowVoteChange ?? this.allowVoteChange,
      participationRules: participationRules ?? this.participationRules,
      anonymityRules: anonymityRules ?? this.anonymityRules,
      visibilityRules: visibilityRules ?? this.visibilityRules,
      quorumRules: quorumRules ?? this.quorumRules,
    );
  }
}
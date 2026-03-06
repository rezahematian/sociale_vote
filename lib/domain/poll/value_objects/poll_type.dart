/// Tipologia di poll / votazione.
///
/// Questo enum definisce il comportamento base del voto.
/// La logica specifica sarà gestita da VoteValidator / VoteAggregator.
enum PollType {
  /// Scelta singola: l'utente seleziona una sola opzione.
  singleChoice,

  /// Scelta multipla: l'utente può selezionare più opzioni.
  multipleChoice,

  /// Referendum semplice: Yes / No.
  yesNo,

  /// Approval voting: l'utente approva tutte le opzioni che ritiene valide.
  approval,

  /// Ordine di preferenza (ranking).
  ranked,

  /// Assegnazione di punteggi alle opzioni.
  score,
}
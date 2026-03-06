/// Stato di un poll nel suo ciclo di vita.
enum PollStatus {
  /// Bozza, non ancora visibile agli utenti.
  draft,

  /// Programmato per il futuro, non ancora votabile.
  scheduled,

  /// Aperto alle votazioni.
  open,

  /// Chiuso, non si può più votare.
  closed,
}
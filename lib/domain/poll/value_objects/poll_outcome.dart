/// Esito ufficiale di un poll.
///
/// - [approved]: una opzione ha ottenuto una maggioranza sufficiente.
/// - [rejected]: (in futuro) potenziale uso per logiche yes/no strette.
/// - [tie]: esiste un pareggio tra le opzioni migliori.
/// - [noMajority]: nessuna opzione ha raggiunto la soglia di maggioranza.
/// - [notApplicable]: outcome non calcolabile / non pertinente.
enum PollOutcome {
  approved,
  rejected,
  tie,
  noMajority,
  notApplicable,
}
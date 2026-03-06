/// Stato del quorum per un poll.
///
/// - [notApplicable]: nessuna regola di quorum configurata
/// - [notReached]: regole presenti ma non soddisfatte
/// - [reached]: quorum soddisfatto
enum QuorumStatus {
  notApplicable,
  notReached,
  reached,
}
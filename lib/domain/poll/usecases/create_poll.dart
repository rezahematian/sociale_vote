import '../entities/poll.dart';
import '../repositories/poll_repository.dart';

/// Use case applicativo per creare una nuova votazione.
///
/// In questa versione il dominio si aspetta già un [Poll] costruito,
/// e delega al [PollRepository] la persistenza.
/// La logica di validazione / costruzione dell'oggetto viene gestita
/// a livello di controller / UI finché non allineiamo tutto il dominio.
class CreatePoll {
  final PollRepository repository;

  CreatePoll(this.repository);

  /// Crea una nuova votazione.
  ///
  /// Restituisce il poll effettivamente creato/persistito.
  Future<Poll> call(Poll poll) {
    return repository.createPoll(poll);
  }
}
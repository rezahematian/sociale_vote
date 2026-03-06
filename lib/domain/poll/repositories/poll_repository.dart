import '../entities/poll.dart';
import '../value_objects/poll_id.dart';

abstract class PollRepository {
  Future<List<Poll>> getPolls({
    String? countryCode,
    String? cityId,
  });

  Future<Poll?> getPollDetail(PollId pollId);

  /// Crea una nuova votazione.
  ///
  /// In questa versione mock:
  /// - il repository può sostituire l'eventuale `PollId` passato
  ///   con uno generato internamente;
  /// - restituisce il `Poll` effettivamente creato/persistito.
  Future<Poll> createPoll(Poll poll);
}
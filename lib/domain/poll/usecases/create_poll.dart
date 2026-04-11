import '../entities/poll.dart';
import '../repositories/poll_repository.dart';

/// Use case applicativo per creare una nuova votazione.
///
/// Qui teniamo le regole business minime di creazione che non devono
/// restare solo nella UI/controller.
class CreatePoll {
  final PollRepository repository;

  CreatePoll(this.repository);

  /// Crea una nuova votazione.
  ///
  /// Regole applicate qui:
  /// - utente creatore obbligatorio
  /// - massimo 1 poll creato al giorno per utente
  ///
  /// Restituisce il poll effettivamente creato/persistito.
  Future<Poll> call(Poll poll) async {
    final createdByUserId = poll.createdByUserId?.trim();
    if (createdByUserId == null || createdByUserId.isEmpty) {
      throw Exception('User is required to create a poll.');
    }

    final now = DateTime.now();
    final startOfLocalDay = DateTime(now.year, now.month, now.day);

    final hasCreatedToday = await repository.hasUserCreatedPollSince(
      userId: createdByUserId,
      since: startOfLocalDay.toUtc(),
    );

    if (hasCreatedToday) {
      throw Exception('daily poll limit reached');
    }

    return repository.createPoll(poll);
  }
}
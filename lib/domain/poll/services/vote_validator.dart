import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/errors/poll_closed_exception.dart';
import 'package:sociale_vote/domain/poll/errors/unauthorized_vote_exception.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';

class VoteValidator {
  final ParticipationPolicy _participationPolicy;

  const VoteValidator({
    required ParticipationPolicy participationPolicy,
  }) : _participationPolicy = participationPolicy;

  /// Validazione canonica usata dai usecase di dominio.
  ///
  /// Copre:
  /// - poll aperto
  /// - regole di partecipazione (ParticipationPolicy)
  /// - regole min/max selezioni
  /// - opzioni selezionate esistenti nel poll
  void validate({
    required Poll poll,
    required String? userId,
    required String? userCountryCode,
    required List<String> optionIds,
  }) {
    _validatePollOpen(poll);
    _validateParticipation(
      poll: poll,
      userId: userId,
      userCountryCode: userCountryCode,
    );
    _validateSelections(
      poll: poll,
      optionIds: optionIds,
    );
  }

  /// Manteniamo il metodo esistente per compatibilità interna
  /// (se già usato da altre parti del codice).
  void validateVote({
    required Poll poll,
    required String? userId,
    required String? userCountryCode,
  }) {
    _validatePollOpen(poll);
    _validateParticipation(
      poll: poll,
      userId: userId,
      userCountryCode: userCountryCode,
    );
  }

  void _validatePollOpen(Poll poll) {
    if (poll.status != PollStatus.open) {
      throw PollClosedException();
    }
  }

  void _validateParticipation({
    required Poll poll,
    required String? userId,
    required String? userCountryCode,
  }) {
    final canVote = _participationPolicy.canVoteOnPoll(
      userId: userId,
      rules: poll.configuration.participationRules,
      userCountryCode: userCountryCode,
    );

    if (!canVote) {
      throw UnauthorizedVoteException();
    }
  }

  void _validateSelections({
    required Poll poll,
    required List<String> optionIds,
  }) {
    if (optionIds.isEmpty) {
      throw UnauthorizedVoteException();
    }

    final min = poll.configuration.minSelections;
    final max = poll.configuration.maxSelections;

    if (optionIds.length < min) {
      throw UnauthorizedVoteException();
    }
    if (optionIds.length > max) {
      throw UnauthorizedVoteException();
    }

    final validOptionIds = poll.options.map((o) => o.id).toSet();
    for (final id in optionIds) {
      if (!validOptionIds.contains(id)) {
        throw UnauthorizedVoteException();
      }
    }
  }
}
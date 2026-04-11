import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/services/vote_validator.dart';

import '../entities/vote.dart';
import '../repositories/vote_repository.dart';

/// Use case applicativo per la sottomissione di un voto.
///
/// Governance completa:
/// - validazione stato poll
/// - enforcement ParticipationRules
/// - enforcement min/max selezioni + opzioni valide
/// - blocco dominio (non solo UI)
class SubmitVote {
  final VoteRepository voteRepository;
  final VoteValidator _voteValidator;

  SubmitVote(
    this.voteRepository, {
    ParticipationPolicy? participationPolicy,
  }) : _voteValidator = VoteValidator(
          participationPolicy:
              participationPolicy ?? const ParticipationPolicy(),
        );

  /// Esegue la sottomissione del voto.
  ///
  /// Richiede il [Poll] completo per poter:
  /// - validare stato (open)
  /// - validare regole di partecipazione
  /// - validare selezioni (min/max + opzioni esistenti)
  Future<void> call(
    Vote vote, {
    required Poll poll,
    required String? userId,
    required String? userCountryCode,
  }) async {
    _voteValidator.validate(
      poll: poll,
      userId: userId,
      userCountryCode: userCountryCode,
      optionIds: vote.optionIds,
    );

    final hasAlreadyVoted = await voteRepository.hasCurrentUserVoted(poll.id);

    if (!hasAlreadyVoted) {
      await voteRepository.submitVote(vote);
      return;
    }

    if (poll.configuration.allowVoteChange) {
      await voteRepository.updateVote(vote);
      return;
    }

    throw Exception('already voted');
  }
}
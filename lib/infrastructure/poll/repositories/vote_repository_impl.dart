import 'dart:async';

import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

/// Implementazione mock del [VoteRepository].
///
/// I voti vengono mantenuti in memoria in una mappa statica, indicizzata
/// per id del poll. Questo è sufficiente per scenari di demo / sviluppo
/// locale senza backend.
class VoteRepositoryImpl implements VoteRepository {
  /// Mappa mock: pollId (string) -> lista di voti.
  static final Map<String, List<Vote>> _votesByPollId = {};

  @override
  Future<void> submitVote(Vote vote) async {
    // Simuliamo una piccola latenza di rete.
    await Future.delayed(const Duration(milliseconds: 300));

    final key = vote.pollId.value;
    final existing = _votesByPollId[key] ?? <Vote>[];
    _votesByPollId[key] = [...existing, vote];
  }

  @override
  Future<List<Vote>> getVotesForPoll(PollId pollId) async {
    // Simuliamo latenza come se fosse una chiamata remota.
    await Future.delayed(const Duration(milliseconds: 200));

    return List.unmodifiable(
      _votesByPollId[pollId.value] ?? const [],
    );
  }
}
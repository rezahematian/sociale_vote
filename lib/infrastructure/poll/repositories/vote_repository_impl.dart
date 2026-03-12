import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

/// Repository reale dei voti su Supabase.
///
/// Tabella attesa: public.votes
/// Colonne attese:
/// - id
/// - poll_id
/// - user_id
/// - selected_options (jsonb)
/// - created_at
class VoteRepositoryImpl implements VoteRepository {
  final SupabaseClient _supabase;

  VoteRepositoryImpl(this._supabase);

  @override
  Future<void> submitVote(Vote vote) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Utente non autenticato');
    }

    await _supabase.from('votes').insert({
      'poll_id': vote.pollId.value,
      'user_id': user.id,
      'selected_options': vote.optionIds,
      'created_at': vote.createdAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<Vote>> getVotesForPoll(PollId pollId) async {
    final response =
        await _supabase.from('votes').select().eq('poll_id', pollId.value);

    final rows = List<Map<String, dynamic>>.from(response);

    return rows.map((row) {
      final rawOptions = row['selected_options'] as List? ?? const [];

      return Vote(
        pollId: PollId(row['poll_id'] as String),
        optionIds: List<String>.from(rawOptions.map((e) => e.toString())),
        createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
      );
    }).toList();
  }
}
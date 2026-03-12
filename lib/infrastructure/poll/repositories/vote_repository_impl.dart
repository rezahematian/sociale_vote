import 'dart:async';

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

  final Map<String, StreamController<void>> _voteWatchControllers = {};
  final Map<String, RealtimeChannel> _voteChannels = {};

  VoteRepositoryImpl(this._supabase);

  @override
  Future<void> submitVote(Vote vote) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Utente non autenticato');
    }

    try {
      await _supabase.from('votes').insert({
        'poll_id': vote.pollId.value,
        'user_id': user.id,
        'selected_options': vote.optionIds,
        'created_at': vote.createdAt.toUtc().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<List<Vote>> getVotesForPoll(PollId pollId) async {
    final response = await _supabase
        .from('votes')
        .select('poll_id, selected_options, created_at')
        .eq('poll_id', pollId.value)
        .order('created_at', ascending: true);

    final rows = List<Map<String, dynamic>>.from(response);

    return rows.map((row) {
      final rawOptions = row['selected_options'];
      final optionIds = rawOptions is List
          ? List<String>.from(rawOptions.map((e) => e.toString()))
          : const <String>[];

      final createdAtRaw = row['created_at'] as String?;

      return Vote(
        pollId: PollId((row['poll_id'] as String?) ?? pollId.value),
        optionIds: optionIds,
        createdAt: createdAtRaw != null
            ? DateTime.parse(createdAtRaw).toUtc()
            : DateTime.now().toUtc(),
      );
    }).toList(growable: false);
  }

  @override
  Stream<void> watchVotesForPoll(PollId pollId) {
    final key = pollId.value;

    final existingController = _voteWatchControllers[key];
    if (existingController != null) {
      return existingController.stream;
    }

    late final StreamController<void> controller;

    controller = StreamController<void>.broadcast(
      onCancel: () async {
        if (controller.hasListener) return;

        final channel = _voteChannels.remove(key);
        if (channel != null) {
          await _supabase.removeChannel(channel);
        }

        _voteWatchControllers.remove(key);
      },
    );

    final channel = _supabase.channel('votes_poll_$key');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'votes',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'poll_id',
        value: key,
      ),
      callback: (_) {
        if (!controller.isClosed) {
          controller.add(null);
        }
      },
    );

    channel.subscribe();

    _voteChannels[key] = channel;
    _voteWatchControllers[key] = controller;

    return controller.stream;
  }
}
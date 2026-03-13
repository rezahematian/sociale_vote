import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';

/// Repository reale Supabase per i poll.
///
/// Nota:
/// questo file mantiene temporaneamente il vecchio path
/// `poll_repository_supabase.dart` per compatibilità,
/// ma l'implementazione è ormai backend reale.
class PollRepositorySupabase implements PollRepository {
  static const String _pollsTable = 'polls_with_vote_count';
  static const String _pollsInsertTable = 'polls';

  @override
  Future<List<Poll>> getPolls({
    String? countryCode,
    String? cityId,
    int? limit,
    int? offset,
  }) async {
    dynamic query = AppSupabase.client.from(_pollsTable).select();

    if (countryCode != null && countryCode.trim().isNotEmpty) {
      query = query.eq('country_code', countryCode);
    }

    if (cityId != null && cityId.trim().isNotEmpty) {
      query = query.eq('city_id', cityId);
    }

    query = query.order('vote_count', ascending: false);
    query = query.order('created_at', ascending: false);

    if (offset != null && limit != null) {
      query = query.range(offset, offset + limit - 1);
    } else if (limit != null) {
      query = query.limit(limit);
    }

    final rawRows = await query as List<dynamic>;

    return rawRows
        .whereType<Map<String, dynamic>>()
        .map(_mapPoll)
        .toList(growable: false);
  }

  @override
  Future<Poll?> getPollDetail(PollId pollId) async {
    final rawRows = await AppSupabase.client
        .from(_pollsTable)
        .select()
        .eq('id', pollId.value)
        .limit(1) as List<dynamic>;

    if (rawRows.isEmpty) {
      return null;
    }

    final row = rawRows.first;
    if (row is! Map<String, dynamic>) {
      return null;
    }

    return _mapPoll(row);
  }

  @override
  Future<Poll> createPoll(Poll poll) async {
    final currentUser = AppSupabase.currentUser;
    if (currentUser == null) {
      throw Exception('Utente non autenticato.');
    }

    final rawRows = await AppSupabase.client
        .from(_pollsInsertTable)
        .insert({
          'author_id': currentUser.id,
          'title': poll.title,
          'description': poll.description,
          'type': _pollTypeValue(poll.type),
          'status': _pollStatusValue(poll.status),
          'options': poll.options
              .map(
                (option) => {
                  'id': option.id,
                  'label': option.label,
                },
              )
              .toList(growable: false),
          'min_selections': poll.configuration.minSelections,
          'max_selections': poll.configuration.maxSelections,
          'participation_scope': _participationScopeValue(
            poll.configuration.participationRules.scope,
          ),
          'country_code': poll.countryCode,
          'city_id': poll.cityId,
        })
        .select()
        .limit(1) as List<dynamic>;

    if (rawRows.isEmpty) {
      throw Exception('Creazione poll fallita.');
    }

    final row = rawRows.first;
    if (row is! Map<String, dynamic>) {
      throw Exception('Creazione poll fallita.');
    }

    return _mapPoll(row);
  }

  Poll _mapPoll(Map<String, dynamic> row) {
    final optionsRaw = row['options'];
    final optionsList = optionsRaw is List ? optionsRaw : const [];

    final options = optionsList
        .whereType<Map>()
        .map(
          (option) => PollOption(
            id: (option['id'] as String?) ?? '',
            label: (option['label'] as String?) ?? '',
          ),
        )
        .toList(growable: false);

    final countryCode = row['country_code'] as String?;
    final cityId = row['city_id'] as String?;

    return Poll(
      id: PollId((row['id'] as String?) ?? ''),
      title: (row['title'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      type: _pollTypeFromValue(row['type'] as String?),
      status: _pollStatusFromValue(row['status'] as String?),
      options: options,
      configuration: PollConfiguration(
        minSelections: (row['min_selections'] as int?) ?? 1,
        maxSelections: (row['max_selections'] as int?) ?? 1,
        participationRules: ParticipationRules(
          scope: _participationScopeFromValue(
            row['participation_scope'] as String?,
          ),
          countryCode: countryCode,
        ),
      ),
      countryCode: countryCode,
      cityId: cityId,
      voteCount: (row['vote_count'] as int?) ?? 0,
    );
  }

  String _pollTypeValue(PollType type) {
    return type.toString().split('.').last;
  }

  String _pollStatusValue(PollStatus status) {
    return status.toString().split('.').last;
  }

  String _participationScopeValue(ParticipationScope scope) {
    return scope.toString().split('.').last;
  }

  PollType _pollTypeFromValue(String? value) {
    switch (value) {
      case 'singleChoice':
        return PollType.singleChoice;
      case 'multipleChoice':
        return PollType.multipleChoice;
      case 'yesNo':
      default:
        return PollType.yesNo;
    }
  }

  PollStatus _pollStatusFromValue(String? value) {
    switch (value) {
      case 'closed':
        return PollStatus.closed;
      case 'draft':
        return PollStatus.draft;
      case 'open':
      default:
        return PollStatus.open;
    }
  }

  ParticipationScope _participationScopeFromValue(String? value) {
    switch (value) {
      case 'geoScopeOnly':
        return ParticipationScope.geoScopeOnly;
      case 'everyone':
      default:
        return ParticipationScope.everyone;
    }
  }
}

/// Alias temporaneo per compatibilità con il vecchio nome.
/// Da rimuovere quando tutto il progetto userà PollRepositorySupabase.
typedef PollRepositoryInMemory = PollRepositorySupabase;
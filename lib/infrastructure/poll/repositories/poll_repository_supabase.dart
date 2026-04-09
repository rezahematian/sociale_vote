import 'package:flutter/foundation.dart';
import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/quorum_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';

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
    final requestedCountryCode = _prepareDbFilterValue(countryCode);
    final requestedCityId = _prepareDbFilterValue(cityId);

    dynamic query = AppSupabase.client.from(_pollsTable).select();

    if (requestedCountryCode != null) {
      query = query.eq('country_code', requestedCountryCode);
    }

    if (requestedCityId != null) {
      query = query.eq('city_id', requestedCityId);
    }

    query = query.order('vote_count', ascending: false);
    query = query.order('created_at', ascending: false);

    final safeOffset = (offset ?? 0) < 0 ? 0 : (offset ?? 0);
    final safeLimit = limit;

    if (safeLimit != null) {
      if (safeLimit <= 0) {
        return const <Poll>[];
      }

      query = query.range(safeOffset, safeOffset + safeLimit - 1);
    } else if (safeOffset > 0) {
      query = query.range(safeOffset, safeOffset + 199);
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

    final payload = _buildInsertPayload(
      poll: poll,
      authorId: currentUser.id,
    );

    if (kDebugMode) {
      debugPrint('POLL INSERT payload: $payload');
    }

    final rawRows = await AppSupabase.client
        .from(_pollsInsertTable)
        .insert(payload)
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

  @override
  Future<void> deletePoll(String pollId) async {
    final currentUser = AppSupabase.currentUser;
    if (currentUser == null) {
      throw Exception('Utente non autenticato.');
    }

    try {
      if (kDebugMode) {
        debugPrint(
          'POLL DELETE attempt -> pollId=$pollId currentUser=${currentUser.id}',
        );
      }

      final deletedRows = await AppSupabase.client
          .from(_pollsInsertTable)
          .delete()
          .eq('id', pollId)
          .eq('author_id', currentUser.id)
          .select('id') as List<dynamic>;

      if (kDebugMode) {
        debugPrint('POLL DELETE result -> rows=${deletedRows.length}');
      }

      if (deletedRows.isEmpty) {
        throw Exception('Eliminazione poll fallita: nessuna riga eliminata.');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('POLL DELETE failed -> $e');
        debugPrint('$st');
      }
      rethrow;
    }
  }

  @override
  Future<Poll> updatePollText({
    required String pollId,
    required String title,
    String? description,
  }) async {
    final currentUser = AppSupabase.currentUser;
    if (currentUser == null) {
      throw Exception('Utente non autenticato.');
    }

    final normalizedTitle = title.trim();
    final normalizedDescription = _normalizeNullableText(description);

    if (normalizedTitle.isEmpty) {
      throw Exception('Il titolo non può essere vuoto.');
    }

    final existingPoll = await getPollDetail(PollId(pollId));
    if (existingPoll == null) {
      throw Exception('Poll non trovato.');
    }

    if (existingPoll.createdByUserId != currentUser.id) {
      throw Exception('Puoi modificare solo i tuoi sondaggi.');
    }

    if (existingPoll.voteCount > 0) {
      throw Exception(
        'Non puoi modificare un sondaggio che ha già ricevuto voti.',
      );
    }

    final payload = <String, dynamic>{
      'title': normalizedTitle,
      'description': normalizedDescription,
    };

    try {
      if (kDebugMode) {
        debugPrint(
          'POLL UPDATE TEXT attempt -> pollId=$pollId currentUser=${currentUser.id} payload=$payload',
        );
      }

      final updatedRows = await AppSupabase.client
          .from(_pollsInsertTable)
          .update(payload)
          .eq('id', pollId)
          .eq('author_id', currentUser.id)
          .select('id') as List<dynamic>;

      if (kDebugMode) {
        debugPrint('POLL UPDATE TEXT result -> rows=${updatedRows.length}');
      }

      if (updatedRows.isEmpty) {
        throw Exception(
          'Aggiornamento poll fallito: nessuna riga aggiornata.',
        );
      }

      final refreshedPoll = await getPollDetail(PollId(pollId));
      if (refreshedPoll == null) {
        throw Exception('Poll aggiornato ma non più leggibile.');
      }

      return refreshedPoll;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('POLL UPDATE TEXT failed -> $e');
        debugPrint('$st');
      }
      rethrow;
    }
  }

  Map<String, dynamic> _buildInsertPayload({
    required Poll poll,
    required String authorId,
  }) {
    return <String, dynamic>{
      'author_id': authorId,
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
      'participation_country_code':
          poll.configuration.participationRules.countryCode,
      'allow_vote_change': poll.configuration.allowVoteChange,
      'anonymity_level': _anonymityLevelValue(
        poll.configuration.anonymityRules.level,
      ),
      'results_visibility': _resultsVisibilityValue(
        poll.configuration.visibilityRules.resultsVisibility,
      ),
      'min_quorum_votes': poll.configuration.quorumRules.minAbsoluteVotes,
      'country_code': poll.countryCode,
      'city_id': poll.cityId,
      'start_at': poll.startAt?.toIso8601String(),
      'end_at': poll.endAt?.toIso8601String(),
      'content_location': poll.contentLocation?.toJson(),
    };
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
    final participationCountryCode =
        row['participation_country_code'] as String?;
    final startAt = _parseDateTime(row['start_at']);
    final endAt = _parseDateTime(row['end_at']);
    final storedStatus = _pollStatusFromValue(row['status'] as String?);
    final effectiveStatus = _resolveEffectiveStatus(
      storedStatus: storedStatus,
      startAt: startAt,
      endAt: endAt,
    );
    final contentLocation = _mapContentLocation(row, countryCode, cityId);

    return Poll(
      id: PollId((row['id'] as String?) ?? ''),
      title: (row['title'] as String?) ?? '',
      description: row['description'] as String?,
      type: _pollTypeFromValue(row['type'] as String?),
      status: effectiveStatus,
      options: options,
      configuration: PollConfiguration(
        minSelections: (row['min_selections'] as int?) ?? 1,
        maxSelections: (row['max_selections'] as int?) ?? 1,
        allowVoteChange: (row['allow_vote_change'] as bool?) ?? false,
        participationRules: ParticipationRules(
          scope: _participationScopeFromValue(
            row['participation_scope'] as String?,
          ),
          countryCode: participationCountryCode,
        ),
        anonymityRules: AnonymityRules(
          level: _anonymityLevelFromValue(
            row['anonymity_level'] as String?,
          ),
        ),
        visibilityRules: VisibilityRules(
          resultsVisibility: _resultsVisibilityFromValue(
            row['results_visibility'] as String?,
          ),
        ),
        quorumRules: QuorumRules(
          minAbsoluteVotes: _toInt(row['min_quorum_votes']),
        ),
      ),
      createdAt: _parseDateTime(row['created_at']),
      startAt: startAt,
      endAt: endAt,
      countryCode: countryCode,
      cityId: cityId,
      contentLocation: contentLocation,
      createdByUserId: row['author_id'] as String?,
      voteCount: (row['vote_count'] as int?) ?? 0,
    );
  }

  PollStatus _resolveEffectiveStatus({
    required PollStatus storedStatus,
    required DateTime? startAt,
    required DateTime? endAt,
  }) {
    if (storedStatus == PollStatus.draft) {
      return PollStatus.draft;
    }

    if (storedStatus == PollStatus.closed) {
      return PollStatus.closed;
    }

    if (startAt == null && endAt == null) {
      return storedStatus;
    }

    final now = DateTime.now();

    if (startAt != null && now.isBefore(startAt)) {
      return PollStatus.scheduled;
    }

    if (endAt != null && now.isAfter(endAt)) {
      return PollStatus.closed;
    }

    return PollStatus.open;
  }

  ContentLocation? _mapContentLocation(
    Map<String, dynamic> row,
    String? countryCode,
    String? cityId,
  ) {
    final raw = row['content_location'];

    if (raw is Map<String, dynamic>) {
      return ContentLocation.fromJson(raw);
    }

    if (raw is Map) {
      return ContentLocation.fromJson(
        raw.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }

    final centerLat = _toDouble(row['center_lat']);
    final centerLng = _toDouble(row['center_lng']);
    final latitude = _toDouble(row['latitude']);
    final longitude = _toDouble(row['longitude']);

    final fallback = ContentLocation(
      source: ContentLocationSource.geoScopeFallback,
      countryCode: countryCode,
      cityId: cityId,
      centerLat: centerLat,
      centerLng: centerLng,
      latitude: latitude,
      longitude: longitude,
    );

    return fallback.isEmpty ? null : fallback;
  }

  String? _prepareDbFilterValue(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  String? _normalizeNullableText(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
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

  String _anonymityLevelValue(AnonymityLevel level) {
    return level.toString().split('.').last;
  }

  String _resultsVisibilityValue(ResultsVisibilityMode mode) {
    return mode.toString().split('.').last;
  }

  PollType _pollTypeFromValue(String? value) {
    switch (value) {
      case 'singleChoice':
        return PollType.singleChoice;
      case 'multipleChoice':
        return PollType.multipleChoice;
      case 'approval':
        return PollType.approval;
      case 'ranked':
        return PollType.ranked;
      case 'score':
        return PollType.score;
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
      case 'scheduled':
        return PollStatus.scheduled;
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

  AnonymityLevel _anonymityLevelFromValue(String? value) {
    switch (value) {
      case 'public':
        return AnonymityLevel.public;
      case 'anonymous':
      default:
        return AnonymityLevel.anonymous;
    }
  }

  ResultsVisibilityMode _resultsVisibilityFromValue(String? value) {
    switch (value) {
      case 'afterVote':
        return ResultsVisibilityMode.afterVote;
      case 'afterClose':
        return ResultsVisibilityMode.afterClose;
      case 'always':
      default:
        return ResultsVisibilityMode.always;
    }
  }
}

typedef PollRepositoryInMemory = PollRepositorySupabase;
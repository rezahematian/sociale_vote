import 'package:flutter/foundation.dart';
import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';

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

    final attempts = <({String label, Map<String, dynamic> payload})>[
      (
        label: 'full',
        payload: _buildInsertPayload(
          poll: poll,
          authorId: currentUser.id,
          includeTiming: true,
          includeContentLocation: true,
        ),
      ),
      (
        label: 'without_content_location',
        payload: _buildInsertPayload(
          poll: poll,
          authorId: currentUser.id,
          includeTiming: true,
          includeContentLocation: false,
        ),
      ),
      (
        label: 'without_timing',
        payload: _buildInsertPayload(
          poll: poll,
          authorId: currentUser.id,
          includeTiming: false,
          includeContentLocation: true,
        ),
      ),
      (
        label: 'legacy_minimal',
        payload: _buildInsertPayload(
          poll: poll,
          authorId: currentUser.id,
          includeTiming: false,
          includeContentLocation: false,
        ),
      ),
    ];

    Object? lastError;

    for (final attempt in attempts) {
      try {
        if (kDebugMode) {
          debugPrint('POLL INSERT attempt [${attempt.label}]');
          debugPrint('POLL INSERT payload: ${attempt.payload}');
        }

        final rawRows = await AppSupabase.client
            .from(_pollsInsertTable)
            .insert(attempt.payload)
            .select()
            .limit(1) as List<dynamic>;

        if (rawRows.isEmpty) {
          throw Exception(
            'Creazione poll fallita: risposta vuota da Supabase.',
          );
        }

        final row = rawRows.first;
        if (row is! Map<String, dynamic>) {
          throw Exception(
            'Creazione poll fallita: risposta non valida.',
          );
        }

        return _mapPoll(row);
      } catch (e, st) {
        lastError = e;
        if (kDebugMode) {
          debugPrint('POLL INSERT failed [${attempt.label}]: $e');
          debugPrint('$st');
        }
      }
    }

    throw Exception('Creazione poll fallita: $lastError');
  }

  Map<String, dynamic> _buildInsertPayload({
    required Poll poll,
    required String authorId,
    required bool includeTiming,
    required bool includeContentLocation,
  }) {
    final payload = <String, dynamic>{
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
      'country_code': poll.countryCode,
      'city_id': poll.cityId,
    };

    if (includeTiming && poll.startAt != null) {
      payload['start_at'] = poll.startAt!.toIso8601String();
    }

    if (includeTiming && poll.endAt != null) {
      payload['end_at'] = poll.endAt!.toIso8601String();
    }

    if (includeContentLocation && poll.contentLocation != null) {
      payload['content_location'] = poll.contentLocation!.toJson();
    }

    return payload;
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
    final contentLocation = _mapContentLocation(row, countryCode, cityId);

    return Poll(
      id: PollId((row['id'] as String?) ?? ''),
      title: (row['title'] as String?) ?? '',
      description: row['description'] as String?,
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
      startAt: _parseDateTime(row['start_at']),
      endAt: _parseDateTime(row['end_at']),
      countryCode: countryCode,
      cityId: cityId,
      contentLocation: contentLocation,
      createdByUserId: row['author_id'] as String?,
      voteCount: (row['vote_count'] as int?) ?? 0,
    );
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
}

typedef PollRepositoryInMemory = PollRepositorySupabase;

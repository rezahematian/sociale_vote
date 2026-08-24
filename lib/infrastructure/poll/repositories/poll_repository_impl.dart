import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/core/http/api_exception.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

import '../mappers/poll_mapper.dart';
import '../models/poll_dto.dart';

class PollRepositoryImpl implements PollRepository {
  final ApiClient _apiClient;

  PollRepositoryImpl(this._apiClient);

  @override
  Future<List<Poll>> getPolls({
    String? countryCode,
    String? cityId,
    int? limit,
    int? offset,
  }) async {
    try {
      final dynamic response = await _apiClient.getJson(
        '/polls',
        query: {
          if (countryCode != null) 'countryCode': countryCode,
          if (cityId != null) 'cityId': cityId,
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

      if (response == null) return <Poll>[];

      final List<dynamic> data = response as List<dynamic>;

      return data
          .map(
            (json) => PollMapper.fromDto(
              PollDto.fromJson(json as Map<String, dynamic>),
            ),
          )
          .toList();
    } on ApiException {
      return <Poll>[];
    } catch (_) {
      return <Poll>[];
    }
  }

  @override
  Future<List<Poll>> getPollsByAuthor({
    required String authorUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    final normalizedAuthorUserId = authorUserId.trim();
    if (normalizedAuthorUserId.isEmpty || limit <= 0) {
      return const <Poll>[];
    }

    final safeOffset = offset < 0 ? 0 : offset;
    final polls = await getPolls();

    final filtered = polls
        .where(
          (poll) => poll.createdByUserId?.trim() == normalizedAuthorUserId,
        )
        .toList(growable: false)
      ..sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

    if (safeOffset >= filtered.length) {
      return const <Poll>[];
    }

    final end = (safeOffset + limit) > filtered.length
        ? filtered.length
        : safeOffset + limit;

    return filtered.sublist(safeOffset, end);
  }

  @override
  Future<List<Poll>> getPollsByPublisherOrganizations({
    required Set<String> organizationIds,
    int limit = 20,
  }) async {
    final normalizedIds = organizationIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    if (normalizedIds.isEmpty || limit <= 0) {
      return const <Poll>[];
    }

    final polls = await getPolls();

    final filtered = polls
        .where(
          (poll) =>
              poll.publisherOrganizationId != null &&
              normalizedIds.contains(poll.publisherOrganizationId!.trim()),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

    if (filtered.length <= limit) {
      return filtered;
    }

    return filtered.take(limit).toList(growable: false);
  }

  @override
  Future<Poll?> getPollDetail(PollId pollId) async {
    try {
      final dynamic response =
          await _apiClient.getJson('/polls/${pollId.value}');

      if (response == null) return null;

      final dto = PollDto.fromJson(response as Map<String, dynamic>);
      return PollMapper.fromDto(dto);
    } on ApiException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Poll> createPoll(Poll poll) async {
    final dto = PollMapper.toDto(poll);

    final dynamic response = await _apiClient.postJson(
      '/polls',
      body: dto.toJson(),
    );

    final createdDto = PollDto.fromJson(response as Map<String, dynamic>);
    return PollMapper.fromDto(createdDto);
  }

  @override
  Future<void> deletePoll(String pollId) async {
    await _apiClient.deleteJson('/polls/$pollId');
  }

  @override
  Future<Poll> updatePollText({
    required String pollId,
    required String title,
    String? description,
  }) async {
    final dynamic response = await _apiClient.postJson(
      '/polls/$pollId',
      body: {
        'title': title,
        'description': description,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Invalid response format while updating poll text.',
      );
    }

    final dto = PollDto.fromJson(response);
    return PollMapper.fromDto(dto);
  }

  @override
  Future<bool> hasUserCreatedPollSince({
    required String userId,
    required DateTime since,
  }) async {
    try {
      final dynamic response = await _apiClient.getJson(
        '/polls/created-since',
        query: {
          'userId': userId,
          'since': since.toUtc().toIso8601String(),
        },
      );

      if (response is bool) return response;

      if (response is Map<String, dynamic>) {
        final dynamic value = response['hasCreated'];
        if (value is bool) return value;
        return value.toString().toLowerCase() == 'true';
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}

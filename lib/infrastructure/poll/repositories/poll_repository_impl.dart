import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/core/http/api_exception.dart';

import 'package:sociale_vote/infrastructure/poll/models/poll_dto.dart';
import 'package:sociale_vote/infrastructure/poll/mappers/poll_mapper.dart';

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

      return data.map((json) {
        final dto =
            PollDto.fromJson(json as Map<String, dynamic>);
        return PollMapper.fromDto(dto);
      }).toList();
    } on ApiException {
      // 🔥 Backend non disponibile → fallback sicuro
      return <Poll>[];
    } catch (_) {
      return <Poll>[];
    }
  }

  @override
  Future<Poll?> getPollDetail(PollId pollId) async {
    try {
      final dynamic response =
          await _apiClient.getJson('/polls/${pollId.value}');

      if (response == null) return null;

      final dto =
          PollDto.fromJson(response as Map<String, dynamic>);

      return PollMapper.fromDto(dto);
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

    final createdDto =
        PollDto.fromJson(response as Map<String, dynamic>);

    return PollMapper.fromDto(createdDto);
  }
}
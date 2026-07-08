import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/core/http/api_exception.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/repositories/reaction_repository.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

class ReactionRepositoryHttp implements ReactionRepository {
  final ApiClient _apiClient;

  ReactionRepositoryHttp(this._apiClient);

  @override
  Future<Reaction?> findByUserAndTarget({
    required String userId,
    required TargetRef target,
  }) async {
    final response = await _apiClient.getJson(
      '/reactions/single',
      query: {
        'userId': userId,
        'type': _mapTargetType(target),
        'id': _mapTargetId(target),
      },
    );

    if (response == null) {
      return null;
    }

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Invalid response format while loading reaction.',
      );
    }

    return _mapReaction(
      Map<String, dynamic>.from(response),
      target,
    );
  }

  @override
  Future<Reaction> create({
    required String userId,
    required TargetRef target,
    required ReactionType type,
    required DateTime createdAt,
  }) async {
    final response = await _apiClient.postJson(
      '/reactions',
      body: {
        'userId': userId,
        'targetType': _mapTargetType(target),
        'targetId': _mapTargetId(target),
        'type': type.name,
        'createdAt': createdAt.toUtc().toIso8601String(),
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Invalid response format while creating reaction.',
      );
    }

    return _mapReaction(
      Map<String, dynamic>.from(response),
      target,
    );
  }

  @override
  Future<Reaction> updateType({
    required String reactionId,
    required ReactionType type,
  }) async {
    throw UnimplementedError(
      'ReactionRepositoryHttp.updateType non è ancora implementato.',
    );
  }

  @override
  Future<void> delete(String reactionId) async {
    await _apiClient.deleteJson('/reactions/$reactionId');
  }

  @override
  Future<ReactionSummary> getSummaryForTarget(TargetRef target) async {
    final response = await _apiClient.getJson(
      '/reactions/summary',
      query: {
        'type': _mapTargetType(target),
        'id': _mapTargetId(target),
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Invalid response format while loading reaction summary.',
      );
    }

    return _mapReactionSummary(
      Map<String, dynamic>.from(response),
      target,
    );
  }

  @override
  Future<List<ReactionSummary>> getSummariesForTargets(
    List<TargetRef> targets,
  ) async {
    final List<ReactionSummary> summaries = [];

    for (final target in targets) {
      summaries.add(await getSummaryForTarget(target));
    }

    return summaries;
  }

  @override
  Future<ReactionSummary> getSummaryForTargetSince(
    TargetRef target, {
    required DateTime since,
  }) {
    return getSummaryForTarget(target);
  }

  @override
  Future<List<ReactionSummary>> getSummariesForTargetsSince(
    List<TargetRef> targets, {
    required DateTime since,
  }) {
    return getSummariesForTargets(targets);
  }

  String _mapTargetType(TargetRef target) {
    switch (target.type) {
      case TargetType.poll:
        return 'poll';
      case TargetType.news:
        return 'news';
      case TargetType.post:
        return 'post';
      case TargetType.video:
        return 'video';
      case TargetType.city:
        return 'city';
      case TargetType.country:
        return 'country';
      case TargetType.topic:
        return 'topic';
      default:
        return target.type.name;
    }
  }

  String _mapTargetId(TargetRef target) {
    return target.id;
  }

  Reaction _mapReaction(
    Map<String, dynamic> json,
    TargetRef target,
  ) {
    final rawType = json['type'] as String?;
    final ReactionType parsedType =
        _parseReactionType(rawType) ?? ReactionType.values.first;

    return Reaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      target: target,
      type: parsedType,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ReactionSummary _mapReactionSummary(
    Map<String, dynamic> json,
    TargetRef target,
  ) {
    final likeCount = _readInt(json['likeCount']);
    final dislikeCount = _readInt(json['dislikeCount']);
    final userReaction = _parseReactionType(json['userReaction'] as String?);

    return ReactionSummary.fromCounts(
      target: target,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      userReaction: userReaction,
    );
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  ReactionType? _parseReactionType(String? raw) {
    if (raw == null) return null;

    try {
      return ReactionType.values.firstWhere(
        (type) => type.name == raw,
      );
    } catch (_) {
      return null;
    }
  }
}

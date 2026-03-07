import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/core/http/api_exception.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/repositories/reaction_repository.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

/// Implementazione HTTP di [ReactionRepository].
///
/// Endpoint ipotizzati (da adattare al backend reale):
///
/// GET    /reactions/single?userId=...&type=poll&id=123
/// POST   /reactions
/// POST   /reactions/{id}           (update type)
/// DELETE /reactions/{id}
///
/// GET    /reactions/summary?type=poll&id=123
///
/// Per il bulk summary (getSummariesForTargets) per ora
/// chiamiamo getSummaryForTarget in loop (v1).
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
    // ⚠️ v1: non implementiamo davvero la logica,
    // perché qui non abbiamo il TargetRef.
    // Quando abiliterai HTTP per le reazioni, potremo
    // estendere il contratto o usare un endpoint che
    // restituisce anche il target.
    throw UnimplementedError(
      'ReactionRepositoryHttp.updateType non è ancora implementato (manca TargetRef).',
    );
  }

  @override
  Future<void> delete(String reactionId) async {
    await _apiClient.deleteJson('/reactions/$reactionId');
  }

  @override
  Future<ReactionSummary> getSummaryForTarget(
    TargetRef target,
  ) async {
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

    final map = Map<String, dynamic>.from(response);

    final likeCount = (map['likeCount'] as int?) ?? 0;
    final dislikeCount = (map['dislikeCount'] as int?) ?? 0;
    final String? rawUserReaction = map['userReaction'] as String?;
    final ReactionType? userReaction = _parseReactionType(rawUserReaction);

    return ReactionSummary.fromCounts(
      target: target,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      userReaction: userReaction,
    );
  }

  @override
  Future<List<ReactionSummary>> getSummariesForTargets(
    List<TargetRef> targets,
  ) async {
    // v1: semplice, chiamiamo getSummaryForTarget in loop.
    // In futuro potremo usare un endpoint bulk (/reactions/summary/bulk).
    final List<ReactionSummary> summaries = [];
    for (final target in targets) {
      final summary = await getSummaryForTarget(target);
      summaries.add(summary);
    }
    return summaries;
  }

  // ==========================================================
  // Mapping helpers
  // ==========================================================

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
        // Fallback per eventuali nuovi tipi futuri
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

  ReactionType? _parseReactionType(String? raw) {
    if (raw == null) return null;
    try {
      return ReactionType.values.firstWhere(
        (e) => e.name == raw,
      );
    } catch (_) {
      return null;
    }
  }
}
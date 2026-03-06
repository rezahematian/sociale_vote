import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comments_for_target.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/discovery/value_objects/trending_score.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';

/// Use case: restituisce contenuti "trending"
/// filtrati per scope seguiti dall'utente (se loggato).
///
/// V1:
/// - Solo Post
/// - Score = TrendingScore v1 (heat + commentCount + recency decay)
class GetTrendingContent {
  final PostRepository _postRepository;
  final GetReactionSummary _getReactionSummary;
  final GetCommentsForTarget _getCommentsForTarget;
  final FollowScopeRepository _followScopeRepository;

  GetTrendingContent({
    required PostRepository postRepository,
    required GetReactionSummary getReactionSummary,
    required GetCommentsForTarget getCommentsForTarget,
    required FollowScopeRepository followScopeRepository,
  })  : _postRepository = postRepository,
        _getReactionSummary = getReactionSummary,
        _getCommentsForTarget = getCommentsForTarget,
        _followScopeRepository = followScopeRepository;

  Future<List<Post>> call({
    required String? userId,
    required GeoScope currentScope,
    int limit = 10,
  }) async {
    // 1️⃣ Recupera tutti i post per lo scope corrente
    final posts = await _postRepository.getFeed(
      countryCode: currentScope.countryCode,
      cityId: currentScope.cityId,
    );

    // 2️⃣ Se utente loggato → filtra per scope seguiti
    if (userId != null) {
      final followed =
          await _followScopeRepository.getFollowedScopesForUser(userId);

      final followedScopes = followed.map((f) => f.scope).toSet();

      // Se non segue nulla → niente trending personalizzato
      if (followedScopes.isNotEmpty) {
        if (!followedScopes.contains(currentScope)) {
          return [];
        }
      }
    }

    // 3️⃣ Calcolo TrendingScore per ogni post
    final scored = <_ScoredPost>[];
    final now = DateTime.now();

    for (final post in posts) {
      final target = TargetRef.post(post.id.value);

      // GetReactionSummary:
      // - primo argomento: List<TargetRef>
      // - ritorno: List<ReactionSummary>
      final List<ReactionSummary> summaries = await _getReactionSummary(
        [target],
        userId: userId,
      );

      final ReactionSummary? summary =
          summaries.isNotEmpty ? summaries.first : null;

      final heat =
          (summary?.likeCount ?? 0) - (summary?.dislikeCount ?? 0);

      // GetCommentsForTarget: un solo TargetRef, ritorna List<Comment>
      final comments = await _getCommentsForTarget(target);
      final commentCount = comments.length;

      final score = TrendingScore.fromTimeBasedMetrics(
        heat: heat,
        commentCount: commentCount,
        createdAt: post.createdAt,
        now: now,
      );

      scored.add(_ScoredPost(post: post, score: score));
    }

    // 4️⃣ Ordina per score desc
    scored.sort((a, b) => TrendingScore.compareDesc(a.score, b.score));

    // 5️⃣ Restituisci solo i post ordinati
    return scored
        .take(limit)
        .map((e) => e.post)
        .toList(growable: false);
  }
}

class _ScoredPost {
  final Post post;
  final TrendingScore score;

  _ScoredPost({
    required this.post,
    required this.score,
  });
}
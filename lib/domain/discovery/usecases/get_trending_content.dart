import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comments_for_target.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

/// Use case: restituisce contenuti "trending"
/// filtrati per scope seguiti dall'utente (se loggato).
///
/// V1:
/// - Solo Post
/// - Ordine:
///   1. fire
///   2. commentCount
///   3. recency
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

    // 3️⃣ Calcolo priorità trending per ogni post
    final scored = <_ScoredPost>[];

    for (final post in posts) {
      final target = TargetRef.post(post.id.value);

      final List<ReactionSummary> summaries = await _getReactionSummary(
        [target],
        userId: userId,
      );

      final ReactionSummary? summary =
          summaries.isNotEmpty ? summaries.first : null;

      final fireCount = summary?.likeCount ?? 0;

      final comments = await _getCommentsForTarget(target);
      final commentCount = comments.length;

      scored.add(
        _ScoredPost(
          post: post,
          fireCount: fireCount,
          commentCount: commentCount,
        ),
      );
    }

    // 4️⃣ Ordine:
    //    1. fire desc
    //    2. commentCount desc
    //    3. createdAt desc
    scored.sort((a, b) {
      final fireCompare = b.fireCount.compareTo(a.fireCount);
      if (fireCompare != 0) {
        return fireCompare;
      }

      final commentCompare = b.commentCount.compareTo(a.commentCount);
      if (commentCompare != 0) {
        return commentCompare;
      }

      return b.post.createdAt.compareTo(a.post.createdAt);
    });

    // 5️⃣ Restituisci solo i post ordinati
    return scored
        .take(limit)
        .map((e) => e.post)
        .toList(growable: false);
  }
}

class _ScoredPost {
  final Post post;
  final int fireCount;
  final int commentCount;

  _ScoredPost({
    required this.post,
    required this.fireCount,
    required this.commentCount,
  });
}
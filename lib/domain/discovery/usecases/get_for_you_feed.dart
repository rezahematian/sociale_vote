import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/discovery/value_objects/for_you_score.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';

/// Use case: restituisce il feed "For You"
/// per l'utente corrente, limitato allo scope attuale
/// e, se loggato, coerente con gli scope che segue.
///
/// V1:
/// - Solo Post
/// - Score = ForYouScore v1 (heat * 0.7 + recency * 0.3)
class GetForYouFeed {
  final PostRepository _postRepository;
  final GetReactionSummary _getReactionSummary;
  final FollowScopeRepository _followScopeRepository;

  GetForYouFeed({
    required PostRepository postRepository,
    required GetReactionSummary getReactionSummary,
    required FollowScopeRepository followScopeRepository,
  })  : _postRepository = postRepository,
        _getReactionSummary = getReactionSummary,
        _followScopeRepository = followScopeRepository;

  /// Restituisce i post ordinati per "For You" score.
  ///
  /// Parametri:
  /// - [userId]: utente corrente (null se guest)
  /// - [currentScope]: scope attuale (world / country / city)
  /// - [limit]: numero massimo di post da restituire
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

    // 2️⃣ Se utente loggato → coerentizza con scope seguiti
    if (userId != null) {
      final followed =
          await _followScopeRepository.getFollowedScopesForUser(userId);

      final followedScopes = followed.map((f) => f.scope).toSet();

      // Se non segue nulla → nessun filtro extra
      // Se segue qualcosa → richiediamo che lo scope corrente sia tra quelli seguiti
      if (followedScopes.isNotEmpty) {
        if (!followedScopes.contains(currentScope)) {
          return [];
        }
      }
    }

    // 3️⃣ Calcolo ForYouScore per ogni post
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

      final score = ForYouScore.fromTimeBasedMetrics(
        heat: heat,
        createdAt: post.createdAt,
        now: now,
      );

      scored.add(_ScoredPost(post: post, score: score));
    }

    // 4️⃣ Ordina per score desc
    scored.sort((a, b) => ForYouScore.compareDesc(a.score, b.score));

    // 5️⃣ Restituisci solo i post ordinati
    return scored
        .take(limit)
        .map((e) => e.post)
        .toList(growable: false);
  }
}

class _ScoredPost {
  final Post post;
  final ForYouScore score;

  _ScoredPost({
    required this.post,
    required this.score,
  });
}
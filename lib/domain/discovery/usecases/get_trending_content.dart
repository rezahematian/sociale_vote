import 'dart:math' as math;

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comments_for_target.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
import 'package:sociale_vote/features/home/application/feed_item.dart';

/// Use case: restituisce contenuti "trending" cross-content,
/// ordinati con formula Hot v1 tuned.
///
/// Obiettivi di questa versione:
/// - ranking hot cross-content credibile
/// - niente quote forzate per tipo contenuto
/// - meno dominanza dei poll dovuta ai soli voti accumulati
/// - più peso al momentum reale (reaction/comment/vote recenti)
/// - load ancora accettabile tramite shortlist preliminare
///
/// Formula finale tuned:
///   base = heat * 1.0 + comments * 0.8 + scaledVotes * 0.55
///   velocity = recentReactionHeat * 2.0
///            + recentComments * 1.5
///            + scaledRecentVotes * 1.0
///   final = (base + velocity) * freshnessMultiplier
///
/// Dove:
/// - votes sono normalizzati con sqrt per evitare che volumi molto alti
///   schiaccino sempre news e post
/// - il ranking resta puro: nessun tipo entra "per forza"
class GetTrendingContent {
  static const Duration _velocityWindow = Duration(hours: 12);
  static const double _freshnessHalfLifeHours = 24.0;

  // Base engagement weights
  static const double _heatWeight = 1.0;
  static const double _commentWeight = 0.8;
  static const double _voteWeight = 0.55;

  // Velocity weights
  static const double _recentReactionHeatWeight = 2.0;
  static const double _recentCommentWeight = 1.5;
  static const double _recentVoteWeight = 1.0;

  final PostRepository _postRepository;
  final NewsRepository _newsRepository;
  final PollRepository _pollRepository;
  final VoteRepository _voteRepository;
  final GetReactionSummary _getReactionSummary;
  final GetCommentsForTarget _getCommentsForTarget;
  final FollowScopeRepository _followScopeRepository;

  GetTrendingContent({
    required PostRepository postRepository,
    required NewsRepository newsRepository,
    required PollRepository pollRepository,
    required VoteRepository voteRepository,
    required GetReactionSummary getReactionSummary,
    required GetCommentsForTarget getCommentsForTarget,
    required FollowScopeRepository followScopeRepository,
  })  : _postRepository = postRepository,
        _newsRepository = newsRepository,
        _pollRepository = pollRepository,
        _voteRepository = voteRepository,
        _getReactionSummary = getReactionSummary,
        _getCommentsForTarget = getCommentsForTarget,
        _followScopeRepository = followScopeRepository;

  Future<List<FeedItem>> call({
    required String? userId,
    required GeoScope currentScope,
    int limit = 10,
  }) async {
    if (userId != null) {
      final followed =
          await _followScopeRepository.getFollowedScopesForUser(userId);

      final followedScopes = followed.map((f) => f.scope).toSet();

      if (followedScopes.isNotEmpty && !followedScopes.contains(currentScope)) {
        return const <FeedItem>[];
      }
    }

    final candidateLimit = _resolveCandidateLimit(limit);
    final now = DateTime.now();
    final since = now.subtract(_velocityWindow);

    final results = await Future.wait<dynamic>([
      _postRepository.getFeed(
        countryCode: currentScope.countryCode,
        cityId: currentScope.cityId,
        limit: candidateLimit,
        offset: 0,
      ),
      _pollRepository.getPolls(
        countryCode: currentScope.countryCode,
        cityId: currentScope.cityId,
        limit: candidateLimit,
        offset: 0,
      ),
      _newsRepository.getTrendingCandidates(
        countryCode: currentScope.countryCode,
        cityId: currentScope.cityId,
        limit: candidateLimit,
      ),
    ]);

    final posts = results[0] as List<dynamic>;
    final polls = results[1] as List<Poll>;
    final news = results[2] as List<dynamic>;

    final candidates = <FeedItem>[
      for (final post in posts)
        FeedItem.post(
          id: post.id.value,
          targetRef: TargetRef.post(post.id.value),
          createdAt: post.createdAt,
          post: post,
        ),
      for (final poll in polls)
        FeedItem.poll(
          id: poll.id.value,
          targetRef: TargetRef.poll(poll.id.value),
          createdAt: poll.rankingDate,
          poll: poll,
          voteCount: poll.voteCount,
        ),
      for (final item in news)
        FeedItem.news(
          id: item.id.value,
          targetRef: TargetRef.news(item.id.value),
          createdAt: item.publishedAt,
          news: item,
        ),
    ];

    if (candidates.isEmpty) {
      return const <FeedItem>[];
    }

    final targets = candidates.map((item) => item.targetRef).toList();

    final reactionResults = await Future.wait<List<ReactionSummary>>([
      _getReactionSummary(targets),
      _getReactionSummary(
        targets,
        since: since,
      ),
    ]);

    final totalReactionByTargetKey = {
      for (final summary in reactionResults[0]) summary.target.key: summary,
    };
    final recentReactionByTargetKey = {
      for (final summary in reactionResults[1]) summary.target.key: summary,
    };

    final shortlist = _buildPreliminaryShortlist(
      candidates: candidates,
      totalReactionByTargetKey: totalReactionByTargetKey,
      recentReactionByTargetKey: recentReactionByTargetKey,
      now: now,
      limit: limit,
    );

    if (shortlist.isEmpty) {
      return const <FeedItem>[];
    }

    final shortlistTargets =
        shortlist.map((item) => item.targetRef).toList(growable: false);

    final commentSignals = await Future.wait<_CommentSignal>(
      shortlistTargets.map(
        (target) => _loadCommentSignal(
          target: target,
          since: since,
        ),
      ),
    );

    final commentSignalByTargetKey = {
      for (final signal in commentSignals) signal.target.key: signal,
    };

    final shortlistPolls = shortlist
        .where((item) => item.isPoll && item.poll != null)
        .map((item) => item.poll!)
        .toList(growable: false);

    final pollVoteSignals = await Future.wait<_PollVoteSignal>(
      shortlistPolls.map(
        (poll) => _loadPollVoteSignal(
          poll: poll,
          since: since,
        ),
      ),
    );

    final voteSignalByPollId = {
      for (final signal in pollVoteSignals) signal.pollId: signal,
    };

    final scored = <FeedItem>[];

    for (final item in shortlist) {
      final totalReaction = totalReactionByTargetKey[item.targetRef.key];
      final recentReaction = recentReactionByTargetKey[item.targetRef.key];
      final commentSignal = commentSignalByTargetKey[item.targetRef.key];

      final totalHeat = totalReaction?.heat.value ?? 0;
      final recentHeat = recentReaction?.heat.value ?? 0;
      final commentCount = commentSignal?.totalCount ?? 0;
      final recentCommentCount = commentSignal?.recentCount ?? 0;

      final voteSignal = item.isPoll ? voteSignalByPollId[item.id] : null;
      final totalVoteCount = voteSignal?.totalCount ?? 0;
      final recentVoteCount = voteSignal?.recentCount ?? 0;

      final score = _computeHotScore(
        createdAt: item.createdAt,
        now: now,
        totalHeat: totalHeat,
        commentCount: commentCount,
        voteCount: totalVoteCount,
        recentReactionHeat: recentHeat,
        recentCommentCount: recentCommentCount,
        recentVoteCount: recentVoteCount,
      );

      scored.add(
        item.copyWith(
          reactionCount: totalReaction?.likeCount ?? 0,
          commentCount: commentCount,
          voteCount: totalVoteCount,
          rankingScore: score,
        ),
      );
    }

    scored.sort((a, b) {
      final scoreCompare = b.rankingScore.compareTo(a.rankingScore);
      if (scoreCompare != 0) {
        return scoreCompare;
      }

      return b.createdAt.compareTo(a.createdAt);
    });

    return scored.take(limit).toList(growable: false);
  }

  List<FeedItem> _buildPreliminaryShortlist({
    required List<FeedItem> candidates,
    required Map<String, ReactionSummary> totalReactionByTargetKey,
    required Map<String, ReactionSummary> recentReactionByTargetKey,
    required DateTime now,
    required int limit,
  }) {
    final prelim = <FeedItem>[];

    for (final item in candidates) {
      final totalReaction = totalReactionByTargetKey[item.targetRef.key];
      final recentReaction = recentReactionByTargetKey[item.targetRef.key];

      final totalHeat = totalReaction?.heat.value ?? 0;
      final recentHeat = recentReaction?.heat.value ?? 0;
      final voteCount = item.isPoll ? item.voteCount : 0;

      final score = _computePreliminaryScore(
        createdAt: item.createdAt,
        now: now,
        totalHeat: totalHeat,
        recentReactionHeat: recentHeat,
        voteCount: voteCount,
      );

      prelim.add(
        item.copyWith(
          rankingScore: score,
        ),
      );
    }

    prelim.sort((a, b) {
      final scoreCompare = b.rankingScore.compareTo(a.rankingScore);
      if (scoreCompare != 0) {
        return scoreCompare;
      }

      return b.createdAt.compareTo(a.createdAt);
    });

    final shortlistLimit = _resolveShortlistLimit(
      requestedLimit: limit,
      availableCount: prelim.length,
    );

    return prelim.take(shortlistLimit).toList(growable: false);
  }

  double _computePreliminaryScore({
    required DateTime createdAt,
    required DateTime now,
    required num totalHeat,
    required num recentReactionHeat,
    required int voteCount,
  }) {
    final freshnessMultiplier = _computeFreshnessMultiplier(
      createdAt: createdAt,
      now: now,
    );

    final scaledVotes = _scaleVoteCount(voteCount);

    final prelimBase = (totalHeat * 1.0) +
        (recentReactionHeat * 1.7) +
        (scaledVotes * 0.20);

    return prelimBase * freshnessMultiplier;
  }

  Future<_CommentSignal> _loadCommentSignal({
    required TargetRef target,
    required DateTime since,
  }) async {
    final List<Comment> comments = await _getCommentsForTarget(target);

    final recentCount = comments.where((comment) {
      return !comment.createdAt.isBefore(since);
    }).length;

    return _CommentSignal(
      target: target,
      totalCount: comments.length,
      recentCount: recentCount,
    );
  }

  Future<_PollVoteSignal> _loadPollVoteSignal({
    required Poll poll,
    required DateTime since,
  }) async {
    final List<Vote> votes = await _voteRepository.getVotesForPoll(poll.id);

    final recentCount = votes.where((vote) {
      return !vote.createdAt.isBefore(since);
    }).length;

    return _PollVoteSignal(
      pollId: poll.id.value,
      totalCount: poll.voteCount,
      recentCount: recentCount,
    );
  }

  double _computeHotScore({
    required DateTime createdAt,
    required DateTime now,
    required num totalHeat,
    required int commentCount,
    required int voteCount,
    required num recentReactionHeat,
    required int recentCommentCount,
    required int recentVoteCount,
  }) {
    final scaledVotes = _scaleVoteCount(voteCount);
    final scaledRecentVotes = _scaleVoteCount(recentVoteCount);

    final baseEngagement = (totalHeat * _heatWeight) +
        (commentCount * _commentWeight) +
        (scaledVotes * _voteWeight);

    final velocityScore = (recentReactionHeat * _recentReactionHeatWeight) +
        (recentCommentCount * _recentCommentWeight) +
        (scaledRecentVotes * _recentVoteWeight);

    final freshnessMultiplier = _computeFreshnessMultiplier(
      createdAt: createdAt,
      now: now,
    );

    return (baseEngagement + velocityScore) * freshnessMultiplier;
  }

  double _scaleVoteCount(int value) {
    if (value <= 0) {
      return 0.0;
    }

    return math.sqrt(value.toDouble());
  }

  double _computeFreshnessMultiplier({
    required DateTime createdAt,
    required DateTime now,
  }) {
    final effectiveNow = now.isBefore(createdAt) ? createdAt : now;
    final ageHours = effectiveNow.difference(createdAt).inMinutes / 60.0;

    if (ageHours <= 0) {
      return 1.0;
    }

    const ln2 = 0.6931471805599453;
    final decay = -ln2 * (ageHours / _freshnessHalfLifeHours);

    return math.exp(decay);
  }

  int _resolveCandidateLimit(int limit) {
    final warmed = limit * 3;
    if (warmed < 20) {
      return 20;
    }
    if (warmed > 60) {
      return 60;
    }
    return warmed;
  }

  int _resolveShortlistLimit({
    required int requestedLimit,
    required int availableCount,
  }) {
    var shortlist = requestedLimit * 3;

    if (shortlist < 15) {
      shortlist = 15;
    }
    if (shortlist > 30) {
      shortlist = 30;
    }
    if (shortlist > availableCount) {
      shortlist = availableCount;
    }

    return shortlist;
  }
}

class _CommentSignal {
  final TargetRef target;
  final int totalCount;
  final int recentCount;

  const _CommentSignal({
    required this.target,
    required this.totalCount,
    required this.recentCount,
  });
}

class _PollVoteSignal {
  final String pollId;
  final int totalCount;
  final int recentCount;

  const _PollVoteSignal({
    required this.pollId,
    required this.totalCount,
    required this.recentCount,
  });
}
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';
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

class GetTrendingContent {
  static const Duration _velocityWindow = Duration(hours: 12);
  static const double _freshnessHalfLifeHours = 48.0;
  static const double _preliminaryFreshnessHalfLifeHours = 36.0;

  static const int _debugTopItems = 12;

  static const double _heatWeight = 1.0;
  static const double _commentWeight = 0.8;
  static const double _voteWeight = 0.55;

  static const double _recentReactionHeatWeight = 2.0;
  static const double _recentCommentWeight = 1.5;
  static const double _recentVoteWeight = 1.0;

  static const double _preliminaryHeatWeight = 1.0;
  static const double _preliminaryRecentReactionHeatWeight = 1.7;
  static const double _preliminaryCommentWeight = 0.35;
  static const double _preliminaryVoteWeight = 0.10;

  final PostRepository _postRepository;
  final NewsRepository _newsRepository;
  final PollRepository _pollRepository;
  final VoteRepository _voteRepository;
  final CommentRepository _commentRepository;
  final GetReactionSummary _getReactionSummary;
  final GetCommentsForTarget _getCommentsForTarget;
  final FollowScopeRepository _followScopeRepository;

  GetTrendingContent({
    required PostRepository postRepository,
    required NewsRepository newsRepository,
    required PollRepository pollRepository,
    required VoteRepository voteRepository,
    required CommentRepository commentRepository,
    required GetReactionSummary getReactionSummary,
    required GetCommentsForTarget getCommentsForTarget,
    required FollowScopeRepository followScopeRepository,
  })  : _postRepository = postRepository,
        _newsRepository = newsRepository,
        _pollRepository = pollRepository,
        _voteRepository = voteRepository,
        _commentRepository = commentRepository,
        _getReactionSummary = getReactionSummary,
        _getCommentsForTarget = getCommentsForTarget,
        _followScopeRepository = followScopeRepository;

  Future<List<FeedItem>> call({
    required String? userId,
    required GeoScope currentScope,
    int limit = 10,
  }) async {
    final totalStopwatch = Stopwatch()..start();

    var fetchMs = 0;
    var reactionMs = 0;
    var prelimCommentBatchMs = 0;
    var prelimBuildMs = 0;
    var shortlistCommentMs = 0;
    var shortlistVoteMs = 0;
    var finalScoreMs = 0;

    _debugPrintLine(
      'Trending call -> scope=$currentScope limit=$limit user=${userId ?? 'guest'}',
    );

    if (userId != null) {
      final followed =
          await _followScopeRepository.getFollowedScopesForUser(userId);

      final followedScopes = followed.map((f) => f.scope).toSet();

      if (followedScopes.isNotEmpty && !followedScopes.contains(currentScope)) {
        _debugPrintLine(
          'Trending skipped -> current scope not followed by user',
        );
        return const <FeedItem>[];
      }
    }

    final candidateLimit = _resolveCandidateLimit(limit);
    final now = DateTime.now();
    final since = now.subtract(_velocityWindow);

    {
      final sw = Stopwatch()..start();
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
      fetchMs = sw.elapsedMilliseconds;

      final posts = (results[0] as List<dynamic>)
          .take(candidateLimit)
          .toList(growable: false);
      final polls = (results[1] as List<Poll>)
          .take(candidateLimit)
          .toList(growable: false);
      final news = (results[2] as List<dynamic>)
          .take(candidateLimit)
          .toList(growable: false);

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

      _debugPrintLine(
        'Trending candidates -> posts=${posts.length} polls=${polls.length} news=${news.length} total=${candidates.length}',
      );

      if (candidates.isEmpty) {
        _debugPrintLine('Trending returned -> count=0');
        _debugPrintLine(
          'Trending timing -> fetch=$fetchMs reactions=0 prelimComments=0 prelimBuild=0 shortlistComments=0 shortlistVotes=0 finalScore=0 total=${totalStopwatch.elapsedMilliseconds}',
        );
        return const <FeedItem>[];
      }

      final targets = candidates.map((item) => item.targetRef).toList();

      late final Map<String, ReactionSummary> totalReactionByTargetKey;
      late final Map<String, ReactionSummary> recentReactionByTargetKey;

      {
        final sw = Stopwatch()..start();
        final reactionResults = await Future.wait<List<ReactionSummary>>([
          _getReactionSummary(targets),
          _getReactionSummary(
            targets,
            since: since,
          ),
        ]);
        reactionMs = sw.elapsedMilliseconds;

        totalReactionByTargetKey = {
          for (final summary in reactionResults[0]) summary.target.key: summary,
        };
        recentReactionByTargetKey = {
          for (final summary in reactionResults[1]) summary.target.key: summary,
        };
      }

      late final Map<String, int> preliminaryCommentCountByTargetKey;

      {
        final sw = Stopwatch()..start();
        try {
          final rawBatchCounts =
              await _commentRepository.countCommentsForTargets(targets);
          preliminaryCommentCountByTargetKey = _normalizeBatchCommentCounts(
            targets: targets,
            rawCounts: rawBatchCounts,
          );
        } catch (_) {
          preliminaryCommentCountByTargetKey = {
            for (final target in targets) target.key: 0,
          };
          _debugPrintLine(
            'Trending prelim comment batch failed -> fallback zeros',
          );
        }
        prelimCommentBatchMs = sw.elapsedMilliseconds;
      }

      late final List<FeedItem> shortlist;

      {
        final sw = Stopwatch()..start();
        shortlist = _buildPreliminaryShortlist(
          candidates: candidates,
          totalReactionByTargetKey: totalReactionByTargetKey,
          recentReactionByTargetKey: recentReactionByTargetKey,
          preliminaryCommentCountByTargetKey: preliminaryCommentCountByTargetKey,
          now: now,
          limit: limit,
        );
        prelimBuildMs = sw.elapsedMilliseconds;
      }

      if (shortlist.isEmpty) {
        _debugPrintLine('Trending returned -> count=0');
        _debugPrintLine(
          'Trending timing -> fetch=$fetchMs reactions=$reactionMs prelimComments=$prelimCommentBatchMs prelimBuild=$prelimBuildMs shortlistComments=0 shortlistVotes=0 finalScore=0 total=${totalStopwatch.elapsedMilliseconds}',
        );
        return const <FeedItem>[];
      }

      final commentSignalByTargetKey = <String, _CommentSignal>{
        for (final item in shortlist)
          item.targetRef.key: _CommentSignal(
            target: item.targetRef,
            totalCount:
                preliminaryCommentCountByTargetKey[item.targetRef.key] ?? 0,
            recentCount: 0,
          ),
      };

      final shortlistTargetsNeedingCommentLoad = shortlist
          .where(
            (item) =>
                (preliminaryCommentCountByTargetKey[item.targetRef.key] ?? 0) >
                0,
          )
          .map((item) => item.targetRef)
          .toList(growable: false);

      if (shortlistTargetsNeedingCommentLoad.isNotEmpty) {
        final sw = Stopwatch()..start();
        final loadedCommentSignals = await Future.wait<_CommentSignal>(
          shortlistTargetsNeedingCommentLoad.map(
            (target) => _loadCommentSignal(
              target: target,
              since: since,
            ),
          ),
        );
        shortlistCommentMs = sw.elapsedMilliseconds;

        for (final signal in loadedCommentSignals) {
          commentSignalByTargetKey[signal.target.key] = signal;
        }
      }

      final shortlistPolls = shortlist
          .where(
            (item) => item.isPoll && item.poll != null && (item.voteCount > 0),
          )
          .map((item) => item.poll!)
          .toList(growable: false);

      final voteSignalByPollId = <String, _PollVoteSignal>{};

      if (shortlistPolls.isNotEmpty) {
        final sw = Stopwatch()..start();
        final pollVoteSignals = await Future.wait<_PollVoteSignal>(
          shortlistPolls.map(
            (poll) => _loadPollVoteSignal(
              poll: poll,
              since: since,
            ),
          ),
        );
        shortlistVoteMs = sw.elapsedMilliseconds;

        for (final signal in pollVoteSignals) {
          voteSignalByPollId[signal.pollId] = signal;
        }
      }

      late final List<FeedItem> returned;

      {
        final sw = Stopwatch()..start();
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

          final breakdown = _buildFinalScoreBreakdown(
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
              rankingScore: breakdown.totalScore,
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

        final nonZeroScored = scored
            .where((item) => item.rankingScore > 0)
            .toList(growable: false);

        returned = nonZeroScored.take(limit).toList(growable: false);
        finalScoreMs = sw.elapsedMilliseconds;
      }

      _debugPrintLine('Trending returned -> count=${returned.length}');

      _debugLogFinalRanking(
        ranked: returned,
        totalReactionByTargetKey: totalReactionByTargetKey,
        recentReactionByTargetKey: recentReactionByTargetKey,
        commentSignalByTargetKey: commentSignalByTargetKey,
        voteSignalByPollId: voteSignalByPollId,
        now: now,
        limit: limit,
      );

      _debugPrintLine(
        'Trending timing -> fetch=$fetchMs reactions=$reactionMs prelimComments=$prelimCommentBatchMs prelimBuild=$prelimBuildMs shortlistComments=$shortlistCommentMs shortlistVotes=$shortlistVoteMs finalScore=$finalScoreMs total=${totalStopwatch.elapsedMilliseconds}',
      );

      return returned;
    }
  }

  Map<String, int> _normalizeBatchCommentCounts({
    required List<TargetRef> targets,
    required Map<String, int> rawCounts,
  }) {
    final normalized = <String, int>{};

    for (final target in targets) {
      final targetKey = target.key;
      final repositoryKey = _commentRepositoryBatchKey(target);

      final count = rawCounts[targetKey] ?? rawCounts[repositoryKey] ?? 0;
      normalized[targetKey] = count;
    }

    return normalized;
  }

  String _commentRepositoryBatchKey(TargetRef target) {
    final type = switch (target.type) {
      TargetType.post => 'post',
      TargetType.news => 'news',
      TargetType.poll => 'poll',
      TargetType.video => 'video',
      _ => target.type.name,
    };

    return '$type|${target.id.trim()}';
  }

  List<FeedItem> _buildPreliminaryShortlist({
    required List<FeedItem> candidates,
    required Map<String, ReactionSummary> totalReactionByTargetKey,
    required Map<String, ReactionSummary> recentReactionByTargetKey,
    required Map<String, int> preliminaryCommentCountByTargetKey,
    required DateTime now,
    required int limit,
  }) {
    final prelim = <FeedItem>[];

    for (final item in candidates) {
      final totalReaction = totalReactionByTargetKey[item.targetRef.key];
      final recentReaction = recentReactionByTargetKey[item.targetRef.key];

      final totalHeat = totalReaction?.heat.value ?? 0;
      final recentHeat = recentReaction?.heat.value ?? 0;
      final commentCount =
          preliminaryCommentCountByTargetKey[item.targetRef.key] ?? 0;
      final voteCount = item.isPoll ? item.voteCount : 0;

      final breakdown = _buildPreliminaryScoreBreakdown(
        createdAt: item.createdAt,
        now: now,
        totalHeat: totalHeat,
        recentReactionHeat: recentHeat,
        commentCount: commentCount,
        voteCount: voteCount,
      );

      prelim.add(
        item.copyWith(
          rankingScore: breakdown.totalScore,
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

    final positivePrelim = prelim
        .where((item) => item.rankingScore > 0)
        .toList(growable: false);

    final shortlistLimit = _resolveShortlistLimit(
      requestedLimit: limit,
      availableCount: positivePrelim.length,
    );

    _debugLogPreliminaryRanking(
      ranked: prelim,
      positiveCandidateCount: positivePrelim.length,
      totalReactionByTargetKey: totalReactionByTargetKey,
      recentReactionByTargetKey: recentReactionByTargetKey,
      preliminaryCommentCountByTargetKey: preliminaryCommentCountByTargetKey,
      now: now,
      shortlistLimit: shortlistLimit,
    );

    return positivePrelim.take(shortlistLimit).toList(growable: false);
  }

  _HotScoreBreakdown _buildPreliminaryScoreBreakdown({
    required DateTime createdAt,
    required DateTime now,
    required num totalHeat,
    required num recentReactionHeat,
    required int commentCount,
    required int voteCount,
  }) {
    final freshnessMultiplier = _computeFreshnessMultiplier(
      createdAt: createdAt,
      now: now,
      halfLifeHours: _preliminaryFreshnessHalfLifeHours,
    );

    final scaledVotes = _scaleVoteCount(voteCount);

    final baseScore = (totalHeat * _preliminaryHeatWeight) +
        (recentReactionHeat * _preliminaryRecentReactionHeatWeight) +
        (commentCount * _preliminaryCommentWeight) +
        (scaledVotes * _preliminaryVoteWeight);

    return _HotScoreBreakdown(
      baseScore: baseScore,
      velocityScore: 0.0,
      freshnessMultiplier: freshnessMultiplier,
      totalScore: baseScore * freshnessMultiplier,
    );
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

  _HotScoreBreakdown _buildFinalScoreBreakdown({
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
      halfLifeHours: _freshnessHalfLifeHours,
    );

    return _HotScoreBreakdown(
      baseScore: baseEngagement,
      velocityScore: velocityScore,
      freshnessMultiplier: freshnessMultiplier,
      totalScore: (baseEngagement + velocityScore) * freshnessMultiplier,
    );
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
    required double halfLifeHours,
  }) {
    final effectiveNow = now.isBefore(createdAt) ? createdAt : now;
    final ageHours = effectiveNow.difference(createdAt).inMinutes / 60.0;

    if (ageHours <= 0) {
      return 1.0;
    }

    const ln2 = 0.6931471805599453;
    final decay = -ln2 * (ageHours / halfLifeHours);

    return math.exp(decay);
  }

  int _resolveCandidateLimit(int limit) {
    final warmed = limit * 3;
    if (warmed < 18) {
      return 18;
    }
    if (warmed > 48) {
      return 48;
    }
    return warmed;
  }

  int _resolveShortlistLimit({
    required int requestedLimit,
    required int availableCount,
  }) {
    var shortlist = requestedLimit * 2;

    if (shortlist < 12) {
      shortlist = 12;
    }
    if (shortlist > 20) {
      shortlist = 20;
    }
    if (shortlist > availableCount) {
      shortlist = availableCount;
    }

    return shortlist;
  }

  void _debugLogPreliminaryRanking({
    required List<FeedItem> ranked,
    required int positiveCandidateCount,
    required Map<String, ReactionSummary> totalReactionByTargetKey,
    required Map<String, ReactionSummary> recentReactionByTargetKey,
    required Map<String, int> preliminaryCommentCountByTargetKey,
    required DateTime now,
    required int shortlistLimit,
  }) {
    assert(() {
      final buffer = StringBuffer();
      final topCount = math.min(_debugTopItems, ranked.length);
      final positiveRanked = ranked
          .where((item) => item.rankingScore > 0)
          .toList(growable: false);
      final cutCount =
          math.min(5, math.max(0, positiveRanked.length - shortlistLimit));

      buffer.writeln(
        'Trending prelim -> totalCandidates=${ranked.length} '
        'positiveCandidates=$positiveCandidateCount '
        'shortlistLimit=$shortlistLimit topLogged=$topCount',
      );

      for (var i = 0; i < topCount; i++) {
        final item = ranked[i];
        final totalReaction = totalReactionByTargetKey[item.targetRef.key];
        final recentReaction = recentReactionByTargetKey[item.targetRef.key];
        final commentCount =
            preliminaryCommentCountByTargetKey[item.targetRef.key] ?? 0;

        final breakdown = _buildPreliminaryScoreBreakdown(
          createdAt: item.createdAt,
          now: now,
          totalHeat: totalReaction?.heat.value ?? 0,
          recentReactionHeat: recentReaction?.heat.value ?? 0,
          commentCount: commentCount,
          voteCount: item.isPoll ? item.voteCount : 0,
        );

        buffer.writeln(
          '[prelim #${i + 1}] '
          'type=${_itemType(item)} '
          'id=${item.id} '
          'heat=${totalReaction?.heat.value ?? 0} '
          'recentHeat=${recentReaction?.heat.value ?? 0} '
          'comments=$commentCount '
          'votes=${item.isPoll ? item.voteCount : 0} '
          'freshness=${breakdown.freshnessMultiplier.toStringAsFixed(3)} '
          'score=${breakdown.totalScore.toStringAsFixed(3)}',
        );
      }

      if (cutCount > 0) {
        buffer.writeln('Trending prelim -> first positive items cut by shortlist:');

        for (var i = 0; i < cutCount; i++) {
          final item = positiveRanked[shortlistLimit + i];
          final totalReaction = totalReactionByTargetKey[item.targetRef.key];
          final recentReaction = recentReactionByTargetKey[item.targetRef.key];
          final commentCount =
              preliminaryCommentCountByTargetKey[item.targetRef.key] ?? 0;

          final breakdown = _buildPreliminaryScoreBreakdown(
            createdAt: item.createdAt,
            now: now,
            totalHeat: totalReaction?.heat.value ?? 0,
            recentReactionHeat: recentReaction?.heat.value ?? 0,
            commentCount: commentCount,
            voteCount: item.isPoll ? item.voteCount : 0,
          );

          buffer.writeln(
            '[cut #${i + 1}] '
            'type=${_itemType(item)} '
            'id=${item.id} '
            'heat=${totalReaction?.heat.value ?? 0} '
            'recentHeat=${recentReaction?.heat.value ?? 0} '
            'comments=$commentCount '
            'votes=${item.isPoll ? item.voteCount : 0} '
            'freshness=${breakdown.freshnessMultiplier.toStringAsFixed(3)} '
            'score=${breakdown.totalScore.toStringAsFixed(3)}',
          );
        }
      }

      _debugPrintBlock(buffer.toString());
      return true;
    }());
  }

  void _debugLogFinalRanking({
    required List<FeedItem> ranked,
    required Map<String, ReactionSummary> totalReactionByTargetKey,
    required Map<String, ReactionSummary> recentReactionByTargetKey,
    required Map<String, _CommentSignal> commentSignalByTargetKey,
    required Map<String, _PollVoteSignal> voteSignalByPollId,
    required DateTime now,
    required int limit,
  }) {
    assert(() {
      final buffer = StringBuffer();
      final topCount = math.min(_debugTopItems, ranked.length);

      buffer.writeln(
        'Trending final -> returned=${ranked.length} requestedLimit=$limit topLogged=$topCount',
      );

      for (var i = 0; i < topCount; i++) {
        final item = ranked[i];
        final totalReaction = totalReactionByTargetKey[item.targetRef.key];
        final recentReaction = recentReactionByTargetKey[item.targetRef.key];
        final commentSignal = commentSignalByTargetKey[item.targetRef.key];
        final voteSignal = item.isPoll ? voteSignalByPollId[item.id] : null;

        final breakdown = _buildFinalScoreBreakdown(
          createdAt: item.createdAt,
          now: now,
          totalHeat: totalReaction?.heat.value ?? 0,
          commentCount: commentSignal?.totalCount ?? 0,
          voteCount: voteSignal?.totalCount ?? 0,
          recentReactionHeat: recentReaction?.heat.value ?? 0,
          recentCommentCount: commentSignal?.recentCount ?? 0,
          recentVoteCount: voteSignal?.recentCount ?? 0,
        );

        buffer.writeln(
          '[final #${i + 1}] '
          'type=${_itemType(item)} '
          'id=${item.id} '
          'heat=${totalReaction?.heat.value ?? 0} '
          'comments=${commentSignal?.totalCount ?? 0} '
          'votes=${voteSignal?.totalCount ?? 0} '
          'recentHeat=${recentReaction?.heat.value ?? 0} '
          'recentComments=${commentSignal?.recentCount ?? 0} '
          'recentVotes=${voteSignal?.recentCount ?? 0} '
          'base=${breakdown.baseScore.toStringAsFixed(3)} '
          'velocity=${breakdown.velocityScore.toStringAsFixed(3)} '
          'freshness=${breakdown.freshnessMultiplier.toStringAsFixed(3)} '
          'score=${breakdown.totalScore.toStringAsFixed(3)}',
        );
      }

      _debugPrintBlock(buffer.toString());
      return true;
    }());
  }

  void _debugPrintLine(String message) {
    assert(() {
      debugPrint(message);
      return true;
    }());
  }

  void _debugPrintBlock(String message) {
    assert(() {
      final lines = message.split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) {
          continue;
        }
        debugPrint(line);
      }
      return true;
    }());
  }

  String _itemType(FeedItem item) {
    if (item.isPoll) {
      return 'poll';
    }
    if (item.news != null) {
      return 'news';
    }
    return 'post';
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

class _HotScoreBreakdown {
  final double baseScore;
  final double velocityScore;
  final double freshnessMultiplier;
  final double totalScore;

  const _HotScoreBreakdown({
    required this.baseScore,
    required this.velocityScore,
    required this.freshnessMultiplier,
    required this.totalScore,
  });
}
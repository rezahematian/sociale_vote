import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/features/home/application/feed_item.dart';

class GetForYouFeed {
  static const Duration _recentWindow = Duration(hours: 18);
  static const double _freshnessHalfLifeHours = 72.0;
  static const double _discoveryHalfLifeHours = 18.0;
  static const int _debugTopItems = 12;

  final PostRepository _postRepository;
  final NewsRepository _newsRepository;
  final PollRepository _pollRepository;
  final CommentRepository _commentRepository;
  final GetReactionSummary _getReactionSummary;
  final FollowScopeRepository _followScopeRepository;

  GetForYouFeed({
    required PostRepository postRepository,
    required NewsRepository newsRepository,
    required PollRepository pollRepository,
    required CommentRepository commentRepository,
    required GetReactionSummary getReactionSummary,
    required FollowScopeRepository followScopeRepository,
  })  : _postRepository = postRepository,
        _newsRepository = newsRepository,
        _pollRepository = pollRepository,
        _commentRepository = commentRepository,
        _getReactionSummary = getReactionSummary,
        _followScopeRepository = followScopeRepository;

  Future<List<FeedItem>> call({
    required String? userId,
    required GeoScope currentScope,
    int limit = 10,
  }) async {
    final now = DateTime.now();
    final since = now.subtract(_recentWindow);

    final followedScopes = await _loadFollowedScopesOrEmpty(userId);
    final candidateScopes = _resolveCandidateScopes(
      currentScope: currentScope,
      followedScopes: followedScopes,
    );

    final candidateLimitPerScope = _resolveCandidateLimitPerScope(
      requestedLimit: limit,
      scopeCount: candidateScopes.length,
    );

    _debugPrintLine(
      'ForYou call -> scope=$currentScope limit=$limit user=${userId ?? 'guest'} '
      'candidateScopes=${candidateScopes.length} candidateLimitPerScope=$candidateLimitPerScope',
    );

    final candidates = await _loadCandidates(
      candidateScopes: candidateScopes,
      candidateLimitPerScope: candidateLimitPerScope,
    );

    if (candidates.isEmpty) {
      _debugPrintLine('ForYou returned -> count=0');
      return const <FeedItem>[];
    }

    final targets = candidates.map((item) => item.targetRef).toList(growable: false);

    final reactionResults = await Future.wait<List<ReactionSummary>>([
      _getReactionSummary(
        targets,
        userId: userId,
      ),
      _getReactionSummary(
        targets,
        userId: userId,
        since: since,
      ),
    ]);

    final totalReactionByTargetKey = {
      for (final summary in reactionResults[0]) summary.target.key: summary,
    };

    final recentReactionByTargetKey = {
      for (final summary in reactionResults[1]) summary.target.key: summary,
    };

    Map<String, int> commentCountByTargetKey;
    try {
      final rawCounts = await _commentRepository.countCommentsForTargets(targets);
      commentCountByTargetKey = _normalizeBatchCommentCounts(
        targets: targets,
        rawCounts: rawCounts,
      );
    } catch (_) {
      commentCountByTargetKey = {
        for (final target in targets) target.key: 0,
      };
      _debugPrintLine('ForYou comment batch failed -> fallback zeros');
    }

    final scored = <FeedItem>[];

    for (final item in candidates) {
      final totalReaction = totalReactionByTargetKey[item.targetRef.key];
      final recentReaction = recentReactionByTargetKey[item.targetRef.key];

      final totalHeat = totalReaction?.heat.value ?? 0;
      final recentHeat = recentReaction?.heat.value ?? 0;
      final commentCount = commentCountByTargetKey[item.targetRef.key] ?? 0;
      final voteCount = item.isPoll ? (item.poll?.voteCount ?? item.voteCount) : 0;

      final breakdown = _buildForYouScoreBreakdown(
        item: item,
        currentScope: currentScope,
        followedScopes: followedScopes,
        now: now,
        totalHeat: totalHeat,
        recentHeat: recentHeat,
        commentCount: commentCount,
        voteCount: voteCount,
      );

      if (breakdown.totalScore <= 0) {
        continue;
      }

      scored.add(
        item.copyWith(
          reactionCount: totalReaction?.likeCount ?? 0,
          commentCount: commentCount,
          voteCount: voteCount,
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

    final returned = scored.take(limit).toList(growable: false);

    _debugLogFinalRanking(
      ranked: returned,
      currentScope: currentScope,
      followedScopes: followedScopes,
      totalReactionByTargetKey: totalReactionByTargetKey,
      recentReactionByTargetKey: recentReactionByTargetKey,
      commentCountByTargetKey: commentCountByTargetKey,
      now: now,
      limit: limit,
    );

    _debugPrintLine('ForYou returned -> count=${returned.length}');

    return returned;
  }

  Future<List<GeoScope>> _loadFollowedScopesOrEmpty(String? userId) async {
    if (userId == null || userId.trim().isEmpty) {
      return const <GeoScope>[];
    }

    try {
      final followed = await _followScopeRepository.getFollowedScopesForUser(userId);
      return followed.map((f) => f.scope).toList(growable: false);
    } catch (_) {
      return const <GeoScope>[];
    }
  }

  List<GeoScope> _resolveCandidateScopes({
    required GeoScope currentScope,
    required List<GeoScope> followedScopes,
  }) {
    final ordered = <GeoScope>[currentScope, ...followedScopes];
    final unique = <String, GeoScope>{};

    for (final scope in ordered) {
      unique.putIfAbsent(_scopeKey(scope), () => scope);
    }

    return unique.values.toList(growable: false);
  }

  String _scopeKey(GeoScope scope) {
    final level = _readScopeLevelName(scope) ?? 'unknown';
    final country = (scope.countryCode ?? '').trim().toLowerCase();
    final city = (scope.cityId ?? '').trim().toLowerCase();
    final lat = scope.centerLat?.toStringAsFixed(4) ?? '';
    final lng = scope.centerLng?.toStringAsFixed(4) ?? '';
    final radius = scope.radiusKm?.toStringAsFixed(2) ?? '';

    return '$level|$country|$city|$lat|$lng|$radius';
  }

  Future<List<FeedItem>> _loadCandidates({
    required List<GeoScope> candidateScopes,
    required int candidateLimitPerScope,
  }) async {
    final seenByTargetKey = <String, FeedItem>{};

    final batches = await Future.wait<_ScopeCandidateBatch>(
      candidateScopes.map(
        (scope) => _loadBatchForScope(
          scope: scope,
          candidateLimitPerScope: candidateLimitPerScope,
        ),
      ),
    );

    for (final batch in batches) {
      for (final post in batch.posts) {
        final item = FeedItem.post(
          id: post.id.value,
          targetRef: TargetRef.post(post.id.value),
          createdAt: post.createdAt,
          post: post,
        );
        seenByTargetKey.putIfAbsent(item.targetRef.key, () => item);
      }

      for (final poll in batch.polls) {
        final item = FeedItem.poll(
          id: poll.id.value,
          targetRef: TargetRef.poll(poll.id.value),
          createdAt: poll.rankingDate,
          poll: poll,
          voteCount: poll.voteCount,
        );
        seenByTargetKey.putIfAbsent(item.targetRef.key, () => item);
      }

      for (final news in batch.news) {
        final item = FeedItem.news(
          id: news.id.value,
          targetRef: TargetRef.news(news.id.value),
          createdAt: news.publishedAt,
          news: news,
        );
        seenByTargetKey.putIfAbsent(item.targetRef.key, () => item);
      }
    }

    final candidates = seenByTargetKey.values.toList(growable: false);

    _debugPrintLine(
      'ForYou candidates -> scopes=${candidateScopes.length} total=${candidates.length}',
    );

    return candidates;
  }

  Future<_ScopeCandidateBatch> _loadBatchForScope({
    required GeoScope scope,
    required int candidateLimitPerScope,
  }) async {
    final results = await Future.wait<dynamic>([
      _postRepository.getFeed(
        countryCode: scope.countryCode,
        cityId: scope.cityId,
        limit: candidateLimitPerScope,
        offset: 0,
      ),
      _pollRepository.getPolls(
        countryCode: scope.countryCode,
        cityId: scope.cityId,
        limit: candidateLimitPerScope,
        offset: 0,
      ),
      _newsRepository.getTrendingCandidates(
        countryCode: scope.countryCode,
        cityId: scope.cityId,
        limit: candidateLimitPerScope,
      ),
    ]);

    return _ScopeCandidateBatch(
      posts: (results[0] as List<dynamic>).cast<Post>(),
      polls: (results[1] as List<dynamic>).cast<Poll>(),
      news: (results[2] as List<dynamic>).cast<NewsItem>(),
    );
  }

  int _resolveCandidateLimitPerScope({
    required int requestedLimit,
    required int scopeCount,
  }) {
    if (scopeCount <= 1) {
      final warmed = requestedLimit * 3;
      if (warmed < 12) {
        return 12;
      }
      if (warmed > 24) {
        return 24;
      }
      return warmed;
    }

    final warmed = ((requestedLimit * 2) / scopeCount).ceil() + 2;
    if (warmed < 6) {
      return 6;
    }
    if (warmed > 10) {
      return 10;
    }
    return warmed;
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

  _ForYouScoreBreakdown _buildForYouScoreBreakdown({
    required FeedItem item,
    required GeoScope currentScope,
    required List<GeoScope> followedScopes,
    required DateTime now,
    required num totalHeat,
    required num recentHeat,
    required int commentCount,
    required int voteCount,
  }) {
    final ageHours = _safeAgeHours(
      createdAt: item.createdAt,
      now: now,
    );

    final currentAffinity = _scopeAffinityForItem(item, currentScope);
    final followedAffinity = followedScopes.fold<double>(
      0.0,
      (best, scope) => math.max(best, _scopeAffinityForItem(item, scope)),
    );

    final qualityScore = (_positiveValue(totalHeat) * 0.75) +
        (_scaleCount(commentCount) * 2.0) +
        (_scaleCount(voteCount) * 1.4) +
        ((item.isNews && item.news?.isBreaking == true) ? 0.8 : 0.0);

    final momentumScore = _positiveValue(recentHeat) * 1.25;

    final discoveryFreshness = _computeFreshnessMultiplier(
      createdAt: item.createdAt,
      now: now,
      halfLifeHours: _discoveryHalfLifeHours,
    );

    final discoveryBoost =
        discoveryFreshness * ((currentAffinity * 1.5) + (followedAffinity * 1.15));

    final personalSignal =
        (currentAffinity * 1.15) + (followedAffinity * 0.95);

    final geoMultiplier =
        0.85 + (currentAffinity * 0.35) + (followedAffinity * 0.25);

    final freshnessMultiplier = _computeFreshnessMultiplier(
      createdAt: item.createdAt,
      now: now,
      halfLifeHours: _freshnessHalfLifeHours,
    );

    final weakPenalty = _computeWeakContentPenalty(
      ageHours: ageHours,
      totalHeat: totalHeat,
      recentHeat: recentHeat,
      commentCount: commentCount,
      voteCount: voteCount,
      currentAffinity: currentAffinity,
      followedAffinity: followedAffinity,
    );

    final baseScore =
        qualityScore + momentumScore + discoveryBoost + personalSignal;

    var totalScore =
        (baseScore * geoMultiplier) * freshnessMultiplier * weakPenalty;

    if (!totalScore.isFinite || totalScore < 0.05) {
      totalScore = 0.0;
    }

    return _ForYouScoreBreakdown(
      baseScore: baseScore,
      qualityScore: qualityScore,
      momentumScore: momentumScore,
      personalSignal: personalSignal + discoveryBoost,
      geoMultiplier: geoMultiplier,
      freshnessMultiplier: freshnessMultiplier,
      weakPenalty: weakPenalty,
      totalScore: totalScore,
    );
  }

  double _computeWeakContentPenalty({
    required double ageHours,
    required num totalHeat,
    required num recentHeat,
    required int commentCount,
    required int voteCount,
    required double currentAffinity,
    required double followedAffinity,
  }) {
    final localAffinity = math.max(currentAffinity, followedAffinity);
    final hasPositiveSignal =
        totalHeat > 0 || recentHeat > 0 || commentCount > 0 || voteCount > 0;

    if (totalHeat < 0 && commentCount == 0 && voteCount == 0) {
      return 0.10;
    }

    if (!hasPositiveSignal) {
      if (ageHours <= 4 && localAffinity >= 0.90) {
        return 0.55;
      }
      if (ageHours <= 12 && localAffinity >= 0.70) {
        return 0.35;
      }
      return 0.0;
    }

    if (totalHeat <= 0 &&
        recentHeat <= 0 &&
        commentCount == 0 &&
        voteCount <= 1 &&
        ageHours > 24) {
      return 0.25;
    }

    if (totalHeat <= 0 &&
        recentHeat <= 0 &&
        commentCount <= 1 &&
        voteCount == 0) {
      return 0.50;
    }

    return 1.0;
  }

  double _scopeAffinityForItem(FeedItem item, GeoScope scope) {
    final level = _readScopeLevelName(scope);
    final scopeCountry = _normalizeGeoValue(scope.countryCode);
    final scopeCity = _normalizeGeoValue(scope.cityId);

    final itemCountry = _readItemCountryCode(item);
    final itemCity = _readItemCityId(item);
    final itemPoint = _readItemPoint(item);

    switch (level) {
      case 'city':
        if (scopeCity != null && itemCity == scopeCity) {
          return 1.15;
        }
        if (scopeCountry != null && itemCountry == scopeCountry) {
          return 0.65;
        }
        return itemCountry == null ? 0.25 : 0.0;

      case 'country':
        if (scopeCountry != null && itemCountry == scopeCountry) {
          return itemCity != null ? 1.00 : 0.85;
        }
        return itemCountry == null ? 0.15 : 0.0;

      case 'area':
        final scopePoint = _readScopePoint(scope);
        final radiusKm = scope.radiusKm;

        if (scopePoint != null &&
            radiusKm != null &&
            radiusKm > 0 &&
            itemPoint != null) {
          final distanceKm = _distanceKm(
            scopePoint.$1,
            scopePoint.$2,
            itemPoint.$1,
            itemPoint.$2,
          );

          if (distanceKm <= radiusKm) {
            final ratio = 1 - (distanceKm / radiusKm);
            return 0.75 + (ratio * 0.50);
          }
        }

        if (scopeCity != null && itemCity == scopeCity) {
          return 1.00;
        }
        if (scopeCountry != null && itemCountry == scopeCountry) {
          return 0.60;
        }
        return 0.0;

      case 'world':
      default:
        if (itemCity != null) {
          return 0.75;
        }
        if (itemCountry != null) {
          return 0.65;
        }
        return 0.55;
    }
  }

  String _readScopeLevelName(GeoScope scope) {
    final raw = scope.level.toString().trim();
    if (raw.isEmpty) {
      return 'world';
    }

    final normalized = raw.split('.').last.trim().toLowerCase();
    return normalized.isEmpty ? 'world' : normalized;
  }

  String? _readItemCountryCode(FeedItem item) {
    if (item.post != null) {
      return _normalizeGeoValue(
        item.post!.contentLocation?.countryCode ?? item.post!.countryCode,
      );
    }

    if (item.poll != null) {
      return _normalizeGeoValue(
        item.poll!.contentLocation?.countryCode ?? item.poll!.countryCode,
      );
    }

    if (item.news != null) {
      return _normalizeGeoValue(
        item.news!.contentLocation?.countryCode ?? item.news!.countryCode,
      );
    }

    return null;
  }

  String? _readItemCityId(FeedItem item) {
    if (item.post != null) {
      return _normalizeGeoValue(
        item.post!.contentLocation?.cityId ?? item.post!.cityId,
      );
    }

    if (item.poll != null) {
      return _normalizeGeoValue(
        item.poll!.contentLocation?.cityId ?? item.poll!.cityId,
      );
    }

    if (item.news != null) {
      return _normalizeGeoValue(
        item.news!.contentLocation?.cityId ?? item.news!.cityId,
      );
    }

    return null;
  }

  (double, double)? _readItemPoint(FeedItem item) {
    final location =
        item.post?.contentLocation ?? item.poll?.contentLocation ?? item.news?.contentLocation;

    if (location == null) {
      return null;
    }

    if (_isValidLatLng(location.latitude, location.longitude)) {
      return (location.latitude!, location.longitude!);
    }

    if (_isValidLatLng(location.centerLat, location.centerLng)) {
      return (location.centerLat!, location.centerLng!);
    }

    return null;
  }

  (double, double)? _readScopePoint(GeoScope scope) {
    if (_isValidLatLng(scope.centerLat, scope.centerLng)) {
      return (scope.centerLat!, scope.centerLng!);
    }
    return null;
  }

  String? _normalizeGeoValue(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  bool _isValidLatLng(double? lat, double? lng) {
    if (lat == null || lng == null) {
      return false;
    }
    if (!lat.isFinite || !lng.isFinite) {
      return false;
    }
    if (lat < -90 || lat > 90) {
      return false;
    }
    if (lng < -180 || lng > 180) {
      return false;
    }
    return true;
  }

  double _distanceKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(endLat - startLat);
    final dLng = _degreesToRadians(endLng - startLng);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_degreesToRadians(startLat)) *
            math.cos(_degreesToRadians(endLat)) *
            math.pow(math.sin(dLng / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  double _positiveValue(num value) {
    if (value <= 0) {
      return 0.0;
    }
    return value.toDouble();
  }

  double _scaleCount(int value) {
    if (value <= 0) {
      return 0.0;
    }
    return math.sqrt(value.toDouble());
  }

  double _safeAgeHours({
    required DateTime createdAt,
    required DateTime now,
  }) {
    final effectiveNow = now.isBefore(createdAt) ? createdAt : now;
    return effectiveNow.difference(createdAt).inMinutes / 60.0;
  }

  double _computeFreshnessMultiplier({
    required DateTime createdAt,
    required DateTime now,
    required double halfLifeHours,
  }) {
    final ageHours = _safeAgeHours(
      createdAt: createdAt,
      now: now,
    );

    if (ageHours <= 0) {
      return 1.0;
    }

    const ln2 = 0.6931471805599453;
    final decay = -ln2 * (ageHours / halfLifeHours);

    return math.exp(decay);
  }

  void _debugLogFinalRanking({
    required List<FeedItem> ranked,
    required GeoScope currentScope,
    required List<GeoScope> followedScopes,
    required Map<String, ReactionSummary> totalReactionByTargetKey,
    required Map<String, ReactionSummary> recentReactionByTargetKey,
    required Map<String, int> commentCountByTargetKey,
    required DateTime now,
    required int limit,
  }) {
    assert(() {
      final buffer = StringBuffer();
      final topCount = math.min(_debugTopItems, ranked.length);

      buffer.writeln(
        'ForYou final -> returned=${ranked.length} requestedLimit=$limit topLogged=$topCount',
      );

      for (var i = 0; i < topCount; i++) {
        final item = ranked[i];
        final totalReaction = totalReactionByTargetKey[item.targetRef.key];
        final recentReaction = recentReactionByTargetKey[item.targetRef.key];
        final commentCount = commentCountByTargetKey[item.targetRef.key] ?? 0;
        final voteCount = item.isPoll ? item.voteCount : 0;

        final breakdown = _buildForYouScoreBreakdown(
          item: item,
          currentScope: currentScope,
          followedScopes: followedScopes,
          now: now,
          totalHeat: totalReaction?.heat.value ?? 0,
          recentHeat: recentReaction?.heat.value ?? 0,
          commentCount: commentCount,
          voteCount: voteCount,
        );

        buffer.writeln(
          '[for_you #${i + 1}] '
          'type=${_itemType(item)} '
          'id=${item.id} '
          'likes=${totalReaction?.likeCount ?? 0} '
          'heat=${totalReaction?.heat.value ?? 0} '
          'recentHeat=${recentReaction?.heat.value ?? 0} '
          'comments=$commentCount '
          'votes=$voteCount '
          'base=${breakdown.baseScore.toStringAsFixed(3)} '
          'quality=${breakdown.qualityScore.toStringAsFixed(3)} '
          'momentum=${breakdown.momentumScore.toStringAsFixed(3)} '
          'personal=${breakdown.personalSignal.toStringAsFixed(3)} '
          'geo=${breakdown.geoMultiplier.toStringAsFixed(3)} '
          'freshness=${breakdown.freshnessMultiplier.toStringAsFixed(3)} '
          'weak=${breakdown.weakPenalty.toStringAsFixed(3)} '
          'score=${breakdown.totalScore.toStringAsFixed(3)}',
        );
      }

      _debugPrintBlock(buffer.toString());
      return true;
    }());
  }

  String _itemType(FeedItem item) {
    if (item.isPoll) {
      return 'poll';
    }
    if (item.isNews) {
      return 'news';
    }
    return 'post';
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
}

class _ScopeCandidateBatch {
  final List<Post> posts;
  final List<Poll> polls;
  final List<NewsItem> news;

  const _ScopeCandidateBatch({
    required this.posts,
    required this.polls,
    required this.news,
  });
}

class _ForYouScoreBreakdown {
  final double baseScore;
  final double qualityScore;
  final double momentumScore;
  final double personalSignal;
  final double geoMultiplier;
  final double freshnessMultiplier;
  final double weakPenalty;
  final double totalScore;

  const _ForYouScoreBreakdown({
    required this.baseScore,
    required this.qualityScore,
    required this.momentumScore,
    required this.personalSignal,
    required this.geoMultiplier,
    required this.freshnessMultiplier,
    required this.weakPenalty,
    required this.totalScore,
  });
}
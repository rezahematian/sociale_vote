import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';

enum FeedItemType {
  poll,
  news,
  post,
}

class FeedItem {
  final String id;
  final FeedItemType type;
  final TargetRef targetRef;
  final DateTime createdAt;

  /// Dati base per ranking iniziale Fase 2
  final int reactionCount;
  final int commentCount;
  final double rankingScore;

  /// Payload tipizzato: solo uno dei tre deve essere valorizzato.
  final Poll? poll;
  final NewsItem? news;
  final Post? post;

  const FeedItem._({
    required this.id,
    required this.type,
    required this.targetRef,
    required this.createdAt,
    required this.reactionCount,
    required this.commentCount,
    required this.rankingScore,
    this.poll,
    this.news,
    this.post,
  });

  factory FeedItem.poll({
    required String id,
    required TargetRef targetRef,
    required DateTime createdAt,
    required Poll poll,
    int reactionCount = 0,
    int commentCount = 0,
    double rankingScore = 0,
  }) {
    return FeedItem._(
      id: id,
      type: FeedItemType.poll,
      targetRef: targetRef,
      createdAt: createdAt,
      reactionCount: reactionCount,
      commentCount: commentCount,
      rankingScore: rankingScore,
      poll: poll,
    );
  }

  factory FeedItem.news({
    required String id,
    required TargetRef targetRef,
    required DateTime createdAt,
    required NewsItem news,
    int reactionCount = 0,
    int commentCount = 0,
    double rankingScore = 0,
  }) {
    return FeedItem._(
      id: id,
      type: FeedItemType.news,
      targetRef: targetRef,
      createdAt: createdAt,
      reactionCount: reactionCount,
      commentCount: commentCount,
      rankingScore: rankingScore,
      news: news,
    );
  }

  factory FeedItem.post({
    required String id,
    required TargetRef targetRef,
    required DateTime createdAt,
    required Post post,
    int reactionCount = 0,
    int commentCount = 0,
    double rankingScore = 0,
  }) {
    return FeedItem._(
      id: id,
      type: FeedItemType.post,
      targetRef: targetRef,
      createdAt: createdAt,
      reactionCount: reactionCount,
      commentCount: commentCount,
      rankingScore: rankingScore,
      post: post,
    );
  }

  bool get isPoll => type == FeedItemType.poll;
  bool get isNews => type == FeedItemType.news;
  bool get isPost => type == FeedItemType.post;

  FeedItem copyWith({
    int? reactionCount,
    int? commentCount,
    double? rankingScore,
  }) {
    return FeedItem._(
      id: id,
      type: type,
      targetRef: targetRef,
      createdAt: createdAt,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      rankingScore: rankingScore ?? this.rankingScore,
      poll: poll,
      news: news,
      post: post,
    );
  }
}
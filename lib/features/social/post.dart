class Post {
  final String id;
  final String userId;
  final String content;
  final String? pollId;
  final String? newsId;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.content,
    this.pollId,
    this.newsId,
    required this.createdAt,
  });
}

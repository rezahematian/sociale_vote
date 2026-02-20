class Comment {
  final String id;
  final String pollId;
  final String userId;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });
}

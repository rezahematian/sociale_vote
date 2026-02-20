class CommentDTO {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  const CommentDTO({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory CommentDTO.fromJson(Map<String, dynamic> json) {
    return CommentDTO(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

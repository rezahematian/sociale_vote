class PostDTO {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  const PostDTO({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory PostDTO.fromJson(Map<String, dynamic> json) {
    return PostDTO(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class VideoDTO {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final String videoUrl;
  final DateTime publishedAt;

  const VideoDTO({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.publishedAt,
  });

  factory VideoDTO.fromJson(Map<String, dynamic> json) {
    return VideoDTO(
      id: json['id'],
      creatorId: json['creator_id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      publishedAt: DateTime.parse(json['published_at']),
    );
  }
}

class VideoItem {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String videoUrl;
  final String? pollId;
  final String? newsId;
  final DateTime publishedAt;

  const VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.videoUrl,
    this.pollId,
    this.newsId,
    required this.publishedAt,
  });
}

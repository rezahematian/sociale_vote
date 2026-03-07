import '../../domain/user/user_identity.dart';
import 'video_item.dart';
import 'video_service.dart';

class VideoController {
  final VideoService videoService;

  VideoController(this.videoService);

  List<VideoItem> loadVideos() {
    return videoService.getAllVideos();
  }

  void createVideo({
    required UserIdentity creator,
    required String title,
    required String description,
    required String videoUrl,
    String? pollId,
    String? newsId,
  }) {
    if (!creator.isVerified) {
      throw Exception('Creator not verified');
    }

    if (title.trim().isEmpty || videoUrl.trim().isEmpty) {
      throw Exception('Invalid video data');
    }

    final video = VideoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      creatorId: creator.userId,
      videoUrl: videoUrl,
      pollId: pollId,
      newsId: newsId,
      publishedAt: DateTime.now(),
    );

    videoService.addVideo(video);
  }
}

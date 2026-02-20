import 'video_item.dart';

class VideoService {
  final List<VideoItem> _videos = [];

  List<VideoItem> getAllVideos() {
    return List.unmodifiable(_videos);
  }

  void addVideo(VideoItem video) {
    _videos.add(video);
  }
}

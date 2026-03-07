import 'package:flutter/material.dart';
import 'video_item.dart';

class VideoCard extends StatelessWidget {
  final VideoItem video;

  const VideoCard({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.play_circle),
        title: Text(video.title),
        subtitle: Text(video.description),
      ),
    );
  }
}

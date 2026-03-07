import 'package:flutter/material.dart';
import 'video_controller.dart';
import 'video_card.dart';
import 'create_video_screen.dart';
import '../../domain/user/user_identity.dart';

class VideoFeedScreen extends StatefulWidget {
  final VideoController controller;
  final UserIdentity currentUser;

  const VideoFeedScreen({
    super.key,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final videos = widget.controller.loadVideos();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Civic Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateVideoScreen(
                    onCreate: (title, desc, url) {
                      widget.controller.createVideo(
                        creator: widget.currentUser,
                        title: title,
                        description: desc,
                        videoUrl: url,
                      );
                    },
                  ),
                ),
              );
              _refresh();
            },
          ),
        ],
      ),
      body: ListView(
        children: videos.map((v) => VideoCard(video: v)).toList(),
      ),
    );
  }
}

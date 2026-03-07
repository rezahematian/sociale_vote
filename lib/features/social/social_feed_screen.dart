import 'package:flutter/material.dart';
import 'post_controller.dart';
import 'post_card.dart';
import 'create_post_screen.dart';
import '../../domain/user/user_identity.dart';

class SocialFeedScreen extends StatefulWidget {
  final PostController controller;
  final UserIdentity currentUser;

  const SocialFeedScreen({
    super.key,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.controller.loadPosts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePostScreen(
                    onCreate: (content) {
                      widget.controller.createPost(
                        user: widget.currentUser,
                        content: content,
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
        children: posts.map((p) => PostCard(post: p)).toList(),
      ),
    );
  }
}

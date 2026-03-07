import 'package:flutter/material.dart';
import 'post.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.forum),
        title: Text(post.content),
        subtitle: Text(post.createdAt.toIso8601String()),
      ),
    );
  }
}

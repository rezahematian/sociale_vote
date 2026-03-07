import 'package:flutter/material.dart';
import '../../domain/user/user_identity.dart';
import 'comment.dart';
import 'comment_card.dart';
import 'comment_controller.dart';

class CommentsScreen extends StatefulWidget {
  /// ID di riferimento (alias compatibile)
  final String pollId;

  final UserIdentity currentUser;
  final CommentController controller;

  const CommentsScreen({
    super.key,

    /// Alias accettato per compatibilità
    String? referenceId,

    /// Nome canonico interno
    String? pollId,

    required this.currentUser,
    required this.controller,
  }) : pollId = pollId ?? referenceId ?? '';

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _textController = TextEditingController();

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Comment> comments =
        widget.controller.loadComments(widget.pollId);

    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: comments
                  .map((c) => CommentCard(comment: c))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    widget.controller.addComment(
                      user: widget.currentUser,
                      pollId: widget.pollId,
                      text: _textController.text,
                    );
                    _textController.clear();
                    _refresh();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

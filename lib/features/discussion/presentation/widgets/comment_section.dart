import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';

/// Sezione commenti generica basata su [DiscussionController].
///
/// Riutilizzabile per:
/// - NewsDetailPage
/// - PollDetailPage
/// - PostDetailPage
/// - VideoDetailPage, ecc.
class CommentSection extends StatefulWidget {
  final String userId;

  const CommentSection({
    super.key,
    required this.userId,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _inputController = TextEditingController();
  Comment? _replyParent;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<DiscussionController>();

    final isLoading = controller.isLoading;
    final isSubmitting = controller.isSubmitting;
    final hasError = controller.errorMessage != null;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Comments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Messaggio di errore
            if (hasError) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.errorMessage ??
                            'An error occurred while loading comments.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        controller.clearError();
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Lista commenti
            if (!controller.hasComments && !isLoading) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No comments yet. Be the first to comment.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ] else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final root in controller.rootComments) ...[
                    _CommentTile(
                      comment: root,
                      isReply: false,
                      onReplyTap: () => _startReply(root),
                      canDelete: root.userId == widget.userId,
                      onDeleteTap: root.userId == widget.userId
                          ? () => controller.deleteComment(root)
                          : null,
                    ),
                    // Replies (depth 1)
                    for (final reply in controller.repliesFor(root.id)) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: _CommentTile(
                          comment: reply,
                          isReply: true,
                          onReplyTap: () => _startReply(root),
                          canDelete: reply.userId == widget.userId,
                          onDeleteTap: reply.userId == widget.userId
                              ? () => controller.deleteComment(reply)
                              : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 24),

            // Stato reply (banner sopra l'input)
            if (_replyParent != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.reply,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Replying to: ${_shorten(_replyParent!.content)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Input nuovo commento / reply
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: _replyParent == null
                          ? 'Add a comment...'
                          : 'Write a reply...',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    enabled: !isSubmitting,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.send,
                          color: theme.colorScheme.primary,
                        ),
                  onPressed: isSubmitting ? null : () => _submit(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startReply(Comment parent) {
    setState(() {
      _replyParent = parent;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyParent = null;
    });
  }

  Future<void> _submit(BuildContext context) async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final controller = context.read<DiscussionController>();

    if (_replyParent == null) {
      await controller.addRootComment(
        userId: widget.userId,
        content: text,
      );
    } else {
      await controller.replyToComment(
        userId: widget.userId,
        parent: _replyParent!,
        content: text,
      );
    }

    // Se non c'è errore, pulisco input + stato reply
    if (controller.errorMessage == null) {
      _inputController.clear();
      if (_replyParent != null) {
        setState(() {
          _replyParent = null;
        });
      }
    }
  }

  String _shorten(String text, {int max = 40}) {
    final trimmed = text.trim();
    if (trimmed.length <= max) return trimmed;
    return '${trimmed.substring(0, max)}…';
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final bool isReply;
  final VoidCallback onReplyTap;
  final bool canDelete;
  final VoidCallback? onDeleteTap;

  const _CommentTile({
    required this.comment,
    required this.isReply,
    required this.onReplyTap,
    required this.canDelete,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isReply ? Icons.subdirectory_arrow_right : Icons.person_outline,
              size: 16,
              color: theme.hintColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                // Per ora usiamo userId come nome
                comment.userId,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _formatTime(comment.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: 10,
              ),
            ),
            if (canDelete && onDeleteTap != null) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDeleteTap!();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: theme.hintColor,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          comment.content,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onReplyTap,
          child: Text(
            'Reply',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
import 'package:flutter/material.dart';
import 'comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 10),
            _buildBody(theme),
            const SizedBox(height: 12),
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.blueGrey.shade100,
          child: Icon(
            Icons.person,
            size: 16,
            color: Colors.blueGrey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Cittadino',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade700,
          ),
        ),
        const Spacer(),
        Text(
          _formatDate(comment.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ================= BODY =================

  Widget _buildBody(ThemeData theme) {
    return Text(
      comment.text,
      style: theme.textTheme.bodyMedium?.copyWith(
        height: 1.45,
        color: Colors.grey.shade800,
      ),
    );
  }

  // ================= FOOTER =================

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.forum_outlined,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          'Discussione pubblica',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          'Rispondi',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade700,
          ),
        ),
      ],
    );
  }

  // ================= HELPERS =================

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'ora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min fa';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h fa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

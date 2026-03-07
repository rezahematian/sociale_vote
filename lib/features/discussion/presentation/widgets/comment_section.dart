import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

/// Sezione commenti generica basata su [DiscussionController].
///
/// Riutilizzabile per:
/// - NewsDetailPage
/// - PollDetailPage
/// - PostDetailPage
/// - VideoDetailPage, ecc.
class CommentSection extends StatefulWidget {
  /// ATTENZIONE:
  /// Questo userId era usato in passato come "utente corrente".
  /// Ora l'utente corrente viene letto da AppDI.instance.currentUserId
  /// dentro al widget, quindi questo parametro è di fatto ignorato
  /// per sicurezza e coerenza con l'AuthGuard.
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
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<DiscussionController>();

    final isLoading = controller.isLoading;
    final isSubmitting = controller.isSubmitting;
    final hasError = controller.errorMessage != null;
    final sortOrder = controller.sortOrder;
    final hasMore = controller.hasMoreRootComments;

    // Utente correntemente loggato (può essere null = guest)
    final String? currentUserId = AppDI.instance.currentUserId;

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
                  l10n.commentSection_title,
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

            const SizedBox(height: 8),

            // Toggle ordinamento (Oldest / Newest)
            Row(
              children: [
                Text(
                  l10n.commentSection_sortLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(
                    l10n.commentSection_sortOldest,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: sortOrder == CommentSortOrder.oldestFirst
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  selected: sortOrder == CommentSortOrder.oldestFirst,
                  onSelected: (selected) {
                    if (!selected) return;
                    controller.setSortOrder(CommentSortOrder.oldestFirst);
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: Text(
                    l10n.commentSection_sortNewest,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: sortOrder == CommentSortOrder.newestFirst
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  selected: sortOrder == CommentSortOrder.newestFirst,
                  onSelected: (selected) {
                    if (!selected) return;
                    controller.setSortOrder(CommentSortOrder.newestFirst);
                  },
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
                            l10n.commentSection_errorGeneric,
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
                  l10n.commentSection_empty,
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
                      isCurrentUser:
                          currentUserId != null && root.userId == currentUserId,
                      onReplyTap: () => _startReply(root),
                      canDelete:
                          currentUserId != null && root.userId == currentUserId,
                      onDeleteTap: (currentUserId != null &&
                              root.userId == currentUserId)
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
                          isCurrentUser: currentUserId != null &&
                              reply.userId == currentUserId,
                          onReplyTap: () => _startReply(root),
                          canDelete: currentUserId != null &&
                              reply.userId == currentUserId,
                          onDeleteTap: (currentUserId != null &&
                                  reply.userId == currentUserId)
                              ? () => controller.deleteComment(reply)
                              : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],

                  // Bottone "Load more" per root comment aggiuntivi
                  if (hasMore) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          controller.loadMoreRootComments();
                        },
                        icon: const Icon(Icons.expand_more),
                        label: Text(l10n.commentSection_loadMore),
                      ),
                    ),
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
                        l10n.commentSection_replyingTo(
                          _shorten(_replyParent!.content),
                        ),
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
                        l10n.commentSection_cancelReply,
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
                          ? l10n.commentSection_inputHintRoot
                          : l10n.commentSection_inputHintReply,
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

    // 1️⃣ Verifica permessi tramite AuthGuard (guest → login / register sheet)
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.comment,
    );
    if (!allowed) {
      return;
    }

    // 2️⃣ Dopo il guard, ci aspettiamo un utente loggato.
    final String? userId = AppDI.instance.currentUserId;
    if (userId == null) {
      // Se succede, significa che la policy o il guard sono cambiati
      // in modo inconsistente. Per sicurezza, non procediamo.
      return;
    }

    final controller = context.read<DiscussionController>();

    if (_replyParent == null) {
      await controller.addRootComment(
        userId: userId,
        content: text,
      );
    } else {
      await controller.replyToComment(
        userId: userId,
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
      // Chiudo la tastiera dopo submit riuscito
      FocusScope.of(context).unfocus();
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
  final bool isCurrentUser;
  final VoidCallback onReplyTap;
  final bool canDelete;
  final VoidCallback? onDeleteTap;

  const _CommentTile({
    required this.comment,
    required this.isReply,
    required this.isCurrentUser,
    required this.onReplyTap,
    required this.canDelete,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: isCurrentUser
          ? BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isReply
                    ? Icons.subdirectory_arrow_right
                    : Icons.person_outline,
                size: 16,
                color: theme.hintColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
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
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.commentSection_youBadge,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
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
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(l10n.commentSection_deleteAction),
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
              l10n.commentSection_replyAction,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
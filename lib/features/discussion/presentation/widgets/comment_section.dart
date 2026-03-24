import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
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
  final Map<String, String> _authorLabels = <String, String>{};
  final Set<String> _loadingAuthorIds = <String>{};

  Comment? _replyParent;
  Comment? _editingComment;

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

    _ensureAuthorLabelsLoaded(controller.comments);

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
                      authorLabel: _authorLabelFor(root),
                      isReply: false,
                      isCurrentUser:
                          currentUserId != null && root.userId == currentUserId,
                      onReplyTap: () => _startReply(root),
                      canEdit:
                          currentUserId != null && root.userId == currentUserId,
                      onEditTap: (currentUserId != null &&
                              root.userId == currentUserId)
                          ? () => _startEdit(root)
                          : null,
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
                          authorLabel: _authorLabelFor(reply),
                          isReply: true,
                          isCurrentUser: currentUserId != null &&
                              reply.userId == currentUserId,
                          onReplyTap: () => _startReply(root),
                          canEdit: currentUserId != null &&
                              reply.userId == currentUserId,
                          onEditTap: (currentUserId != null &&
                                  reply.userId == currentUserId)
                              ? () => _startEdit(reply)
                              : null,
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

            // Stato edit (banner sopra l'input)
            if (_editingComment != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Stai modificando: ${_shorten(_editingComment!.content)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _cancelEdit,
                      child: Text(
                        'Annulla',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Stato reply (banner sopra l'input)
            if (_replyParent != null && _editingComment == null) ...[
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

            // Input nuovo commento / reply / edit
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
                      hintText: _editingComment != null
                          ? 'Modifica il tuo commento'
                          : _replyParent == null
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
                          _editingComment != null ? Icons.check : Icons.send,
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

  void _ensureAuthorLabelsLoaded(List<Comment> comments) {
    final authorIds = comments
        .map((comment) => comment.userId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    for (final authorId in authorIds) {
      if (_authorLabels.containsKey(authorId) ||
          _loadingAuthorIds.contains(authorId)) {
        continue;
      }

      _loadingAuthorIds.add(authorId);
      unawaited(_loadAuthorLabel(authorId));
    }
  }

  Future<void> _loadAuthorLabel(String userId) async {
    try {
      final profile =
          await AppDI.instance.userProfileRepository.getUserProfile(userId);

      if (!mounted) {
        return;
      }

      setState(() {
        _authorLabels[userId] = _buildAuthorLabel(profile, userId);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _authorLabels[userId] = _shortUserId(userId);
      });
    } finally {
      _loadingAuthorIds.remove(userId);
    }
  }

  String _authorLabelFor(Comment comment) {
    final userId = comment.userId.trim();
    if (userId.isEmpty) {
      return 'Utente';
    }

    return _authorLabels[userId] ?? _shortUserId(userId);
  }

  String _buildAuthorLabel(UserProfile? profile, String fallbackUserId) {
    final displayName = profile?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = profile?.username?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }

    return _shortUserId(fallbackUserId);
  }

  String _shortUserId(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 'Utente';
    }
    if (normalized.length <= 8) {
      return normalized;
    }
    return normalized.substring(0, 8);
  }

  void _startReply(Comment parent) {
    setState(() {
      _editingComment = null;
      _replyParent = parent;
      _inputController.clear();
    });
  }

  void _cancelReply() {
    setState(() {
      _replyParent = null;
    });
  }

  void _startEdit(Comment comment) {
    setState(() {
      _replyParent = null;
      _editingComment = comment;
      _inputController.text = comment.content;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingComment = null;
      _inputController.clear();
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

    if (_editingComment != null) {
      await controller.editComment(
        comment: _editingComment!,
        content: text,
      );
    } else if (_replyParent == null) {
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

    // Se non c'è errore, pulisco input + stato reply/edit
    if (controller.errorMessage == null) {
      _inputController.clear();
      if (_replyParent != null || _editingComment != null) {
        setState(() {
          _replyParent = null;
          _editingComment = null;
        });
      }
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
  final String authorLabel;
  final bool isReply;
  final bool isCurrentUser;
  final VoidCallback onReplyTap;
  final bool canEdit;
  final VoidCallback? onEditTap;
  final bool canDelete;
  final VoidCallback? onDeleteTap;

  const _CommentTile({
    required this.comment,
    required this.authorLabel,
    required this.isReply,
    required this.isCurrentUser,
    required this.onReplyTap,
    required this.canEdit,
    this.onEditTap,
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
                        authorLabel,
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
              if ((canEdit && onEditTap != null) ||
                  (canDelete && onDeleteTap != null)) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEditTap?.call();
                    }
                    if (value == 'delete') {
                      onDeleteTap?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (canEdit && onEditTap != null)
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Modifica'),
                      ),
                    if (canDelete && onDeleteTap != null)
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
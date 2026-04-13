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
  final TextEditingController _primaryInputController =
      TextEditingController();
  final TextEditingController _replyInputController = TextEditingController();

  final Map<String, String> _authorLabels = <String, String>{};
  final Set<String> _loadingAuthorIds = <String>{};
  final Set<String> _expandedReplyThreads = <String>{};

  Comment? _replyParent;
  Comment? _replyTarget;
  Comment? _editingComment;

  bool _commentsExpanded = false;

  @override
  void dispose() {
    _primaryInputController.dispose();
    _replyInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<DiscussionController>();

    final isLoading = controller.isLoading;
    final isSubmitting = controller.isSubmitting;
    final hasError = controller.errorMessage != null;
    final sortOrder = controller.sortOrder;
    final hasMore = controller.hasMoreRootComments;

    _ensureAuthorLabelsLoaded(controller.comments);

    final String? currentUserId = AppDI.instance.currentUserId;
    final int totalComments = controller.comments.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(isDark ? 0.38 : 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.22 : 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.commentSection_title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(
                      isDark ? 0.18 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(
                        isDark ? 0.32 : 0.18,
                      ),
                    ),
                  ),
                  child: Text(
                    '$totalComments',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Composer principale SEMPRE visibile per nuovo commento / edit
            _buildPrimaryComposer(
              context,
              isSubmitting: isSubmitting,
            ),

            if (hasError) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.errorMessage ??
                            l10n.commentSection_errorGeneric,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: controller.clearError,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _commentsExpanded = !_commentsExpanded;
                  });
                },
                icon: Icon(
                  _commentsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                label: Text(
                  _commentsExpanded
                      ? _localizedText(
                          l10n,
                          it: 'Chiudi commenti',
                          en: 'Hide comments',
                        )
                      : _localizedText(
                          l10n,
                          it: 'Visualizza commenti',
                          en: 'View comments',
                        ),
                ),
              ),
            ),

            if (_commentsExpanded) ...[
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    l10n.commentSection_sortLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(
                        isDark ? 0.62 : 0.52,
                      ),
                    ),
                  ),
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
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: colorScheme.outline.withOpacity(isDark ? 0.18 : 0.08),
              ),
              const SizedBox(height: 14),
              if (!controller.hasComments && !isLoading) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(isDark ? 0.30 : 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(
                        isDark ? 0.22 : 0.12,
                      ),
                    ),
                  ),
                  child: Text(
                    l10n.commentSection_empty,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(
                        isDark ? 0.60 : 0.52,
                      ),
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
                            currentUserId != null &&
                            root.userId == currentUserId,
                        onReplyTap: () => _startReply(
                          parentForSubmit: root,
                          anchorComment: root,
                        ),
                        canEdit:
                            currentUserId != null &&
                            root.userId == currentUserId,
                        onEditTap: (currentUserId != null &&
                                root.userId == currentUserId)
                            ? () => _startEdit(root)
                            : null,
                        canDelete:
                            currentUserId != null &&
                            root.userId == currentUserId,
                        onDeleteTap: (currentUserId != null &&
                                root.userId == currentUserId)
                            ? () => controller.deleteComment(root)
                            : null,
                      ),
                      if (_isInlineReplyOpenFor(root)) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: _buildInlineReplyComposer(
                            context,
                            isSubmitting: isSubmitting,
                            replyingToLabel: _authorLabelFor(_replyTarget!),
                          ),
                        ),
                      ],
                      Builder(
                        builder: (_) {
                          final replies = controller.repliesFor(root.id);
                          final repliesCount = replies.length;
                          final repliesExpanded =
                              _expandedReplyThreads.contains(root.id);

                          if (repliesCount == 0) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 2,
                              bottom: 6,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    _toggleReplyThread(root.id);
                                  },
                                  icon: Icon(
                                    repliesExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 18,
                                  ),
                                  label: Text(
                                    repliesExpanded
                                        ? _localizedText(
                                            l10n,
                                            it: 'Nascondi risposte',
                                            en: 'Hide replies',
                                          )
                                        : _viewRepliesLabel(
                                            l10n,
                                            repliesCount,
                                          ),
                                  ),
                                ),
                                if (repliesExpanded) ...[
                                  for (final reply in replies) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 18),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 2,
                                            height: 72,
                                            margin: const EdgeInsets.only(
                                              top: 8,
                                              right: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary
                                                  .withOpacity(0.18),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _CommentTile(
                                                  comment: reply,
                                                  authorLabel:
                                                      _authorLabelFor(reply),
                                                  isReply: true,
                                                  isCurrentUser:
                                                      currentUserId != null &&
                                                          reply.userId ==
                                                              currentUserId,
                                                  onReplyTap: () => _startReply(
                                                    parentForSubmit: root,
                                                    anchorComment: reply,
                                                  ),
                                                  canEdit:
                                                      currentUserId != null &&
                                                          reply.userId ==
                                                              currentUserId,
                                                  onEditTap: (currentUserId !=
                                                              null &&
                                                          reply.userId ==
                                                              currentUserId)
                                                      ? () =>
                                                          _startEdit(reply)
                                                      : null,
                                                  canDelete:
                                                      currentUserId != null &&
                                                          reply.userId ==
                                                              currentUserId,
                                                  onDeleteTap: (currentUserId !=
                                                              null &&
                                                          reply.userId ==
                                                              currentUserId)
                                                      ? () => controller
                                                          .deleteComment(reply)
                                                      : null,
                                                ),
                                                if (_isInlineReplyOpenFor(
                                                  reply,
                                                )) ...[
                                                  const SizedBox(height: 8),
                                                  _buildInlineReplyComposer(
                                                    context,
                                                    isSubmitting: isSubmitting,
                                                    replyingToLabel:
                                                        _authorLabelFor(
                                                      _replyTarget!,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (hasMore) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: controller.loadMoreRootComments,
                          icon: const Icon(Icons.expand_more),
                          label: Text(l10n.commentSection_loadMore),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryComposer(
    BuildContext context, {
    required bool isSubmitting,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_editingComment != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: colorScheme.secondary.withOpacity(0.14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _localizedText(
                      l10n,
                      it:
                          'Stai modificando: ${_shorten(_editingComment!.content)}',
                      en:
                          'Editing: ${_shorten(_editingComment!.content)}',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _cancelEdit,
                  child: Text(
                    _localizedText(
                      l10n,
                      it: 'Annulla',
                      en: 'Cancel',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _primaryInputController,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: _commentInputDecoration(
                  context,
                  hintText: _editingComment != null
                      ? _localizedText(
                          l10n,
                          it: 'Modifica il tuo commento',
                          en: 'Edit your comment',
                        )
                      : _localizedText(
                          l10n,
                          it: 'Aggiungi un commento...',
                          en: 'Add a comment...',
                        ),
                ),
                enabled: !isSubmitting,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              width: 44,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _editingComment != null
                            ? Icons.check
                            : Icons.send_rounded,
                        color: colorScheme.primary,
                      ),
                onPressed: isSubmitting ? null : () => _submitPrimary(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInlineReplyComposer(
    BuildContext context, {
    required bool isSubmitting,
    required String replyingToLabel,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.reply,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _localizedText(
                    l10n,
                    it: 'Rispondi a $replyingToLabel',
                    en: 'Reply to $replyingToLabel',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _cancelReply,
                child: Text(
                  l10n.commentSection_cancelReply,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _replyInputController,
                  maxLines: 3,
                  minLines: 1,
                  autofocus: true,
                  textInputAction: TextInputAction.newline,
                  decoration: _commentInputDecoration(
                    context,
                    hintText: l10n.commentSection_inputHintReply,
                  ),
                  enabled: !isSubmitting,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                width: 44,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: colorScheme.primary,
                        ),
                  onPressed: isSubmitting ? null : () => _submitReply(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _commentInputDecoration(
    BuildContext context, {
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
      );
    }

    return InputDecoration(
      hintText: hintText,
      isDense: true,
      filled: true,
      fillColor: colorScheme.surface.withOpacity(isDark ? 0.92 : 1),
      border: border(
        colorScheme.outline.withOpacity(isDark ? 0.26 : 0.12),
      ),
      enabledBorder: border(
        colorScheme.outline.withOpacity(isDark ? 0.26 : 0.12),
      ),
      focusedBorder: border(
        colorScheme.primary.withOpacity(0.42),
        width: 1.2,
      ),
      disabledBorder: border(
        colorScheme.outline.withOpacity(isDark ? 0.18 : 0.08),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
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
      return _localizedText(
        AppLocalizations.of(context)!,
        it: 'Utente',
        en: 'User',
      );
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
      return _localizedText(
        AppLocalizations.of(context)!,
        it: 'Utente',
        en: 'User',
      );
    }
    if (normalized.length <= 8) {
      return normalized;
    }
    return normalized.substring(0, 8);
  }

  void _toggleReplyThread(String rootId) {
    setState(() {
      if (_expandedReplyThreads.contains(rootId)) {
        _expandedReplyThreads.remove(rootId);

        if (_replyParent != null &&
            _replyParent!.id == rootId &&
            _replyTarget != null &&
            _replyTarget!.id != rootId) {
          _cancelReply();
        }
      } else {
        _expandedReplyThreads.add(rootId);
      }
    });
  }

  void _startReply({
    required Comment parentForSubmit,
    required Comment anchorComment,
  }) {
    setState(() {
      _commentsExpanded = true;
      _editingComment = null;
      _replyParent = parentForSubmit;
      _replyTarget = anchorComment;
      _replyInputController.clear();
      _expandedReplyThreads.add(parentForSubmit.id);
    });
  }

  void _cancelReply() {
    setState(() {
      _replyParent = null;
      _replyTarget = null;
      _replyInputController.clear();
    });
  }

  void _startEdit(Comment comment) {
    setState(() {
      _commentsExpanded = true;
      _replyParent = null;
      _replyTarget = null;
      _editingComment = comment;
      _primaryInputController.text = comment.content;
      _primaryInputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _primaryInputController.text.length),
      );
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingComment = null;
      _primaryInputController.clear();
    });
  }

  bool _isInlineReplyOpenFor(Comment comment) {
    return _editingComment == null &&
        _replyTarget != null &&
        _replyTarget!.id == comment.id &&
        _replyParent != null;
  }

  Future<void> _submitPrimary(BuildContext context) async {
    final text = _primaryInputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.comment,
    );
    if (!allowed) {
      return;
    }

    final String? userId = AppDI.instance.currentUserId;
    if (userId == null) {
      return;
    }

    final controller = context.read<DiscussionController>();

    if (_editingComment != null) {
      await controller.editComment(
        comment: _editingComment!,
        content: text,
      );
    } else {
      await controller.addRootComment(
        userId: userId,
        content: text,
      );
    }

    if (controller.errorMessage == null) {
      _primaryInputController.clear();
      setState(() {
        _editingComment = null;
        _commentsExpanded = true;
      });
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _submitReply(BuildContext context) async {
    final text = _replyInputController.text.trim();
    if (text.isEmpty || _replyParent == null) {
      return;
    }

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.comment,
    );
    if (!allowed) {
      return;
    }

    final String? userId = AppDI.instance.currentUserId;
    if (userId == null) {
      return;
    }

    final controller = context.read<DiscussionController>();

    await controller.replyToComment(
      userId: userId,
      parent: _replyParent!,
      content: text,
    );

    if (controller.errorMessage == null) {
      final rootId = _replyParent!.id;
      _replyInputController.clear();
      setState(() {
        _replyParent = null;
        _replyTarget = null;
        _commentsExpanded = true;
        _expandedReplyThreads.add(rootId);
      });
      FocusScope.of(context).unfocus();
    }
  }

  String _viewRepliesLabel(AppLocalizations l10n, int count) {
    final isItalian = l10n.localeName.toLowerCase().startsWith('it');

    if (count == 1) {
      return isItalian ? 'Visualizza 1 risposta' : 'View 1 reply';
    }
    return isItalian ? 'Visualizza $count risposte' : 'View $count replies';
  }

  String _shorten(String text, {int max = 40}) {
    final trimmed = text.trim();
    if (trimmed.length <= max) return trimmed;
    return '${trimmed.substring(0, max)}…';
  }

  String _localizedText(
    AppLocalizations l10n, {
    required String it,
    required String en,
  }) {
    final locale = l10n.localeName.toLowerCase();
    return locale.startsWith('it') ? it : en;
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor;
    if (isCurrentUser) {
      backgroundColor = colorScheme.primary.withOpacity(isDark ? 0.10 : 0.05);
    } else if (isReply) {
      backgroundColor = colorScheme.primary.withOpacity(isDark ? 0.07 : 0.025);
    } else {
      backgroundColor = colorScheme.surface.withOpacity(isDark ? 0.30 : 0.72);
    }

    final Color borderColor = isReply
        ? colorScheme.primary.withOpacity(isDark ? 0.26 : 0.18)
        : colorScheme.outline.withOpacity(isDark ? 0.18 : 0.10);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AuthorAvatar(
                label: authorLabel,
                isReply: isReply,
                isCurrentUser: isCurrentUser,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          authorLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.commentSection_youBadge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (isReply)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _localizedText(
                                l10n,
                                it: 'Reply',
                                en: 'Reply',
                              ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(
                          isDark ? 0.56 : 0.48,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if ((canEdit && onEditTap != null) ||
                  (canDelete && onDeleteTap != null))
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
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(
                          _localizedText(
                            l10n,
                            it: 'Modifica',
                            en: 'Edit',
                          ),
                        ),
                      ),
                    if (canDelete && onDeleteTap != null)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(l10n.commentSection_deleteAction),
                      ),
                  ],
                  icon: Icon(
                    Icons.more_horiz,
                    size: 18,
                    color: colorScheme.onSurface.withOpacity(
                      isDark ? 0.56 : 0.48,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onReplyTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reply_outlined,
                        size: 15,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.commentSection_replyAction,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  String _localizedText(
    AppLocalizations l10n, {
    required String it,
    required String en,
  }) {
    final locale = l10n.localeName.toLowerCase();
    return locale.startsWith('it') ? it : en;
  }
}

class _AuthorAvatar extends StatelessWidget {
  final String label;
  final bool isReply;
  final bool isCurrentUser;

  const _AuthorAvatar({
    required this.label,
    required this.isReply,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isCurrentUser
        ? colorScheme.primary.withOpacity(isDark ? 0.18 : 0.14)
        : isReply
            ? colorScheme.primary.withOpacity(isDark ? 0.12 : 0.08)
            : colorScheme.surfaceVariant.withOpacity(isDark ? 0.28 : 0.55);

    final borderColor = isCurrentUser
        ? colorScheme.primary.withOpacity(isDark ? 0.36 : 0.25)
        : colorScheme.outline.withOpacity(isDark ? 0.22 : 0.12);

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: Text(
        _initial(label),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  static String _initial(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }

    final cleaned = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
    if (cleaned.isEmpty) {
      return 'U';
    }

    return cleaned.characters.first.toUpperCase();
  }
}
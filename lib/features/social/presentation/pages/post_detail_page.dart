import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/moderation/entities/report.dart';
import 'package:sociale_vote/domain/moderation/repositories/moderation_repository.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/features/social/application/post_detail_controller.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/shared/widgets/user_identity_mark.dart';

/// Pagina di dettaglio per un singolo post del social feed.
///
/// Riceve [postId] come String (vedi AppRouter.socialDetail).
class PostDetailPage extends StatelessWidget {
  final String postId;

  const PostDetailPage({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailController>(
      create: (_) => AppDI.instance.createPostDetailController(postId)..load(),
      child: const _PostDetailView(),
    );
  }
}

class _PostDetailView extends StatefulWidget {
  const _PostDetailView();

  @override
  State<_PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<_PostDetailView> {
  static const List<String> _reportReasons = [
    'spam',
    'harassment',
    'hate_speech',
    'misinformation',
    'violence',
    'other',
  ];

  bool _isFavorite = false;
  bool _favoriteInitialized = false;
  bool _favoriteLoading = false;
  bool _editLoading = false;
  bool _deleteLoading = false;
  int _commentCount = 0;
  String? _initializedPostId;

  Future<void> _initFavoriteStatus(Post post) async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _isFavorite = false;
        _favoriteInitialized = true;
      });
      return;
    }

    try {
      final isFav = await AppDI.instance.isFavorite(
        userId: userId,
        target: TargetRef.post(post.id.value),
      );
      if (!mounted) return;
      setState(() {
        _isFavorite = isFav;
        _favoriteInitialized = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _favoriteInitialized = true;
      });
    }
  }

  Future<void> _loadCommentCount(Post post) async {
    try {
      final count = await AppDI.instance.getCommentCountForTarget(
        TargetRef.post(post.id.value),
      );
      if (!mounted) return;
      setState(() {
        _commentCount = count;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _commentCount = 0;
      });
    }
  }

  Future<void> _onFavoritePressed(Post post) async {
    if (_favoriteLoading) {
      return;
    }

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.react,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

    setState(() {
      _favoriteLoading = true;
    });

    try {
      final newState = await AppDI.instance.toggleFavorite(
        userId: userId,
        target: TargetRef.post(post.id.value),
      );
      if (!mounted) return;
      setState(() {
        _isFavorite = newState;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aggiornare i preferiti')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _favoriteLoading = false;
        });
      }
    }
  }

  Future<void> _onSharePressed(Post post) async {
    final content = post.content.trim();
    final preview = content.length > 220
        ? '${content.substring(0, 220).trim()}...'
        : content;

    final buffer = StringBuffer()..writeln(post.title);

    if (preview.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(preview);
    }

    buffer
      ..writeln()
      ..writeln('Apri Sociale_Vote per vedere questo post.');

    try {
      await Share.share(
        buffer.toString().trim(),
        subject: post.title,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile condividere il post')),
      );
    }
  }

  bool _isOwner(Post post) {
    final currentUserId = AppDI.instance.currentUserId;
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return false;
    }

    final createdByUserId = post.createdByUserId;
    if (createdByUserId == null || createdByUserId.trim().isEmpty) {
      return false;
    }

    return currentUserId == createdByUserId;
  }

  Future<({String title, String content})?> _showEditPostDialog(
    Post post,
  ) async {
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);
    String? validationMessage;

    try {
      final result = await showDialog<({String title, String content})>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Modifica post'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Titolo',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: contentController,
                        minLines: 4,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'Contenuto',
                          alignLabelWithHint: true,
                        ),
                      ),
                      if (validationMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          validationMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Annulla'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();

                      if (title.isEmpty || content.isEmpty) {
                        setDialogState(() {
                          validationMessage =
                              'Titolo e contenuto sono obbligatori.';
                        });
                        return;
                      }

                      Navigator.of(dialogContext).pop((
                        title: title,
                        content: content,
                      ));
                    },
                    child: const Text('Salva'),
                  ),
                ],
              );
            },
          );
        },
      );

      return result;
    } finally {
      titleController.dispose();
      contentController.dispose();
    }
  }

  Future<void> _onEditPressed(Post post) async {
    if (_editLoading || _deleteLoading) {
      return;
    }

    final edited = await _showEditPostDialog(post);
    if (!mounted || edited == null) return;

    setState(() {
      _editLoading = true;
    });

    try {
      await context.read<PostDetailController>().update(
            title: edited.title,
            content: edited.content,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post aggiornato')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aggiornare il post')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _editLoading = false;
        });
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminare il post?'),
          content: const Text(
            'Questa azione non può essere annullata.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> _onDeletePressed() async {
    if (_deleteLoading || _editLoading) {
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog();
    if (!mounted || !confirmed) return;

    setState(() {
      _deleteLoading = true;
    });

    var deleted = false;

    try {
      await context.read<PostDetailController>().delete();

      if (!mounted) return;
      deleted = true;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile eliminare il post')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deleteLoading = false;
        });
      }
    }

    if (deleted && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _onReportPressed(Post post) async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.reportContent,
    );
    if (!allowed || !mounted) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devi essere autenticato per segnalare')),
      );
      return;
    }

    final reason = await _showReportReasonDialog(context);
    if (!mounted || reason == null) return;

    try {
      final result = await AppDI.instance.reportContent(
        Report(
          target: TargetRef.post(post.id.value),
          userId: userId,
          reason: reason,
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      final message = switch (result) {
        SubmitReportResult.submitted => 'Segnalazione inviata',
        SubmitReportResult.alreadyReported =>
          'Hai già segnalato questo contenuto',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile inviare la segnalazione')),
      );
    }
  }

  Future<String?> _showReportReasonDialog(BuildContext context) async {
    String selectedReason = _reportReasons.first;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Segnala contenuto'),
              content: RadioGroup<String>(
                groupValue: selectedReason,
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() {
                    selectedReason = value;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _reportReasons.map((reason) {
                    return RadioListTile<String>(
                      value: reason,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_reportReasonLabel(reason)),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annulla'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(selectedReason);
                  },
                  child: const Text('Invia'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _reportReasonLabel(String reason) {
    switch (reason) {
      case 'spam':
        return 'Spam';
      case 'harassment':
        return 'Molestie o abuso';
      case 'hate_speech':
        return 'Incitamento all’odio';
      case 'misinformation':
        return 'Disinformazione';
      case 'violence':
        return 'Violenza';
      case 'other':
        return 'Altro';
    }
    return reason;
  }

  void _ensurePostInitialized(Post post) {
    if (_initializedPostId == post.id.value) {
      return;
    }

    _initializedPostId = post.id.value;
    _favoriteInitialized = false;
    _favoriteLoading = false;
    _isFavorite = false;
    _commentCount = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_favoriteInitialized) {
        _initFavoriteStatus(post);
      }

      _loadCommentCount(post);
    });
  }

  bool _shouldShowIdentityMark(Post post) {
    return UserIdentityMark.shouldShow(
      actorType: post.authorActorType,
      verificationLevel: post.authorVerificationLevel,
      institutionLevel: post.authorInstitutionLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pageBackground =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F7FB);

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: const Text('Dettaglio post'),
        actions: [
          Consumer<PostDetailController>(
            builder: (context, controller, _) {
              final post = controller.post;
              if (post == null || _deleteLoading || _editLoading) {
                return const SizedBox.shrink();
              }

              final isOwner = _isOwner(post);

              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _onEditPressed(post);
                    return;
                  }

                  if (value == 'delete') {
                    _onDeletePressed();
                    return;
                  }

                  if (value == 'report') {
                    _onReportPressed(post);
                  }
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String>>[];

                  if (isOwner) {
                    items.addAll(
                      const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Modifica post'),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Elimina post'),
                        ),
                      ],
                    );
                  } else {
                    items.add(
                      const PopupMenuItem<String>(
                        value: 'report',
                        child: Text('Report content'),
                      ),
                    );
                  }

                  return items;
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<PostDetailController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.hasError) {
            return _PostDetailError(
              message: controller.errorMessage ??
                  'Si è verificato un errore nel caricamento del post.',
            );
          }

          final Post? post = controller.post;
          if (post == null) {
            return const _PostDetailError(
              message: 'Post non trovato.',
            );
          }

          _ensurePostInitialized(post);

          final fireCount = controller.likeCount;
          final iceCount = controller.dislikeCount;
          final userReaction = controller.userReaction;

          return ChangeNotifierProvider<DiscussionController>(
            key: ValueKey('discussion-post-${post.id.value}'),
            create: (_) => AppDI.instance.createDiscussionController(
              TargetRef.post(post.id.value),
              onCommentsChanged: () {
                _loadCommentCount(post);
              },
            )..loadComments(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostDetailHeroCard(
                    post: post,
                    isFavorite: _isFavorite,
                    favoriteLoading: _favoriteLoading,
                    commentCount: _commentCount,
                    fireCount: fireCount,
                    iceCount: iceCount,
                    userReaction: userReaction,
                    showIdentityMark: _shouldShowIdentityMark(post),
                    onSharePressed: () => _onSharePressed(post),
                    onFavoritePressed: _favoriteLoading
                        ? null
                        : () => _onFavoritePressed(post),
                    onFireTap: () async {
                      final allowed = await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!context.mounted || !allowed) return;

                      final userId = AppDI.instance.currentUserId;
                      if (userId == null) return;

                      await context
                          .read<PostDetailController>()
                          .toggleFire(userId: userId);
                    },
                    onIceTap: () async {
                      final allowed = await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!context.mounted || !allowed) return;

                      final userId = AppDI.instance.currentUserId;
                      if (userId == null) return;

                      await context
                          .read<PostDetailController>()
                          .toggleIce(userId: userId);
                    },
                  ),
                  const SizedBox(height: 20),
                  CommentSection(
                    userId: AppDI.instance.currentUserId ?? 'guest',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PostDetailHeroCard extends StatelessWidget {
  final Post post;
  final bool isFavorite;
  final bool favoriteLoading;
  final int commentCount;
  final int fireCount;
  final int iceCount;
  final dynamic userReaction;
  final bool showIdentityMark;
  final VoidCallback onSharePressed;
  final VoidCallback? onFavoritePressed;
  final Future<void> Function() onFireTap;
  final Future<void> Function() onIceTap;

  const _PostDetailHeroCard({
    required this.post,
    required this.isFavorite,
    required this.favoriteLoading,
    required this.commentCount,
    required this.fireCount,
    required this.iceCount,
    required this.userReaction,
    required this.showIdentityMark,
    required this.onSharePressed,
    required this.onFavoritePressed,
    required this.onFireTap,
    required this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardTopColor =
        isDark ? const Color(0xFF162130) : const Color(0xFFFCFDFE);
    final cardBottomColor =
        isDark ? const Color(0xFF101927) : const Color(0xFFF1F5FA);
    final cardBorderColor =
        isDark ? const Color(0xFF2C3948) : const Color(0xFFD7DFEA);

    final title = post.title.trim();
    final content = post.content.trim();
    final authorName =
        post.authorName.trim().isNotEmpty ? post.authorName.trim() : 'Author';

    final authorTextColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.90 : 0.84,
    );
    final metaTextColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.62 : 0.58,
    );
    final contentTextColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.88 : 0.86,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF0F172A).withValues(alpha: isDark ? 0.18 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color:
                const Color(0xFF94A3B8).withValues(alpha: isDark ? 0.06 : 0.10),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: cardBorderColor,
              width: 1.2,
            ),
            gradient: LinearGradient(
              colors: [
                cardTopColor,
                cardBottomColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 640;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _AuthorAvatar(
                                name: authorName,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        authorName,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: authorTextColor,
                                        ),
                                      ),
                                    ),
                                    if (showIdentityMark)
                                      UserIdentityMark(
                                        actorType: post.authorActorType,
                                        verificationLevel:
                                            post.authorVerificationLevel,
                                        institutionLevel:
                                            post.authorInstitutionLevel,
                                        size: 16,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _formatDateTime(post.createdAt),
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: metaTextColor,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (title.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                    if (content.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.56,
                          color: contentTextColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: isDark ? 0.24 : 0.12,
                            ),
                            width: 1,
                          ),
                        ),
                      ),
                      child: isCompact
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: EngagementBar(
                                    fireCount: fireCount,
                                    iceCount: iceCount,
                                    commentCount: commentCount,
                                    userReaction: userReaction,
                                    onFireTap: onFireTap,
                                    onIceTap: onIceTap,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _DetailActionIcon(
                                  icon: Icons.share_outlined,
                                  tooltip: 'Condividi',
                                  onPressed: onSharePressed,
                                ),
                                const SizedBox(width: 8),
                                _DetailActionIcon(
                                  icon: isFavorite
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  tooltip: isFavorite
                                      ? 'Rimuovi dai preferiti'
                                      : 'Salva',
                                  onPressed: onFavoritePressed,
                                  isActive: isFavorite,
                                  isLoading: favoriteLoading,
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: EngagementBar(
                                    fireCount: fireCount,
                                    iceCount: iceCount,
                                    commentCount: commentCount,
                                    userReaction: userReaction,
                                    onFireTap: onFireTap,
                                    onIceTap: onIceTap,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _DetailActionPill(
                                      icon: Icons.share_outlined,
                                      label: 'Condividi',
                                      onPressed: onSharePressed,
                                    ),
                                    const SizedBox(width: 8),
                                    _DetailActionPill(
                                      icon: isFavorite
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      label: 'Salva',
                                      onPressed: onFavoritePressed,
                                      isActive: isFavorite,
                                      isLoading: favoriteLoading,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }
}

class _AuthorAvatar extends StatelessWidget {
  final String name;

  const _AuthorAvatar({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial =
        name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.14),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool isLoading;

  const _DetailActionPill({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isActive
        ? colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.10)
        : colorScheme.surface.withValues(alpha: isDark ? 0.30 : 0.82);

    final borderColor = isActive
        ? colorScheme.primary.withValues(alpha: isDark ? 0.32 : 0.22)
        : colorScheme.outline.withValues(alpha: isDark ? 0.18 : 0.14);

    final foregroundColor = isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.84);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foregroundColor,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 18,
                  color: foregroundColor,
                ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool isLoading;

  const _DetailActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isActive
        ? colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.10)
        : colorScheme.surface.withValues(alpha: isDark ? 0.30 : 0.82);

    final borderColor = isActive
        ? colorScheme.primary.withValues(alpha: isDark ? 0.32 : 0.22)
        : colorScheme.outline.withValues(alpha: isDark ? 0.18 : 0.14);

    final foregroundColor = isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.84);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foregroundColor,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 18,
                      color: foregroundColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostDetailError extends StatelessWidget {
  final String message;

  const _PostDetailError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Errore',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/moderation/entities/report.dart';
import 'package:sociale_vote/domain/moderation/repositories/moderation_repository.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

/// Pagina di dettaglio per una singola news.
///
/// Uso previsto:
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => NewsDetailPage(news: newsItem),
///   ),
/// );
class NewsDetailPage extends StatefulWidget {
  final NewsItem news;

  const NewsDetailPage({
    super.key,
    required this.news,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  static const List<String> _reportReasons = [
    'spam',
    'harassment',
    'hate_speech',
    'misinformation',
    'violence',
    'other',
  ];

  bool _isFavorite = false;

  bool _favoriteLoading = false;
  int _commentCount = 0;
  String? _initializedNewsId;

  @override
  void initState() {
    super.initState();
    _initializeForCurrentNews();
  }

  @override
  void didUpdateWidget(covariant NewsDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.news.id.value != widget.news.id.value) {
      _isFavorite = false;
      _favoriteInitialized = false;
      _favoriteLoading = false;
      _commentCount = 0;
      _initializedNewsId = null;
      _initializeForCurrentNews();
    }
  }

  void _initializeForCurrentNews() {
    _initializedNewsId = widget.news.id.value;
    _initFavoriteStatus();
    _loadCommentCount();
  }

  Future<void> _initFavoriteStatus() async {
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
        target: TargetRef.news(widget.news.id.value),
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

  Future<void> _loadCommentCount() async {
    try {
      final count = await AppDI.instance.getCommentCountForTarget(
        TargetRef.news(widget.news.id.value),
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

  Future<void> _onFavoritePressed() async {
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
        target: TargetRef.news(widget.news.id.value),
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
      if (!mounted) return;
      setState(() {
        _favoriteLoading = false;
      });
    }
  }

  Future<void> _onSharePressed() async {
    final summary = widget.news.summary?.trim();
    final content = widget.news.content.trim();
    final previewSource =
        (summary != null && summary.isNotEmpty) ? summary : content;
    final preview = previewSource.length > 220
        ? '${previewSource.substring(0, 220).trim()}...'
        : previewSource;
    final articleUrl = widget.news.articleUrl?.trim();

    final buffer = StringBuffer()..writeln(widget.news.title);

    if (preview.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(preview);
    }

    if (articleUrl != null && articleUrl.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(articleUrl);
    }

    buffer
      ..writeln()
      ..writeln('Apri Sociale_Vote per vedere questa news.');

    try {
      await Share.share(
        buffer.toString().trim(),
        subject: widget.news.title,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile condividere la news')),
      );
    }
  }

  Future<void> _onReportPressed() async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.reportContent,
    );
    if (!allowed) return;

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
          target: TargetRef.news(widget.news.id.value),
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _reportReasons.map((reason) {
                  return RadioListTile<String>(
                    value: reason,
                    groupValue: selectedReason,
                    contentPadding: EdgeInsets.zero,
                    title: Text(_reportReasonLabel(reason)),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedReason = value;
                      });
                    },
                  );
                }).toList(),
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

  Future<void> _openOriginalArticle() async {
    final rawUrl = widget.news.articleUrl?.trim();

    if (rawUrl == null || rawUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link articolo originale non disponibile'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme || uri.host.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link articolo non valido'),
        ),
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile aprire l’articolo originale'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossibile aprire l’articolo originale'),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final news = widget.news;
    final sourceLabel = news.effectiveSourceLabel;

    if (_initializedNewsId != news.id.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _isFavorite = false;
          _favoriteInitialized = false;
          _favoriteLoading = false;
          _commentCount = 0;
          _initializedNewsId = news.id.value;
        });
        _initializeForCurrentNews();
      });
    }

    return ChangeNotifierProvider<DiscussionController>(
      create: (_) => AppDI.instance.createDiscussionController(
        TargetRef.news(news.id.value),
        onCommentsChanged: _loadCommentCount,
      )..loadComments(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.newsDetail_title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report') {
                  _onReportPressed();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'report',
                  child: Text('Report content'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (news.isBreaking) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.newsDetail_breakingBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onError,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        news.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      tooltip: 'Condividi',
                      onPressed: _onSharePressed,
                    ),
                    IconButton(
                      icon: _favoriteLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _isFavorite ? Icons.star : Icons.star_border,
                              color: _isFavorite
                                  ? theme.colorScheme.primary
                                  : theme.iconTheme.color,
                            ),
                      tooltip: _isFavorite
                          ? l10n.newsDetail_removeFromFavoritesTooltip
                          : l10n.newsDetail_addToFavoritesTooltip,
                      onPressed: _favoriteLoading ? null : _onFavoritePressed,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatPublishedAt(news.publishedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                if (sourceLabel != null && sourceLabel.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.newspaper,
                        size: 14,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          sourceLabel.trim(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.dividerColor.withOpacity(0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Text(
                      _resolveBodyText(l10n),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                if (news.hasOriginalArticleUrl) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _openOriginalArticle,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Leggi articolo originale'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Builder(
                  builder: (context) {
                    NewsController? newsController;
                    try {
                      newsController = Provider.of<NewsController>(
                        context,
                        listen: true,
                      );
                    } catch (_) {
                      newsController = null;
                    }

                    if (newsController == null) {
                      return const SizedBox.shrink();
                    }

                    final summary = newsController.summaryForNews(news);
                    final fireCount = summary?.likeCount ?? 0;
                    final iceCount = summary?.dislikeCount ?? 0;
                    final userReaction = summary?.userReaction;

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: EngagementBar(
                        fireCount: fireCount,
                        iceCount: iceCount,
                        commentCount: _commentCount,
                        userReaction: userReaction,
                        onFireTap: () async {
                          final allowed =
                              await AuthGuard.ensureCanPerformAction(
                            context,
                            ParticipationAction.react,
                          );
                          if (!allowed) return;

                          final String? userId = AppDI.instance.currentUserId;
                          if (userId == null) return;

                          newsController!.toggleFireForNews(
                            userId: userId,
                            newsItem: news,
                          );
                        },
                        onIceTap: () async {
                          final allowed =
                              await AuthGuard.ensureCanPerformAction(
                            context,
                            ParticipationAction.react,
                          );
                          if (!allowed) return;

                          final String? userId = AppDI.instance.currentUserId;
                          if (userId == null) return;

                          newsController!.toggleIceForNews(
                            userId: userId,
                            newsItem: news,
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.newsDetail_footerMoreContext,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                CommentSection(
                  userId: AppDI.instance.currentUserId ?? 'guest',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _resolveBodyText(AppLocalizations l10n) {
    final summary = widget.news.summary;
    if (summary != null && summary.trim().isNotEmpty) {
      return summary;
    }

    final content = widget.news.content;
    if (content.trim().isNotEmpty) {
      return content;
    }

    return l10n.newsDetail_bodyFallback;
  }

  String _formatPublishedAt(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

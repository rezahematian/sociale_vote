import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
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
  bool _isFavorite = false;
  bool _favoriteInitialized = false;

  @override
  void initState() {
    super.initState();
    _initFavoriteStatus();
  }

  Future<void> _initFavoriteStatus() async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
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
      // v1: nessun handling specifico per errori sui preferiti in-memory.
      if (!mounted) return;
      setState(() {
        _favoriteInitialized = true;
      });
    }
  }

  Future<void> _onFavoritePressed() async {
    // Usiamo la stessa policy delle reazioni per ora.
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.react,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

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
      // v1: silenzioso; in futuro si può mostrare SnackBar.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final news = widget.news;

    return ChangeNotifierProvider<DiscussionController>(
      create: (_) => AppDI.instance.createDiscussionController(
        // news.id è un EntityId, serve la String interna
        TargetRef.news(news.id.value),
      )..loadComments(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.newsDetail_title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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

                // Titolo principale + ⭐ preferiti
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
                      icon: Icon(
                        _isFavorite ? Icons.star : Icons.star_border,
                        color: _isFavorite
                            ? theme.colorScheme.primary
                            : theme.iconTheme.color,
                      ),
                      tooltip: _isFavorite
                          ? l10n.newsDetail_removeFromFavoritesTooltip
                          : l10n.newsDetail_addToFavoritesTooltip,
                      onPressed: _onFavoritePressed,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Meta info (data pubblicazione)
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

                const SizedBox(height: 16),

                // Divider editoriale
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

                // Contenuto / summary come corpo principale
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

                const SizedBox(height: 24),

                // Barra di engagement 🔥 / ❄ nel dettaglio.
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
                      // Nessun NewsController trovato → niente barra, ma nessun crash.
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
                        userReaction: userReaction,
                        onFireTap: () async {
                          // 🔐 Proteggiamo le reazioni come nel resto dell'app
                          final allowed =
                              await AuthGuard.ensureCanPerformAction(
                            context,
                            ParticipationAction.react,
                          );
                          if (!allowed) return;

                          final String? userId =
                              AppDI.instance.currentUserId;
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

                          final String? userId =
                              AppDI.instance.currentUserId;
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

                // Placeholder per future meta: fonte, tag, scope, ecc.
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

                // Sezione commenti (discussion/)
                const Divider(),
                const SizedBox(height: 16),
                CommentSection(
                  // Questo parametro è storicamente ignorato dalla logica interna,
                  // l'utente corrente reale viene letto da AppDI.instance.currentUserId.
                  // Usiamo un fallback neutro, NON "anonymous".
                  userId: AppDI.instance.currentUserId ?? 'guest',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Per ora usiamo la summary come corpo principale.
  /// In futuro possiamo collegare un campo "content" o testo completo.
  String _resolveBodyText(AppLocalizations l10n) {
    final s = widget.news.summary;
    if (s == null || s.trim().isEmpty) {
      return l10n.newsDetail_bodyFallback;
    }
    return s;
  }

  String _formatPublishedAt(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    // Formato: 22/02/2026 14:35
    return '$day/$month/$year $hour:$minute';
  }
}
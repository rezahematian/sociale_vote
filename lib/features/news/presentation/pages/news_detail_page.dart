import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';

/// Pagina di dettaglio per una singola news.
///
/// Uso previsto:
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => NewsDetailPage(news: newsItem),
///   ),
/// );
class NewsDetailPage extends StatelessWidget {
  final NewsItem news;

  const NewsDetailPage({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider<DiscussionController>(
      create: (_) => AppDI.instance.createDiscussionController(
        // QUI era l'errore: news.id è un EntityId, serve la String interna
        TargetRef.news(news.id.value),
      )..loadComments(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'News detail',
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'BREAKING',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onError,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],

                // Titolo principale
                Text(
                  news.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
                      _resolveBodyText(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Placeholder per future meta: fonte, tag, scope, ecc.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'More context and sources coming soon.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Sezione commenti (discussion/)
                const Divider(),
                const SizedBox(height: 16),
                const CommentSection(
                  userId: 'demo-user', // TODO: collegare a identity reale
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
  String _resolveBodyText() {
    final s = news.summary;
    if (s == null || s.trim().isEmpty) {
      return 'No additional text is available for this news item.';
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
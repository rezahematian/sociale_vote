import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

/// Card visuale per una singola news.
///
/// v1:
/// - mostra un header minimale
/// - mostra un corpo testuale base (news.toString())
/// - mostra barra di engagement con 🔥 / ❄
///
/// La logica di caricamento contatori e toggle viene gestita dal controller.
/// Qui passiamo solo i dati già pronti (fireCount, iceCount, callback).
class NewsCard extends StatelessWidget {
  final NewsItem news;

  /// Conteggio like (🔥) e dislike (❄) da mostrare sotto la news.
  final int fireCount;
  final int iceCount;

  /// Callback per tap su 🔥 e ❄.
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const NewsCard({
    super.key,
    required this.news,
    this.fireCount = 0,
    this.iceCount = 0,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // v1: assumiamo che il dettaglio news usi la route AppRouter.newsDetail
          // con l'id della news come argomento.
          Navigator.of(context).pushNamed(
            AppRouter.newsDetail,
            // Se NewsItem ha un id diverso (es. news.id.value), potremo adattarlo più avanti.
            news.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header molto semplice (titolo / sorgente in futuro).
              Text(
                'News',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Contenuto news - placeholder sicuro.
              //
              // NON usiamo campi specifici (title, summary, etc.)
              // per non rompere la compilazione se il modello è diverso.
              Text(
                news.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // ===== FOOTER: COMMENT COUNT + ENGAGEMENT BAR =====
              Row(
                children: [
                  _CommentCountBadge(news: news),
                  const Spacer(),
                  EngagementBar(
                    fireCount: fireCount,
                    iceCount: iceCount,
                    onFireTap: onFireTap,
                    onIceTap: onIceTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge che mostra il numero di commenti per questa news usando il dominio `discussion/`.
class _CommentCountBadge extends StatelessWidget {
  final NewsItem news;

  const _CommentCountBadge({required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: AppDI.instance
          .getCommentsForTarget(TargetRef.news(news.id)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Durante il load non mostriamo nulla per non far saltare il layout.
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          // In caso di errore, nessun badge (silenzioso).
          return const SizedBox.shrink();
        }

        final comments = snapshot.data as List<dynamic>? ?? const [];
        final count = comments.length;

        if (count == 0) {
          // Nessun commento → nessun badge.
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
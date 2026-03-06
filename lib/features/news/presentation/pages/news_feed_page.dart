import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppDI.instance.createNewsController()..loadNews(),
      child: const _NewsFeedView(),
    );
  }
}

class _NewsFeedView extends StatelessWidget {
  const _NewsFeedView();

  String _scopeShortLabel(GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return 'World';
      case GeoScopeLevel.country:
        return scope.countryCode ?? 'Country';
      case GeoScopeLevel.city:
        return scope.cityId ?? 'City';
    }
  }

  String _scopeDescription(GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return 'Showing global news.';
      case GeoScopeLevel.country:
        return 'Showing news for this country.';
      case GeoScopeLevel.city:
        return 'Showing news for this city.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppDI.instance.geoScopeController.scope;
    final scopeLabel = _scopeShortLabel(scope);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('News'),
            const SizedBox(height: 2),
            Text(
              'Scope: $scopeLabel',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: Consumer<NewsController>(
          builder: (context, controller, _) {
            final scope = AppDI.instance.geoScopeController.scope;
            final scopeLabel = _scopeShortLabel(scope);
            final scopeDescription = _scopeDescription(scope);

            // 1) Stato di loading iniziale
            if (controller.isLoading && controller.news.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // 2) Stato di errore: mostriamo messaggio + bottone Retry
            if (controller.hasError) {
              return _NewsErrorView(
                message: controller.errorMessage ??
                    'An unexpected error occurred while loading news.',
                onRetry: controller.loadNews,
              );
            }

            // 3) Stato "lista vuota" senza errore
            if (controller.news.isEmpty) {
              return RefreshIndicator(
                onRefresh: controller.loadNews,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildScopeHeader(
                      context,
                      scopeLabel: scopeLabel,
                      scopeDescription: scopeDescription,
                      newsCount: 0,
                    ),
                    const SizedBox(height: 24),
                    _buildEmptyStateCard(context),
                  ],
                ),
              );
            }

            // 4) Stato normale: lista con RefreshIndicator
            return RefreshIndicator(
              onRefresh: controller.loadNews,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: controller.news.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        _buildScopeHeader(
                          context,
                          scopeLabel: scopeLabel,
                          scopeDescription: scopeDescription,
                          newsCount: controller.news.length,
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }

                  final news = controller.news[index - 1];
                  return _NewsCard(news: news);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScopeHeader(
    BuildContext context, {
    required String scopeLabel,
    required String scopeDescription,
    required int newsCount,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.public,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  scopeLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              scopeDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.textTheme.bodySmall?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.article,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$newsCount news item(s) found',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 32,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'No news available for this area.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Pull to refresh or try again later.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista di errore "enterprise": messaggio chiaro + bottone di retry.
class _NewsErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _NewsErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
              'Unable to load news',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem news;

  const _NewsCard({
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final newsController = context.watch<NewsController>();

    // TODO: quando colleghiamo davvero l'auth, prendiamo lo userId dalla sessione.
    const String userId = 'demo-user';

    final fireCount = newsController.likeCountForNews(news);
    final iceCount = newsController.dislikeCountForNews(news);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NewsDetailPage(news: news),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.4),
              ),
            ),
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
                    margin: const EdgeInsets.only(bottom: 8),
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

                // Titolo
                Text(
                  news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // Summary / abstract
                if (news.summary != null &&
                    news.summary!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    news.summary!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.3,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withOpacity(0.85),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Meta info: data pubblicazione
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

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Barra di engagement 🔥 / ❄
                EngagementBar(
                  fireCount: fireCount,
                  iceCount: iceCount,
                  onFireTap: () {
                    newsController.toggleFireForNews(
                      userId: userId,
                      newsItem: news,
                    );
                  },
                  onIceTap: () {
                    newsController.toggleIceForNews(
                      userId: userId,
                      newsItem: news,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
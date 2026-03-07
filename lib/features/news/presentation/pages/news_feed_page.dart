import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/news/domain/news_language.dart';
import 'package:sociale_vote/features/news/domain/news_topic.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api.dart';

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NewsController>(
      create: (_) {
        final controller = AppDI.instance.createNewsController();
        final userId = AppDI.instance.currentUserId;
        controller.loadNews(userId: userId);
        return controller;
      },
      child: const _NewsFeedView(),
    );
  }
}

class _NewsFeedView extends StatefulWidget {
  const _NewsFeedView();

  @override
  State<_NewsFeedView> createState() => _NewsFeedViewState();
}

class _NewsFeedViewState extends State<_NewsFeedView> {
  final ScrollController _scrollController = ScrollController();

  GeoScope? _lastScope;

  @override
  void initState() {
    super.initState();
    _lastScope = AppDI.instance.geoScopeController.scope;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = context.read<NewsController>();
    if (controller.isLoading) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      // Con paginazione reale: chiediamo una nuova pagina se la sorgente ha ancora dati.
      if (controller.hasMoreFromSource) {
        controller.loadMoreNews();
      }
    }
  }

  void _reloadIfScopeChanged(GeoScope currentScope) {
    final last = _lastScope;
    if (last == null) {
      _lastScope = currentScope;
      return;
    }

    final changed = last.level != currentScope.level ||
        last.countryCode != currentScope.countryCode ||
        last.cityId != currentScope.cityId;

    if (!changed) return;

    _lastScope = currentScope;

    final controller = context.read<NewsController>();
    final userId = AppDI.instance.currentUserId;

    // Evita loop / doppio load durante build: scheduliamo post-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.loadNews(userId: userId);
    });
  }

  String _scopeShortLabel(BuildContext context, GeoScope scope) {
    final l10n = AppLocalizations.of(context)!;

    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.newsFeed_scopeWorld;
      case GeoScopeLevel.country:
        return scope.countryCode ?? l10n.newsFeed_scopeCountry;
      case GeoScopeLevel.city:
        // Se in futuro avrai cityName puoi usarlo qui.
        return scope.cityId ?? l10n.newsFeed_scopeCity;
    }
  }

  String _scopeDescription(BuildContext context, GeoScope scope) {
    final l10n = AppLocalizations.of(context)!;

    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.newsFeed_scopeGlobalDescription;
      case GeoScopeLevel.country:
        return l10n.newsFeed_scopeCountryDescription;
      case GeoScopeLevel.city:
        return l10n.newsFeed_scopeCityDescription;
    }
  }

  String _topicLabel(BuildContext context, NewsTopic topic) {
    final l10n = AppLocalizations.of(context)!;

    switch (topic) {
      case NewsTopic.all:
        return l10n.newsTopic_all;
      case NewsTopic.world:
        return l10n.newsTopic_world;
      case NewsTopic.nation:
        return l10n.newsTopic_nation;
      case NewsTopic.business:
        return l10n.newsTopic_business;
      case NewsTopic.technology:
        return l10n.newsTopic_technology;
      case NewsTopic.science:
        return l10n.newsTopic_science;
      case NewsTopic.health:
        return l10n.newsTopic_health;
      case NewsTopic.sports:
        return l10n.newsTopic_sports;
      case NewsTopic.entertainment:
        return l10n.newsTopic_entertainment;
    }
  }

  String _languageLabel(NewsLanguage language) {
    switch (language) {
      case NewsLanguage.auto:
        return 'AUTO';
      case NewsLanguage.it:
        return 'IT';
      case NewsLanguage.en:
        return 'EN';
      case NewsLanguage.es:
        return 'ES';
      case NewsLanguage.fr:
        return 'FR';
      case NewsLanguage.de:
        return 'DE';
      case NewsLanguage.ar:
        return 'AR';
      case NewsLanguage.fa:
        return 'FA';
    }
  }

  /// Message “enterprise” (localizzato) a partire dall'errore normalizzato.
  /// Fallback: usa le stringhe già presenti in controller / l10n generic.
  String _localizedErrorMessage(
    BuildContext context,
    NewsController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final kind = controller.errorKind;

    if (kind == NewsApiErrorKind.unauthorized) {
      return l10n.newsFeed_errorUnauthorized;
    }
    if (kind == NewsApiErrorKind.rateLimited) {
      return l10n.newsFeed_errorRateLimited;
    }
    if (kind == NewsApiErrorKind.serverError) {
      return l10n.newsFeed_errorServerUnavailable;
    }
    if (kind == NewsApiErrorKind.timeout) {
      return l10n.newsFeed_errorTimeout;
    }
    if (kind == NewsApiErrorKind.network) {
      return l10n.newsFeed_errorNetwork;
    }

    // unknown o null → fallback
    return controller.errorMessage ?? l10n.newsFeed_errorGeneric;
  }

  String _languageTooltip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.newsFeed_languageTooltip;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final scope = AppDI.instance.geoScopeController.scope;
    _reloadIfScopeChanged(scope);

    final scopeLabel = _scopeShortLabel(context, scope);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.newsFeed_title),
            const SizedBox(height: 2),
            Text(
              l10n.newsFeed_scopeLabel(scopeLabel),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<NewsController>(
            builder: (context, controller, _) {
              final currentUserId = AppDI.instance.currentUserId;
              final selected = controller.selectedLanguage;

              return PopupMenuButton<NewsLanguage>(
                tooltip: _languageTooltip(context),
                onSelected: (lang) {
                  controller.setLanguage(lang, userId: currentUserId);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<NewsLanguage>(
                    value: NewsLanguage.auto,
                    child: Text('AUTO'),
                  ),
                  PopupMenuItem<NewsLanguage>(
                    value: NewsLanguage.it,
                    child: Text('IT'),
                  ),
                  PopupMenuItem<NewsLanguage>(
                    value: NewsLanguage.en,
                    child: Text('EN'),
                  ),
                  PopupMenuItem<NewsLanguage>(
                    value: NewsLanguage.es,
                    child: Text('ES'),
                  ),
                  PopupMenuItem<NewsLanguage>(
                    value: NewsLanguage.fr,
                    child: Text('FR'),
                  ),
                  PopupMenuItem<NewsLanguage>(
                    value: NewsLanguage.de,
                    child: Text('DE'),
                  ),
                  PopupMenuItem<NewsLanguage>(
                    value: NewsLanguage.ar,
                    child: Text('AR'),
                  ),
                  PopupMenuItem<NewsLanguage>(
                    value: NewsLanguage.fa,
                    child: Text('FA'),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.public, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _languageLabel(selected),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: Consumer<NewsController>(
          builder: (context, controller, _) {
            final scope = AppDI.instance.geoScopeController.scope;
            final scopeLabel = _scopeShortLabel(context, scope);
            final scopeDescription = _scopeDescription(context, scope);
            final currentUserId = AppDI.instance.currentUserId;

            // Tutte le news caricate finora (aggregato delle pagine)
            final allNews = controller.news;

            // 1) Stato di loading iniziale
            if (controller.isLoading && allNews.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // 2) Stato di errore: mostriamo messaggio + bottone Retry
            if (controller.hasError) {
              return _NewsErrorView(
                message: _localizedErrorMessage(context, controller),
                onRetry: () => controller.loadNews(userId: currentUserId),
              );
            }

            // 3) Stato "lista vuota" senza errore
            if (allNews.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.loadNews(userId: currentUserId),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildScopeHeader(
                      context,
                      scopeLabel: scopeLabel,
                      scopeDescription: scopeDescription,
                      newsCount: 0,
                    ),
                    const SizedBox(height: 12),
                    _buildTopicChips(context, controller),
                    const SizedBox(height: 24),
                    _buildEmptyStateCard(context),
                  ],
                ),
              );
            }

            // 4) Stato normale: lista con RefreshIndicator + infinite scroll (paginazione reale)
            return RefreshIndicator(
              onRefresh: () => controller.loadNews(userId: currentUserId),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                // +1 per l'header, +1 opzionale per il "loading bottom"
                itemCount: allNews.length + 2,
                itemBuilder: (context, index) {
                  // Header in cima
                  if (index == 0) {
                    return Column(
                      children: [
                        _buildScopeHeader(
                          context,
                          scopeLabel: scopeLabel,
                          scopeDescription: scopeDescription,
                          newsCount: allNews.length,
                        ),
                        const SizedBox(height: 12),
                        _buildTopicChips(context, controller),
                        const SizedBox(height: 12),
                      ],
                    );
                  }

                  // Ultimo item: se stiamo caricando o ci sono altre pagine,
                  // mostriamo un indicatore in fondo.
                  if (index == allNews.length + 1) {
                    if (controller.isLoading && allNews.isNotEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.hasMoreFromSource) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            l10n.newsFeed_loadingMoreHint,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      );
                    }

                    // Nessun loading, nessun "load more" → spazio vuoto
                    return const SizedBox.shrink();
                  }

                  final news = allNews[index - 1];
                  return _NewsCard(news: news);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopicChips(BuildContext context, NewsController controller) {
    final theme = Theme.of(context);
    final currentUserId = AppDI.instance.currentUserId;

    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: kNewsTopics.map((topic) {
            final bool selected = controller.selectedTopic == topic;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_topicLabel(context, topic)),
                selected: selected,
                onSelected: (value) {
                  if (!value) return;
                  controller.setTopic(topic, userId: currentUserId);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
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
    final l10n = AppLocalizations.of(context)!;

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
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
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
                  l10n.newsFeed_itemsFound(newsCount),
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
    final l10n = AppLocalizations.of(context)!;

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
              l10n.newsFeed_emptyTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.newsFeed_emptySubtitle,
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
    final l10n = AppLocalizations.of(context)!;

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
              l10n.newsFeed_errorTitle,
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
              label: Text(l10n.newsFeed_retryButton),
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
    final l10n = AppLocalizations.of(context)!;
    final newsController = context.watch<NewsController>();

    final summary = newsController.summaryForNews(news);
    final fireCount = summary?.likeCount ?? 0;
    final iceCount = summary?.dislikeCount ?? 0;
    final userReaction = summary?.userReaction; // può essere null (nessuna reazione)

    final sourceLabel = _sourceLabel(news);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Passiamo lo stesso NewsController al dettaglio
            final newsController = context.read<NewsController>();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider<NewsController>.value(
                  value: newsController,
                  child: NewsDetailPage(news: news),
                ),
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
                // Immagine (se presente) — 16:9 + errorBuilder
                if (_hasImage(news)) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        news.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            alignment: Alignment.center,
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.35),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.55),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.35),
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Header row: breaking badge + source
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (news.isBreaking) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Row(
                        children: [
                          _SourceDot(label: sourceLabel),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              sourceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.hintColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

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
                if (news.summary != null && news.summary!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    news.summary!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.3,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Bottom row: data pubblicazione + menu (in basso destra)
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatPublishedAt(news.publishedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                    _NewsCardMoreButton(
                      news: news,
                      onCopyTitle: () async {
                        await Clipboard.setData(
                          ClipboardData(text: news.title),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.newsFeed_copiedTitleToast),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        }
                      },
                      onRefresh: () {
                        final userId = AppDI.instance.currentUserId;
                        context.read<NewsController>().loadNews(userId: userId);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Barra di engagement 🔥 / ❄ con stato utente
                EngagementBar(
                  fireCount: fireCount,
                  iceCount: iceCount,
                  userReaction: userReaction,
                  onFireTap: () {
                    AuthGuard.ensureCanPerformAction(
                      context,
                      ParticipationAction.react,
                    ).then((allowed) {
                      if (!allowed) return;
                      final userId = AppDI.instance.currentUserId;
                      if (userId == null) return;
                      newsController.toggleFireForNews(
                        userId: userId,
                        newsItem: news,
                      );
                    });
                  },
                  onIceTap: () {
                    AuthGuard.ensureCanPerformAction(
                      context,
                      ParticipationAction.react,
                    ).then((allowed) {
                      if (!allowed) return;
                      final userId = AppDI.instance.currentUserId;
                      if (userId == null) return;
                      newsController.toggleIceForNews(
                        userId: userId,
                        newsItem: news,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static bool _hasImage(NewsItem news) {
    final url = news.imageUrl;
    return url != null && url.trim().isNotEmpty;
  }

  static String _sourceLabel(NewsItem news) {
    final raw = news.authorId.trim();
    if (raw.isEmpty) return 'GNews';
    if (raw.length <= 28) return raw;
    return raw.substring(0, 28);
  }

  static String _formatPublishedAt(DateTime dateTime) {
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

/// Piccolo “dot” come favicon placeholder (senza dipendenze).
/// In futuro potrai sostituirlo con favicon reale dal dominio url della source.
class _SourceDot extends StatelessWidget {
  final String label;

  const _SourceDot({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // colore derivato in modo deterministico dal label
    final hash = label.hashCode.abs();
    final hue = (hash % 360).toDouble();
    final color = HSVColor.fromAHSV(1.0, hue, 0.55, 0.85).toColor();

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
          width: 0.8,
        ),
      ),
    );
  }
}

class _NewsCardMoreButton extends StatelessWidget {
  final NewsItem news;
  final Future<void> Function() onCopyTitle;
  final VoidCallback onRefresh;

  const _NewsCardMoreButton({
    required this.news,
    required this.onCopyTitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<_NewsCardAction>(
      tooltip: l10n.newsFeed_moreTooltip,
      icon: Icon(
        Icons.more_horiz,
        size: 18,
        color: theme.hintColor,
      ),
      itemBuilder: (context) => [
        PopupMenuItem<_NewsCardAction>(
          value: _NewsCardAction.copyTitle,
          child: Row(
            children: [
              const Icon(Icons.copy, size: 18),
              const SizedBox(width: 10),
              Text(l10n.newsFeed_actionCopyTitle),
            ],
          ),
        ),
        PopupMenuItem<_NewsCardAction>(
          value: _NewsCardAction.refreshFeed,
          child: Row(
            children: [
              const Icon(Icons.refresh, size: 18),
              const SizedBox(width: 10),
              Text(l10n.newsFeed_actionRefreshFeed),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case _NewsCardAction.copyTitle:
            onCopyTitle();
            break;
          case _NewsCardAction.refreshFeed:
            onRefresh();
            break;
        }
      },
    );
  }
}

enum _NewsCardAction {
  copyTitle,
  refreshFeed,
}
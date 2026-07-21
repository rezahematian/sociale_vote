import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/news/domain/news_language.dart';
import 'package:sociale_vote/features/news/domain/news_topic.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/features/news/presentation/widgets/news_card.dart'
    as shared_news;
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';
import 'package:sociale_vote/shared/ui/loading_indicator.dart';

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
    AppDI.instance.geoScopeController.addListener(_onScopeChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    AppDI.instance.geoScopeController.removeListener(_onScopeChanged);
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
      if (controller.hasMoreFromSource) {
        controller.loadMoreNews();
      }
    }
  }

  void _onScopeChanged() {
    if (!mounted) return;

    final currentScope = AppDI.instance.geoScopeController.scope;
    final last = _lastScope;

    final changed = last == null ||
        last.level != currentScope.level ||
        last.countryCode != currentScope.countryCode ||
        last.cityId != currentScope.cityId;

    if (!changed) return;

    setState(() {
      _lastScope = currentScope;
    });

    final controller = context.read<NewsController>();
    final userId = AppDI.instance.currentUserId;
    controller.loadNews(userId: userId);
  }

  String _scopeShortLabel(BuildContext context, GeoScope scope) {
    final l10n = AppLocalizations.of(context)!;

    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.newsFeed_scopeWorld;
      case GeoScopeLevel.country:
        return scope.countryCode ?? l10n.newsFeed_scopeCountry;
      case GeoScopeLevel.city:
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

    return controller.errorMessage ?? l10n.newsFeed_errorGeneric;
  }

  String _languageTooltip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.newsFeed_languageTooltip;
  }

  Color _topicAccentColor(BuildContext context, NewsTopic topic) {
    final scheme = Theme.of(context).colorScheme;

    switch (topic) {
      case NewsTopic.all:
        return scheme.primary;
      case NewsTopic.world:
        return Colors.blue.shade700;
      case NewsTopic.nation:
        return Colors.indigo.shade600;
      case NewsTopic.business:
        return Colors.amber.shade800;
      case NewsTopic.technology:
        return Colors.teal.shade700;
      case NewsTopic.science:
        return Colors.purple.shade600;
      case NewsTopic.health:
        return Colors.green.shade700;
      case NewsTopic.sports:
        return Colors.orange.shade700;
      case NewsTopic.entertainment:
        return Colors.pink.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final scope = AppDI.instance.geoScopeController.scope;
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
            final scopeLabel = _scopeShortLabel(context, scope);
            final scopeDescription = _scopeDescription(context, scope);
            final currentUserId = AppDI.instance.currentUserId;

            final allNews = controller.news;

            if (controller.isLoading && allNews.isEmpty) {
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: LoadingIndicator(),
                ),
              );
            }

            if (controller.hasError) {
              return _NewsErrorView(
                message: _localizedErrorMessage(context, controller),
                onRetry: () => controller.loadNews(userId: currentUserId),
              );
            }

            if (allNews.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.loadNews(userId: currentUserId),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildScopeHeader(
                        context,
                        scopeLabel: scopeLabel,
                        scopeDescription: scopeDescription,
                        newsCount: 0,
                        selectedLanguage: controller.selectedLanguage,
                        onLanguageSelected: (lang) {
                          controller.setLanguage(lang, userId: currentUserId);
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildTopicChips(context, controller),
                    ),
                    const SizedBox(height: 24),
                    _buildEmptyStateCard(context),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadNews(userId: currentUserId),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: allNews.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _buildScopeHeader(
                            context,
                            scopeLabel: scopeLabel,
                            scopeDescription: scopeDescription,
                            newsCount: allNews.length,
                            selectedLanguage: controller.selectedLanguage,
                            onLanguageSelected: (lang) {
                              controller.setLanguage(
                                lang,
                                userId: currentUserId,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _buildTopicChips(context, controller),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }

                  if (index == allNews.length + 1) {
                    if (controller.isLoading && allNews.isNotEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: LoadingIndicator(),
                          ),
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
            final accent = _topicAccentColor(context, topic);

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
                  side: BorderSide(
                    color: selected
                        ? accent.withValues(alpha: 0.38)
                        : accent.withValues(alpha: 0.18),
                  ),
                ),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: accent.withValues(alpha: 0.14),
                checkmarkColor: accent,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? accent : theme.colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                side: BorderSide(
                  color: selected
                      ? accent.withValues(alpha: 0.38)
                      : accent.withValues(alpha: 0.18),
                ),
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
    required NewsLanguage selectedLanguage,
    required ValueChanged<NewsLanguage> onLanguageSelected,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    const borderRadius = BorderRadius.all(Radius.circular(20));

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: primary.withValues(alpha: 0.10),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withValues(alpha: 0.10),
              primary.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -34,
              right: -20,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -42,
              left: -10,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.72,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primary.withValues(alpha: 0.16),
                                ),
                              ),
                              child: Icon(
                                Icons.public,
                                size: 20,
                                color: primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scopeLabel,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    scopeDescription,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: onSurface.withValues(alpha: 0.76),
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildLanguageSelector(
                        context,
                        selectedLanguage: selectedLanguage,
                        onLanguageSelected: onLanguageSelected,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 16,
                          color: primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.newsFeed_itemsFound(newsCount),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context, {
    required NewsLanguage selectedLanguage,
    required ValueChanged<NewsLanguage> onLanguageSelected,
  }) {
    final theme = Theme.of(context);

    return PopupMenuButton<NewsLanguage>(
      tooltip: _languageTooltip(context),
      onSelected: onLanguageSelected,
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
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              _languageLabel(selectedLanguage),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      elevated: false,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 32,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
        child: AppCard(
          elevated: true,
          child: Padding(
            padding: const EdgeInsets.all(20),
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

  Future<void> _openDetailAndRefresh(BuildContext context) async {
    final newsController = context.read<NewsController>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<NewsController>.value(
          value: newsController,
          child: NewsDetailPage(news: news),
        ),
      ),
    );

    if (!context.mounted) return;
    await newsController.refreshCommentCountForNews(news);
  }

  @override
  Widget build(BuildContext context) {
    final newsController = context.watch<NewsController>();

    final summary = newsController.summaryForNews(news);
    final fireCount = summary?.likeCount ?? 0;
    final iceCount = summary?.dislikeCount ?? 0;
    final commentCount = newsController.commentCountForNews(news);
    final userReaction = summary?.userReaction;

    return shared_news.NewsCard(
      news: news,
      fireCount: fireCount,
      iceCount: iceCount,
      commentCount: commentCount,
      userReaction: userReaction,
      onCardTap: () => _openDetailAndRefresh(context),
      onCommentTap: () => _openDetailAndRefresh(context),
      onFireTap: () async {
        final allowed = await AuthGuard.ensureCanPerformAction(
          context,
          ParticipationAction.react,
        );
        if (!allowed) return;

        final userId = AppDI.instance.currentUserId;
        if (userId == null) return;

        await newsController.toggleFireForNews(
          userId: userId,
          newsItem: news,
        );
      },
      onIceTap: () async {
        final allowed = await AuthGuard.ensureCanPerformAction(
          context,
          ParticipationAction.react,
        );
        if (!allowed) return;

        final userId = AppDI.instance.currentUserId;
        if (userId == null) return;

        await newsController.toggleIceForNews(
          userId: userId,
          newsItem: news,
        );
      },
    );
  }
}

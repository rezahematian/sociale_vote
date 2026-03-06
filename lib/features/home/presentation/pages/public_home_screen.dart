import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/usecases/get_polls.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  GeoScopeController get _geoScopeController =>
      AppDI.instance.geoScopeController;

  late final GetPolls _getPollsUseCase;

  @override
  void initState() {
    super.initState();
    _getPollsUseCase = AppDI.instance.getPolls;
  }

  void _setWorld() => _geoScopeController.setWorld();
  void _setItaly() => _geoScopeController.setCountry('IT');
  void _setTorino() =>
      _geoScopeController.setCity(countryCode: 'IT', cityId: 'TORINO');

  String _scopeLabel(GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return 'World – Votazioni e news globali';
      case GeoScopeLevel.country:
        return 'Country – Votazioni e news del paese';
      case GeoScopeLevel.city:
        return 'City – Votazioni e news della città';
    }
  }

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

  Future<List<Poll>> _fetchHighlightedPolls(GeoScope scope) async {
    String? countryCode;
    String? cityId;

    switch (scope.level) {
      case GeoScopeLevel.world:
        break;
      case GeoScopeLevel.country:
        countryCode = scope.countryCode;
        break;
      case GeoScopeLevel.city:
        countryCode = scope.countryCode;
        cityId = scope.cityId;
        break;
    }

    final polls = await _getPollsUseCase(
      countryCode: countryCode,
      cityId: cityId,
    );

    return polls.length <= 3 ? polls : polls.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _geoScopeController,
      builder: (context, _) {
        final scope = _geoScopeController.scope;
        final scopeLabel = _scopeLabel(scope);
        final scopeShortLabel = _scopeShortLabel(scope);

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Sociale Vote'),
                const SizedBox(height: 2),
                Text(
                  scopeShortLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ====== MAPPA + SCOPE CONTROLS ======
                SizedBox(
                  height: 260,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CivicMapWidget(
                        currentScopeLabel: scopeShortLabel,
                      ),
                    ),
                  ),
                ),

                _buildScopePanel(context, scope, scopeLabel),

                const Divider(height: 1),

                // ====== CONTENUTO PRINCIPALE: POLLS + NEWS + SOCIAL ======
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      // ================= POLLS =================
                      _buildSectionHeader(
                        context,
                        title: 'Highlighted Polls ($scopeShortLabel)',
                        icon: Icons.how_to_vote,
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Poll>>(
                        key: ValueKey(
                          'highlighted_${scope.level}_${scope.countryCode}_${scope.cityId}',
                        ),
                        future: _fetchHighlightedPolls(scope),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return _buildPlaceholderCard(
                              context,
                              title: 'Unable to load polls',
                              subtitle:
                                  'Si è verificato un problema nel caricamento delle votazioni per quest’area.',
                            );
                          }

                          final polls = snapshot.data ?? [];

                          if (polls.isEmpty) {
                            return _buildPlaceholderCard(
                              context,
                              title: 'No polls for this area',
                              subtitle:
                                  'Non ci sono votazioni per questo scope.',
                            );
                          }

                          return Column(
                            children: polls
                                .map(
                                  (poll) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRouter.pollDetail,
                                          arguments: poll.id,
                                        );
                                      },
                                      child: PollCard(poll: poll),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.polls,
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('View all polls'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ================= NEWS =================
                      ChangeNotifierProvider<NewsController>(
                        key: ValueKey(
                          'home_news_${scope.level}_${scope.countryCode}_${scope.cityId}',
                        ),
                        create: (_) =>
                            AppDI.instance.createNewsController()
                              ..loadNews(),
                        child: _HomeNewsSection(
                          scopeShortLabel: scopeShortLabel,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ================= SOCIAL =================
                      _buildSectionHeader(
                        context,
                        title: 'Discussions / Feed',
                        icon: Icons.forum,
                      ),
                      const SizedBox(height: 8),
                      _buildPlaceholderCard(
                        context,
                        title: 'Discussioni, post, thread',
                        subtitle: 'Feed sociale filtrato per scope.',
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.social,
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('View social feed'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScopePanel(
    BuildContext context,
    GeoScope scope,
    String scopeLabel,
  ) {
    final theme = Theme.of(context);

    final isWorld = scope.level == GeoScopeLevel.world;
    final isItaly = scope.level == GeoScopeLevel.country &&
        (scope.countryCode ?? '').toUpperCase() == 'IT';
    final isTorino = scope.level == GeoScopeLevel.city &&
        (scope.cityId ?? '').toUpperCase() == 'TORINO';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.public,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scopeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('World'),
                    selected: isWorld,
                    onSelected: (_) => _setWorld(),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Italy'),
                    selected: isItaly,
                    onSelected: (_) => _setItaly(),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Torino'),
                    selected: isTorino,
                    onSelected: (_) => _setTorino(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCard(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sezione "Top News" nella Home, con 🔥❄ sotto ogni preview.
class _HomeNewsSection extends StatelessWidget {
  final String scopeShortLabel;

  const _HomeNewsSection({
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<NewsController>();

    // Prendiamo al massimo 3 news come "Top".
    final allNews = controller.news;
    final newsList =
        allNews.length <= 3 ? allNews : allNews.take(3).toList();

    // TODO: prendere userId reale quando colleghiamo l'auth.
    const String userId = 'demo-user';

    // Header sezione
    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.article,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Top News ($scopeShortLabel)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    Widget content;

    if (controller.isLoading && newsList.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.hasError) {
      content = _HomeNewsPlaceholderCard(
        title: 'Unable to load news',
        subtitle:
            'Si è verificato un problema nel caricamento delle news per quest’area.',
      );
    } else if (newsList.isEmpty) {
      content = _HomeNewsPlaceholderCard(
        title: 'No news for this area',
        subtitle: 'Non ci sono news per questo scope al momento.',
      );
    } else {
      content = Column(
        children: newsList
            .map(
              (news) {
                final fire = controller.likeCountForNews(news);
                final ice = controller.dislikeCountForNews(news);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NewsPreviewCard(
                    news: news,
                    fireCount: fire,
                    iceCount: ice,
                    onFireTap: () {
                      controller.toggleFireForNews(
                        userId: userId,
                        newsItem: news,
                      );
                    },
                    onIceTap: () {
                      controller.toggleIceForNews(
                        userId: userId,
                        newsItem: news,
                      );
                    },
                  ),
                );
              },
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.news,
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('View all news'),
          ),
        ),
      ],
    );
  }
}

class _HomeNewsPlaceholderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HomeNewsPlaceholderCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsPreviewCard extends StatelessWidget {
  final NewsItem news;
  final int fireCount;
  final int iceCount;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const _NewsPreviewCard({
    required this.news,
    this.fireCount = 0,
    this.iceCount = 0,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NewsDetailPage(news: news),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.isBreaking) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
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
              Text(
                news.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (news.summary != null &&
                  news.summary!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  news.summary!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
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
                      color:
                          theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 4),
              // Barra di engagement 🔥 / ❄
              EngagementBar(
                fireCount: fireCount,
                iceCount: iceCount,
                onFireTap: onFireTap,
                onIceTap: onIceTap,
              ),
            ],
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
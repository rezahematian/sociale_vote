import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';

class CivicMapPage extends StatelessWidget {
  const CivicMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CivicMapController>(
      create: (_) => AppDI.instance.createCivicMapController(),
      child: const _CivicMapPageView(),
    );
  }
}

class _CivicMapPageView extends StatelessWidget {
  const _CivicMapPageView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<CivicMapController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Civic Map'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _MapTypeFilters(controller: controller),
              const SizedBox(height: 12),
              Expanded(
                child: CivicMapWidget(
                  controller: controller,
                  onItemTap: (item) => _openTarget(context, item.targetRef),
                ),
              ),
              if (controller.hasData || controller.isEmpty) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contenuti visibili: ${controller.visibleItems.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTarget(BuildContext context, TargetRef targetRef) async {
    final targetId = _readTargetRefId(targetRef);
    if (targetId == null || targetId.trim().isEmpty) {
      return;
    }

    switch (targetRef.type) {
      case TargetType.poll:
        Navigator.of(context).pushNamed(
          AppRouter.pollDetail,
          arguments: PollId(targetId),
        );
        return;

      case TargetType.post:
        Navigator.of(context).pushNamed(
          AppRouter.socialDetail,
          arguments: targetId,
        );
        return;

      case TargetType.news:
        final newsItem = await _resolveNewsItem(targetId);
        if (!context.mounted) return;

        if (newsItem == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossibile aprire il dettaglio news'),
            ),
          );
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NewsDetailPage(news: newsItem),
          ),
        );
        return;

      default:
        return;
    }
  }

  Future<NewsItem?> _resolveNewsItem(String newsId) async {
    final appDi = AppDI.instance;

    try {
      final dynamic useCase = appDi.getNewsDetail;
      final dynamic result = await _tryResolveDynamicNewsDetail(
        useCase: useCase,
        newsId: newsId,
      );
      if (result is NewsItem) {
        return result;
      }
    } catch (_) {}

    try {
      final items = await appDi.getNewsFeed();
      for (final item in items) {
        if (item.id.value == newsId) {
          return item;
        }
      }
    } catch (_) {}

    return null;
  }

  Future<dynamic> _tryResolveDynamicNewsDetail({
    required dynamic useCase,
    required String newsId,
  }) async {
    final attempts = <Future<dynamic> Function()>[
      () => useCase(newsId: newsId),
      () => useCase(id: newsId),
      () => useCase(newsId),
    ];

    Object? lastError;

    for (final attempt in attempts) {
      try {
        return await attempt();
      } catch (e) {
        lastError = e;
      }
    }

    throw StateError(
      'Impossibile risolvere il dettaglio news: ${lastError ?? 'errore sconosciuto'}',
    );
  }

  String? _readTargetRefId(TargetRef targetRef) {
    try {
      final dynamic value = (targetRef as dynamic).targetId;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = (targetRef as dynamic).id;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = (targetRef as dynamic).value;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = (targetRef as dynamic).target;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    return null;
  }
}

class _MapTypeFilters extends StatelessWidget {
  final CivicMapController controller;

  const _MapTypeFilters({
    required this.controller,
  });

  Color _chipColor(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Colors.green;
      case CivicMapItemType.post:
        return Colors.blue;
      case CivicMapItemType.news:
        return Colors.red;
    }
  }

  IconData _chipIcon(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Icons.poll_outlined;
      case CivicMapItemType.post:
        return Icons.forum_outlined;
      case CivicMapItemType.news:
        return Icons.newspaper_outlined;
    }
  }

  String _chipLabel(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return 'Poll';
      case CivicMapItemType.post:
        return 'Post';
      case CivicMapItemType.news:
        return 'News';
    }
  }

  Widget _buildChip(BuildContext context, CivicMapItemType type) {
    final active = controller.isTypeVisible(type);
    final color = _chipColor(type);

    return FilterChip(
      label: Text(_chipLabel(type)),
      selected: active,
      onSelected: (_) => controller.toggleType(type),
      avatar: Icon(
        _chipIcon(type),
        size: 18,
        color: active ? color : null,
      ),
      selectedColor: color.withOpacity(0.15),
      checkmarkColor: color,
      side: BorderSide(
        color: active ? color.withOpacity(0.45) : Colors.grey.withOpacity(0.25),
      ),
      labelStyle: TextStyle(
        color: active ? color : null,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(context, CivicMapItemType.poll),
        _buildChip(context, CivicMapItemType.post),
        _buildChip(context, CivicMapItemType.news),
      ],
    );
  }
}

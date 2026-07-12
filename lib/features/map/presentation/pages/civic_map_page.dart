import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';
import 'package:sociale_vote/features/news/domain/news_language.dart';
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

class _CivicMapPageView extends StatefulWidget {
  const _CivicMapPageView();

  @override
  State<_CivicMapPageView> createState() => _CivicMapPageViewState();
}

class _CivicMapPageViewState extends State<_CivicMapPageView> {
  String? _lastSyncedScopeKey;
  NewsLanguage _selectedLanguage = NewsLanguage.auto;
  bool _isChangingLanguage = false;

  @override
  void initState() {
    super.initState();
    _restoreSavedLanguagePreference();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<CivicMapController>();
    final geoScopeController = context.watch<GeoScopeController?>();
    final activeScope = _readActiveScope(geoScopeController);
    final activeScopeKey = activeScope == null ? null : _scopeKey(activeScope);

    _scheduleScopeSyncIfNeeded(
      controller: controller,
      scope: activeScope,
      scopeKey: activeScopeKey,
    );

    final selectorBusy = _isChangingLanguage || controller.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Civic Map'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.isLoading
                ? null
                : () {
                    controller.refresh();
                  },
            icon: controller.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _MapTopControls(
                controller: controller,
                selectedLanguage: _selectedLanguage,
                languageSelectorEnabled: !selectorBusy,
                onLanguageChanged: (value) => _handleLanguageChanged(
                  value,
                  controller: controller,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CivicMapWidget(
                  controller: controller,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: controller.selectedItem == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _MarkerPreviewCard(
                          key: ValueKey<String>(controller.selectedItem!.id),
                          item: controller.selectedItem!,
                          onClose: controller.clearSelection,
                          onOpen: () => _openTarget(
                            context,
                            controller,
                            controller.selectedItem!.targetRef,
                          ),
                        ),
                      ),
              ),
              if (controller.hasData || controller.isEmpty) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contenuti visibili: ${controller.visibleItems.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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

  Future<void> _restoreSavedLanguagePreference() async {
    try {
      final storedValue = await AppDI.instance.getContentLanguagePreference();
      final restored = _newsLanguageFromStoredValue(storedValue);

      if (!mounted || restored == null) {
        return;
      }

      setState(() {
        _selectedLanguage = restored;
      });
    } catch (_) {}
  }

  Future<void> _handleLanguageChanged(
    NewsLanguage language, {
    required CivicMapController controller,
  }) async {
    if (_selectedLanguage == language || _isChangingLanguage) {
      return;
    }

    setState(() {
      _selectedLanguage = language;
      _isChangingLanguage = true;
    });

    try {
      if (language == NewsLanguage.auto) {
        await AppDI.instance.clearContentLanguagePreference();
      } else {
        await AppDI.instance.setContentLanguagePreference(language.name);
      }

      await controller.refresh();
    } finally {
      if (mounted) {
        setState(() {
          _isChangingLanguage = false;
        });
      }
    }
  }

  NewsLanguage? _newsLanguageFromStoredValue(String? value) {
    if (value == null) {
      return NewsLanguage.auto;
    }

    switch (value.trim().toLowerCase()) {
      case 'auto':
        return NewsLanguage.auto;
      case 'it':
        return NewsLanguage.it;
      case 'en':
        return NewsLanguage.en;
      case 'es':
        return NewsLanguage.es;
      case 'fr':
        return NewsLanguage.fr;
      case 'de':
        return NewsLanguage.de;
      case 'ar':
        return NewsLanguage.ar;
      case 'fa':
        return NewsLanguage.fa;
      default:
        return NewsLanguage.auto;
    }
  }

  void _scheduleScopeSyncIfNeeded({
    required CivicMapController controller,
    required GeoScope? scope,
    required String? scopeKey,
  }) {
    if (scope == null || scopeKey == null) {
      return;
    }

    if (_lastSyncedScopeKey == scopeKey) {
      return;
    }

    _lastSyncedScopeKey = scopeKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.syncScope(scope);
    });
  }

  GeoScope? _readActiveScope(GeoScopeController? controller) {
    if (controller == null) return null;

    try {
      final dynamic dynamicController = controller;

      final dynamic currentScope = dynamicController.currentScope;
      if (currentScope is GeoScope) {
        return currentScope;
      }
    } catch (_) {}

    try {
      final dynamic dynamicController = controller;

      final dynamic selectedScope = dynamicController.selectedScope;
      if (selectedScope is GeoScope) {
        return selectedScope;
      }
    } catch (_) {}

    try {
      final dynamic dynamicController = controller;

      final dynamic scope = dynamicController.scope;
      if (scope is GeoScope) {
        return scope;
      }
    } catch (_) {}

    try {
      final dynamic dynamicController = controller;
      final dynamic state = dynamicController.state;

      if (state != null) {
        try {
          final dynamic currentScope = state.currentScope;
          if (currentScope is GeoScope) {
            return currentScope;
          }
        } catch (_) {}

        try {
          final dynamic selectedScope = state.selectedScope;
          if (selectedScope is GeoScope) {
            return selectedScope;
          }
        } catch (_) {}

        try {
          final dynamic scope = state.scope;
          if (scope is GeoScope) {
            return scope;
          }
        } catch (_) {}
      }
    } catch (_) {}

    return null;
  }

  String _scopeKey(GeoScope scope) {
    final dynamic dynamicScope = scope;

    Object? readSafely(Object? Function() reader) {
      try {
        return reader();
      } catch (_) {
        return null;
      }
    }

    String normalizeText(Object? value) {
      return (value ?? '').toString().trim().toLowerCase();
    }

    String normalizeNum(Object? value) {
      if (value is num) {
        return value.toStringAsFixed(6);
      }
      return '';
    }

    return <String>[
      normalizeText(readSafely(() => dynamicScope.level) ?? scope.level),
      normalizeText(readSafely(() => dynamicScope.id)),
      normalizeText(readSafely(() => dynamicScope.code)),
      normalizeText(readSafely(() => dynamicScope.slug)),
      normalizeText(readSafely(() => dynamicScope.name)),
      normalizeText(readSafely(() => dynamicScope.countryCode)),
      normalizeText(readSafely(() => dynamicScope.countryName)),
      normalizeText(readSafely(() => dynamicScope.cityId)),
      normalizeText(readSafely(() => dynamicScope.cityName)),
      normalizeNum(readSafely(() => dynamicScope.centerLat) ?? scope.centerLat),
      normalizeNum(readSafely(() => dynamicScope.centerLng) ?? scope.centerLng),
      normalizeNum(readSafely(() => dynamicScope.radiusKm) ?? scope.radiusKm),
    ].join('|');
  }

  Future<void> _openTarget(
    BuildContext context,
    CivicMapController controller,
    TargetRef targetRef,
  ) async {
    final targetId = _readTargetRefId(targetRef);
    if (targetId == null || targetId.trim().isEmpty) {
      return;
    }

    switch (targetRef.type) {
      case TargetType.poll:
        await Navigator.of(context).pushNamed(
          AppRouter.pollDetail,
          arguments: PollId(targetId),
        );
        return;

      case TargetType.post:
        await Navigator.of(context).pushNamed(
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

        await Navigator.of(context).push(
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
    final currentScope = appDi.geoScopeController.scope;
    final language = _selectedLanguage == NewsLanguage.auto
        ? null
        : _selectedLanguage.apiValue;

    final attempts = <Future<List<NewsItem>> Function()>[];

    switch (currentScope.level) {
      case GeoScopeLevel.world:
        attempts.add(
          () => appDi.getNewsFeed(
            language: language,
            limit: 100,
            offset: 0,
          ),
        );
        break;

      case GeoScopeLevel.country:
        attempts.add(
          () => appDi.getNewsFeed(
            countryCode: currentScope.countryCode,
            language: language,
            limit: 100,
            offset: 0,
          ),
        );
        attempts.add(
          () => appDi.getNewsFeed(
            language: language,
            limit: 100,
            offset: 0,
          ),
        );
        break;

      case GeoScopeLevel.city:
        attempts.add(
          () => appDi.getNewsFeed(
            countryCode: currentScope.countryCode,
            cityId: currentScope.cityId,
            language: language,
            limit: 100,
            offset: 0,
          ),
        );
        attempts.add(
          () => appDi.getNewsFeed(
            countryCode: currentScope.countryCode,
            language: language,
            limit: 100,
            offset: 0,
          ),
        );
        attempts.add(
          () => appDi.getNewsFeed(
            language: language,
            limit: 100,
            offset: 0,
          ),
        );
        break;
    }

    for (final attempt in attempts) {
      try {
        final items = await attempt();
        for (final item in items) {
          if (_matchesNewsId(item, newsId)) {
            return item;
          }
        }
      } catch (_) {
        // best effort
      }
    }

    return null;
  }

  bool _matchesNewsId(NewsItem item, String newsId) {
    return item.id.value.trim() == newsId.trim();
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

class _MapTopControls extends StatelessWidget {
  final CivicMapController controller;
  final NewsLanguage selectedLanguage;
  final bool languageSelectorEnabled;
  final ValueChanged<NewsLanguage> onLanguageChanged;

  const _MapTopControls({
    required this.controller,
    required this.selectedLanguage,
    required this.languageSelectorEnabled,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final languageSelector = SizedBox(
          width: 250,
          child: _MapLanguageSelector(
            selectedLanguage: selectedLanguage,
            enabled: languageSelectorEnabled,
            onChanged: onLanguageChanged,
          ),
        );

        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _MapTypeFilters(controller: controller),
                ),
              ),
              const SizedBox(width: 12),
              languageSelector,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MapTypeFilters(controller: controller),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: languageSelector,
            ),
          ],
        );
      },
    );
  }
}

class _MapLanguageSelector extends StatelessWidget {
  final NewsLanguage selectedLanguage;
  final bool enabled;
  final ValueChanged<NewsLanguage> onChanged;

  const _MapLanguageSelector({
    required this.selectedLanguage,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<NewsLanguage>(
      initialValue: selectedLanguage,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(Icons.language, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      items: NewsLanguage.values.map((language) {
        return DropdownMenuItem<NewsLanguage>(
          value: language,
          child: Text(_labelForLanguage(language)),
        );
      }).toList(growable: false),
      onChanged: enabled
          ? (value) {
              if (value != null) {
                onChanged(value);
              }
            }
          : null,
    );
  }

  String _labelForLanguage(NewsLanguage language) {
    switch (language) {
      case NewsLanguage.auto:
        return 'Auto';
      case NewsLanguage.it:
        return 'Italiano (IT)';
      case NewsLanguage.en:
        return 'English (EN)';
      case NewsLanguage.es:
        return 'Español (ES)';
      case NewsLanguage.fr:
        return 'Français (FR)';
      case NewsLanguage.de:
        return 'Deutsch (DE)';
      case NewsLanguage.ar:
        return 'العربية (AR)';
      case NewsLanguage.fa:
        return 'فارسی (FA)';
    }
  }
}

class _MarkerPreviewCard extends StatelessWidget {
  final CivicMapItem item;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const _MarkerPreviewCard({
    super.key,
    required this.item,
    required this.onClose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = item.title.trim().isEmpty ? 'Contenuto' : item.title.trim();
    final previewText = _buildPreviewText(item);
    final typeColor = _typeColor(item.type);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.14),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: typeColor.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _CompactBadge(
                          label: _typeLabel(item.type),
                          icon: _typeIcon(item.type),
                          backgroundColor: typeColor.withValues(alpha: 0.12),
                          foregroundColor: typeColor,
                        ),
                        if (item.heatTier != CivicMapHeatTier.normal)
                          _CompactBadge(
                            label: _activityLabel(item.heatTier),
                            icon: _activityIcon(item.heatTier),
                            backgroundColor: _activityColor(item.heatTier)
                                .withValues(alpha: 0.12),
                            foregroundColor: _activityColor(item.heatTier),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Chiudi',
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                    onPressed: onClose,
                    icon: Icon(
                      Icons.close,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            if (previewText != null) ...[
              const SizedBox(height: 8),
              Text(
                previewText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.86),
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _PreviewMetaRow(item: item),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Apri dettaglio'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _buildPreviewText(CivicMapItem item) {
    final raw = item.subtitle?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return raw.replaceAll(RegExp(r'\s+'), ' ');
  }

  Color _typeColor(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Colors.green;
      case CivicMapItemType.post:
        return Colors.blue;
      case CivicMapItemType.news:
        return Colors.red;
    }
  }

  IconData _typeIcon(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Icons.poll_outlined;
      case CivicMapItemType.post:
        return Icons.forum_outlined;
      case CivicMapItemType.news:
        return Icons.newspaper_outlined;
    }
  }

  String _typeLabel(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return 'Poll';
      case CivicMapItemType.post:
        return 'Post';
      case CivicMapItemType.news:
        return 'News';
    }
  }

  String _activityLabel(CivicMapHeatTier tier) {
    switch (tier) {
      case CivicMapHeatTier.hot:
        return 'Hot';
      case CivicMapHeatTier.active:
        return 'Attivo';
      case CivicMapHeatTier.normal:
        return 'Normale';
    }
  }

  IconData _activityIcon(CivicMapHeatTier tier) {
    switch (tier) {
      case CivicMapHeatTier.hot:
        return Icons.local_fire_department;
      case CivicMapHeatTier.active:
        return Icons.trending_up;
      case CivicMapHeatTier.normal:
        return Icons.adjust;
    }
  }

  Color _activityColor(CivicMapHeatTier tier) {
    switch (tier) {
      case CivicMapHeatTier.hot:
        return Colors.deepOrange;
      case CivicMapHeatTier.active:
        return Colors.amber;
      case CivicMapHeatTier.normal:
        return Colors.grey;
    }
  }
}

class _PreviewMetaRow extends StatelessWidget {
  final CivicMapItem item;

  const _PreviewMetaRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final heat = item.normalizedHeat.toInt();
    final comments = item.normalizedCommentCount;
    final timeText = _formatRelativeTime(item.createdAt) ?? '—';

    return DefaultTextStyle(
      style: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
        fontWeight: FontWeight.w600,
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _MetaInlineItem(
            icon: Icons.local_fire_department_outlined,
            text: '$heat',
          ),
          _MetaInlineItem(
            icon: Icons.mode_comment_outlined,
            text: '$comments',
          ),
          _MetaInlineItem(
            icon: Icons.schedule_outlined,
            text: timeText,
          ),
        ],
      ),
    );
  }

  String? _formatRelativeTime(DateTime? value) {
    if (value == null) {
      return null;
    }

    final now = DateTime.now();
    final date = value.toLocal();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'ora';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} h';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} g';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MetaInlineItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaInlineItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}

class _CompactBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _CompactBadge({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
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
      selectedColor: color.withValues(alpha: 0.15),
      checkmarkColor: color,
      side: BorderSide(
        color: active
            ? color.withValues(alpha: 0.45)
            : Colors.grey.withValues(alpha: 0.25),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/search/entities/search_result_item.dart';
import 'package:sociale_vote/domain/search/value_objects/search_filters.dart';
import 'package:sociale_vote/domain/search/value_objects/search_query.dart';
import 'package:sociale_vote/features/search/application/search_controller.dart'
    as app_search;
import 'package:sociale_vote/features/profile/presentation/pages/public_user_profile_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/ui/app_button.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';
import 'package:sociale_vote/shared/ui/loading_indicator.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const double _maxContentWidth = 1120;
  static const double _stateCardMaxWidth = 480;
  static const double _singleRowFiltersMinWidth = 720;

  final TextEditingController _queryController = TextEditingController();
  SearchContentType _selectedType = SearchContentType.all;
  SearchSort _selectedSort = SearchSort.hottest;
  PollStatusFilter _selectedPollStatus = PollStatusFilter.all;
  String? _openingTargetKey;

  bool get _hasNonDefaultFilters =>
      _selectedType != SearchContentType.all ||
      _selectedSort != SearchSort.hottest ||
      _selectedPollStatus != PollStatusFilter.all;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onSubmit(app_search.SearchController controller) {
    final raw = _queryController.text.trim();

    controller.setContentType(_selectedType);
    controller.setSort(_selectedSort);

    if (_selectedType == SearchContentType.poll ||
        _selectedType == SearchContentType.all) {
      controller.setPollStatus(_selectedPollStatus);
    } else {
      controller.setPollStatus(PollStatusFilter.all);
    }

    controller.search(
      rawQuery: raw,
      type: _selectedType,
    );
  }

  void _clearSearch(app_search.SearchController controller) {
    _queryController.clear();
    controller.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedType = SearchContentType.all;
      _selectedSort = SearchSort.hottest;
      _selectedPollStatus = PollStatusFilter.all;
    });
  }

  void _updateType(
    app_search.SearchController controller,
    SearchContentType type,
  ) {
    setState(() {
      _selectedType = type;
      if (type != SearchContentType.poll && type != SearchContentType.all) {
        _selectedPollStatus = PollStatusFilter.all;
      }
    });

    controller.setContentType(type);
    if (_queryController.text.trim().isNotEmpty) {
      _onSubmit(controller);
    }
  }

  void _updateSort(
    app_search.SearchController controller,
    SearchSort sort,
  ) {
    setState(() {
      _selectedSort = sort;
    });

    controller.setSort(sort);
    if (_queryController.text.trim().isNotEmpty) {
      _onSubmit(controller);
    }
  }

  void _updatePollStatus(
    app_search.SearchController controller,
    PollStatusFilter status,
  ) {
    setState(() {
      _selectedPollStatus = status;
    });

    controller.setPollStatus(status);
    if (_queryController.text.trim().isNotEmpty) {
      _onSubmit(controller);
    }
  }

  Future<void> _openResult(SearchResultItem item) async {
    if (_openingTargetKey != null) {
      return;
    }

    setState(() {
      _openingTargetKey = item.target.key;
    });

    try {
      switch (item.contentType) {
        case SearchContentType.poll:
          await Navigator.of(context).pushNamed(
            AppRouter.pollDetail,
            arguments: item.target.id,
          );
          break;

        case SearchContentType.post:
          await Navigator.of(context).pushNamed(
            AppRouter.socialDetail,
            arguments: item.target.id,
          );
          break;

        case SearchContentType.news:
          final scope = AppDI.instance.geoScopeController.scope;
          final newsItems = await AppDI.instance.getNewsFeed(
            countryCode: scope.countryCode,
            cityId: scope.cityId,
          );

          NewsItem? news;
          for (final candidate in newsItems) {
            if (candidate.id.value == item.target.id) {
              news = candidate;
              break;
            }
          }

          news ??= await AppDI.instance.getNewsDetail(
            EntityId(item.target.id),
          );

          if (!mounted) {
            return;
          }

          await Navigator.of(context).pushNamed(
            AppRouter.newsDetail,
            arguments: news,
          );
          break;

        case SearchContentType.account:
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PublicUserProfilePage(
                userId: item.target.id,
              ),
            ),
          );
          break;

        case SearchContentType.all:
          throw StateError('Unsupported mixed search result');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.searchContentUnavailable),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingTargetKey = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final pageBackground = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: isDark ? 0.035 : 0.012),
      theme.scaffoldBackgroundColor,
    );

    return ChangeNotifierProvider<app_search.SearchController>(
      create: (_) => AppDI.instance.createSearchController(),
      child: Consumer<app_search.SearchController>(
        builder: (context, controller, _) {
          final canClear = _queryController.text.isNotEmpty ||
              _hasNonDefaultFilters ||
              !controller.isIdle;

          return Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              backgroundColor: pageBackground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(l10n.searchPageTitle),
            ),
            body: ColoredBox(
              color: pageBackground,
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _maxContentWidth,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pagePadding,
                              AppSpacing.s,
                              AppSpacing.pagePadding,
                              AppSpacing.xs,
                            ),
                            child: AppCard(
                              padding: const EdgeInsets.all(AppSpacing.s),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _queryController,
                                          textInputAction:
                                              TextInputAction.search,
                                          onChanged: (_) => setState(() {}),
                                          onSubmitted: (_) {
                                            FocusScope.of(context).unfocus();
                                            _onSubmit(controller);
                                          },
                                          decoration: InputDecoration(
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            hintText: l10n.searchInputHint,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      SizedBox.square(
                                        dimension: 44,
                                        child: IconButton(
                                          onPressed: canClear
                                              ? () => _clearSearch(controller)
                                              : null,
                                          tooltip: l10n.searchClearTooltip,
                                          icon: const Icon(Icons.close),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.s),
                                  _HorizontalChipGroup(
                                    children: [
                                      _TypeFilterChip(
                                        label: l10n.searchTypeAll,
                                        type: SearchContentType.all,
                                        selectedType: _selectedType,
                                        onSelected: (type) =>
                                            _updateType(controller, type),
                                      ),
                                      _TypeFilterChip(
                                        label: l10n.searchTypePolls,
                                        type: SearchContentType.poll,
                                        selectedType: _selectedType,
                                        onSelected: (type) =>
                                            _updateType(controller, type),
                                      ),
                                      _TypeFilterChip(
                                        label: l10n.searchTypeNews,
                                        type: SearchContentType.news,
                                        selectedType: _selectedType,
                                        onSelected: (type) =>
                                            _updateType(controller, type),
                                      ),
                                      _TypeFilterChip(
                                        label: l10n.searchTypePosts,
                                        type: SearchContentType.post,
                                        selectedType: _selectedType,
                                        onSelected: (type) =>
                                            _updateType(controller, type),
                                      ),
                                      _TypeFilterChip(
                                        label: l10n.searchTypeAccounts,
                                        type: SearchContentType.account,
                                        selectedType: _selectedType,
                                        onSelected: (type) =>
                                            _updateType(controller, type),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final sortChips = <Widget>[
                                        _SortFilterChip(
                                          label: l10n.searchSortHottest,
                                          sort: SearchSort.hottest,
                                          selectedSort: _selectedSort,
                                          onSelected: (sort) => _updateSort(
                                            controller,
                                            sort,
                                          ),
                                        ),
                                        _SortFilterChip(
                                          label: l10n.searchSortLatest,
                                          sort: SearchSort.latest,
                                          selectedSort: _selectedSort,
                                          onSelected: (sort) => _updateSort(
                                            controller,
                                            sort,
                                          ),
                                        ),
                                      ];

                                      final showsPollStatus = _selectedType ==
                                              SearchContentType.poll ||
                                          _selectedType ==
                                              SearchContentType.all;

                                      if (!showsPollStatus) {
                                        return _HorizontalChipGroup(
                                          children: sortChips,
                                        );
                                      }

                                      final pollStatusChips = <Widget>[
                                        _PollStatusFilterChip(
                                          label: l10n.searchPollStatusAll,
                                          status: PollStatusFilter.all,
                                          selectedStatus: _selectedPollStatus,
                                          onSelected: (status) =>
                                              _updatePollStatus(
                                            controller,
                                            status,
                                          ),
                                        ),
                                        _PollStatusFilterChip(
                                          label: l10n.searchPollStatusOpen,
                                          status: PollStatusFilter.open,
                                          selectedStatus: _selectedPollStatus,
                                          onSelected: (status) =>
                                              _updatePollStatus(
                                            controller,
                                            status,
                                          ),
                                        ),
                                        _PollStatusFilterChip(
                                          label: l10n.searchPollStatusClosed,
                                          status: PollStatusFilter.closed,
                                          selectedStatus: _selectedPollStatus,
                                          onSelected: (status) =>
                                              _updatePollStatus(
                                            controller,
                                            status,
                                          ),
                                        ),
                                      ];

                                      if (constraints.maxWidth >=
                                          _singleRowFiltersMinWidth) {
                                        return Row(
                                          children: [
                                            _InlineChipGroup(
                                              children: sortChips,
                                            ),
                                            const Spacer(),
                                            _InlineChipGroup(
                                              children: pollStatusChips,
                                            ),
                                          ],
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _HorizontalChipGroup(
                                            children: sortChips,
                                          ),
                                          const SizedBox(
                                            height: AppSpacing.xs,
                                          ),
                                          _HorizontalChipGroup(
                                            children: pollStatusChips,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: _buildResultsArea(
                                context: context,
                                controller: controller,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsArea({
    required BuildContext context,
    required app_search.SearchController controller,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (controller.isIdle) {
      return _SearchStateView(
        key: const ValueKey<String>('search-idle'),
        icon: Icons.manage_search_rounded,
        message: l10n.searchIdleMessage,
      );
    }

    if (controller.isLoading && controller.results.isEmpty) {
      return const Center(
        key: ValueKey<String>('search-loading'),
        child: LoadingIndicator(),
      );
    }

    if (controller.hasError) {
      return _SearchStateView(
        key: const ValueKey<String>('search-error'),
        icon: Icons.error_outline_rounded,
        message: l10n.searchErrorMessage,
        actionLabel: l10n.searchRetryButton,
        onAction: controller.retry,
      );
    }

    if (!controller.isLoading && controller.results.isEmpty) {
      return _SearchStateView(
        key: const ValueKey<String>('search-empty'),
        icon: Icons.search_off_rounded,
        message: l10n.searchEmptyMessage,
      );
    }

    final results = controller.results;

    return Column(
      key: const ValueKey<String>('search-results'),
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 140),
          child: controller.isLoading
              ? const LinearProgressIndicator(
                  key: ValueKey<String>('search-refreshing'),
                  minHeight: 2,
                )
              : const SizedBox(
                  key: ValueKey<String>('search-not-refreshing'),
                  height: 2,
                ),
        ),
        Expanded(
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.xxs,
              AppSpacing.pagePadding,
              AppSpacing.pagePadding,
            ),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final item = results[index];
              final isOpening = _openingTargetKey == item.target.key;
              final isNavigationLocked = _openingTargetKey != null;

              return _SearchResultTile(
                item: item,
                isOpening: isOpening,
                onTap: isNavigationLocked ? null : () => _openResult(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HorizontalChipGroup extends StatelessWidget {
  final List<Widget> children;

  const _HorizontalChipGroup({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.xs),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _InlineChipGroup extends StatelessWidget {
  final List<Widget> children;

  const _InlineChipGroup({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.xs),
          children[index],
        ],
      ],
    );
  }
}

class _TypeFilterChip extends StatelessWidget {
  final String label;
  final SearchContentType type;
  final SearchContentType selectedType;
  final ValueChanged<SearchContentType> onSelected;

  const _TypeFilterChip({
    required this.label,
    required this.type,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = type == selectedType;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      checkmarkColor:
          isDark ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
      onSelected: (_) => onSelected(type),
    );
  }
}

class _SortFilterChip extends StatelessWidget {
  final String label;
  final SearchSort sort;
  final SearchSort selectedSort;
  final ValueChanged<SearchSort> onSelected;

  const _SortFilterChip({
    required this.label,
    required this.sort,
    required this.selectedSort,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = sort == selectedSort;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      checkmarkColor:
          isDark ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
      onSelected: (_) => onSelected(sort),
    );
  }
}

class _PollStatusFilterChip extends StatelessWidget {
  final String label;
  final PollStatusFilter status;
  final PollStatusFilter selectedStatus;
  final ValueChanged<PollStatusFilter> onSelected;

  const _PollStatusFilterChip({
    required this.label,
    required this.status,
    required this.selectedStatus,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = status == selectedStatus;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      checkmarkColor:
          isDark ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
      onSelected: (_) => onSelected(status),
    );
  }
}

class _SearchStateView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  const _SearchStateView({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _SearchPageState._stateCardMaxWidth,
          ),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.76),
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  AppButton.secondary(
                    label: actionLabel!,
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      onAction!();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResultItem item;
  final bool isOpening;
  final VoidCallback? onTap;

  const _SearchResultTile({
    required this.item,
    required this.isOpening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = _labelForType(context, item.contentType);
    final dateText = _formatDate(context, item.date);
    final palette = _paletteForType(context, item.contentType);

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '$typeLabel: ${item.title}',
      child: SizedBox(
        width: double.infinity,
        child: AppCard(
          onTap: onTap,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _SearchTypeBadge(
                            icon: _iconForType(item.contentType),
                            label: typeLabel,
                            foregroundColor: palette.foreground,
                            backgroundColor: palette.background,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      if (isOpening)
                        const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else if (dateText != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.58),
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              dateText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.66),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  item.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (item.hasSnippet) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.snippet!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.76),
                      height: 1.35,
                    ),
                  ),
                ],
                if (item.contentType == SearchContentType.account &&
                    item.heat != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 15,
                        color: colorScheme.onSurface.withValues(alpha: 0.62),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        '${item.heat} ${l10n.publicProfileFollowersLabel}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForType(SearchContentType type) {
    switch (type) {
      case SearchContentType.poll:
        return Icons.how_to_vote_rounded;
      case SearchContentType.news:
        return Icons.article_rounded;
      case SearchContentType.post:
        return Icons.forum_rounded;
      case SearchContentType.account:
        return Icons.person_search_rounded;
      case SearchContentType.all:
        return Icons.search_rounded;
    }
  }

  String _labelForType(BuildContext context, SearchContentType type) {
    final l10n = AppLocalizations.of(context)!;

    switch (type) {
      case SearchContentType.poll:
        return l10n.searchResultTypePoll;
      case SearchContentType.news:
        return l10n.searchResultTypeNews;
      case SearchContentType.post:
        return l10n.searchResultTypePost;
      case SearchContentType.account:
        return l10n.searchResultTypeAccount;
      case SearchContentType.all:
        return l10n.searchResultTypeMixed;
    }
  }

  _SearchTypePalette _paletteForType(
    BuildContext context,
    SearchContentType type,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case SearchContentType.poll:
        return _SearchTypePalette(
          foreground: AppColors.success,
          background: isDark
              ? AppColors.successSoftBackgroundDark
              : AppColors.successSoftBackground,
        );
      case SearchContentType.news:
        return _SearchTypePalette(
          foreground: AppColors.heat,
          background: isDark
              ? AppColors.heatSoftBackgroundDark
              : AppColors.heatSoftBackground,
        );
      case SearchContentType.post:
      case SearchContentType.account:
      case SearchContentType.all:
        return _SearchTypePalette(
          foreground: isDark
              ? AppColors.primarySoftForegroundDark
              : AppColors.primarySoftForeground,
          background: isDark
              ? AppColors.primarySoftBackgroundDark
              : AppColors.primarySoftBackground,
        );
    }
  }

  String? _formatDate(BuildContext context, DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }

    final local = dateTime.toLocal();
    final materialLocalizations = MaterialLocalizations.of(context);
    final date = materialLocalizations.formatCompactDate(local);
    final time = materialLocalizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    return '$date $time';
  }
}

class _SearchTypeBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  const _SearchTypeBadge({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.pillRadius,
        border: Border.all(
          color: foregroundColor.withValues(alpha: 0.26),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: foregroundColor,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTypePalette {
  final Color foreground;
  final Color background;

  const _SearchTypePalette({
    required this.foreground,
    required this.background,
  });
}

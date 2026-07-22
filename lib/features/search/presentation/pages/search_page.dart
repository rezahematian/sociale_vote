import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/search/entities/search_result_item.dart';
import 'package:sociale_vote/domain/search/value_objects/search_filters.dart';
import 'package:sociale_vote/domain/search/value_objects/search_query.dart';
import 'package:sociale_vote/features/search/application/search_controller.dart'
    as app_search;
import 'package:sociale_vote/l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const double _maxContentWidth = 1120;
  static const double _singleRowFiltersMinWidth = 720;

  final TextEditingController _queryController = TextEditingController();
  SearchContentType _selectedType = SearchContentType.all;
  SearchSort _selectedSort = SearchSort.hottest;
  PollStatusFilter _selectedPollStatus = PollStatusFilter.all;
  String? _openingTargetKey;

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
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<app_search.SearchController>(
      create: (_) => AppDI.instance.createSearchController(),
      child: Consumer<app_search.SearchController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.searchPageTitle),
            ),
            body: ColoredBox(
              color: theme.scaffoldBackgroundColor,
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
                              AppSpacing.xxs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _queryController,
                                    textInputAction: TextInputAction.search,
                                    onSubmitted: (_) => _onSubmit(controller),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search),
                                      hintText: l10n.searchInputHint,
                                      isDense: true,
                                      border: const OutlineInputBorder(
                                        borderRadius: AppRadius.inputRadius,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                IconButton(
                                  onPressed: () {
                                    _queryController.clear();
                                    controller.clear();

                                    setState(() {
                                      _selectedType = SearchContentType.all;
                                      _selectedSort = SearchSort.hottest;
                                      _selectedPollStatus =
                                          PollStatusFilter.all;
                                    });
                                  },
                                  tooltip: l10n.searchClearTooltip,
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pagePadding,
                              vertical: AppSpacing.xxs,
                            ),
                            child: _HorizontalChipGroup(
                              children: [
                                _TypeFilterChip(
                                  label: l10n.searchTypeAll,
                                  type: SearchContentType.all,
                                  selectedType: _selectedType,
                                  onSelected: (type) {
                                    setState(() {
                                      _selectedType = type;
                                      if (_selectedType !=
                                              SearchContentType.poll &&
                                          _selectedType !=
                                              SearchContentType.all) {
                                        _selectedPollStatus =
                                            PollStatusFilter.all;
                                      }
                                    });
                                    controller.setContentType(type);
                                    if (_queryController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _onSubmit(controller);
                                    }
                                  },
                                ),
                                _TypeFilterChip(
                                  label: l10n.searchTypePolls,
                                  type: SearchContentType.poll,
                                  selectedType: _selectedType,
                                  onSelected: (type) {
                                    setState(() {
                                      _selectedType = type;
                                    });
                                    controller.setContentType(type);
                                    if (_queryController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _onSubmit(controller);
                                    }
                                  },
                                ),
                                _TypeFilterChip(
                                  label: l10n.searchTypeNews,
                                  type: SearchContentType.news,
                                  selectedType: _selectedType,
                                  onSelected: (type) {
                                    setState(() {
                                      _selectedType = type;
                                      _selectedPollStatus =
                                          PollStatusFilter.all;
                                    });
                                    controller.setContentType(type);
                                    if (_queryController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _onSubmit(controller);
                                    }
                                  },
                                ),
                                _TypeFilterChip(
                                  label: l10n.searchTypePosts,
                                  type: SearchContentType.post,
                                  selectedType: _selectedType,
                                  onSelected: (type) {
                                    setState(() {
                                      _selectedType = type;
                                      _selectedPollStatus =
                                          PollStatusFilter.all;
                                    });
                                    controller.setContentType(type);
                                    if (_queryController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _onSubmit(controller);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pagePadding,
                              vertical: AppSpacing.xxs,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final sortFilters = _HorizontalChipGroup(
                                  children: [
                                    _SortFilterChip(
                                      label: l10n.searchSortHottest,
                                      sort: SearchSort.hottest,
                                      selectedSort: _selectedSort,
                                      onSelected: (sort) {
                                        setState(() {
                                          _selectedSort = sort;
                                        });
                                        controller.setSort(sort);
                                        if (_queryController.text
                                            .trim()
                                            .isNotEmpty) {
                                          _onSubmit(controller);
                                        }
                                      },
                                    ),
                                    _SortFilterChip(
                                      label: l10n.searchSortLatest,
                                      sort: SearchSort.latest,
                                      selectedSort: _selectedSort,
                                      onSelected: (sort) {
                                        setState(() {
                                          _selectedSort = sort;
                                        });
                                        controller.setSort(sort);
                                        if (_queryController.text
                                            .trim()
                                            .isNotEmpty) {
                                          _onSubmit(controller);
                                        }
                                      },
                                    ),
                                  ],
                                );

                                final showsPollStatus =
                                    _selectedType == SearchContentType.poll ||
                                        _selectedType == SearchContentType.all;

                                if (!showsPollStatus) {
                                  return sortFilters;
                                }

                                final pollStatusFilters = _HorizontalChipGroup(
                                  children: [
                                    _PollStatusFilterChip(
                                      label: l10n.searchPollStatusAll,
                                      status: PollStatusFilter.all,
                                      selectedStatus: _selectedPollStatus,
                                      onSelected: (status) {
                                        setState(() {
                                          _selectedPollStatus = status;
                                        });
                                        controller.setPollStatus(status);
                                        if (_queryController.text
                                            .trim()
                                            .isNotEmpty) {
                                          _onSubmit(controller);
                                        }
                                      },
                                    ),
                                    _PollStatusFilterChip(
                                      label: l10n.searchPollStatusOpen,
                                      status: PollStatusFilter.open,
                                      selectedStatus: _selectedPollStatus,
                                      onSelected: (status) {
                                        setState(() {
                                          _selectedPollStatus = status;
                                        });
                                        controller.setPollStatus(status);
                                        if (_queryController.text
                                            .trim()
                                            .isNotEmpty) {
                                          _onSubmit(controller);
                                        }
                                      },
                                    ),
                                    _PollStatusFilterChip(
                                      label: l10n.searchPollStatusClosed,
                                      status: PollStatusFilter.closed,
                                      selectedStatus: _selectedPollStatus,
                                      onSelected: (status) {
                                        setState(() {
                                          _selectedPollStatus = status;
                                        });
                                        controller.setPollStatus(status);
                                        if (_queryController.text
                                            .trim()
                                            .isNotEmpty) {
                                          _onSubmit(controller);
                                        }
                                      },
                                    ),
                                  ],
                                );

                                if (constraints.maxWidth >=
                                    _singleRowFiltersMinWidth) {
                                  return Row(
                                    children: [
                                      Expanded(child: sortFilters),
                                      const SizedBox(width: AppSpacing.m),
                                      Expanded(child: pollStatusFilters),
                                    ],
                                  );
                                }

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    sortFilters,
                                    const SizedBox(height: AppSpacing.xs),
                                    pollStatusFilters,
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Expanded(
                            child: _buildResultsArea(
                              context: context,
                              controller: controller,
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (controller.isIdle) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
          ),
          child: Text(
            l10n.searchIdleMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (controller.isLoading && controller.results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.searchErrorMessage,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s),
              ElevatedButton.icon(
                onPressed: controller.retry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.searchRetryButton),
              ),
            ],
          ),
        ),
      );
    }

    if (!controller.isLoading && controller.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
          ),
          child: Text(
            l10n.searchEmptyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final results = controller.results;

    return ListView.separated(
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

        return _SearchResultTile(
          item: item,
          isOpening: isOpening,
          onTap: isOpening ? null : () => _openResult(item),
        );
      },
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

    return ChoiceChip(
      label: Text(label),
      selected: selected,
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

    return ChoiceChip(
      label: Text(label),
      selected: selected,
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

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(status),
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

    final icon = _iconForType(item.contentType);
    final typeLabel = _labelForType(context, item.contentType);
    final dateText = _formatDate(context, item.date);

    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.inputRadius,
      ),
      child: InkWell(
        borderRadius: AppRadius.inputRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    typeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (isOpening)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else if (dateText != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      dateText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.hasSnippet) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.snippet!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(SearchContentType type) {
    switch (type) {
      case SearchContentType.poll:
        return Icons.how_to_vote;
      case SearchContentType.news:
        return Icons.article;
      case SearchContentType.post:
        return Icons.forum;
      case SearchContentType.all:
        return Icons.search;
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
      case SearchContentType.all:
        return l10n.searchResultTypeMixed;
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

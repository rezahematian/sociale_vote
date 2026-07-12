import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/search/entities/search_result_item.dart';
import 'package:sociale_vote/domain/search/value_objects/search_query.dart';
import 'package:sociale_vote/domain/search/value_objects/search_filters.dart';
import 'package:sociale_vote/features/search/application/search_controller.dart'
    as app_search;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _queryController = TextEditingController();
  SearchContentType _selectedType = SearchContentType.all;

  // Nuovi stati locale per i filtri
  SearchSort _selectedSort = SearchSort.hottest;
  PollStatusFilter _selectedPollStatus = PollStatusFilter.all;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onSubmit(app_search.SearchController controller) {
    final raw = _queryController.text.trim();

    // Sync filtri nel controller prima di eseguire la ricerca
    controller.setContentType(_selectedType);
    controller.setSort(_selectedSort);

    // Filtro Poll open/closed ha senso solo per Poll / All
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<app_search.SearchController>(
      create: (_) => AppDI.instance.createSearchController(),
      child: Consumer<app_search.SearchController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Search'),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // ========= SEARCH BAR + CLEAR =========
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _queryController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _onSubmit(controller),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Search polls, news, posts...',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _queryController.clear();
                            controller.clear();

                            setState(() {
                              _selectedType = SearchContentType.all;
                              _selectedSort = SearchSort.hottest;
                              _selectedPollStatus = PollStatusFilter.all;
                            });
                          },
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  // ========= FILTER CHIPS (CONTENT TYPE) =========
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _TypeFilterChip(
                            label: 'All',
                            type: SearchContentType.all,
                            selectedType: _selectedType,
                            onSelected: (t) {
                              setState(() {
                                _selectedType = t;
                                // Per sicurezza, se usciamo dal mondo Poll,
                                // azzeriamo il filtro stato poll.
                                if (_selectedType != SearchContentType.poll &&
                                    _selectedType != SearchContentType.all) {
                                  _selectedPollStatus = PollStatusFilter.all;
                                }
                              });
                              controller.setContentType(t);
                              if (_queryController.text.trim().isNotEmpty) {
                                _onSubmit(controller);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _TypeFilterChip(
                            label: 'Polls',
                            type: SearchContentType.poll,
                            selectedType: _selectedType,
                            onSelected: (t) {
                              setState(() {
                                _selectedType = t;
                              });
                              controller.setContentType(t);
                              if (_queryController.text.trim().isNotEmpty) {
                                _onSubmit(controller);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _TypeFilterChip(
                            label: 'News',
                            type: SearchContentType.news,
                            selectedType: _selectedType,
                            onSelected: (t) {
                              setState(() {
                                _selectedType = t;
                                if (_selectedType != SearchContentType.poll &&
                                    _selectedType != SearchContentType.all) {
                                  _selectedPollStatus = PollStatusFilter.all;
                                }
                              });
                              controller.setContentType(t);
                              if (_queryController.text.trim().isNotEmpty) {
                                _onSubmit(controller);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _TypeFilterChip(
                            label: 'Posts',
                            type: SearchContentType.post,
                            selectedType: _selectedType,
                            onSelected: (t) {
                              setState(() {
                                _selectedType = t;
                                if (_selectedType != SearchContentType.poll &&
                                    _selectedType != SearchContentType.all) {
                                  _selectedPollStatus = PollStatusFilter.all;
                                }
                              });
                              controller.setContentType(t);
                              if (_queryController.text.trim().isNotEmpty) {
                                _onSubmit(controller);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ========= FILTER BAR (SORT + POLL STATUS) =========
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        // Sort (Latest / Hottest)
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _SortFilterChip(
                                label: 'Hottest',
                                sort: SearchSort.hottest,
                                selectedSort: _selectedSort,
                                onSelected: (s) {
                                  setState(() {
                                    _selectedSort = s;
                                  });
                                  controller.setSort(s);
                                  if (_queryController.text.trim().isNotEmpty) {
                                    _onSubmit(controller);
                                  }
                                },
                              ),
                              _SortFilterChip(
                                label: 'Latest',
                                sort: SearchSort.latest,
                                selectedSort: _selectedSort,
                                onSelected: (s) {
                                  setState(() {
                                    _selectedSort = s;
                                  });
                                  controller.setSort(s);
                                  if (_queryController.text.trim().isNotEmpty) {
                                    _onSubmit(controller);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        // Poll status (All / Open / Closed) → solo per Poll / All
                        if (_selectedType == SearchContentType.poll ||
                            _selectedType == SearchContentType.all) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _PollStatusFilterChip(
                                  label: 'All Polls',
                                  status: PollStatusFilter.all,
                                  selectedStatus: _selectedPollStatus,
                                  onSelected: (s) {
                                    setState(() {
                                      _selectedPollStatus = s;
                                    });
                                    controller.setPollStatus(s);
                                    if (_queryController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _onSubmit(controller);
                                    }
                                  },
                                ),
                                _PollStatusFilterChip(
                                  label: 'Open',
                                  status: PollStatusFilter.open,
                                  selectedStatus: _selectedPollStatus,
                                  onSelected: (s) {
                                    setState(() {
                                      _selectedPollStatus = s;
                                    });
                                    controller.setPollStatus(s);
                                    if (_queryController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _onSubmit(controller);
                                    }
                                  },
                                ),
                                _PollStatusFilterChip(
                                  label: 'Closed',
                                  status: PollStatusFilter.closed,
                                  selectedStatus: _selectedPollStatus,
                                  onSelected: (s) {
                                    setState(() {
                                      _selectedPollStatus = s;
                                    });
                                    controller.setPollStatus(s);
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
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ========= RESULTS / STATES =========
                  Expanded(
                    child: _buildResultsArea(
                      context: context,
                      controller: controller,
                    ),
                  ),
                ],
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

    if (controller.isIdle) {
      return Center(
        child: Text(
          'Digita qualcosa per iniziare una ricerca.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Si è verificato un errore durante la ricerca.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                controller.errorMessage ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: controller.retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    if (!controller.isLoading && controller.results.isEmpty) {
      return Center(
        child: Text(
          'Nessun risultato trovato per questa ricerca.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    final results = controller.results;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = results[index];
        return _SearchResultTile(item: item);
      },
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

  const _SearchResultTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final icon = _iconForType(item.contentType);
    final typeLabel = _labelForType(item.contentType);
    final dateText = _formatDate(item.date);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // V1: niente navigazione complessa.
          // In futuro: router verso PollDetail / NewsDetail / PostDetail.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Open ${typeLabel.toLowerCase()}: ${item.title}',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type + date
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
                  if (dateText != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 4),
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
                const SizedBox(height: 4),
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

  String _labelForType(SearchContentType type) {
    switch (type) {
      case SearchContentType.poll:
        return 'Poll';
      case SearchContentType.news:
        return 'News';
      case SearchContentType.post:
        return 'Post';
      case SearchContentType.all:
        return 'Mixed';
    }
  }

  String? _formatDate(DateTime? dateTime) {
    if (dateTime == null) return null;
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';
import 'package:sociale_vote/shared/ui/loading_indicator.dart';

class PollListPage extends StatefulWidget {
  const PollListPage({super.key});

  @override
  State<PollListPage> createState() => _PollListPageState();
}

class _PollListPageState extends State<PollListPage> {
  final ScrollController _scrollController = ScrollController();
  late final PollListController _pollListController;

  StreamSubscription<String?>? _sessionSub;
  String? _openingPollId;

  static const double _singleRowFiltersMinWidth = 720;
  static const double _compactHeaderMaxWidth = 620;

  @override
  void initState() {
    super.initState();
    _pollListController = AppDI.instance.createPollListController();

    _reloadPolls();

    _scrollController.addListener(_onScroll);
    _sessionSub =
        AppDI.instance.sessionRepository.watchCurrentUserId().listen((_) {
      _reloadPolls();
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pollListController.dispose();
    super.dispose();
  }

  Future<void> _reloadPolls() async {
    final userId = AppDI.instance.currentUserId;
    await _pollListController.loadPolls(userId: userId);
  }

  Future<void> _openPollDetail(
    Poll poll, {
    bool openCommentsOnLoad = false,
  }) async {
    if (_openingPollId != null) return;

    setState(() {
      _openingPollId = poll.id.value;
    });

    try {
      await Navigator.of(context).pushNamed(
        AppRouter.pollDetail,
        arguments: openCommentsOnLoad
            ? {
                'pollId': poll.id,
                'openCommentsOnLoad': true,
              }
            : poll.id,
      );

      if (!mounted) return;

      final userId = AppDI.instance.currentUserId;
      await _pollListController.loadPolls(userId: userId);
    } finally {
      if (mounted) {
        setState(() {
          _openingPollId = null;
        });
      }
    }
  }

  void _onScroll() {
    if (_pollListController.isLoading) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      if (_pollListController.hasMoreFromSource) {
        _pollListController.loadMorePolls();
      }
    }
  }

  String _scopeShortLabel(
    BuildContext context,
    AppLocalizations l10n,
    GeoScope scope,
  ) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.pollList_scopeWorld;
      case GeoScopeLevel.country:
        final countryCode = scope.countryCode?.trim();
        if (countryCode == null || countryCode.isEmpty) {
          return l10n.pollList_scopeCountryFallback;
        }

        return Countries.nameForCode(
          countryCode,
          languageCode: Localizations.localeOf(context).languageCode,
          fallback: countryCode.toUpperCase(),
        );
      case GeoScopeLevel.city:
        final cityId = scope.cityId?.trim();
        if (cityId == null || cityId.isEmpty) {
          return l10n.pollList_scopeCityFallback;
        }

        return _humanizeScopeValue(cityId);
    }
  }

  String _humanizeScopeValue(String value) {
    final words = value
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);

    return words
        .map(
          (word) => word.length == 1
              ? word.toUpperCase()
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  String _scopeDescription(AppLocalizations l10n, GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.pollList_scopeDescriptionGlobal;
      case GeoScopeLevel.country:
        return l10n.pollList_scopeDescriptionCountry;
      case GeoScopeLevel.city:
        return l10n.pollList_scopeDescriptionCity;
    }
  }

  String _statusFilterLabel(
    AppLocalizations l10n,
    PollStatusFilter filter,
  ) {
    switch (filter) {
      case PollStatusFilter.all:
        return l10n.pollList_filterStatus_all;
      case PollStatusFilter.open:
        return l10n.pollList_filterStatus_open;
      case PollStatusFilter.closed:
        return l10n.pollList_filterStatus_closed;
    }
  }

  String _sortModeLabel(AppLocalizations l10n, PollSortMode mode) {
    switch (mode) {
      case PollSortMode.latest:
        return l10n.pollList_sort_latest;
      case PollSortMode.hottest:
        return l10n.pollList_sort_hottest;
    }
  }

  Future<void> _openCreatePoll() async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.createPoll,
    );
    if (!allowed || !mounted) return;

    final result = await Navigator.of(context).pushNamed(AppRouter.createPoll);

    if (!mounted) return;

    final pollListController = _pollListController;
    final userId = AppDI.instance.currentUserId;

    if (result is PollId) {
      await pollListController.loadPolls(userId: userId);

      if (!mounted) return;

      await Navigator.of(context).pushNamed(
        AppRouter.pollDetail,
        arguments: result,
      );

      if (!mounted) return;

      await pollListController.loadPolls(userId: userId);
    } else if (result == true) {
      await pollListController.loadPolls(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PollListController>.value(
      value: _pollListController,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(context);
          final surfaceVisible = TickerMode.valuesOf(context).enabled;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pollListController.setSurfaceVisible(surfaceVisible);
          });
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          final pageBackground = Color.alphaBlend(
            colorScheme.primary.withValues(alpha: isDark ? 0.035 : 0.012),
            theme.scaffoldBackgroundColor,
          );

          return Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              backgroundColor: pageBackground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(l10n.pollList_title),
            ),
            body: Consumer<PollListController>(
              builder: (context, controller, _) {
                final scope = AppDI.instance.geoScopeController.scope;
                final scopeLabel = _scopeShortLabel(context, l10n, scope);
                final scopeDescription = _scopeDescription(l10n, scope);

                final visiblePolls = controller.polls;
                final hasMore = controller.hasMoreFromSource;

                return ColoredBox(
                  color: pageBackground,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: RefreshIndicator(
                        onRefresh: _reloadPolls,
                        child: ListView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePadding,
                            AppSpacing.xs,
                            AppSpacing.pagePadding,
                            AppSpacing.l,
                          ),
                          children: [
                            _buildScopeHeader(
                              context,
                              l10n: l10n,
                              scopeLabel: scopeLabel,
                              scopeDescription: scopeDescription,
                              pollCount: visiblePolls.length,
                            ),
                            const SizedBox(height: 14),
                            _buildFiltersBlock(context, controller),
                            const SizedBox(height: 18),
                            if (controller.isLoading && visiblePolls.isEmpty)
                              const LoadingIndicator(
                                padding: EdgeInsets.only(top: AppSpacing.l),
                              ),
                            if (!controller.isLoading && visiblePolls.isEmpty)
                              _buildEmptyStateCard(context),
                            if (visiblePolls.isNotEmpty)
                              ...visiblePolls.map(
                                (poll) {
                                  final fire =
                                      controller.likeCountForPoll(poll);
                                  final ice =
                                      controller.dislikeCountForPoll(poll);
                                  final userReaction =
                                      controller.userReactionForPoll(poll);

                                  return PollCard(
                                    poll: poll,
                                    onTap: _openingPollId == null
                                        ? () async {
                                            await _openPollDetail(poll);
                                          }
                                        : null,
                                    result: controller.resultForPoll(poll),
                                    fireCount: fire,
                                    iceCount: ice,
                                    userReaction: userReaction,
                                    onFireTap: () async {
                                      final allowed = await AuthGuard
                                          .ensureCanPerformAction(
                                        context,
                                        ParticipationAction.react,
                                      );
                                      if (!allowed) return;

                                      final userId =
                                          AppDI.instance.currentUserId;
                                      if (userId == null || userId.isEmpty) {
                                        return;
                                      }

                                      await controller.toggleFireForPoll(
                                        userId: userId,
                                        poll: poll,
                                      );
                                    },
                                    onIceTap: () async {
                                      final allowed = await AuthGuard
                                          .ensureCanPerformAction(
                                        context,
                                        ParticipationAction.react,
                                      );
                                      if (!allowed) return;

                                      final userId =
                                          AppDI.instance.currentUserId;
                                      if (userId == null || userId.isEmpty) {
                                        return;
                                      }

                                      await controller.toggleIceForPoll(
                                        userId: userId,
                                        poll: poll,
                                      );
                                    },
                                    onCommentTap: () async {
                                      await _openPollDetail(
                                        poll,
                                        openCommentsOnLoad: true,
                                      );
                                    },
                                  );
                                },
                              ),
                            if (hasMore &&
                                !controller.isLoading &&
                                visiblePolls.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs,
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.pollList_paginationHint,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                            if (controller.isLoading && visiblePolls.isNotEmpty)
                              const LoadingIndicator.inline(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.s,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersBlock(
    BuildContext context,
    PollListController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final primaryItems = <_PollFilterItem>[
      _PollFilterItem(
        label: _sortModeLabel(l10n, PollSortMode.hottest),
        selected: controller.sortMode == PollSortMode.hottest,
        onTap: () => controller.setSortMode(PollSortMode.hottest),
      ),
      _PollFilterItem(
        label: _sortModeLabel(l10n, PollSortMode.latest),
        selected: controller.sortMode == PollSortMode.latest,
        onTap: () => controller.setSortMode(PollSortMode.latest),
      ),
    ];

    final statusItems = <_PollFilterItem>[
      _PollFilterItem(
        label: _statusFilterLabel(l10n, PollStatusFilter.all),
        selected: controller.statusFilter == PollStatusFilter.all,
        onTap: () => controller.setStatusFilter(PollStatusFilter.all),
      ),
      _PollFilterItem(
        label: _statusFilterLabel(l10n, PollStatusFilter.open),
        selected: controller.statusFilter == PollStatusFilter.open,
        onTap: () => controller.setStatusFilter(PollStatusFilter.open),
      ),
      _PollFilterItem(
        label: _statusFilterLabel(l10n, PollStatusFilter.closed),
        selected: controller.statusFilter == PollStatusFilter.closed,
        onTap: () => controller.setStatusFilter(PollStatusFilter.closed),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _singleRowFiltersMinWidth) {
          return Row(
            children: [
              _buildInlineFilterGroup(
                context,
                items: primaryItems,
                isPrimary: true,
              ),
              const Spacer(),
              _buildInlineFilterGroup(
                context,
                items: statusItems,
                isPrimary: false,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScrollableFilterGroup(
              context,
              items: primaryItems,
              isPrimary: true,
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildScrollableFilterGroup(
              context,
              items: statusItems,
              isPrimary: false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildInlineFilterGroup(
    BuildContext context, {
    required List<_PollFilterItem> items,
    required bool isPrimary,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.xs),
          _buildFilterButton(
            context,
            label: items[index].label,
            selected: items[index].selected,
            onTap: items[index].onTap,
            isPrimary: isPrimary,
          ),
        ],
      ],
    );
  }

  Widget _buildScrollableFilterGroup(
    BuildContext context, {
    required List<_PollFilterItem> items,
    required bool isPrimary,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildInlineFilterGroup(
        context,
        items: items,
        isPrimary: isPrimary,
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = selected
        ? colorScheme.primary.withValues(alpha: isPrimary ? 0.12 : 0.10)
        : colorScheme.surface.withValues(alpha: isDark ? 0.28 : 0.82);

    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: isDark ? 0.24 : 0.14);

    final textColor = selected
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: isPrimary ? 0.86 : 0.72);

    final textStyle =
        (isPrimary ? theme.textTheme.labelLarge : theme.textTheme.labelMedium)
            ?.copyWith(
      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      color: textColor,
      height: 1,
    );

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.buttonRadius,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: isPrimary ? 112 : 84,
              minHeight: 44,
            ),
            child: Ink(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: AppRadius.buttonRadius,
                border: Border.all(
                  color: borderColor,
                  width: selected ? 1.2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScopeHeader(
    BuildContext context, {
    required AppLocalizations l10n,
    required String scopeLabel,
    required String scopeDescription,
    required int pollCount,
  }) {
    final theme = Theme.of(context);

    final contextBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.public,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pollList_headerTitle(scopeLabel, pollCount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                scopeDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    final createButton = FilledButton.icon(
      onPressed: _openCreatePoll,
      icon: const Icon(Icons.add, size: 18),
      label: Text(l10n.pollList_createPollButton),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        textStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _compactHeaderMaxWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              contextBlock,
              const SizedBox(height: AppSpacing.s),
              createButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: contextBlock),
            const SizedBox(width: AppSpacing.m),
            createButton,
          ],
        );
      },
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.pollList_emptyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PollFilterItem {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PollFilterItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });
}

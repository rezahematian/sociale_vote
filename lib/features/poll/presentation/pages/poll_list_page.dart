import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    _pollListController = AppDI.instance.createPollListController();

    _reloadPolls();

    _scrollController.addListener(_onScroll);
    AppDI.instance.geoScopeController.addListener(_onScopeChanged);
    _sessionSub =
        AppDI.instance.sessionRepository.watchCurrentUserId().listen((_) {
      _reloadPolls();
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    AppDI.instance.geoScopeController.removeListener(_onScopeChanged);
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
  }

  void _onScopeChanged() {
    _reloadPolls();
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

  String _scopeShortLabel(AppLocalizations l10n, GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return l10n.pollList_scopeWorld;
      case GeoScopeLevel.country:
        return scope.countryCode ?? l10n.pollList_scopeCountryFallback;
      case GeoScopeLevel.city:
        return scope.cityId ?? l10n.pollList_scopeCityFallback;
    }
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

  String _scopeFilterLabel(
    AppLocalizations l10n,
    PollScopeFilter filter,
  ) {
    switch (filter) {
      case PollScopeFilter.currentScope:
        return l10n.pollList_filterScope_currentArea;
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
                final scopeLabel = _scopeShortLabel(l10n, scope);
                final scopeDescription = _scopeDescription(l10n, scope);

                final visiblePolls = controller.polls;
                final hasMore = controller.hasMoreFromSource;

                return ColoredBox(
                  color: pageBackground,
                  child: RefreshIndicator(
                    onRefresh: _reloadPolls,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
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
                              final fire = controller.likeCountForPoll(poll);
                              final ice = controller.dislikeCountForPoll(poll);
                              final userReaction =
                                  controller.userReactionForPoll(poll);

                              return PollCard(
                                poll: poll,
                                onTap: () async {
                                  await _openPollDetail(poll);
                                },
                                result: controller.resultForPoll(poll),
                                fireCount: fire,
                                iceCount: ice,
                                userReaction: userReaction,
                                onFireTap: () async {
                                  final allowed =
                                      await AuthGuard.ensureCanPerformAction(
                                    context,
                                    ParticipationAction.react,
                                  );
                                  if (!allowed) return;

                                  final userId = AppDI.instance.currentUserId;
                                  if (userId == null || userId.isEmpty) {
                                    return;
                                  }

                                  await controller.toggleFireForPoll(
                                    userId: userId,
                                    poll: poll,
                                  );
                                },
                                onIceTap: () async {
                                  final allowed =
                                      await AuthGuard.ensureCanPerformAction(
                                    context,
                                    ParticipationAction.react,
                                  );
                                  if (!allowed) return;

                                  final userId = AppDI.instance.currentUserId;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPrimaryFilterRow(
          context,
          items: [
            _PollFilterItem(
              label: _scopeFilterLabel(l10n, PollScopeFilter.currentScope),
              selected: controller.scopeFilter == PollScopeFilter.currentScope,
              onTap: () =>
                  controller.setScopeFilter(PollScopeFilter.currentScope),
            ),
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
          ],
        ),
        const SizedBox(height: 10),
        _buildSecondaryFilterRow(
          context,
          items: [
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
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryFilterRow(
    BuildContext context, {
    required List<_PollFilterItem> items,
  }) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: _buildFilterButton(
              context,
              label: items[i].label,
              selected: items[i].selected,
              onTap: items[i].onTap,
              isPrimary: true,
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _buildSecondaryFilterRow(
    BuildContext context, {
    required List<_PollFilterItem> items,
  }) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: _buildFilterButton(
              context,
              label: items[i].label,
              selected: items[i].selected,
              onTap: items[i].onTap,
              isPrimary: false,
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: isPrimary ? 42 : 38,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.public,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.unitS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pollList_headerTitle(scopeLabel, pollCount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scopeDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _openCreatePoll,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.pollList_createPollButton),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            textStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 32,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.unitS),
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

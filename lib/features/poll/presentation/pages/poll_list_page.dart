import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/radius.dart';
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PollListController>.value(
      value: _pollListController,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.pollList_title),
            ),
            body: Consumer<PollListController>(
              builder: (context, controller, _) {
                final scope = AppDI.instance.geoScopeController.scope;
                final scopeLabel = _scopeShortLabel(l10n, scope);
                final scopeDescription = _scopeDescription(l10n, scope);

                final visiblePolls = controller.polls;
                final hasMore = controller.hasMoreFromSource;

                return RefreshIndicator(
                  onRefresh: _reloadPolls,
                  child: ListView(
                    controller: _scrollController,
                    padding: AppSpacing.page,
                    children: [
                      _buildScopeHeader(
                        context,
                        l10n: l10n,
                        scopeLabel: scopeLabel,
                        scopeDescription: scopeDescription,
                        pollCount: visiblePolls.length,
                      ),
                      const SizedBox(height: AppSpacing.unitS),
                      _buildFiltersRow(context, controller),
                      const SizedBox(height: AppSpacing.unitL),

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

                            return GestureDetector(
                              onTap: () async {
                                final pollListController =
                                    context.read<PollListController>();

                                await Navigator.of(context).pushNamed(
                                  AppRouter.pollDetail,
                                  arguments: poll.id,
                                );

                                if (!context.mounted) return;

                                final userId = AppDI.instance.currentUserId;
                                await pollListController.loadPolls(
                                  userId: userId,
                                );
                              },
                              child: PollCard(
                                poll: poll,
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
                              ),
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
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersRow(
    BuildContext context,
    PollListController controller,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildScopeFilterChips(context, controller),
          const SizedBox(width: AppSpacing.unitL),
          _buildStatusFilterChips(context, controller),
          const SizedBox(width: AppSpacing.unitL),
          _buildSortFilterChips(context, controller),
        ],
      ),
    );
  }

  Widget _buildScopeFilterChips(
    BuildContext context,
    PollListController controller,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentFilter = controller.scopeFilter;

    return Row(
      children: PollScopeFilter.values.map((filter) {
        final selected = currentFilter == filter;

        final Color borderColor = selected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withOpacity(0.4);

        final Color bgColor = selected
            ? theme.colorScheme.primary.withOpacity(0.10)
            : Colors.transparent;

        final Color textColor = selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.80);

        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.unitS),
          child: ChoiceChip(
            label: Text(
              _scopeFilterLabel(l10n, filter),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
            ),
            selected: selected,
            showCheckmark: false,
            backgroundColor: bgColor,
            selectedColor: bgColor,
            side: BorderSide(color: borderColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
            onSelected: (value) {
              if (!value) return;
              controller.setScopeFilter(filter);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilterChips(
    BuildContext context,
    PollListController controller,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentFilter = controller.statusFilter;

    return Row(
      children: PollStatusFilter.values.map((filter) {
        final selected = currentFilter == filter;

        final Color borderColor = selected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withOpacity(0.4);

        final Color bgColor = selected
            ? theme.colorScheme.primary.withOpacity(0.10)
            : Colors.transparent;

        final Color textColor = selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.80);

        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.unitS),
          child: ChoiceChip(
            label: Text(
              _statusFilterLabel(l10n, filter),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
            ),
            selected: selected,
            showCheckmark: false,
            backgroundColor: bgColor,
            selectedColor: bgColor,
            side: BorderSide(color: borderColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
            onSelected: (value) {
              if (!value) return;
              controller.setStatusFilter(filter);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSortFilterChips(
    BuildContext context,
    PollListController controller,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentMode = controller.sortMode;

    return Row(
      children: PollSortMode.values.map((mode) {
        final selected = currentMode == mode;

        final Color borderColor = selected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withOpacity(0.4);

        final Color bgColor = selected
            ? theme.colorScheme.primary.withOpacity(0.10)
            : Colors.transparent;

        final Color textColor = selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.80);

        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.unitS),
          child: ChoiceChip(
            label: Text(
              _sortModeLabel(l10n, mode),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
            ),
            selected: selected,
            showCheckmark: false,
            backgroundColor: bgColor,
            selectedColor: bgColor,
            side: BorderSide(color: borderColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
            onSelected: (value) {
              if (!value) return;
              controller.setSortMode(mode);
            },
          ),
        );
      }).toList(),
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
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.unitXS),
              Text(
                scopeDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.unitS),
        OutlinedButton.icon(
          onPressed: () async {
            final allowed = await AuthGuard.ensureCanPerformAction(
              context,
              ParticipationAction.createPoll,
            );
            if (!allowed) return;

            final result =
                await Navigator.of(context).pushNamed(AppRouter.createPoll);

            if (!context.mounted) return;

            final pollListController = context.read<PollListController>();
            final userId = AppDI.instance.currentUserId;

            if (result is PollId) {
              await pollListController.loadPolls(userId: userId);

              if (!context.mounted) return;

              Navigator.of(context).pushNamed(
                AppRouter.pollDetail,
                arguments: result,
              );
            } else if (result == true) {
              await pollListController.loadPolls(userId: userId);
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.pollList_createPollButton),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            textStyle: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
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
          Icon(
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
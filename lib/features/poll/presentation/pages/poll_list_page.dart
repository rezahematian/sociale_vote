import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';

class PollListPage extends StatelessWidget {
  const PollListPage({super.key});

  String _scopeShortLabel(GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return 'World';
      case GeoScopeLevel.country:
        return scope.countryCode ?? 'Country';
      case GeoScopeLevel.city:
        // Se hai cityName in futuro, puoi mostrarlo qui.
        return scope.cityId ?? 'City';
    }
  }

  String _scopeDescription(GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return 'Showing global polls.';
      case GeoScopeLevel.country:
        return 'Showing polls for this country.';
      case GeoScopeLevel.city:
        return 'Showing polls for this city.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = AppDI.instance.createPollListController();
        controller.loadPolls();
        return controller;
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Polls'),
            ),
            body: Consumer<PollListController>(
              builder: (context, controller, _) {
                final scope = AppDI.instance.geoScopeController.scope;
                final scopeLabel = _scopeShortLabel(scope);
                final scopeDescription = _scopeDescription(scope);

                // Per ora user demo; in futuro prenderemo l'ID reale da identity.
                const String userId = 'demo-user';

                return RefreshIndicator(
                  onRefresh: controller.loadPolls,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildScopeHeader(
                        context,
                        scopeLabel: scopeLabel,
                        scopeDescription: scopeDescription,
                        pollCount: controller.polls.length,
                      ),
                      const SizedBox(height: 16),

                      // ===== LOADING INIZIALE =====
                      if (controller.isLoading && controller.polls.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      // ===== EMPTY STATE =====
                      if (!controller.isLoading && controller.polls.isEmpty)
                        _buildEmptyStateCard(context),

                      // ===== LISTA POLL =====
                      if (controller.polls.isNotEmpty)
                        ...controller.polls.map(
                          (poll) {
                            final fire = controller.likeCountForPoll(poll);
                            final ice = controller.dislikeCountForPoll(poll);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRouter.pollDetail,
                                    arguments: poll.id,
                                  );
                                },
                                child: PollCard(
                                  poll: poll,
                                  fireCount: fire,
                                  iceCount: ice,
                                  onFireTap: () {
                                    controller.toggleFireForPoll(
                                      userId: userId,
                                      poll: poll,
                                    );
                                  },
                                  onIceTap: () {
                                    controller.toggleIceForPoll(
                                      userId: userId,
                                      poll: poll,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                      // ===== LOADING DURANTE REFRESH (overlay in fondo) =====
                      if (controller.isLoading &&
                          controller.polls.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(),
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

  Widget _buildScopeHeader(
    BuildContext context, {
    required String scopeLabel,
    required String scopeDescription,
    required int pollCount,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Riga superiore: scope + pulsante Create poll
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.public,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scopeLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context)
                        .pushNamed(AppRouter.createPoll);

                    if (!context.mounted) return;

                    // Nuovo comportamento: se CreatePoll ritorna un PollId,
                    // ricarichiamo i poll e apriamo subito il dettaglio.
                    if (result is PollId) {
                      await context
                          .read<PollListController>()
                          .loadPolls();

                      Navigator.of(context).pushNamed(
                        AppRouter.pollDetail,
                        arguments: result,
                      );
                    } else if (result == true) {
                      // Fallback per eventuali vecchi flussi (retrocompatibilità)
                      context.read<PollListController>().loadPolls();
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create poll'),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              scopeDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$pollCount poll(s) found',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 32,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'No polls available for this area.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
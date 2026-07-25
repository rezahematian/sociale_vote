import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class HomeMapSection extends StatelessWidget {
  final String scopeShortLabel;

  const HomeMapSection({
    super.key,
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CivicMapController>(
      create: (_) => AppDI.instance.createCivicMapController(),
      child: _HomeMapSectionView(
        scopeShortLabel: scopeShortLabel,
      ),
    );
  }
}

class _HomeMapSectionView extends StatefulWidget {
  final String scopeShortLabel;

  const _HomeMapSectionView({
    required this.scopeShortLabel,
  });

  @override
  State<_HomeMapSectionView> createState() => _HomeMapSectionViewState();
}

class _HomeMapSectionViewState extends State<_HomeMapSectionView> {
  String? _lastSyncedScopeKey;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CivicMapController>();
    final geoScopeController = context.watch<GeoScopeController?>();
    final activeScope = _readActiveScope(geoScopeController);
    final activeScopeKey = activeScope == null ? null : _scopeKey(activeScope);

    _scheduleScopeSyncIfNeeded(
      controller: controller,
      scope: activeScope,
      scopeKey: activeScopeKey,
    );

    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final isVeryNarrow = constraints.maxWidth < 480;
        final sectionHeight = isCompact ? 310.0 : 340.0;
        final horizontalPadding = isVeryNarrow ? 16.0 : 30.0;

        return SizedBox(
          height: sectionHeight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              16,
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  CivicMapWidget(
                    controller: controller,
                    currentScopeLabel: widget.scopeShortLabel,
                    onTap: () async {
                      await _openFullMap(
                        context,
                        controller: controller,
                        scope: activeScope,
                      );
                    },
                    onItemTap: (_) async {
                      await _openFullMap(
                        context,
                        controller: controller,
                        scope: activeScope,
                      );
                    },
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await _openFullMap(
                          context,
                          controller: controller,
                          scope: activeScope,
                        );
                      },
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.symmetric(
                          horizontal: isVeryNarrow ? 12 : 14,
                          vertical: 10,
                        ),
                      ),
                      icon: const Icon(Icons.open_in_full, size: 18),
                      label: Text(l10n.homeMapOpenButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openFullMap(
    BuildContext context, {
    required CivicMapController controller,
    required GeoScope? scope,
  }) async {
    await Navigator.of(context).pushNamed(AppRouter.civicMap);

    if (!mounted) return;

    if (scope != null) {
      _lastSyncedScopeKey = _scopeKey(scope);
      await controller.syncScope(
        scope,
        forceReload: true,
        clearSelection: false,
      );
      return;
    }

    await controller.refresh();
  }

  void _scheduleScopeSyncIfNeeded({
    required CivicMapController controller,
    required GeoScope? scope,
    required String? scopeKey,
  }) {
    if (scope == null || scopeKey == null) {
      return;
    }

    final controllerScope = controller.currentScope;
    final controllerScopeKey =
        controllerScope == null ? null : _scopeKey(controllerScope);

    final needsSync =
        _lastSyncedScopeKey != scopeKey || controllerScopeKey != scopeKey;

    if (!needsSync) {
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
      final dynamic scope = dynamicController.scope;
      if (scope is GeoScope) {
        return scope;
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
      normalizeNum(readSafely(() => dynamicScope.radiusKm)),
    ].join('|');
  }
}

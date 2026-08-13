import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';
import 'package:sociale_vote/features/map/presentation/widgets/world_globe_widget.dart';

class HomeMapSection extends StatelessWidget {
  final String scopeShortLabel;
  final ValueChanged<bool>? onGlobeScrollLockChanged;
  final ValueChanged<Offset>? onGlobeOrientationChanged;
  final bool desktopHeroMode;

  const HomeMapSection({
    super.key,
    required this.scopeShortLabel,
    this.onGlobeScrollLockChanged,
    this.onGlobeOrientationChanged,
    this.desktopHeroMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CivicMapController>(
      create: (_) => AppDI.instance.createCivicMapController(),
      child: _HomeMapSectionView(
        scopeShortLabel: scopeShortLabel,
        onGlobeScrollLockChanged: onGlobeScrollLockChanged,
        onGlobeOrientationChanged: onGlobeOrientationChanged,
        desktopHeroMode: desktopHeroMode,
      ),
    );
  }
}

class _HomeMapSectionView extends StatefulWidget {
  final String scopeShortLabel;
  final ValueChanged<bool>? onGlobeScrollLockChanged;
  final ValueChanged<Offset>? onGlobeOrientationChanged;
  final bool desktopHeroMode;

  const _HomeMapSectionView({
    required this.scopeShortLabel,
    required this.onGlobeScrollLockChanged,
    required this.onGlobeOrientationChanged,
    required this.desktopHeroMode,
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
    final isWorldScope = activeScope?.level == GeoScopeLevel.world;

    // WEB-G1: World uses the same 3D globe on native and standard Flutter
    // Web. Country/City remain on the classic 2D map.
    final showHomeGlobe = isWorldScope;

    _scheduleScopeSyncIfNeeded(
      controller: controller,
      scope: activeScope,
      scopeKey: activeScopeKey,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final isVeryNarrow = constraints.maxWidth < 480;

        // Mobile keeps the approved app dimensions. Desktop split gives the
        // globe its own large right-hand column without nested horizontal
        // padding.
        final sectionHeight = widget.desktopHeroMode
            ? 560.0
            : showHomeGlobe
                ? (isCompact ? 360.0 : 430.0)
                : (isCompact ? 300.0 : 330.0);

        final horizontalPadding =
            widget.desktopHeroMode ? 0.0 : (isVeryNarrow ? 16.0 : 30.0);

        return SizedBox(
          height: sectionHeight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              16,
            ),
            child: showHomeGlobe
                ? WorldGlobeWidget(
                    items: controller.visibleItems,
                    onItemTap: controller.selectItem,
                    onUseClassicMap: () async {
                      await _openFullMap(
                        context,
                        controller: controller,
                        scope: activeScope,
                      );
                    },
                    interactionProfile: WorldGlobeInteractionProfile.home,
                    onPageScrollLockChanged: widget.onGlobeScrollLockChanged,
                    onOrientationChanged: widget.onGlobeOrientationChanged,
                  )
                : Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: CivicMapWidget(
                              controller: controller,
                              currentScopeLabel: widget.scopeShortLabel,
                              interactive: false,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await _openFullMap(
                                  context,
                                  controller: controller,
                                  scope: activeScope,
                                );
                              },
                            ),
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
    widget.onGlobeScrollLockChanged?.call(false);

    // Guest: il globo resta consultabile/ruotabile ma il tap non apre
    // la Civic Map e non ripropone continuamente il login.
    final currentUserId = AppDI.instance.currentUserId?.trim();
    if (currentUserId == null || currentUserId.isEmpty) {
      return;
    }

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

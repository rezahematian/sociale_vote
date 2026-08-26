import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';
import 'package:sociale_vote/features/map/presentation/widgets/world_globe_widget.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';
import 'package:sociale_vote/shared/widgets/radio_mondo_dock.dart';

class HomeMapSection extends StatelessWidget {
  final String scopeShortLabel;
  final ValueChanged<bool>? onGlobeScrollLockChanged;
  final ValueChanged<Offset>? onGlobeOrientationChanged;
  final bool desktopHeroMode;
  final bool suspendWebSurface;

  const HomeMapSection({
    super.key,
    required this.scopeShortLabel,
    this.onGlobeScrollLockChanged,
    this.onGlobeOrientationChanged,
    this.desktopHeroMode = false,
    this.suspendWebSurface = false,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && suspendWebSurface) {
      return _HomeMapSuspendedSurface(
        scopeShortLabel: scopeShortLabel,
        desktopHeroMode: desktopHeroMode,
        isWorldScope: AppDI.instance.geoScopeController.scope.level ==
            GeoScopeLevel.world,
      );
    }

    return ChangeNotifierProvider<CivicMapController>(
      create: (_) => AppDI.instance.createCivicMapController(homePreview: true),
      child: _HomeMapSectionView(
        scopeShortLabel: scopeShortLabel,
        onGlobeScrollLockChanged: onGlobeScrollLockChanged,
        onGlobeOrientationChanged: onGlobeOrientationChanged,
        desktopHeroMode: desktopHeroMode,
      ),
    );
  }
}

class _HomeMapSuspendedSurface extends StatelessWidget {
  final String scopeShortLabel;
  final bool desktopHeroMode;
  final bool isWorldScope;

  const _HomeMapSuspendedSurface({
    required this.scopeShortLabel,
    required this.desktopHeroMode,
    required this.isWorldScope,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final isVeryNarrow = constraints.maxWidth < 480;
        final sectionHeight = desktopHeroMode
            ? 560.0
            : isWorldScope
                ? (isCompact ? 360.0 : 430.0)
                : (isCompact ? 300.0 : 330.0);
        final horizontalPadding =
            desktopHeroMode ? 0.0 : (isVeryNarrow ? 16.0 : 30.0);
        final theme = Theme.of(context);

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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.public,
                      size: 34,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scopeShortLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
  static const Duration _webMarkerWarmupDelay = Duration(milliseconds: 700);
  static const Duration _nativeMarkerWarmupDelay = Duration(milliseconds: 1900);

  String? _lastSyncedScopeKey;

  @override
  void initState() {
    super.initState();
    unawaited(WorldAppearanceService.instance.ensureLoaded());
  }

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
                ? AnimatedBuilder(
                    animation: WorldAppearanceService.instance,
                    builder: (context, _) {
                      final appearance = WorldAppearanceService.instance;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: WorldGlobeWidget(
                              items: controller.visibleItems,
                              onItemTap: (item) async {
                                await _openTarget(context, item);
                              },
                              onUseClassicMap: () async {
                                await _openFullMap(
                                  context,
                                  controller: controller,
                                  scope: activeScope,
                                );
                              },
                              interactionProfile:
                                  WorldGlobeInteractionProfile.home,
                              onPageScrollLockChanged:
                                  widget.onGlobeScrollLockChanged,
                              onOrientationChanged:
                                  widget.onGlobeOrientationChanged,
                              visualStyle: appearance.globeStyle,
                              rotationVisualStyle: appearance.rotationStyle,
                              markerDataSettled: !controller.isLoading &&
                                  !controller.isRefreshing,
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final innerWidth = constraints.maxWidth -
                                  (horizontalPadding * 2);
                              final innerHeight = sectionHeight - 32;
                              final available = innerWidth < innerHeight
                                  ? innerWidth
                                  : innerHeight;
                              final candidateSquare = available - 12;
                              final globeSquare = candidateSquare < 220
                                  ? 220.0
                                  : candidateSquare;

                              return Positioned.fill(
                                child: Center(
                                  child: SizedBox.square(
                                    dimension: globeSquare,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          left: 24,
                                          bottom: 24,
                                          child: RadioMondoDock(
                                            visualStyle: appearance.radioStyle,
                                            size: 44,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
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
                              initialScope: kIsWeb ? activeScope : null,
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

  Future<void> _openTarget(
    BuildContext context,
    CivicMapItem item,
  ) async {
    final targetRef = item.targetRef;
    final targetId = targetRef.id.trim();
    if (targetId.isEmpty) return;

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
        var newsItem = item.newsItem;
        if (newsItem == null) {
          try {
            newsItem = await AppDI.instance.getNewsDetail(EntityId(targetId));
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Impossibile aprire il dettaglio della notizia'),
              ),
            );
            return;
          }
        }
        if (!context.mounted) return;
        await Navigator.of(context).pushNamed(
          AppRouter.newsDetail,
          arguments: newsItem,
        );
        return;
      default:
        return;
    }
  }

  Future<void> _openFullMap(
    BuildContext context, {
    required CivicMapController controller,
    required GeoScope? scope,
  }) async {
    widget.onGlobeScrollLockChanged?.call(false);

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

    final scheduledScopeKey = scopeKey;
    const warmupDelay =
        kIsWeb ? _webMarkerWarmupDelay : _nativeMarkerWarmupDelay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(warmupDelay, () {
        if (!mounted || _lastSyncedScopeKey != scheduledScopeKey) {
          return;
        }

        controller.syncScope(scope);
      });
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

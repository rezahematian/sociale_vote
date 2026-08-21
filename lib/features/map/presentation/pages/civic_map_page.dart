import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';
import 'package:sociale_vote/features/map/presentation/widgets/world_globe_widget.dart';
import 'package:sociale_vote/features/news/domain/news_language.dart';
import 'package:sociale_vote/shared/data/countries.dart';

void _goBackFromCivicMap(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
    return;
  }

  navigator.pushNamedAndRemoveUntil(AppRouter.home, (_) => false);
}

Widget _buildCivicMapBackButton(BuildContext context) {
  return IconButton(
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    icon: const Icon(Icons.arrow_back),
    onPressed: () => _goBackFromCivicMap(context),
  );
}

class CivicMapPage extends StatelessWidget {
  const CivicMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CivicMapController>(
      create: (_) => AppDI.instance.createCivicMapController(),
      child: const _CivicMapPageView(),
    );
  }
}

class _CivicMapPageView extends StatefulWidget {
  const _CivicMapPageView();

  @override
  State<_CivicMapPageView> createState() => _CivicMapPageViewState();
}

class _CivicMapPageViewState extends State<_CivicMapPageView> {
  static const String _worldGlobePreferenceKey =
      'civic_map_world_globe_enabled';

  String? _lastSyncedScopeKey;
  NewsLanguage _selectedLanguage = NewsLanguage.auto;
  bool _isChangingLanguage = false;
  bool _useWorldGlobe = false;
  WorldGlobeMapHandoff? _worldMapHandoff;
  CivicMapGlobeHandoff? _worldGlobeHandoff;
  bool _showBroaderScopePrompt = false;

  @override
  void initState() {
    super.initState();
    _restoreSavedLanguagePreference();
    _restoreWorldMapModePreference();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<CivicMapController>();
    final geoScopeController = context.watch<GeoScopeController?>();
    final activeScope = _readActiveScope(geoScopeController);
    final activeScopeKey = activeScope == null ? null : _scopeKey(activeScope);
    final isWorldScope = activeScope?.level == GeoScopeLevel.world;
    final showWorldGlobe = isWorldScope && _useWorldGlobe;
    final worldMapHandoff = isWorldScope ? _worldMapHandoff : null;
    final worldGlobeHandoff = isWorldScope ? _worldGlobeHandoff : null;

    _scheduleScopeSyncIfNeeded(
      controller: controller,
      scope: activeScope,
      scopeKey: activeScopeKey,
    );

    final selectorBusy = _isChangingLanguage || controller.isLoading;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leading: _buildCivicMapBackButton(context),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Civic Map'),
            Text(
              _scopeLabel(context, activeScope),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: Localizations.localeOf(context).languageCode == 'it'
                ? 'Aggiorna'
                : 'Refresh',
            onPressed: controller.isLoading
                ? null
                : () {
                    controller.refresh();
                  },
            icon: controller.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            children: [
              _MapTopControls(
                controller: controller,
                selectedLanguage: _selectedLanguage,
                languageSelectorEnabled: !selectorBusy,
                onLanguageChanged: (value) =>
                    _handleLanguageChanged(value, controller: controller),
                isWorldScope: isWorldScope,
                useGlobe: _useWorldGlobe,
                onWorldModeChanged: _setWorldGlobeEnabled,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    showWorldGlobe
                        ? WorldGlobeWidget(
                            key: const ValueKey<String>('civic-map-world-3d'),
                            items: controller.visibleItems,
                            onItemTap: controller.selectItem,
                            onUseClassicMap: () => _setWorldGlobeEnabled(false),
                            onZoomIntoClassicMap:
                                _handleGlobeZoomIntoClassicMap,
                            initialFocusLatitude: worldGlobeHandoff?.latitude,
                            initialFocusLongitude: worldGlobeHandoff?.longitude,
                            initialFocusZoom: worldGlobeHandoff?.globeZoom,
                          )
                        : CivicMapWidget(
                            key: const ValueKey<String>('civic-map-classic-2d'),
                            controller: controller,
                            handoffLatitude: worldMapHandoff?.latitude,
                            handoffLongitude: worldMapHandoff?.longitude,
                            handoffZoom: worldMapHandoff?.mapZoom,
                            onZoomOutToGlobe: isWorldScope
                                ? _handleClassicMapZoomOutToGlobe
                                : null,
                            onBeyondActiveScopeChanged: isWorldScope
                                ? null
                                : _handleBeyondActiveScopeChanged,
                          ),
                    if (_showBroaderScopePrompt &&
                        activeScope != null &&
                        !isWorldScope)
                      Positioned(
                        left: 12,
                        right: 12,
                        top: 12,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _BroaderScopePrompt(
                            scope: activeScope,
                            scopeLabel: _scopeLabel(context, activeScope),
                            onShowCountry:
                                activeScope.level == GeoScopeLevel.city &&
                                    activeScope.countryCode != null
                                ? () => _switchToCountryScope(
                                    geoScopeController,
                                    activeScope.countryCode!,
                                  )
                                : null,
                            onShowWorld: () =>
                                _switchToWorldScope(geoScopeController),
                          ),
                        ),
                      ),
                    if (controller.selectedItem == null &&
                        (controller.hasData || controller.isEmpty))
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.90,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            child: Text(
                              'Contenuti visibili: '
                              '${controller.visibleItems.length}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (controller.selectedItem != null)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: _MarkerPreviewCard(
                              key: ValueKey<String>(
                                controller.selectedItem!.id,
                              ),
                              item: controller.selectedItem!,
                              onClose: controller.clearSelection,
                              onOpen: () => _openTarget(
                                context,
                                controller.selectedItem!,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _scopeLabel(BuildContext context, GeoScope? scope) {
    final isItalian =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'it';

    if (scope == null) {
      return isItalian ? 'Caricamento area…' : 'Loading area…';
    }

    switch (scope.level) {
      case GeoScopeLevel.world:
        return isItalian ? 'Mondo' : 'World';
      case GeoScopeLevel.country:
        final countryCode = scope.countryCode?.trim().toUpperCase();
        return countryCode == null || countryCode.isEmpty
            ? (isItalian ? 'Paese' : 'Country')
            : countryCode;
      case GeoScopeLevel.city:
        final city = scope.cityId?.trim();
        final countryCode = scope.countryCode?.trim().toUpperCase();

        if (city != null && city.isNotEmpty) {
          if (countryCode != null && countryCode.isNotEmpty) {
            return '$city · $countryCode';
          }
          return city;
        }

        return countryCode == null || countryCode.isEmpty
            ? (isItalian ? 'Area locale' : 'Local area')
            : countryCode;
    }
  }

  Future<void> _restoreWorldMapModePreference() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final enabled = preferences.getBool(_worldGlobePreferenceKey) ?? false;

      if (!mounted) return;

      setState(() {
        _useWorldGlobe = enabled;
      });
    } catch (_) {
      // Keep the safe default: classic 2D map.
    }
  }

  Future<void> _setWorldGlobeEnabled(bool enabled) async {
    if (_useWorldGlobe == enabled && _worldMapHandoff == null) {
      return;
    }

    setState(() {
      _useWorldGlobe = enabled;
      _worldMapHandoff = null;
      _worldGlobeHandoff = null;
    });

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_worldGlobePreferenceKey, enabled);
    } catch (_) {
      // The map mode can still be used for the current session.
    }
  }

  void _handleGlobeZoomIntoClassicMap(WorldGlobeMapHandoff handoff) {
    if (!mounted) {
      return;
    }

    // Automatic 3D -> 2D zoom transition stays inside World scope.
    // Do not persist "2D" as the user's preferred mode: this is a transient
    // continuation of the same map exploration, not an explicit mode choice.
    setState(() {
      _worldMapHandoff = handoff;
      _worldGlobeHandoff = null;
      _useWorldGlobe = false;
    });

    debugPrint(
      '[CivicMapPage] accepting 3D->2D handoff: '
      'center=(${handoff.latitude}, ${handoff.longitude}) '
      'zoom=${handoff.mapZoom.toStringAsFixed(2)}',
    );
  }

  void _handleClassicMapZoomOutToGlobe(CivicMapGlobeHandoff handoff) {
    if (!mounted) {
      return;
    }

    // Automatic 2D -> 3D transition also stays inside World scope and is
    // transient. It does not overwrite the explicit 2D/3D user preference.
    setState(() {
      _worldGlobeHandoff = handoff;
      _worldMapHandoff = null;
      _useWorldGlobe = true;
    });

    debugPrint(
      '[CivicMapPage] accepting 2D->3D handoff: '
      'center=(${handoff.latitude}, ${handoff.longitude}) '
      'globeZoom=${handoff.globeZoom.toStringAsFixed(2)}',
    );
  }

  void _handleBeyondActiveScopeChanged(bool isBeyondScope) {
    if (!mounted || _showBroaderScopePrompt == isBeyondScope) {
      return;
    }

    setState(() {
      _showBroaderScopePrompt = isBeyondScope;
    });
  }

  void _switchToCountryScope(
    GeoScopeController? controller,
    String countryCode,
  ) {
    if (controller == null) {
      return;
    }

    setState(() {
      _showBroaderScopePrompt = false;
      _useWorldGlobe = false;
      _worldMapHandoff = null;
      _worldGlobeHandoff = null;
    });

    controller.setCountry(countryCode.trim().toUpperCase());
  }

  void _switchToWorldScope(GeoScopeController? controller) {
    if (controller == null) {
      return;
    }

    // The user is already exploring the 2D map. Expanding the geographic
    // filter must reveal worldwide markers in the same view instead of
    // unexpectedly switching renderers. The stored 2D/3D preference is not
    // overwritten; this is a transient continuation of the current gesture.
    setState(() {
      _showBroaderScopePrompt = false;
      _useWorldGlobe = false;
      _worldMapHandoff = null;
      _worldGlobeHandoff = null;
    });

    controller.setWorld();
  }

  Future<void> _restoreSavedLanguagePreference() async {
    try {
      final storedValue = await AppDI.instance.getContentLanguagePreference();
      final restored = _newsLanguageFromStoredValue(storedValue);

      if (!mounted || restored == null) {
        return;
      }

      setState(() {
        _selectedLanguage = restored;
      });
    } catch (_) {}
  }

  Future<void> _handleLanguageChanged(
    NewsLanguage language, {
    required CivicMapController controller,
  }) async {
    if (_selectedLanguage == language || _isChangingLanguage) {
      return;
    }

    setState(() {
      _selectedLanguage = language;
      _isChangingLanguage = true;
    });

    try {
      if (language == NewsLanguage.auto) {
        await AppDI.instance.clearContentLanguagePreference();
      } else {
        await AppDI.instance.setContentLanguagePreference(language.name);
      }

      final activeScope = controller.currentScope;
      if (activeScope != null) {
        await controller.loadForScope(activeScope, clearSelection: false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingLanguage = false;
        });
      }
    }
  }

  NewsLanguage? _newsLanguageFromStoredValue(String? value) {
    if (value == null) {
      return NewsLanguage.auto;
    }

    switch (value.trim().toLowerCase()) {
      case 'auto':
        return NewsLanguage.auto;
      case 'it':
        return NewsLanguage.it;
      case 'en':
        return NewsLanguage.en;
      case 'es':
        return NewsLanguage.es;
      case 'fr':
        return NewsLanguage.fr;
      case 'de':
        return NewsLanguage.de;
      case 'ar':
        return NewsLanguage.ar;
      case 'fa':
        return NewsLanguage.fa;
      default:
        return NewsLanguage.auto;
    }
  }

  void _scheduleScopeSyncIfNeeded({
    required CivicMapController controller,
    required GeoScope? scope,
    required String? scopeKey,
  }) {
    if (scope == null || scopeKey == null) {
      return;
    }

    if (_lastSyncedScopeKey == scopeKey) {
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

      final dynamic selectedScope = dynamicController.selectedScope;
      if (selectedScope is GeoScope) {
        return selectedScope;
      }
    } catch (_) {}

    try {
      final dynamic dynamicController = controller;

      final dynamic scope = dynamicController.scope;
      if (scope is GeoScope) {
        return scope;
      }
    } catch (_) {}

    try {
      final dynamic dynamicController = controller;
      final dynamic state = dynamicController.state;

      if (state != null) {
        try {
          final dynamic currentScope = state.currentScope;
          if (currentScope is GeoScope) {
            return currentScope;
          }
        } catch (_) {}

        try {
          final dynamic selectedScope = state.selectedScope;
          if (selectedScope is GeoScope) {
            return selectedScope;
          }
        } catch (_) {}

        try {
          final dynamic scope = state.scope;
          if (scope is GeoScope) {
            return scope;
          }
        } catch (_) {}
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
      normalizeNum(readSafely(() => dynamicScope.radiusKm) ?? scope.radiusKm),
    ].join('|');
  }

  Future<void> _openTarget(BuildContext context, CivicMapItem item) async {
    final targetRef = item.targetRef;
    final targetId = _readTargetRefId(targetRef);
    if (targetId == null || targetId.trim().isEmpty) {
      return;
    }

    switch (targetRef.type) {
      case TargetType.poll:
        await Navigator.of(
          context,
        ).pushNamed(AppRouter.pollDetail, arguments: PollId(targetId));
        return;

      case TargetType.post:
        await Navigator.of(
          context,
        ).pushNamed(AppRouter.socialDetail, arguments: targetId);
        return;

      case TargetType.news:
        // The map loader already has the complete NewsItem used to build this
        // marker. Reuse it so opening the detail is immediate. The repository
        // lookup remains only as a compatibility fallback for older items.
        final newsItem = item.newsItem ?? await _resolveNewsItem(targetId);
        if (!context.mounted) return;

        if (newsItem == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Localizations.localeOf(context).languageCode == 'it'
                    ? 'Impossibile aprire il dettaglio della notizia'
                    : 'Unable to open news detail',
              ),
            ),
          );
          return;
        }

        await Navigator.of(
          context,
        ).pushNamed(AppRouter.newsDetail, arguments: newsItem);
        return;

      default:
        return;
    }
  }

  Future<NewsItem?> _resolveNewsItem(String newsId) async {
    final normalizedNewsId = newsId.trim();
    if (normalizedNewsId.isEmpty) {
      return null;
    }

    try {
      return await AppDI.instance.getNewsDetail(EntityId(normalizedNewsId));
    } catch (_) {
      return null;
    }
  }

  String? _readTargetRefId(TargetRef targetRef) {
    try {
      final dynamic value = (targetRef as dynamic).targetId;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = (targetRef as dynamic).id;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = (targetRef as dynamic).value;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = (targetRef as dynamic).target;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    return null;
  }
}

class _BroaderScopePrompt extends StatelessWidget {
  final GeoScope scope;
  final String scopeLabel;
  final VoidCallback? onShowCountry;
  final VoidCallback onShowWorld;

  const _BroaderScopePrompt({
    required this.scope,
    required this.scopeLabel,
    required this.onShowCountry,
    required this.onShowWorld,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isItalian = languageCode.toLowerCase() == 'it';
    final countryCode = scope.countryCode?.trim().toUpperCase();
    final countryName = countryCode == null || countryCode.isEmpty
        ? null
        : Countries.nameForCode(
            countryCode,
            languageCode: languageCode,
            fallback: countryCode,
          );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0.96),
        elevation: 4,
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  size: 19,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  isItalian
                      ? 'La mappa è ancora filtrata su $scopeLabel'
                      : 'The map is still filtered to $scopeLabel',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (onShowCountry != null && countryName != null)
                  OutlinedButton(
                    onPressed: onShowCountry,
                    child: Text(
                      isItalian ? 'Mostra $countryName' : 'Show $countryName',
                    ),
                  ),
                FilledButton.tonal(
                  onPressed: onShowWorld,
                  child: Text(isItalian ? 'Mostra Mondo' : 'Show World'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldMapModeSelector extends StatelessWidget {
  final bool useGlobe;
  final ValueChanged<bool> onChanged;

  const _WorldMapModeSelector({
    required this.useGlobe,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _WorldMapModeButton(
              selected: !useGlobe,
              icon: Icons.map_outlined,
              label: '2D',
              onTap: () => onChanged(false),
            ),
            const SizedBox(width: 4),
            _WorldMapModeButton(
              selected: useGlobe,
              icon: Icons.public,
              label: '3D',
              onTap: () => onChanged(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldMapModeButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WorldMapModeButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: foreground),
              const SizedBox(width: 5),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapTopControls extends StatelessWidget {
  final CivicMapController controller;
  final NewsLanguage selectedLanguage;
  final bool languageSelectorEnabled;
  final ValueChanged<NewsLanguage> onLanguageChanged;
  final bool isWorldScope;
  final bool useGlobe;
  final ValueChanged<bool> onWorldModeChanged;

  const _MapTopControls({
    required this.controller,
    required this.selectedLanguage,
    required this.languageSelectorEnabled,
    required this.onLanguageChanged,
    required this.isWorldScope,
    required this.useGlobe,
    required this.onWorldModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final modeSelector = isWorldScope
            ? _WorldMapModeSelector(
                useGlobe: useGlobe,
                onChanged: onWorldModeChanged,
              )
            : null;

        final languageSelector = SizedBox(
          width: 126,
          child: _MapLanguageSelector(
            selectedLanguage: selectedLanguage,
            enabled: languageSelectorEnabled,
            onChanged: onLanguageChanged,
          ),
        );

        final firstRow = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (modeSelector != null) ...[
              modeSelector,
              const SizedBox(width: 10),
            ],
            languageSelector,
          ],
        );

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth < 440 ? constraints.maxWidth : 440,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    firstRow,
                    const SizedBox(height: 10),
                    _MapTypeFilters(controller: controller),
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

class _MapLanguageSelector extends StatelessWidget {
  final NewsLanguage selectedLanguage;
  final bool enabled;
  final ValueChanged<NewsLanguage> onChanged;

  const _MapLanguageSelector({
    required this.selectedLanguage,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<NewsLanguage>(
      initialValue: selectedLanguage,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        prefixIcon: const Icon(Icons.language, size: 18),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      selectedItemBuilder: (context) => NewsLanguage.values
          .map(
            (language) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _compactLabelForLanguage(language),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      items: NewsLanguage.values
          .map((language) {
            return DropdownMenuItem<NewsLanguage>(
              value: language,
              child: Text(_fullLabelForLanguage(language)),
            );
          })
          .toList(growable: false),
      onChanged: enabled
          ? (value) {
              if (value != null) {
                onChanged(value);
              }
            }
          : null,
    );
  }

  String _compactLabelForLanguage(NewsLanguage language) {
    switch (language) {
      case NewsLanguage.auto:
        return 'Auto';
      case NewsLanguage.it:
        return 'IT';
      case NewsLanguage.en:
        return 'EN';
      case NewsLanguage.es:
        return 'ES';
      case NewsLanguage.fr:
        return 'FR';
      case NewsLanguage.de:
        return 'DE';
      case NewsLanguage.ar:
        return 'AR';
      case NewsLanguage.fa:
        return 'FA';
    }
  }

  String _fullLabelForLanguage(NewsLanguage language) {
    switch (language) {
      case NewsLanguage.auto:
        return 'Auto';
      case NewsLanguage.it:
        return 'Italiano (IT)';
      case NewsLanguage.en:
        return 'English (EN)';
      case NewsLanguage.es:
        return 'Español (ES)';
      case NewsLanguage.fr:
        return 'Français (FR)';
      case NewsLanguage.de:
        return 'Deutsch (DE)';
      case NewsLanguage.ar:
        return 'العربية (AR)';
      case NewsLanguage.fa:
        return 'فارسی (FA)';
    }
  }
}

class _MarkerPreviewCard extends StatelessWidget {
  final CivicMapItem item;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const _MarkerPreviewCard({
    super.key,
    required this.item,
    required this.onClose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = item.title.trim().isEmpty ? 'Contenuto' : item.title.trim();
    final previewText = _buildPreviewText(item);
    final typeColor = _typeColor(item.type);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.14),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: typeColor.withValues(alpha: 0.16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _CompactBadge(
                          label: _typeLabel(context, item.type),
                          icon: _typeIcon(item.type),
                          backgroundColor: typeColor.withValues(alpha: 0.12),
                          foregroundColor: typeColor,
                        ),
                        if (item.heatTier != CivicMapHeatTier.normal)
                          _CompactBadge(
                            label: _activityLabel(context, item.heatTier),
                            icon: _activityIcon(item.heatTier),
                            backgroundColor: _activityColor(
                              item.heatTier,
                            ).withValues(alpha: 0.12),
                            foregroundColor: _activityColor(item.heatTier),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip:
                        Localizations.localeOf(context).languageCode == 'it'
                        ? 'Chiudi'
                        : 'Close',
                    visualDensity: VisualDensity.compact,
                    splashRadius: 18,
                    onPressed: onClose,
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.72,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            if (previewText != null) ...[
              const SizedBox(height: 8),
              Text(
                previewText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.86),
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _PreviewMetaRow(item: item)),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(
                    Localizations.localeOf(context).languageCode == 'it'
                        ? 'Apri dettaglio'
                        : 'Open details',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _buildPreviewText(CivicMapItem item) {
    final raw = item.subtitle?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return raw.replaceAll(RegExp(r'\s+'), ' ');
  }

  Color _typeColor(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Colors.green;
      case CivicMapItemType.post:
        return Colors.blue;
      case CivicMapItemType.news:
        return Colors.red;
    }
  }

  IconData _typeIcon(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Icons.poll_outlined;
      case CivicMapItemType.post:
        return Icons.forum_outlined;
      case CivicMapItemType.news:
        return Icons.newspaper_outlined;
    }
  }

  String _typeLabel(BuildContext context, CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Localizations.localeOf(context).languageCode == 'it'
            ? 'Sondaggio'
            : 'Poll';
      case CivicMapItemType.post:
        return 'Post';
      case CivicMapItemType.news:
        return Localizations.localeOf(context).languageCode == 'it'
            ? 'Notizia'
            : 'News';
    }
  }

  String _activityLabel(BuildContext context, CivicMapHeatTier tier) {
    switch (tier) {
      case CivicMapHeatTier.hot:
        return 'Hot';
      case CivicMapHeatTier.active:
        return Localizations.localeOf(context).languageCode == 'it'
            ? 'Attivo'
            : 'Active';
      case CivicMapHeatTier.normal:
        return Localizations.localeOf(context).languageCode == 'it'
            ? 'Normale'
            : 'Normal';
    }
  }

  IconData _activityIcon(CivicMapHeatTier tier) {
    switch (tier) {
      case CivicMapHeatTier.hot:
        return Icons.local_fire_department;
      case CivicMapHeatTier.active:
        return Icons.trending_up;
      case CivicMapHeatTier.normal:
        return Icons.adjust;
    }
  }

  Color _activityColor(CivicMapHeatTier tier) {
    switch (tier) {
      case CivicMapHeatTier.hot:
        return Colors.deepOrange;
      case CivicMapHeatTier.active:
        return Colors.amber;
      case CivicMapHeatTier.normal:
        return Colors.grey;
    }
  }
}

class _PreviewMetaRow extends StatelessWidget {
  final CivicMapItem item;

  const _PreviewMetaRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final heat = item.normalizedHeat.toInt();
    final comments = item.normalizedCommentCount;
    final timeText = _formatRelativeTime(context, item.createdAt) ?? '—';

    return DefaultTextStyle(
      style: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
        fontWeight: FontWeight.w600,
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _MetaInlineItem(
            icon: Icons.local_fire_department_outlined,
            text: '$heat',
          ),
          _MetaInlineItem(icon: Icons.mode_comment_outlined, text: '$comments'),
          _MetaInlineItem(icon: Icons.schedule_outlined, text: timeText),
        ],
      ),
    );
  }

  String? _formatRelativeTime(BuildContext context, DateTime? value) {
    if (value == null) {
      return null;
    }

    final now = DateTime.now();
    final date = value.toLocal();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return Localizations.localeOf(context).languageCode == 'it'
          ? 'ora'
          : 'now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} h';
    }
    if (diff.inDays < 7) {
      return Localizations.localeOf(context).languageCode == 'it'
          ? '${diff.inDays} g'
          : '${diff.inDays} d';
    }
    return MaterialLocalizations.of(context).formatShortDate(date);
  }
}

class _MetaInlineItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaInlineItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.72);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}

class _CompactBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _CompactBadge({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapTypeFilters extends StatelessWidget {
  final CivicMapController controller;

  const _MapTypeFilters({required this.controller});

  Color _chipColor(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Colors.green;
      case CivicMapItemType.post:
        return Colors.blue;
      case CivicMapItemType.news:
        return Colors.red;
    }
  }

  IconData _chipIcon(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Icons.poll_outlined;
      case CivicMapItemType.post:
        return Icons.forum_outlined;
      case CivicMapItemType.news:
        return Icons.newspaper_outlined;
    }
  }

  String _chipLabel(BuildContext context, CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Localizations.localeOf(context).languageCode == 'it'
            ? 'Sondaggio'
            : 'Poll';
      case CivicMapItemType.post:
        return 'Post';
      case CivicMapItemType.news:
        return Localizations.localeOf(context).languageCode == 'it'
            ? 'Notizie'
            : 'News';
    }
  }

  Widget _buildChip(BuildContext context, CivicMapItemType type) {
    final active = controller.isTypeVisible(type);
    final color = _chipColor(type);
    final count = controller.allItems.where((item) => item.type == type).length;

    return FilterChip(
      label: Text('${_chipLabel(context, type)} $count'),
      selected: active,
      onSelected: (_) => controller.toggleType(type),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(_chipIcon(type), size: 18, color: active ? color : null),
      selectedColor: color.withValues(alpha: 0.15),
      checkmarkColor: color,
      side: BorderSide(
        color: active
            ? color.withValues(alpha: 0.45)
            : Colors.grey.withValues(alpha: 0.25),
      ),
      labelStyle: TextStyle(
        color: active ? color : null,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(context, CivicMapItemType.poll),
        _buildChip(context, CivicMapItemType.post),
        _buildChip(context, CivicMapItemType.news),
      ],
    );
  }
}

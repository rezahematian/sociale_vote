import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/entities/geo_point.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';
import 'package:sociale_vote/shared/services/world_marker_policy_service.dart';
import 'package:sociale_vote/shared/widgets/radio_mondo_dock.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';
import 'package:sociale_vote/shared/widgets/world_control_visuals.dart';

import 'package:sociale_vote/app/localization/de_fallback.dart';

import 'web_world_globe_surface_stub.dart'
    if (dart.library.js_interop) 'web_world_globe_surface_web.dart';

enum WorldGlobeInteractionProfile { home, explore }

enum _HomeGestureIntent { idle, undecided, globe, page }

SocialVoteContentKind _contentKindForMapType(CivicMapItemType type) {
  return switch (type) {
    CivicMapItemType.poll => SocialVoteContentKind.vote,
    CivicMapItemType.post => SocialVoteContentKind.voce,
    CivicMapItemType.news => SocialVoteContentKind.news,
  };
}

String _homeGlobeMarkerTypeLabel(CivicMapItemType type) {
  return switch (type) {
    CivicMapItemType.poll => 'Vote',
    CivicMapItemType.post => 'Voce',
    CivicMapItemType.news => 'News',
  };
}

Future<void> _showHomeGlobeMarkerPreview({
  required BuildContext context,
  required CivicMapItem item,
  required ValueChanged<CivicMapItem> onOpen,
}) async {
  final kind = _contentKindForMapType(item.type);
  final typeColor = SocialVoteSymbols.contentColor(kind);
  final subtitle = item.subtitle?.trim();
  final languageCode = Localizations.localeOf(context).languageCode;
  final openLabel = switch (languageCode) {
    'it' => 'Apri dettaglio',
    'de' => 'Details öffnen',
    'fa' => 'باز کردن جزئیات',
    'es' => 'Abrir detalles',
    'pt' => 'Abrir detalhes',
    'fr' => 'Ouvrir les détails',
    'ar' => 'فتح التفاصيل',
    'ro' => 'Deschide detaliile',
    _ => 'Open details',
  };

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContentTypeMark(
                    kind: kind,
                    size: 38,
                    showTooltip: false,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _homeGlobeMarkerTypeLabel(item.type),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle.replaceAll(RegExp(r'\s+'), ' '),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    onOpen(item);
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(openLabel),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class WorldGlobeMapHandoff {
  final double latitude;
  final double longitude;
  final double mapZoom;

  const WorldGlobeMapHandoff({
    required this.latitude,
    required this.longitude,
    required this.mapZoom,
  });
}

/// Exercises the actual overlay in widget tests without bootstrapping map data
/// or a platform renderer. Production callers still use the existing widget.
@visibleForTesting
Widget worldGlobeStylePickerForTest({
  required GlobeVisualStyle selectedStyle,
  required double diameter,
  required ValueChanged<GlobeVisualStyle> onSelected,
  required VoidCallback onDismiss,
}) => _GlobeStyleRadialPicker(
      selectedStyle: selectedStyle,
      diameter: diameter,
      onSelected: onSelected,
      onDismiss: onDismiss,
    );

class _GlobeStyleRadialPicker extends StatelessWidget {
  final GlobeVisualStyle selectedStyle;
  final double diameter;
  final ValueChanged<GlobeVisualStyle> onSelected;
  final VoidCallback onDismiss;

  const _GlobeStyleRadialPicker({
    required this.selectedStyle,
    required this.diameter,
    required this.onSelected,
    required this.onDismiss,
  });

  String _label(GlobeVisualStyle style) {
    return GlobePresetVisual.forStyle(style).shortLabel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const styles = WorldAppearanceService.selectableGlobeStyles;
    final itemExtent = (diameter * 0.20).clamp(56.0, 82.0).toDouble();
    final previewSize = math.max(28.0, itemExtent - 36.0);
    final orbitRadius = math.min(
      (diameter * 0.315).clamp(0.0, 180.0).toDouble(),
      math.max(0.0, (diameter - itemExtent) / 2 - 8),
    );

    return Semantics(
      container: true,
      label: 'Globe style selector',
      child: Material(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Keep dismiss hit-testing BEHIND the preset buttons.
              //
              // A parent GestureDetector used to compete in the same gesture
              // arena as each InkWell. On Web this made a normal tap dismiss
              // the picker before the preset reliably received the tap, so a
              // long press appeared necessary. As a background sibling, this
              // detector receives only taps outside a preset.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDismiss,
                  child: const SizedBox.expand(),
                ),
              ),
              IgnorePointer(
                child: Container(
                  width: orbitRadius * 2.20,
                  height: orbitRadius * 2.20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.18),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              for (var index = 0; index < styles.length; index++)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 150 + (index * 24)),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, child) {
                    final angle = (-math.pi / 2) +
                        ((math.pi * 2 * index) / styles.length);
                    final offset = Offset(
                      math.cos(angle) * orbitRadius * progress,
                      math.sin(angle) * orbitRadius * progress,
                    );
                    return Transform.translate(
                      offset: offset,
                      child: Transform.scale(
                        scale: 0.72 + (0.28 * progress),
                        child: child,
                      ),
                    );
                  },
                  child: _GlobeStyleRadialButton(
                    style: styles[index],
                    label: _label(styles[index]),
                    selected: styles[index] == selectedStyle,
                    extent: itemExtent,
                    previewSize: previewSize,
                    onTap: () => onSelected(styles[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlobeStyleRadialButton extends StatelessWidget {
  final GlobeVisualStyle style;
  final String label;
  final bool selected;
  final double extent;
  final double previewSize;
  final VoidCallback onTap;

  const _GlobeStyleRadialButton({
    required this.style,
    required this.label,
    required this.selected,
    required this.extent,
    required this.previewSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: GlobePresetVisual.forStyle(style).name,
      child: Tooltip(
        message: GlobePresetVisual.forStyle(style).name,
        child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: extent,
            height: extent,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.92),
              border: Border.all(
                color: selected
                    ? colors.primary
                    : colors.outlineVariant.withValues(alpha: 0.78),
                width: selected ? 2.2 : 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.28)
                      : colors.shadow.withValues(alpha: 0.14),
                  blurRadius: selected ? 16 : 9,
                  spreadRadius: selected ? 1.0 : 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PremiumGlobePreview(style: style, size: previewSize),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: selected ? colors.primary : colors.onSurface,
                    fontSize: label.length > 3 ? 9.2 : 10.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class WorldGlobeWidget extends StatefulWidget {
  final List<CivicMapItem> items;
  final ValueChanged<CivicMapItem> onItemTap;
  final VoidCallback onUseClassicMap;
  final WorldGlobeInteractionProfile interactionProfile;
  final ValueChanged<bool>? onPageScrollLockChanged;
  final ValueChanged<WorldGlobeMapHandoff>? onZoomIntoClassicMap;
  final ValueChanged<Offset>? onOrientationChanged;
  final double? initialFocusLatitude;
  final double? initialFocusLongitude;
  final double? initialFocusZoom;
  final GlobeVisualStyle visualStyle;
  final GlobeRotationVisualStyle rotationVisualStyle;

  /// Home-only Radio control. Keeping Radio and Rotate inside the same globe
  /// viewport prevents mobile drift/overflow between independent overlays.
  final bool showHomeRadioControl;
  final RadioVisualStyle radioVisualStyle;

  /// False while the map controller is refreshing/loading a same-scope
  /// snapshot. Renderers must keep the last stable markers in that interval.
  final bool markerDataSettled;

  /// Admin-only preview override for Home marker density. Public surfaces use
  /// the backend-authoritative WorldMarkerPolicyService value.
  final int? homeMarkerDensityOverride;

  const WorldGlobeWidget({
    super.key,
    required this.items,
    required this.onItemTap,
    required this.onUseClassicMap,
    this.interactionProfile = WorldGlobeInteractionProfile.explore,
    this.onPageScrollLockChanged,
    this.onZoomIntoClassicMap,
    this.onOrientationChanged,
    this.initialFocusLatitude,
    this.initialFocusLongitude,
    this.initialFocusZoom,
    this.visualStyle = GlobeVisualStyle.bright,
    this.rotationVisualStyle = GlobeRotationVisualStyle.minimal,
    this.showHomeRadioControl = false,
    this.radioVisualStyle = RadioVisualStyle.oldStyle,
    this.markerDataSettled = true,
    this.homeMarkerDensityOverride,
  });

  @override
  // Platform selection is intentionally isolated here:
  // Web uses the Three.js/WebGL state, native keeps the approved Flutter state.
  // ignore: no_logic_in_create_state
  State<WorldGlobeWidget> createState() {
    if (kIsWeb) {
      return _WebWorldGlobeWidgetState();
    }

    return _WorldGlobeWidgetState();
  }
}

class _WebWorldGlobeWidgetState extends State<WorldGlobeWidget>
    with WidgetsBindingObserver {
  static const double _countryFocusDistance = 2.24;
  static const double _handoffMapZoom = 4.05;
  static const bool _enableCountrySurfaceSelection = false;

  final ValueNotifier<WebGlobeFocus?> _focusNotifier =
      ValueNotifier<WebGlobeFocus?>(null);

  bool _isSelectingCountry = false;
  String? _selectedCountryLabel;
  GeoScope? _selectedCountryScope;
  int _countrySelectionRequestId = 0;
  bool _deepZoomHandoffTriggered = false;
  bool _autoRotateEnabled = true;
  bool _stylePickerOpen = false;
  DateTime? _suppressHomeSurfaceTapUntil;
  String? _lastWebLayoutDiagnostic;
  final WorldMarkerPolicyService _markerPolicy =
      WorldMarkerPolicyService.instance;
  bool _markerPolicyRebuildScheduled = false;

  bool get _isHomeProfile =>
      widget.interactionProfile == WorldGlobeInteractionProfile.home;

  void _openGlobeStylePicker() {
    if (!mounted || _stylePickerOpen) return;
    setState(() {
      _stylePickerOpen = true;
    });
  }

  void _dismissGlobeStylePicker() {
    if (!mounted || !_stylePickerOpen) return;

    // WEB HOME RADIAL TAP GUARD V1.0.6
    //
    // The Web 3D globe is an HtmlElementView. A pointer used on the Flutter
    // radial overlay can also reach the underlying DOM globe surface. On Home
    // that surface tap means "open Civic Map". Keep a very short guard after
    // closing/selecting the radial picker so the SAME pointer cannot navigate.
    if (_isHomeProfile) {
      _suppressHomeSurfaceTapUntil =
          DateTime.now().add(const Duration(milliseconds: 420));
    }

    setState(() {
      _stylePickerOpen = false;
    });
  }

  void _selectGlobeStyle(GlobeVisualStyle style) {
    _dismissGlobeStylePicker();
    unawaited(WorldAppearanceService.instance.setGlobeStyle(style));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _markerPolicy.addListener(_handleMarkerPolicyChanged);
    // Refresh on each newly attached Web globe so a backend Admin density
    // change is picked up when the user revisits/reloads the surface. The
    // service de-duplicates concurrent requests across Admin/Home/Civic Map.
    unawaited(_markerPolicy.ensureLoaded(forceRefresh: true));
  }

  void _handleMarkerPolicyChanged() {
    if (!mounted || _markerPolicyRebuildScheduled) return;
    _markerPolicyRebuildScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markerPolicyRebuildScheduled = false;
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Another Web tab/window may have changed the backend-authoritative
      // density. Refresh only the marker budget when this surface resumes.
      unawaited(_markerPolicy.ensureLoaded(forceRefresh: true));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _markerPolicy.removeListener(_handleMarkerPolicyChanged);
    _focusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = AppDI.instance.currentUserId?.trim();
    final isAuthenticated = currentUserId != null && currentUserId.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final finiteWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final finiteHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;

        final available = math.max(1.0, math.min(finiteWidth, finiteHeight));
        final inset = _isHomeProfile ? 12.0 : 8.0;
        final squareSize = math.max(1.0, available - inset);
        final narrowHome = _isHomeProfile &&
            MediaQuery.sizeOf(context).width < 900;
        final surfaceSize = narrowHome
            ? WorldHomeGlobeGeometry.sphereDiameter(finiteWidth, squareSize) /
                WorldHomeGlobeGeometry.webSphereFraction
            : squareSize;
        final controlInset = narrowHome
            ? WorldHomeGlobeGeometry.narrowHomeControlInset
            : 18.0;

        final diagnostic = '${finiteWidth.toStringAsFixed(1)}x'
            '${finiteHeight.toStringAsFixed(1)}'
            ' square=${squareSize.toStringAsFixed(1)}'
            ' profile=${_isHomeProfile ? 'home' : 'explore'}';

        if (_lastWebLayoutDiagnostic != diagnostic) {
          _lastWebLayoutDiagnostic = diagnostic;
          debugPrint('[WEB-G3D FLUTTER] $diagnostic');
        }

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Center(
              child: SizedBox.square(
                dimension: squareSize,
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: SizedBox.square(
                        dimension: surfaceSize,
                        child: WebWorldGlobeSurface(
                      items: widget.items,
                      homeProfile: _isHomeProfile,
                      isAuthenticated: isAuthenticated,
                      autoRotateEnabled: _autoRotateEnabled,
                      visualStyle: widget.visualStyle.name,
                      markerDataSettled: widget.markerDataSettled,
                      homeMarkerLimit: _markerPolicy.homeMarkerLimitForDensity(
                        widget.homeMarkerDensityOverride,
                      ),
                      onMarkerTap: _handleMarkerTap,
                      onSurfaceTap: _handleSurfaceTap,
                      onSurfaceLongPress: _openGlobeStylePicker,
                      onOrientationChanged: widget.onOrientationChanged,
                      onDeepZoom: _isHomeProfile ? null : _handleDeepZoom,
                      focusListenable: _focusNotifier,
                      initialFocusLatitude: widget.initialFocusLatitude,
                      initialFocusLongitude: widget.initialFocusLongitude,
                      initialFocusZoom: widget.initialFocusZoom,
                      onUnavailable: widget.onUseClassicMap,
                        ),
                      ),
                    ),
                    if (widget.showHomeRadioControl)
                      Positioned(
                        left: controlInset,
                        bottom: controlInset,
                        child: RadioMondoDock(
                          visualStyle: widget.radioVisualStyle,
                          globeStyle: widget.visualStyle,
                          rotationVisualStyle: widget.rotationVisualStyle,
                          size: WorldHomeGlobeGeometry.controlSize,
                        ),
                      ),
                    if (widget.showHomeRadioControl || isAuthenticated)
                      Positioned(
                        right: controlInset,
                        bottom: controlInset,
                        child: _GlobeRotationButton(
                          isRotating: _autoRotateEnabled,
                          globeStyle: widget.visualStyle,
                          visualStyle: widget.rotationVisualStyle,
                          onPressed: () {
                            setState(() {
                              _autoRotateEnabled = !_autoRotateEnabled;
                            });
                          },
                        ),
                      ),
                    if (_stylePickerOpen)
                      Positioned.fill(
                        child: _GlobeStyleRadialPicker(
                          selectedStyle: widget.visualStyle,
                          diameter: squareSize,
                          onSelected: _selectGlobeStyle,
                          onDismiss: _dismissGlobeStylePicker,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (!_isHomeProfile &&
                (_isSelectingCountry || _selectedCountryLabel != null))
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 6,
                        top: 5,
                        bottom: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSelectingCountry) ...[
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            Icon(
                              Icons.location_on_outlined,
                              size: 17,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              _selectedCountryLabel ??
                                  (Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'it'
                                      ? 'Identificazione Paese…'
                                      : deOrEnglish(
                                          context,
                                          english: 'Identifying country…',
                                          german: 'Land wird identifiziert…',
                                        )),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!_isSelectingCountry &&
                              _selectedCountryScope != null) ...[
                            const SizedBox(width: 6),
                            TextButton(
                              onPressed: _openSelectedCountry,
                              child: Text(
                                Localizations.localeOf(context).languageCode ==
                                        'it'
                                    ? 'Apri Paese'
                                    : deOrEnglish(
                                        context,
                                        english: 'Open country',
                                        german: 'Land öffnen',
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _handleMarkerTap(CivicMapItem item) {
    _countrySelectionRequestId += 1;

    if (_isSelectingCountry ||
        _selectedCountryLabel != null ||
        _selectedCountryScope != null) {
      setState(() {
        _isSelectingCountry = false;
        _selectedCountryLabel = null;
        _selectedCountryScope = null;
      });
    }

    if (_isHomeProfile) {
      unawaited(
        _showHomeGlobeMarkerPreview(
          context: context,
          item: item,
          onOpen: widget.onItemTap,
        ),
      );
      return;
    }

    _focusNotifier.value = WebGlobeFocus(
      latitude: item.latitude,
      longitude: item.longitude,
      distance: _countryFocusDistance,
      recoverToNaturalRotation: true,
      recoveryHoldMs: 260,
    );
    widget.onItemTap(item);
  }

  void _handleSurfaceTap(double latitude, double longitude) {
    if (_isHomeProfile) {
      final suppressUntil = _suppressHomeSurfaceTapUntil;
      if (_stylePickerOpen ||
          (suppressUntil != null &&
              DateTime.now().isBefore(suppressUntil))) {
        return;
      }

      widget.onUseClassicMap();
      return;
    }

    if (_enableCountrySurfaceSelection) {
      _resolveCountryFromTap(latitude, longitude);
    }
  }

  void _handleDeepZoom(double latitude, double longitude) {
    final callback = widget.onZoomIntoClassicMap;

    if (_isHomeProfile || callback == null || _deepZoomHandoffTriggered) {
      return;
    }

    _deepZoomHandoffTriggered = true;

    callback(
      WorldGlobeMapHandoff(
        latitude: latitude,
        longitude: longitude,
        mapZoom: _handoffMapZoom,
      ),
    );
  }

  Future<void> _resolveCountryFromTap(double latitude, double longitude) async {
    if (_isHomeProfile || _isSelectingCountry) {
      return;
    }

    final requestId = ++_countrySelectionRequestId;

    setState(() {
      _isSelectingCountry = true;
      _selectedCountryLabel = null;
      _selectedCountryScope = null;
    });

    try {
      final resolved = await AppDI.instance.resolveScopeFromPoint(
        GeoPoint(latitude: latitude, longitude: longitude),
      );

      if (!mounted || requestId != _countrySelectionRequestId) {
        return;
      }

      final countryCode = resolved.scope.countryCode?.trim().toUpperCase();

      if (countryCode == null || countryCode.isEmpty) {
        return;
      }

      final countryScope = await _countryScopeForSelection(
        countryCode: countryCode,
        resolvedScope: resolved.scope,
        tappedLatitude: latitude,
        tappedLongitude: longitude,
      );

      if (!mounted || requestId != _countrySelectionRequestId) {
        return;
      }

      final languageCode = Localizations.localeOf(context).languageCode;

      final countryLabel = Countries.nameForCode(
        countryCode,
        languageCode: languageCode,
        fallback: resolved.displayName,
      );

      setState(() {
        _isSelectingCountry = false;
        _selectedCountryLabel = countryLabel;
        _selectedCountryScope = countryScope;
      });

      _focusNotifier.value = WebGlobeFocus(
        latitude: countryScope.centerLat ?? latitude,
        longitude: countryScope.centerLng ?? longitude,
        distance: _countryFocusDistance,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[WorldGlobe/Web] country selection failed: '
        '$error\n$stackTrace',
      );
    } finally {
      if (mounted && requestId == _countrySelectionRequestId) {
        setState(() {
          _isSelectingCountry = false;
        });
      }
    }
  }

  void _openSelectedCountry() {
    final countryScope = _selectedCountryScope;

    if (_isHomeProfile || _isSelectingCountry || countryScope == null) {
      return;
    }

    AppDI.instance.geoScopeController.setScope(countryScope);
  }

  Future<GeoScope> _countryScopeForSelection({
    required String countryCode,
    required GeoScope resolvedScope,
    required double tappedLatitude,
    required double tappedLongitude,
  }) async {
    if (resolvedScope.level == GeoScopeLevel.country &&
        _isValidLatLng(resolvedScope.centerLat, resolvedScope.centerLng)) {
      return resolvedScope;
    }

    final countryRadius = resolvedScope.level == GeoScopeLevel.country
        ? resolvedScope.radiusKm
        : null;

    try {
      final geocoded =
          await AppDI.instance.geocodingRepository.geocodeContentLocation(
        ContentLocation(
          source: ContentLocationSource.geoScopeFallback,
          countryCode: countryCode,
        ),
      );

      final centerLat = geocoded?.centerLat ?? geocoded?.latitude;
      final centerLng = geocoded?.centerLng ?? geocoded?.longitude;

      if (_isValidLatLng(centerLat, centerLng)) {
        return GeoScope.country(
          countryCode,
          centerLat: centerLat,
          centerLng: centerLng,
          radiusKm: countryRadius,
        );
      }
    } catch (_) {
      // Best effort: the tapped point remains a valid fallback.
    }

    return GeoScope.country(
      countryCode,
      centerLat: tappedLatitude,
      centerLng: tappedLongitude,
      radiusKm: countryRadius,
    );
  }

  bool _isValidLatLng(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return false;
    }

    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }
}

class _WorldGlobeWidgetState extends State<WorldGlobeWidget>
    with WidgetsBindingObserver {
  static const bool _isWasmBuild = bool.fromEnvironment('dart.tool.dart2wasm');

  static const String _earthTextureClassicAsset =
      GlobePresetVisual.dayAsset;
  static const String _earthTextureRealisticAsset =
      GlobePresetVisual.satelliteAsset;
  static const String _earthTextureNightAsset =
      GlobePresetVisual.nightAsset;

  static const double _approvedPanSensitivity = 0.58;
  static const double _gestureIntentThreshold = 7.0;
  static const double _gestureFallbackThreshold = 16.0;
  static const double _axisDominance = 1.08;
  static const double _sphereHitSlop = 8.0;
  static const double _homeMaxViewport = 520.0;
  static const double _exploreMaxViewport = 820.0;
  static const bool _enableCountrySurfaceSelection = false;
  static const double _countryFocusZoom = 0.055;
  static const Duration _countryFocusDuration = Duration(milliseconds: 480);
  static const double _exploreTapMovementTolerance = 12.0;
  static const Duration _styleLongPressDuration = Duration(milliseconds: 460);
  static const double _styleLongPressMoveTolerance = 9.0;

  // Use the renderer's own AnimationController for passive rotation. This is
  // the same controller that already pauses during a gesture and resumes on
  // release, so automatic rotation never competes with manual movement.
  static const double _nativeApprovedRotationSpeed = 0.0065;
  static const double _nativeNaturalLatitudeDegrees = 18.0;
  static const Duration _nativeInitialRotationWarmup = Duration(
    milliseconds: 700,
  );
  static const Duration _nativeNaturalTiltDelay = Duration(milliseconds: 90);
  static const Duration _nativeNaturalTiltDuration = Duration(
    milliseconds: 720,
  );
  static const Duration _countrySelectionAutoDismiss = Duration(seconds: 4);

  // G5B Explore marker/zoom baseline. Home stays visually untouched.
  static const double _exploreMaxZoom = 1.15;

  // G5C: once the 3D view is close enough that curvature is no longer the
  // useful part of the experience, hand the exact geographic center to the
  // existing 2D Civic Map. GeoScope is intentionally NOT changed.
  // Transition only when the globe is effectively at its visual maximum.
  // The last part of the same zoom gesture is then continued by Civic Map
  // through the animated camera handoff, avoiding an early renderer snap.
  static const double _globeToMapHandoffZoom = 1.12;
  static const double _handoffMapZoomMin = 3.7;
  static const double _handoffMapZoomMax = 4.35;

  // Home shows only a small set of high-value beacons. Larger clustering
  // keeps dense regions readable at the fixed Home globe scale.
  static const double _homeMarkerClusterDegrees = 18.0;

  static const int _exploreMarkerLimitFar = 36;
  static const int _exploreMarkerLimitNear = 96;

  late final FlutterEarthGlobeController _globeController;
  final WorldMarkerPolicyService _markerPolicy =
      WorldMarkerPolicyService.instance;
  bool _texturePrecached = false;
  bool _autoRotateEnabled = true;
  bool _stylePickerOpen = false;
  bool _suppressTapAfterStyleLongPress = false;
  Timer? _styleLongPressTimer;
  int? _styleLongPressPointer;
  Offset? _styleLongPressStart;
  String? _nativeTextureAsset;
  String? _lastNativeMarkerInputSignature;

  // Scientific sky runs independently of the Earth renderer. We sample the
  // renderer attitude at 30 fps: smooth enough for an infinite background and
  // deliberately lighter than 60 fps on older Android devices.
  final ValueNotifier<Offset> _scientificSkyOrientation = ValueNotifier<Offset>(
    Offset.zero,
  );
  Timer? _scientificSkyTimer;

  final Map<int, Offset> _activePointers = <int, Offset>{};

  _HomeGestureIntent _homeGestureIntent = _HomeGestureIntent.idle;
  int? _primaryPointer;
  Offset? _primaryStartPosition;
  bool _primaryStartedOnSphere = false;
  bool _pageScrollLocked = false;

  bool _isSelectingCountry = false;
  String? _selectedCountryLabel;
  GeoScope? _selectedCountryScope;
  int _countrySelectionRequestId = 0;

  final Set<int> _exploreTapPointers = <int>{};
  int? _exploreTapCandidatePointer;
  Offset? _exploreTapDownPosition;
  bool _exploreTapMoved = false;
  bool _exploreTapStartedOnSphere = false;

  final Map<String, CivicMapItem> _globeMarkerItemsByPointId =
      <String, CivicMapItem>{};
  final Map<String, List<CivicMapItem>> _globeMarkerGroupsByPointId =
      <String, List<CivicMapItem>>{};
  int _lastMarkerZoomBucket = -1;
  bool _globeToMapHandoffTriggered = false;
  bool _initialFocusApplied = false;

  bool _nativeRotationWarmupComplete = false;
  Timer? _nativeRotationWarmupTimer;
  Timer? _nativeNaturalTiltTimer;
  int _nativeNaturalTiltToken = 0;
  Timer? _countrySelectionDismissTimer;

  double _viewportSize = 0.0;
  double _baseRadius = 0.0;

  bool get _canRenderGlobe => !kIsWeb || _isWasmBuild;

  bool get _isHomeProfile =>
      widget.interactionProfile == WorldGlobeInteractionProfile.home;

  void _cancelNativeStyleLongPress() {
    _styleLongPressTimer?.cancel();
    _styleLongPressTimer = null;
    _styleLongPressPointer = null;
    _styleLongPressStart = null;
  }

  void _startNativeStyleLongPress(PointerDownEvent event) {
    if (_stylePickerOpen || !_isInsideVisibleSphere(event.localPosition)) {
      return;
    }

    _cancelNativeStyleLongPress();
    _styleLongPressPointer = event.pointer;
    _styleLongPressStart = event.localPosition;
    _styleLongPressTimer = Timer(_styleLongPressDuration, () {
      if (!mounted || _styleLongPressPointer != event.pointer) return;
      _openNativeGlobeStylePicker();
    });
  }

  void _trackNativeStyleLongPress(PointerMoveEvent event) {
    if (event.pointer != _styleLongPressPointer ||
        _styleLongPressStart == null) {
      return;
    }

    if ((event.localPosition - _styleLongPressStart!).distance >
        _styleLongPressMoveTolerance) {
      _cancelNativeStyleLongPress();
    }
  }

  void _openNativeGlobeStylePicker() {
    if (!mounted || _stylePickerOpen) return;
    _cancelNativeStyleLongPress();
    _suppressTapAfterStyleLongPress = true;
    _globeController.panSensitivity = 0.0;
    if (_isHomeProfile) {
      _setPageScrollLocked(true);
    }
    setState(() {
      _stylePickerOpen = true;
    });
  }

  void _dismissNativeGlobeStylePicker() {
    if (!mounted || !_stylePickerOpen) return;
    setState(() {
      _stylePickerOpen = false;
    });
    _globeController.panSensitivity = _approvedPanSensitivity;
    if (_isHomeProfile) {
      _setPageScrollLocked(false);
    }
  }

  void _selectNativeGlobeStyle(GlobeVisualStyle style) {
    _dismissNativeGlobeStylePicker();
    unawaited(WorldAppearanceService.instance.setGlobeStyle(style));
  }

  @override
  void initState() {
    super.initState();

    _nativeTextureAsset = _textureAssetForStyle(widget.visualStyle);
    _globeController = FlutterEarthGlobeController(
      surface: Image.asset(_nativeTextureAsset!).image,

      // G5E: the renderer owns only Earth + markers + circular atmosphere.
      // Any page/Space background must live outside the square globe viewport.
      background: null,
      isBackgroundFollowingSphereRotation: false,
      isRotating: false,
      rotationSpeed: _nativeApprovedRotationSpeed,

      // Approved zoom envelope: the globe can approach the available edges
      // without exposing the square rendering viewport.
      zoom: 0.0,
      minZoom: -0.22,
      maxZoom: _isHomeProfile ? 0.08 : _exploreMaxZoom,
      isZoomEnabled: true,
      zoomSensitivity: _isHomeProfile ? 0.30 : 0.26,
      zoomToMousePosition: false,

      // Runtime-approved rotation sensitivity. Do not change this value while
      // tuning Home-vs-page gesture ownership.
      panSensitivity: _approvedPanSensitivity,

      // G2 final candidate — fixed, subtle surface lighting.
      // It gives the sphere depth without turning the globe into a dark
      // day/night visualization, which is intentionally kept out of Home.
      surfaceLightingEnabled: true,
      lightAngle: -28.0,
      lightIntensity: 1.18,
      ambientLight: 0.68,

      // G2 final candidate — thin atmospheric rim only.
      // Values stay deliberately restrained so the Earth remains the focus
      // and the glow does not expose the square renderer at max zoom.
      showAtmosphere: true,
      atmosphereColor: const Color(0xFF69B5FF),
      atmosphereBlur: 15.0,
      atmosphereThickness: 0.008,
      atmosphereOpacity: 0.20,

      // Deliberate G2 product decision: no day/night cycle.
      // Keep it for a later optional polish pass after performance, markers
      // and country transitions are stable across native and web renderers.
      isDayNightCycleEnabled: false,
      useRealTimeSunPosition: false,
    );
    _applyNativeVisualStyle(widget.visualStyle, reloadTexture: false);

    _globeController.onLoaded = () {
      debugPrint('[WorldGlobe] controller loaded');
      _applyInitialFocusIfNeeded();

      _nativeRotationWarmupTimer?.cancel();
      _nativeRotationWarmupTimer = Timer(_nativeInitialRotationWarmup, () {
        if (!mounted) {
          return;
        }
        _nativeRotationWarmupComplete = true;
        _applyNativeRotationPolicy();
      });
    };

    if (widget.onOrientationChanged != null) {
      _scientificSkyTimer = Timer.periodic(
        const Duration(milliseconds: 50),
        (_) => _syncScientificSkyOrientation(),
      );
    }

    _syncGlobeContentPoints();
    WidgetsBinding.instance.addObserver(this);
    _markerPolicy.addListener(_handleMarkerPolicyChanged);
    unawaited(_markerPolicy.ensureLoaded(forceRefresh: true));
  }

  void _handleMarkerPolicyChanged() {
    if (!mounted || !_isHomeProfile) {
      return;
    }

    _lastNativeMarkerInputSignature = null;
    _syncGlobeContentPoints();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_markerPolicy.ensureLoaded(forceRefresh: true));
    }
  }

  bool get _hasValidInitialFocus {
    final latitude = widget.initialFocusLatitude;
    final longitude = widget.initialFocusLongitude;

    if (latitude == null || longitude == null) {
      return false;
    }

    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }

  void _applyInitialFocusIfNeeded() {
    if (_isHomeProfile || _initialFocusApplied || !_hasValidInitialFocus) {
      return;
    }

    final latitude = widget.initialFocusLatitude!;
    final longitude = widget.initialFocusLongitude!;
    final requestedZoom = widget.initialFocusZoom ?? 0.0;
    final targetZoom = requestedZoom
        .clamp(_globeController.minZoom, _globeController.maxZoom)
        .toDouble();

    _initialFocusApplied = true;
    _globeController.setZoom(targetZoom);
    _globeController.focusOnCoordinates(
      GlobeCoordinates(latitude, longitude),
      animate: false,
    );

    debugPrint(
      '[WorldGlobe] 2D->3D initial focus: '
      'center=($latitude, $longitude) '
      'zoom=${targetZoom.toStringAsFixed(2)}',
    );
  }

  bool get _isAuthenticatedNow {
    final currentUserId = AppDI.instance.currentUserId?.trim();
    return currentUserId != null && currentUserId.isNotEmpty;
  }

  bool get _shouldNativeAutoRotate {
    return _nativeRotationWarmupComplete && _autoRotateEnabled;
  }

  void _toggleNativeAutoRotation() {
    _cancelNativeNaturalTiltRecovery();
    setState(() {
      _autoRotateEnabled = !_autoRotateEnabled;
    });
    _applyNativeRotationPolicy();
  }

  double get _nativeRotationSpeed =>
      _isHomeProfile ? 0.0080 : _nativeApprovedRotationSpeed;

  void _applyNativeRotationPolicy() {
    if (!_globeController.isReady || !_nativeRotationWarmupComplete) {
      return;
    }

    if (_shouldNativeAutoRotate) {
      if (_globeController.isRotating) {
        _globeController.setRotationSpeed(_nativeRotationSpeed);
      } else {
        _globeController.startRotation(rotationSpeed: _nativeRotationSpeed);
      }
      return;
    }

    if (_globeController.isRotating) {
      _globeController.stopRotation();
    }
  }

  void _cancelNativeNaturalTiltRecovery() {
    _nativeNaturalTiltTimer?.cancel();
    _nativeNaturalTiltToken += 1;
  }

  void _scheduleNativeNaturalTiltRecovery({
    Duration delay = _nativeNaturalTiltDelay,
    bool refreshMarkersBeforeRecovery = false,
  }) {
    if (!_globeController.isReady ||
        (!_shouldNativeAutoRotate && !refreshMarkersBeforeRecovery)) {
      return;
    }

    final token = ++_nativeNaturalTiltToken;
    _nativeNaturalTiltTimer?.cancel();

    // The renderer has just finished its gesture/deceleration or temporary
    // marker-focus hand-off. Stop passive rotation while latitude returns to
    // the approved natural attitude; longitude is preserved.
    _globeController.stopRotation();

    _nativeNaturalTiltTimer = Timer(delay, () {
      if (!mounted ||
          token != _nativeNaturalTiltToken ||
          !_globeController.isReady) {
        _applyNativeRotationPolicy();
        return;
      }

      if (refreshMarkersBeforeRecovery) {
        // Re-publish the same immutable marker points after a programmatic
        // focus. This repairs the native overlay-label cache without changing
        // coordinates, clustering, density, or content selection.
        _lastNativeMarkerInputSignature = null;
        _syncGlobeContentPoints();
      }

      if (!_shouldNativeAutoRotate) {
        return;
      }

      final globeState = _globeController.globeKey.currentState;
      if (globeState == null) {
        _applyNativeRotationPolicy();
        return;
      }

      globeState.returnToNaturalTilt(
        latitudeDegrees: _nativeNaturalLatitudeDegrees,
        duration: _nativeNaturalTiltDuration,
        curve: Curves.easeOutCubic,
        onCompleted: () {
          if (!mounted || token != _nativeNaturalTiltToken) {
            return;
          }
          _applyNativeRotationPolicy();
        },
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_texturePrecached) {
      _texturePrecached = true;
      precacheImage(Image.asset(_earthTextureClassicAsset).image, context);
      precacheImage(Image.asset(_earthTextureRealisticAsset).image, context);
      precacheImage(Image.asset(_earthTextureNightAsset).image, context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _markerPolicy.removeListener(_handleMarkerPolicyChanged);
    _scientificSkyTimer?.cancel();
    _nativeRotationWarmupTimer?.cancel();
    _nativeNaturalTiltTimer?.cancel();
    _countrySelectionDismissTimer?.cancel();
    _cancelNativeStyleLongPress();
    _scientificSkyOrientation.dispose();

    if (_pageScrollLocked) {
      widget.onPageScrollLockChanged?.call(false);
    }

    super.dispose();
  }

  void _syncScientificSkyOrientation() {
    if (!mounted || !_canRenderGlobe) {
      return;
    }

    final globeState = _globeController.globeKey.currentState;
    if (globeState == null) {
      return;
    }

    // Renderer angles are in radians. For the sky we publish the visual
    // camera attitude rather than a second artificial 2D pan.
    final next = Offset(globeState.rotationZ, globeState.rotationX);

    final previous = _scientificSkyOrientation.value;
    if ((next - previous).distanceSquared < 0.000001) {
      return;
    }

    _scientificSkyOrientation.value = next;
    widget.onOrientationChanged?.call(next);
  }

  @override
  void didUpdateWidget(covariant WorldGlobeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.interactionProfile != widget.interactionProfile) {
      _resetHomeGestureState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _applyNativeRotationPolicy();
        }
      });
    }

    if (oldWidget.visualStyle != widget.visualStyle) {
      _applyNativeVisualStyle(widget.visualStyle);
    }

    if (oldWidget.homeMarkerDensityOverride !=
        widget.homeMarkerDensityOverride) {
      _lastNativeMarkerInputSignature = null;
      _syncGlobeContentPoints();
    }

    if (oldWidget.onOrientationChanged != widget.onOrientationChanged) {
      _scientificSkyTimer?.cancel();
      _scientificSkyTimer = null;
      if (widget.onOrientationChanged != null) {
        _scientificSkyTimer = Timer.periodic(
          const Duration(milliseconds: 50),
          (_) => _syncScientificSkyOrientation(),
        );
      }
    }

    if (oldWidget.initialFocusLatitude != widget.initialFocusLatitude ||
        oldWidget.initialFocusLongitude != widget.initialFocusLongitude ||
        oldWidget.initialFocusZoom != widget.initialFocusZoom) {
      _initialFocusApplied = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _applyInitialFocusIfNeeded();
        }
      });
    }

    final markerInputChanged =
        _markerInputSignature(oldWidget.items, oldWidget.markerDataSettled) !=
            _markerInputSignature(widget.items, widget.markerDataSettled);
    if (markerInputChanged) {
      _syncGlobeContentPoints();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canRenderGlobe) {
      return _WasmRequiredFallback(onUseClassicMap: widget.onUseClassicMap);
    }

    final screenSize = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isAuthenticated = _isAuthenticatedNow;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : availableWidth;

        final maxViewport =
            _isHomeProfile ? _homeMaxViewport : _exploreMaxViewport;

        final narrowHome = _isHomeProfile && screenSize.width < 900;
        final viewportSize = narrowHome
            ? WorldHomeGlobeGeometry.frameSize(availableWidth, availableHeight)
            : math.min(availableWidth, availableHeight)
                .clamp(1.0, maxViewport).toDouble();

        final radius = narrowHome
            ? WorldHomeGlobeGeometry.sphereDiameter(
                availableWidth, viewportSize) / 2
            : viewportSize * 0.46;
        final controlInset = narrowHome
            ? WorldHomeGlobeGeometry.narrowHomeControlInset
            : WorldHomeGlobeGeometry.controlInset;

        _viewportSize = viewportSize;
        _baseRadius = radius;

        final alignmentX = screenSize.width > 0
            ? ((viewportSize / screenSize.width) - 1.0)
                .clamp(-1.0, 1.0)
                .toDouble()
            : 0.0;

        final alignmentY = screenSize.height > 0
            ? ((viewportSize / screenSize.height) - 1.0)
                .clamp(-1.0, 1.0)
                .toDouble()
            : 0.0;

        final globe = FlutterEarthGlobe(
          controller: _globeController,
          radius: radius,
          alignment: Alignment(alignmentX, alignmentY),

          // G3 interaction profile.
          //
          // Home:
          // - North stays up
          // - horizontal rotation with restrained vertical tilt
          // - short, restrained inertia
          //
          // Explore:
          // - horizontal rotation remains free
          // - vertical tilt is allowed but cannot flip the planet
          // - inertia remains short and controlled
          lockVerticalRotation: _isHomeProfile,
          maxVerticalTiltDegrees: _isHomeProfile ? 22.0 : 55.0,
          decelerationDuration: Duration(
            milliseconds: _isHomeProfile ? 450 : 550,
          ),
          inertiaStrength: _isHomeProfile ? 0.45 : 0.60,
          showSpaceBackground: false,
          onZoomChanged: _handleGlobeZoomChanged,
          onTap: null,
        );

        return Align(
          alignment: _isHomeProfile && !narrowHome
              ? Alignment.topCenter : Alignment.center,
          child: SizedBox.square(
            dimension: viewportSize,
            child: RepaintBoundary(
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  _isHomeProfile && !isAuthenticated
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            if (_isInsideVisibleSphere(details.localPosition)) {
                              widget.onUseClassicMap();
                            }
                          },
                          onLongPressStart: (details) {
                            if (_isInsideVisibleSphere(details.localPosition)) {
                              _openNativeGlobeStylePicker();
                            }
                          },
                          child: IgnorePointer(child: globe),
                        )
                      : _isHomeProfile
                          ? Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: _handleHomePointerDown,
                              onPointerMove: _handleHomePointerMove,
                              onPointerUp: _handleHomePointerUp,
                              onPointerCancel: _handleHomePointerCancel,
                              child: globe,
                            )
                          : Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: _handleExplorePointerDown,
                              onPointerMove: _handleExplorePointerMove,
                              onPointerUp: _handleExplorePointerUp,
                              onPointerCancel: _handleExplorePointerCancel,
                              child: globe,
                            ),
                  if (widget.showHomeRadioControl || isAuthenticated)
                    Positioned(
                      left: controlInset,
                      right: controlInset,
                      bottom: controlInset,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.showHomeRadioControl)
                            RadioMondoDock(
                              visualStyle: widget.radioVisualStyle,
                              globeStyle: widget.visualStyle,
                              rotationVisualStyle: widget.rotationVisualStyle,
                              size: WorldHomeGlobeGeometry.controlSize,
                            )
                          else
                            const SizedBox.square(dimension: WorldHomeGlobeGeometry.controlSize),
                          if (widget.showHomeRadioControl || isAuthenticated)
                            _GlobeRotationButton(
                              isRotating: _autoRotateEnabled,
                              globeStyle: widget.visualStyle,
                              visualStyle: widget.rotationVisualStyle,
                              onPressed: _toggleNativeAutoRotation,
                            )
                          else
                            const SizedBox.square(dimension: WorldHomeGlobeGeometry.controlSize),
                        ],
                      ),
                    ),
                  if (_stylePickerOpen)
                    Positioned.fill(
                      child: _GlobeStyleRadialPicker(
                        selectedStyle: widget.visualStyle,
                        diameter: viewportSize,
                        onSelected: _selectNativeGlobeStyle,
                        onDismiss: _dismissNativeGlobeStylePicker,
                      ),
                    ),
                  if (!_isHomeProfile &&
                      (_isSelectingCountry || _selectedCountryLabel != null))
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Center(
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
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 6,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isSelectingCountry) ...[
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ] else ...[
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 17,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Text(
                                    _selectedCountryLabel ??
                                        (Localizations.localeOf(
                                                  context,
                                                ).languageCode ==
                                                'it'
                                            ? 'Identificazione Paese…'
                                            : deOrEnglish(
                                                context,
                                                english: 'Identifying country…',
                                                german:
                                                    'Land wird identifiziert…',
                                              )),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (!_isSelectingCountry &&
                                    _selectedCountryScope != null) ...[
                                  const SizedBox(width: 6),
                                  TextButton(
                                    onPressed: _openSelectedCountry,
                                    child: Text(
                                      Localizations.localeOf(
                                                context,
                                              ).languageCode ==
                                              'it'
                                          ? 'Apri Paese'
                                          : deOrEnglish(
                                              context,
                                              english: 'Open country',
                                              german: 'Land öffnen',
                                            ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!_isHomeProfile && _selectedCountryLabel != null)
                    Center(
                      child: IgnorePointer(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
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

  void _handleExplorePointerDown(PointerDownEvent event) {
    _cancelNativeNaturalTiltRecovery();
    _exploreTapPointers.add(event.pointer);

    if (_exploreTapPointers.length == 1) {
      _startNativeStyleLongPress(event);
      _exploreTapCandidatePointer = event.pointer;
      _exploreTapDownPosition = event.localPosition;
      _exploreTapMoved = false;
      _exploreTapStartedOnSphere = _isInsideVisibleSphere(event.localPosition);
      return;
    }

    _cancelNativeStyleLongPress();
    // Pinch/multi-touch can zoom the globe but must never select a country.
    _resetExploreTapCandidate(keepPointers: true);
  }

  void _handleExplorePointerMove(PointerMoveEvent event) {
    _trackNativeStyleLongPress(event);
    if (event.pointer != _exploreTapCandidatePointer ||
        _exploreTapDownPosition == null) {
      return;
    }

    if ((event.localPosition - _exploreTapDownPosition!).distance >
        _exploreTapMovementTolerance) {
      _exploreTapMoved = true;
    }
  }

  void _handleExplorePointerUp(PointerUpEvent event) {
    _cancelNativeStyleLongPress();
    final confirmedTap = event.pointer == _exploreTapCandidatePointer &&
        _exploreTapPointers.length == 1 &&
        !_exploreTapMoved &&
        !_suppressTapAfterStyleLongPress &&
        _exploreTapStartedOnSphere;

    _exploreTapPointers.remove(event.pointer);
    final interactionFinished = _exploreTapPointers.isEmpty;

    if (!confirmedTap) {
      if (event.pointer == _exploreTapCandidatePointer) {
        _resetExploreTapCandidate();
      }
      if (interactionFinished) {
        _scheduleNativeNaturalTiltRecovery();
        _suppressTapAfterStyleLongPress = false;
      }
      return;
    }

    final globalPosition = event.position;
    _resetExploreTapCandidate();
    _suppressTapAfterStyleLongPress = false;
    _handleExploreSurfaceTap(globalPosition);
  }

  void _handleExploreSurfaceTap(Offset globalPosition) {
    if (!mounted || _isHomeProfile) {
      return;
    }

    final globeContext = _globeController.globeKey.currentContext;
    final globeState = _globeController.globeKey.currentState;
    final renderObject = globeContext?.findRenderObject();

    if (globeState == null || renderObject is! RenderBox) {
      debugPrint('[WorldGlobe] Explore tap ignored: renderer unavailable');
      return;
    }

    final rendererLocalPosition = renderObject.globalToLocal(globalPosition);

    // G5B: marker hit-testing has absolute priority over Country selection.
    // The vendored renderer compensates its internal alignment and returns the
    // visible point id directly, so this does not depend on a delayed paint
    // callback or Flutter's gesture arena.
    final markerPointId = globeState.pointIdAtLocalPosition(
      rendererLocalPosition,
    );
    if (markerPointId != null) {
      final markerItem = _globeMarkerItemsByPointId[markerPointId];
      final markerGroup = _globeMarkerGroupsByPointId[markerPointId];
      if (markerItem != null) {
        debugPrint('[WorldGlobe] G5 marker hit: $markerPointId');
        if (markerGroup != null && markerGroup.length > 1) {
          _showGlobeMarkerGroupPicker(markerGroup);
        } else {
          _handleGlobeMarkerTap(markerItem);
        }
        return;
      }
    }

    if (_enableCountrySurfaceSelection) {
      final coordinates = globeState.coordinatesAtLocalPosition(
        rendererLocalPosition,
      );

      debugPrint('[WorldGlobe] Explore tap coordinates: $coordinates');
      _handleExploreGlobeTap(coordinates);
    }
  }

  void _handleGlobeZoomChanged(double zoom) {
    if (_isHomeProfile) {
      return;
    }

    final bucket = _markerZoomBucket(zoom);
    if (bucket != _lastMarkerZoomBucket) {
      _lastMarkerZoomBucket = bucket;
      _syncGlobeContentPoints();
    }

    if (_globeToMapHandoffTriggered ||
        widget.onZoomIntoClassicMap == null ||
        zoom < _globeToMapHandoffZoom) {
      return;
    }

    // Wait until this zoom frame has settled, then read the true geographic
    // point at the visual center of the rendered sphere.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _isHomeProfile ||
          _globeToMapHandoffTriggered ||
          _globeController.zoom < _globeToMapHandoffZoom) {
        return;
      }

      final centerCoordinates =
          _globeController.globeKey.currentState?.centerCoordinates();

      if (centerCoordinates == null) {
        debugPrint('[WorldGlobe] 3D->2D handoff skipped: center unavailable');
        return;
      }

      final mapZoom = _mapZoomForGlobeHandoff(_globeController.zoom);
      _globeToMapHandoffTriggered = true;

      debugPrint(
        '[WorldGlobe] 3D->2D handoff: '
        'center=(${centerCoordinates.latitude}, '
        '${centerCoordinates.longitude}) '
        'globeZoom=${_globeController.zoom.toStringAsFixed(2)} '
        'mapZoom=${mapZoom.toStringAsFixed(2)}',
      );

      widget.onZoomIntoClassicMap!(
        WorldGlobeMapHandoff(
          latitude: centerCoordinates.latitude,
          longitude: centerCoordinates.longitude,
          mapZoom: mapZoom,
        ),
      );
    });
  }

  double _mapZoomForGlobeHandoff(double globeZoom) {
    final normalized = ((globeZoom - 0.78) / (_exploreMaxZoom - 0.78))
        .clamp(0.0, 1.0)
        .toDouble();

    return _handoffMapZoomMin +
        ((_handoffMapZoomMax - _handoffMapZoomMin) * normalized);
  }

  int _markerZoomBucket(double zoom) {
    if (zoom < 0.25) return 0;
    if (zoom < 0.60) return 1;
    if (zoom < 0.90) return 2;
    return 3;
  }

  double _markerClusterDegreesForZoom(double zoom) {
    switch (_markerZoomBucket(zoom)) {
      case 0:
        return 7.0;
      case 1:
        return 4.0;
      case 2:
        return 2.0;
      default:
        return 0.75;
    }
  }

  int _markerLimitForZoom(double zoom) {
    final t =
        ((zoom + 0.22) / (_exploreMaxZoom + 0.22)).clamp(0.0, 1.0).toDouble();
    return (_exploreMarkerLimitFar +
            ((_exploreMarkerLimitNear - _exploreMarkerLimitFar) * t))
        .round();
  }

  String _markerInputSignature(
    List<CivicMapItem> items,
    bool settled, {
    int? zoomBucket,
    int? markerLimit,
  }) {
    final buffer = StringBuffer()
      ..write(settled ? '1' : '0')
      ..write('|')
      ..write(zoomBucket ?? -1)
      ..write('|')
      ..write(markerLimit ?? -1)
      ..write('|');

    for (final item in items) {
      buffer
        ..write(item.type.name)
        ..write(':')
        ..write(item.id)
        ..write('@')
        ..write(item.latitude.toStringAsFixed(5))
        ..write(',')
        ..write(item.longitude.toStringAsFixed(5))
        ..write(';');
    }

    return buffer.toString();
  }

  String _textureAssetForStyle(GlobeVisualStyle style) {
    return GlobePresetVisual.forStyle(style).asset;
  }

  void _applyNativeVisualStyle(
    GlobeVisualStyle style, {
    bool reloadTexture = true,
  }) {
    final preset = GlobePresetVisual.forStyle(style);
    if (reloadTexture && _nativeTextureAsset != preset.asset) {
      _nativeTextureAsset = preset.asset;
      _globeController.loadSurface(AssetImage(preset.asset));
    }
    _globeController
      ..surfaceLightingEnabled = !preset.unlit
      ..lightAngle = preset.lightAngle
      ..lightIntensity = preset.lightIntensity
      ..ambientLight = preset.ambientLight
      ..showAtmosphere = true
      ..atmosphereColor = Color(0xFF000000 | preset.atmosphereRgb)
      ..atmosphereBlur = preset.atmosphereBlur
      ..atmosphereThickness = preset.atmosphereThickness
      ..atmosphereOpacity = preset.atmosphereOpacity;
  }

  void _syncGlobeContentPoints() {
    if (widget.items.isEmpty && !widget.markerDataSettled) {
      // Loading/refresh is transient: retain the previous stable points.
      return;
    }

    final zoom = _globeController.zoom;
    final markerLimit = _isHomeProfile
        ? _markerPolicy.homeMarkerLimitForDensity(
            widget.homeMarkerDensityOverride,
          )
        : _markerLimitForZoom(zoom);
    final markerSignature = _markerInputSignature(
      widget.items,
      widget.markerDataSettled,
      zoomBucket: _markerZoomBucket(zoom),
      markerLimit: markerLimit,
    );
    if (_lastNativeMarkerInputSignature == markerSignature) {
      return;
    }
    _lastNativeMarkerInputSignature = markerSignature;
    final clusterDegrees = _isHomeProfile
        ? _homeMarkerClusterDegrees
        : _markerClusterDegreesForZoom(zoom);
    final groups = _buildExploreMarkerGroups(
      widget.items,
      clusterDegrees: clusterDegrees,
      markerLimit: markerLimit,
    );

    final points = <Point>[];
    _globeMarkerItemsByPointId.clear();
    _globeMarkerGroupsByPointId.clear();

    for (final group in groups) {
      final item = group.representative;
      final markerSize = switch (item.markerSizeTier) {
        CivicMapMarkerSizeTier.small => _isHomeProfile ? 4.2 : 2.8,
        CivicMapMarkerSizeTier.medium => _isHomeProfile ? 5.4 : 3.8,
        CivicMapMarkerSizeTier.large => _isHomeProfile ? 6.6 : 4.9,
      };
      final markerVisualSize = switch (item.markerSizeTier) {
        CivicMapMarkerSizeTier.small => _isHomeProfile ? 24.0 : 22.0,
        CivicMapMarkerSizeTier.medium => _isHomeProfile ? 29.0 : 26.0,
        CivicMapMarkerSizeTier.large => _isHomeProfile ? 34.0 : 30.0,
      };

      final pointId = 'social-vote:${item.type.name}:${item.id}';
      _globeMarkerItemsByPointId[pointId] = item;
      _globeMarkerGroupsByPointId[pointId] = group.items;

      points.add(
        Point(
          id: pointId,
          coordinates: GlobeCoordinates(group.latitude, group.longitude),
          label: null,
          labelBuilder: (_, __, ___, isVisible) {
            if (!isVisible) return null;
            return GlobeContentMarker(
              kind: _contentKindForMapType(item.type),
              size: markerVisualSize,
              clusterCount: 1,
            );
          },
          isLabelVisible: true,
          // Keep the geographic anchor exact. If Vote/Voce/News share the
          // same area, fan their visual labels in screen space instead of
          // falsifying latitude/longitude by a tiny offset that is invisible
          // at World zoom.
          labelOffset: Offset(
            group.visualOffset.dx,
            (-markerVisualSize / 2) + group.visualOffset.dy,
          ),
          // labelOffset is subtracted by the globe renderer. Mirror that
          // screen-space fan-out in the point hit target so Android/native
          // taps select the marker the user actually sees.
          hitTestOffset: Offset(
            -group.visualOffset.dx,
            -group.visualOffset.dy,
          ),
          labelTextStyle: TextStyle(
            color: const Color(0xFFF7FAFF),
            fontSize: _isHomeProfile ? 10.5 : 9,
            fontWeight: FontWeight.w800,
            shadows: const <Shadow>[
              Shadow(blurRadius: 4, color: Color(0xCC000000)),
            ],
          ),
          style: PointStyle(
            size: markerSize,
            color: _markerColorForType(item.type),
            altitude: _isHomeProfile ? 0.024 : 0.018,
            transitionDuration: 180,
          ),
        ),
      );
    }

    _lastMarkerZoomBucket = _markerZoomBucket(zoom);
    _globeController.points = points;

    debugPrint(
      '[WorldGlobe] G5 markers synced: '
      'profile=${_isHomeProfile ? 'home' : 'explore'} '
      'source=${widget.items.length} rendered=${points.length} '
      'zoom=${zoom.toStringAsFixed(2)} '
      'cluster=${clusterDegrees.toStringAsFixed(2)}°',
    );
  }

  List<_WorldGlobeMarkerGroup> _buildExploreMarkerGroups(
    List<CivicMapItem> items, {
    required double clusterDegrees,
    required int markerLimit,
  }) {
    if (items.isEmpty) {
      return const <_WorldGlobeMarkerGroup>[];
    }

    final candidates = CivicMapMarkerSelectionRules.select(
      items: items.where(
        (item) => _isValidLatLng(item.latitude, item.longitude),
      ),
      totalLimit: markerLimit,
      newsLimit: _isHomeProfile ? 3 : 4,
    );

    final grouped = <String, List<CivicMapItem>>{};
    final typesByCell = <String, Set<CivicMapItemType>>{};

    for (final item in candidates) {
      final latCell = (item.latitude / clusterDegrees).floor();
      final lngCell = (item.longitude / clusterDegrees).floor();
      final baseKey = '$latCell|$lngCell';
      final key = '$baseKey|${item.type.name}';
      grouped.putIfAbsent(key, () => <CivicMapItem>[]).add(item);
      typesByCell
          .putIfAbsent(baseKey, () => <CivicMapItemType>{})
          .add(item.type);
    }

    final output = <_WorldGlobeMarkerGroup>[];

    for (final entry in grouped.entries) {
      final groupItems = entry.value;
      final representative = _preferredGlobeMarkerRepresentative(groupItems);

      final keyParts = entry.key.split('|');
      final baseKey = '${keyParts[0]}|${keyParts[1]}';
      final hasMixedTypes = (typesByCell[baseKey]?.length ?? 0) > 1;

      output.add(
        _WorldGlobeMarkerGroup(
          representative: representative,
          items: List<CivicMapItem>.unmodifiable(groupItems),
          // The representative's persisted anchor is authoritative. A
          // geographic average would invent a coordinate and can jump across
          // the antimeridian; overlap is handled only in screen space.
          latitude: representative.latitude,
          longitude: representative.longitude,
          visualOffset: hasMixedTypes
              ? _globeScreenOffsetForType(representative.type)
              : Offset.zero,
        ),
      );
    }

    output.sort(
      (a, b) => b.representative.mapImportanceScore.compareTo(
        a.representative.mapImportanceScore,
      ),
    );

    return output;
  }

  Offset _globeScreenOffsetForType(CivicMapItemType type) {
    final distance = _isHomeProfile ? 17.0 : 13.0;
    return switch (type) {
      CivicMapItemType.poll => Offset(-distance, distance * 0.45),
      CivicMapItemType.post => Offset(distance, distance * 0.45),
      CivicMapItemType.news => Offset(0, -distance * 0.75),
    };
  }

  CivicMapItem _preferredGlobeMarkerRepresentative(List<CivicMapItem> items) {
    final ordered = List<CivicMapItem>.from(items)
      ..sort((a, b) {
        final aNews = a.type == CivicMapItemType.news ? 1 : 0;
        final bNews = b.type == CivicMapItemType.news ? 1 : 0;
        if (aNews != bNews) {
          return aNews.compareTo(bNews);
        }
        return b.mapImportanceScore.compareTo(a.mapImportanceScore);
      });
    return ordered.first;
  }

  String _globeMarkerGroupTitle() {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'it') {
      return 'Contenuti in questo punto';
    }
    return deOrEnglish(
      context,
      english: 'Content at this location',
      german: 'Inhalte an diesem Ort',
    );
  }

  String _globeMarkerTypeLabel(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return 'Vote';
      case CivicMapItemType.post:
        return 'Voce';
      case CivicMapItemType.news:
        return 'News';
    }
  }

  Future<void> _showGlobeMarkerGroupPicker(List<CivicMapItem> items) async {
    if (!mounted || items.isEmpty) {
      return;
    }

    final ordered = List<CivicMapItem>.from(items)
      ..sort((a, b) {
        final aNews = a.type == CivicMapItemType.news ? 1 : 0;
        final bNews = b.type == CivicMapItemType.news ? 1 : 0;
        if (aNews != bNews) {
          return aNews.compareTo(bNews);
        }
        return b.mapImportanceScore.compareTo(a.mapImportanceScore);
      });

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    _globeMarkerGroupTitle(),
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: ordered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (itemContext, index) {
                      final item = ordered[index];
                      final subtitle = item.subtitle?.trim();

                      return ListTile(
                        leading: Icon(
                          SocialVoteSymbols.contentIcon(
                            _contentKindForMapType(item.type),
                          ),
                          color: SocialVoteSymbols.contentColor(
                            _contentKindForMapType(item.type),
                          ),
                        ),
                        title: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          subtitle == null || subtitle.isEmpty
                              ? _globeMarkerTypeLabel(item.type)
                              : '${_globeMarkerTypeLabel(item.type)} · $subtitle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          _handleGlobeMarkerTap(item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _markerColorForType(CivicMapItemType type) {
    return SocialVoteSymbols.contentColor(_contentKindForMapType(type));
  }

  void _handleGlobeMarkerTap(CivicMapItem item) {
    _countrySelectionDismissTimer?.cancel();
    _countrySelectionRequestId += 1;

    if (mounted &&
        (_isSelectingCountry ||
            _selectedCountryLabel != null ||
            _selectedCountryScope != null)) {
      setState(() {
        _isSelectingCountry = false;
        _selectedCountryLabel = null;
        _selectedCountryScope = null;
      });
    }

    debugPrint('[WorldGlobe] G5 marker tap: ${item.type.name} ${item.id}');

    if (_isHomeProfile) {
      unawaited(
        _showHomeGlobeMarkerPreview(
          context: context,
          item: item,
          onOpen: widget.onItemTap,
        ),
      );
      return;
    }

    if (_globeController.isReady) {
      _cancelNativeNaturalTiltRecovery();
      _globeController.stopRotation();

      final targetZoom = _countryFocusZoom
          .clamp(_globeController.minZoom, _globeController.maxZoom)
          .toDouble();
      _globeController.setZoom(targetZoom);
      _globeController.focusOnCoordinates(
        GlobeCoordinates(item.latitude, item.longitude),
        animate: true,
        duration: _countryFocusDuration,
        curve: Curves.easeInOutCubic,
      );

      // Marker focus is intentionally temporary. Let the marker remain
      // highlighted for a short beat, then restore the same natural tilt and
      // passive rotation used after a normal drag. A user gesture cancels this
      // timer through _cancelNativeNaturalTiltRecovery().
      _scheduleNativeNaturalTiltRecovery(
        delay: const Duration(milliseconds: 740),
        refreshMarkersBeforeRecovery: true,
      );
    }

    widget.onItemTap(item);
  }

  void _handleExplorePointerCancel(PointerCancelEvent event) {
    _cancelNativeStyleLongPress();
    _suppressTapAfterStyleLongPress = false;
    _exploreTapPointers.remove(event.pointer);
    if (event.pointer == _exploreTapCandidatePointer) {
      _resetExploreTapCandidate();
    }
    if (_exploreTapPointers.isEmpty) {
      _scheduleNativeNaturalTiltRecovery();
    }
  }

  void _resetExploreTapCandidate({bool keepPointers = false}) {
    if (!keepPointers) {
      _exploreTapPointers.clear();
    }
    _exploreTapCandidatePointer = null;
    _exploreTapDownPosition = null;
    _exploreTapMoved = false;
    _exploreTapStartedOnSphere = false;
  }

  Future<void> _handleExploreGlobeTap(GlobeCoordinates? coordinates) async {
    if (_isHomeProfile || coordinates == null || _isSelectingCountry) {
      return;
    }

    final requestId = ++_countrySelectionRequestId;
    _countrySelectionDismissTimer?.cancel();

    setState(() {
      _isSelectingCountry = true;
      _selectedCountryLabel = null;
      _selectedCountryScope = null;
    });

    try {
      final resolved = await AppDI.instance.resolveScopeFromPoint(
        GeoPoint(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
        ),
      );

      if (!mounted || requestId != _countrySelectionRequestId) {
        return;
      }

      final countryCode = resolved.scope.countryCode?.trim().toUpperCase();
      if (countryCode == null || countryCode.isEmpty) {
        return;
      }

      final countryScope = await _countryScopeForSelection(
        countryCode: countryCode,
        resolvedScope: resolved.scope,
        tappedCoordinates: coordinates,
      );

      if (!mounted || requestId != _countrySelectionRequestId) {
        return;
      }

      final languageCode = Localizations.localeOf(context).languageCode;
      final countryLabel = Countries.nameForCode(
        countryCode,
        languageCode: languageCode,
        fallback: resolved.displayName,
      );

      setState(() {
        _isSelectingCountry = false;
        _selectedCountryLabel = countryLabel;
        _selectedCountryScope = countryScope;
      });
      _scheduleCountrySelectionDismiss(requestId);

      final targetLatitude = countryScope.centerLat ?? coordinates.latitude;
      final targetLongitude = countryScope.centerLng ?? coordinates.longitude;
      final targetZoom = _countryFocusZoom
          .clamp(_globeController.minZoom, _globeController.maxZoom)
          .toDouble();

      _globeController.setZoom(targetZoom);
      _globeController.focusOnCoordinates(
        GlobeCoordinates(targetLatitude, targetLongitude),
        animate: true,
        duration: _countryFocusDuration,
        curve: Curves.easeInOutCubic,
      );
    } catch (error, stackTrace) {
      debugPrint('[WorldGlobe] country selection failed: $error\n$stackTrace');
    } finally {
      if (mounted && requestId == _countrySelectionRequestId) {
        setState(() {
          _isSelectingCountry = false;
        });
      }
    }
  }

  void _scheduleCountrySelectionDismiss(int requestId) {
    _countrySelectionDismissTimer?.cancel();
    _countrySelectionDismissTimer = Timer(_countrySelectionAutoDismiss, () {
      if (!mounted ||
          requestId != _countrySelectionRequestId ||
          _isSelectingCountry) {
        return;
      }

      if (_selectedCountryLabel == null && _selectedCountryScope == null) {
        return;
      }

      setState(() {
        _selectedCountryLabel = null;
        _selectedCountryScope = null;
      });
    });
  }

  void _openSelectedCountry() {
    final countryScope = _selectedCountryScope;
    if (_isHomeProfile || _isSelectingCountry || countryScope == null) {
      return;
    }

    _countrySelectionDismissTimer?.cancel();

    debugPrint(
      '[WorldGlobe] opening selected country: ${countryScope.countryCode}',
    );
    AppDI.instance.geoScopeController.setScope(countryScope);
  }

  Future<GeoScope> _countryScopeForSelection({
    required String countryCode,
    required GeoScope resolvedScope,
    required GlobeCoordinates tappedCoordinates,
  }) async {
    if (resolvedScope.level == GeoScopeLevel.country &&
        _isValidLatLng(resolvedScope.centerLat, resolvedScope.centerLng)) {
      return resolvedScope;
    }

    final countryRadius = resolvedScope.level == GeoScopeLevel.country
        ? resolvedScope.radiusKm
        : null;

    try {
      final geocoded =
          await AppDI.instance.geocodingRepository.geocodeContentLocation(
        ContentLocation(
          source: ContentLocationSource.geoScopeFallback,
          countryCode: countryCode,
        ),
      );

      final centerLat = geocoded?.centerLat ?? geocoded?.latitude;
      final centerLng = geocoded?.centerLng ?? geocoded?.longitude;

      if (_isValidLatLng(centerLat, centerLng)) {
        return GeoScope.country(
          countryCode,
          centerLat: centerLat,
          centerLng: centerLng,
          radiusKm: countryRadius,
        );
      }
    } catch (_) {
      // Best effort: the tapped point remains a valid country focus fallback.
    }

    return GeoScope.country(
      countryCode,
      centerLat: tappedCoordinates.latitude,
      centerLng: tappedCoordinates.longitude,
      radiusKm: countryRadius,
    );
  }

  bool _isValidLatLng(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return false;
    }

    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  void _handleHomePointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;

    if (_activePointers.length == 1) {
      _startNativeStyleLongPress(event);
      _primaryPointer = event.pointer;
      _primaryStartPosition = event.localPosition;
      _primaryStartedOnSphere = _isInsideVisibleSphere(event.localPosition);
      if (_primaryStartedOnSphere) {
        _cancelNativeNaturalTiltRecovery();
      }
      _homeGestureIntent = _primaryStartedOnSphere
          ? _HomeGestureIntent.undecided
          : _HomeGestureIntent.page;

      // Until intent is known, suppress globe pan. This prevents the first
      // vertical pixels of a Home scroll from tilting the Earth.
      _globeController.panSensitivity = 0.0;
      _setPageScrollLocked(false);
      return;
    }

    _cancelNativeStyleLongPress();

    // A second finger that lands on the Earth before a page-scroll decision
    // means pinch zoom. Lock the Home page until all fingers are released.
    if (_homeGestureIntent != _HomeGestureIntent.page &&
        _allActivePointersAreOnSphere()) {
      _homeGestureIntent = _HomeGestureIntent.globe;
      _globeController.panSensitivity = 0.0;
      _setPageScrollLocked(true);
    }
  }

  void _handleHomePointerMove(PointerMoveEvent event) {
    _trackNativeStyleLongPress(event);
    if (!_activePointers.containsKey(event.pointer)) {
      return;
    }

    _activePointers[event.pointer] = event.localPosition;

    if (_homeGestureIntent == _HomeGestureIntent.page) {
      return;
    }

    if (_activePointers.length >= 2) {
      if (_allActivePointersAreOnSphere()) {
        _homeGestureIntent = _HomeGestureIntent.globe;
        // Pinch zoom should not also rotate the Earth in Home.
        _globeController.panSensitivity = 0.0;
        _setPageScrollLocked(true);
      }
      return;
    }

    if (_homeGestureIntent == _HomeGestureIntent.globe) {
      return;
    }

    if (event.pointer != _primaryPointer || !_primaryStartedOnSphere) {
      return;
    }

    final start = _primaryStartPosition;
    if (start == null) {
      return;
    }

    final delta = event.localPosition - start;
    final dx = delta.dx.abs();
    final dy = delta.dy.abs();
    final distance = delta.distance;

    if (distance < _gestureIntentThreshold) {
      return;
    }

    if (dx >= dy * _axisDominance) {
      _claimHomeGestureForGlobe();
      return;
    }

    if (dy >= dx * _axisDominance) {
      _claimHomeGestureForPage();
      return;
    }

    // Very diagonal starts are allowed a little more travel before choosing.
    // After that point we must choose once and keep that owner until release.
    if (distance >= _gestureFallbackThreshold) {
      if (dx >= dy) {
        _claimHomeGestureForGlobe();
      } else {
        _claimHomeGestureForPage();
      }
    }
  }

  bool _tryHandleHomeMarkerTap(Offset globalPosition) {
    final globeContext = _globeController.globeKey.currentContext;
    final globeState = _globeController.globeKey.currentState;
    final renderObject = globeContext?.findRenderObject();

    if (globeState == null || renderObject is! RenderBox) {
      return false;
    }

    final localPosition = renderObject.globalToLocal(globalPosition);
    final pointId = globeState.pointIdAtLocalPosition(localPosition);
    if (pointId == null) {
      return false;
    }

    final item = _globeMarkerItemsByPointId[pointId];
    final group = _globeMarkerGroupsByPointId[pointId];
    if (item == null) {
      return false;
    }

    if (group != null && group.length > 1) {
      unawaited(_showGlobeMarkerGroupPicker(group));
    } else {
      _handleGlobeMarkerTap(item);
    }
    return true;
  }

  void _handleHomePointerUp(PointerUpEvent event) {
    _cancelNativeStyleLongPress();
    final start = _primaryStartPosition;
    final wasGlobeGesture = _homeGestureIntent == _HomeGestureIntent.globe;
    final wasSinglePointer = _activePointers.length == 1;
    final shouldHandleHomeTap = wasSinglePointer &&
        event.pointer == _primaryPointer &&
        _primaryStartedOnSphere &&
        !_suppressTapAfterStyleLongPress &&
        _homeGestureIntent == _HomeGestureIntent.undecided &&
        start != null &&
        (event.localPosition - start).distance < _gestureIntentThreshold;
    final tapGlobalPosition = event.position;

    _activePointers.remove(event.pointer);

    if (_activePointers.isEmpty) {
      _resetHomeGestureState();

      if (wasGlobeGesture) {
        _scheduleNativeNaturalTiltRecovery();
      }

      if (shouldHandleHomeTap) {
        // Marker hit-testing has priority on Home too. Tapping a content marker
        // opens its preview; tapping the Earth outside a marker opens Civic Map.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final markerHandled = _tryHandleHomeMarkerTap(tapGlobalPosition);
          if (!markerHandled) {
            widget.onUseClassicMap();
          }
        });
      }

      _suppressTapAfterStyleLongPress = false;
      return;
    }

    // If a pinch ends with one finger still down, keep the gesture assigned to
    // the globe until the final finger is released. This prevents the page from
    // suddenly taking over halfway through the same physical interaction.
    if (_homeGestureIntent == _HomeGestureIntent.globe) {
      _globeController.panSensitivity = _approvedPanSensitivity;
      _setPageScrollLocked(true);
    }
  }

  void _handleHomePointerCancel(PointerCancelEvent event) {
    _cancelNativeStyleLongPress();
    _suppressTapAfterStyleLongPress = false;
    final wasGlobeGesture = _homeGestureIntent == _HomeGestureIntent.globe;
    _activePointers.remove(event.pointer);

    if (_activePointers.isEmpty) {
      _resetHomeGestureState();
      if (wasGlobeGesture) {
        _scheduleNativeNaturalTiltRecovery();
      }
    }
  }

  void _claimHomeGestureForGlobe() {
    if (_homeGestureIntent == _HomeGestureIntent.globe) {
      return;
    }

    _homeGestureIntent = _HomeGestureIntent.globe;
    _globeController.panSensitivity = _approvedPanSensitivity;
    _setPageScrollLocked(true);
  }

  void _claimHomeGestureForPage() {
    if (_homeGestureIntent == _HomeGestureIntent.page) {
      return;
    }

    _homeGestureIntent = _HomeGestureIntent.page;
    _globeController.panSensitivity = 0.0;
    _setPageScrollLocked(false);
  }

  void _resetHomeGestureState() {
    _activePointers.clear();
    _primaryPointer = null;
    _primaryStartPosition = null;
    _primaryStartedOnSphere = false;
    _homeGestureIntent = _HomeGestureIntent.idle;
    _globeController.panSensitivity = _approvedPanSensitivity;
    _setPageScrollLocked(false);
  }

  void _setPageScrollLocked(bool locked) {
    if (_pageScrollLocked == locked) {
      return;
    }

    _pageScrollLocked = locked;
    widget.onPageScrollLockChanged?.call(locked);
  }

  bool _allActivePointersAreOnSphere() {
    if (_activePointers.isEmpty) {
      return false;
    }

    return _activePointers.values.every(_isInsideVisibleSphere);
  }

  bool _isInsideVisibleSphere(Offset position) {
    if (_viewportSize <= 0 || _baseRadius <= 0) {
      return false;
    }

    final center = Offset(_viewportSize / 2, _viewportSize / 2);
    final zoomScale = math.pow(2.0, _globeController.zoom).toDouble();
    final visibleRadius = math.min(
      _viewportSize / 2,
      (_baseRadius * zoomScale) + _sphereHitSlop,
    );

    return (position - center).distance <= visibleRadius;
  }
}

class _GlobeRotationButton extends StatelessWidget {
  final bool isRotating;
  final GlobeVisualStyle globeStyle;
  final GlobeRotationVisualStyle visualStyle;
  final VoidCallback onPressed;

  const _GlobeRotationButton({
    required this.isRotating,
    required this.globeStyle,
    required this.visualStyle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final label = isRotating
        ? switch (languageCode) {
            'it' => 'Ferma rotazione',
            'de' => 'Drehung stoppen',
            'fa' => 'توقف چرخش',
            'es' => 'Detener rotación',
            'pt' => 'Parar rotação',
            'fr' => 'Arrêter la rotation',
            'ar' => 'إيقاف الدوران',
            'ro' => 'Oprește rotația',
            _ => 'Stop rotation',
          }
        : switch (languageCode) {
            'it' => 'Avvia rotazione',
            'de' => 'Drehung starten',
            'fa' => 'شروع چرخش',
            'es' => 'Iniciar rotación',
            'pt' => 'Iniciar rotação',
            'fr' => 'Démarrer la rotation',
            'ar' => 'بدء الدوران',
            'ro' => 'Pornește rotația',
            _ => 'Start rotation',
          };

    return WorldRoundControl(
      icon: Icons.rotate_right_rounded,
      label: label,
      active: isRotating,
      globeStyle: globeStyle,
      visualStyle: visualStyle,
      onTap: onPressed,
    );
  }
}

class _WorldGlobeMarkerGroup {
  final CivicMapItem representative;
  final List<CivicMapItem> items;
  final double latitude;
  final double longitude;
  final Offset visualOffset;

  const _WorldGlobeMarkerGroup({
    required this.representative,
    required this.items,
    required this.latitude,
    required this.longitude,
    required this.visualOffset,
  });
}

class _WasmRequiredFallback extends StatelessWidget {
  final VoidCallback onUseClassicMap;

  const _WasmRequiredFallback({required this.onUseClassicMap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.public, size: 44, color: theme.colorScheme.primary),
              const SizedBox(height: 14),
              Text(
                Localizations.localeOf(context).languageCode == 'it'
                    ? 'Il Globe 3D richiede la build WebAssembly sul Web'
                    : deOrEnglish(
                        context,
                        english: '3D Globe requires the WebAssembly web build',
                        german:
                            'Der 3D-Globus benötigt im Web den WebAssembly-Build.',
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Localizations.localeOf(context).languageCode == 'it'
                    ? 'La Civic Map 2D resta disponibile e invariata.'
                    : deOrEnglish(
                        context,
                        english:
                            'The classic Civic Map is still available and unchanged.',
                        german:
                            'Die klassische Civic Map bleibt unverändert verfügbar.',
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onUseClassicMap,
                icon: const Icon(Icons.map_outlined),
                label: Text(
                  Localizations.localeOf(context).languageCode == 'it'
                      ? 'Usa mappa 2D'
                      : deOrEnglish(
                          context,
                          english: 'Use 2D map',
                          german: '2D-Karte verwenden',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

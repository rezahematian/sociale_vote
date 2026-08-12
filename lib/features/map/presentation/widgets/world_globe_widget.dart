import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';

import 'package:sociale_vote/features/map/application/civic_map_controller.dart';

/// World-only 3D renderer for Civic Map.
///
/// Current G1 Android baseline:
/// - Earth sphere
/// - Earth asset texture
/// - transparent surrounding area
/// - centered inside a compact square viewport
/// - no markers
/// - no atmosphere
/// - no day/night cycle
/// - no surface lighting
/// - no entrance/focus animations
///
/// Civic Map 2D remains untouched.
class WorldGlobeWidget extends StatefulWidget {
  final List<CivicMapItem> items;
  final ValueChanged<CivicMapItem> onItemTap;
  final VoidCallback onUseClassicMap;

  const WorldGlobeWidget({
    super.key,
    required this.items,
    required this.onItemTap,
    required this.onUseClassicMap,
  });

  @override
  State<WorldGlobeWidget> createState() => _WorldGlobeWidgetState();
}

class _WorldGlobeWidgetState extends State<WorldGlobeWidget> {
  static const bool _isWasmBuild = bool.fromEnvironment('dart.tool.dart2wasm');

  static const String _earthTextureAsset =
      'assets/globe/earth_day_nasa_blue_marble_2048.png';

  late final FlutterEarthGlobeController _globeController;

  bool get _canRenderGlobe => !kIsWeb || _isWasmBuild;

  @override
  void initState() {
    super.initState();

    _globeController = FlutterEarthGlobeController(
      surface: Image.asset(_earthTextureAsset).image,
      isRotating: false,
      zoom: 0.0,
      minZoom: -0.65,
      maxZoom: 2.0,
      isZoomEnabled: true,
      zoomSensitivity: 0.45,
      panSensitivity: 0.55,
      zoomToMousePosition: false,
      showAtmosphere: false,
      isDayNightCycleEnabled: false,
      useRealTimeSunPosition: false,
      surfaceLightingEnabled: false,
    );

    _globeController.onLoaded = () {
      debugPrint('[WorldGlobe] controller loaded');
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_canRenderGlobe) {
      return _WasmRequiredFallback(
        onUseClassicMap: widget.onUseClassicMap,
      );
    }

    final screenSize = MediaQuery.sizeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : availableWidth;

        final viewportSize = math
            .min(
              availableWidth,
              availableHeight,
            )
            .clamp(1.0, 520.0)
            .toDouble();

        // Large globe, while keeping a small margin around the sphere.
        final radius = viewportSize * 0.46;

        /*
         * flutter_earth_globe internally lays out its rendering canvas
         * using MediaQuery screen dimensions instead of this widget's
         * compact viewport.
         *
         * Compensate its internal alignment so that the physical centre
         * of the sphere matches the centre of our square viewport.
         */
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

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox.square(
            dimension: viewportSize,
            child: ClipRect(
              child: FlutterEarthGlobe(
                controller: _globeController,
                radius: radius,
                alignment: Alignment(
                  alignmentX,
                  alignmentY,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WasmRequiredFallback extends StatelessWidget {
  final VoidCallback onUseClassicMap;

  const _WasmRequiredFallback({
    required this.onUseClassicMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.public,
                size: 44,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                '3D Globe requires the WebAssembly web build',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The classic Civic Map is still available and unchanged.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onUseClassicMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Use 2D map'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

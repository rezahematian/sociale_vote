import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:sociale_vote/features/map/application/civic_map_controller.dart';

class WebGlobeFocus {
  final double latitude;
  final double longitude;
  final double distance;

  const WebGlobeFocus({
    required this.latitude,
    required this.longitude,
    required this.distance,
  });
}

class WebWorldGlobeSurface extends StatelessWidget {
  final List<CivicMapItem> items;
  final bool homeProfile;
  final bool isAuthenticated;
  final bool autoRotateEnabled;
  final ValueChanged<CivicMapItem> onMarkerTap;
  final void Function(double latitude, double longitude) onSurfaceTap;
  final ValueChanged<Offset>? onOrientationChanged;
  final void Function(double latitude, double longitude)? onDeepZoom;
  final ValueListenable<WebGlobeFocus?>? focusListenable;
  final double? initialFocusLatitude;
  final double? initialFocusLongitude;
  final double? initialFocusZoom;
  final VoidCallback onUnavailable;

  const WebWorldGlobeSurface({
    super.key,
    required this.items,
    required this.homeProfile,
    required this.isAuthenticated,
    required this.autoRotateEnabled,
    required this.onMarkerTap,
    required this.onSurfaceTap,
    required this.onUnavailable,
    this.onOrientationChanged,
    this.onDeepZoom,
    this.focusListenable,
    this.initialFocusLatitude,
    this.initialFocusLongitude,
    this.initialFocusZoom,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// CivicMapWidget
///
/// Widget di mappa civica
///
/// - Home: preview mappa (height definita)
/// - Fullscreen: mappa reale interattiva
///
/// RESPONSABILITÀ:
/// - Rendering mappa
/// - Marker e interazioni
/// - Emissione eventi (onLocationSelected, onRequestFullscreen)
///
/// NON FA:
/// - Routing diretto
/// - Gestione sessione
/// - Gestione fullscreen
class CivicMapWidget extends StatefulWidget {
  final double? height;
  final void Function(String locationId)? onLocationSelected;

  /// 🔑 Callback per richiesta fullscreen
  final VoidCallback? onRequestFullscreen;

  /// 🔑 Location iniziale (fullscreen)
  final String? initialLocationId;

  /// Flag architetturale (NON usato ora)
  final bool useMapbox;

  const CivicMapWidget({
    super.key,
    this.height = 220,
    this.onLocationSelected,
    this.onRequestFullscreen,
    this.initialLocationId,
    this.useMapbox = false,
  });

  @override
  State<CivicMapWidget> createState() => _CivicMapWidgetState();
}

class _CivicMapWidgetState extends State<CivicMapWidget> {
  late final MapController _mapController;

  /// 🔑 Stato locale marker selezionato
  String? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocationId = widget.initialLocationId;

    if (widget.initialLocationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _locationConfig(widget.initialLocationId!);
        if (target != null) {
          _mapController.move(target.$1, target.$2);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final map =
        widget.useMapbox ? _buildPlaceholderMap() : _buildRealMap(context);

    final content = Stack(
      children: [
        Positioned.fill(child: map),

        // =========================
        // FULLSCREEN BUTTON (HOME ONLY)
        // =========================
        if (widget.height != null && widget.onRequestFullscreen != null)
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onRequestFullscreen,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.height == null) {
      return SizedBox.expand(child: content);
    }

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: content,
    );
  }

  // ============================================================
  // MAPPA REALE – OPENSTREETMAP
  // ============================================================
  Widget _buildRealMap(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(25, 10),
        initialZoom: 2.2,
        minZoom: 1.2,
        maxZoom: 18,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.sociale_vote',
        ),
        MarkerLayer(
          markers: [
            _realMarker(
              context,
              const LatLng(41.9028, 12.4964),
              'Roma',
              'rome',
              zoom: 6,
            ),
            _realMarker(
              context,
              const LatLng(40.7128, -74.0060),
              'New York',
              'new_york',
              zoom: 5,
            ),
            _realMarker(
              context,
              const LatLng(35.6762, 139.6503),
              'Tokyo',
              'tokyo',
              zoom: 5,
            ),
          ],
        ),
      ],
    );
  }

  Marker _realMarker(
    BuildContext context,
    LatLng point,
    String label,
    String id, {
    required double zoom,
  }) {
    final bool isSelected = _selectedLocationId == id;

    return Marker(
      width: isSelected ? 140 : 120,
      height: isSelected ? 72 : 60,
      point: point,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedLocationId = id;
          });

          _mapController.move(point, zoom);

          // 🔑 UNICO EVENTO EMESSO
          widget.onLocationSelected?.call(id);
        },
        child: Column(
          children: [
            Icon(
              Icons.location_on,
              color: isSelected ? Colors.blueAccent : Colors.redAccent,
              size: isSelected ? 38 : 32,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION CONFIG
  // ============================================================
  (LatLng, double)? _locationConfig(String id) {
    switch (id) {
      case 'rome':
        return (const LatLng(41.9028, 12.4964), 6);
      case 'new_york':
        return (const LatLng(40.7128, -74.0060), 5);
      case 'tokyo':
        return (const LatLng(35.6762, 139.6503), 5);
      default:
        return null;
    }
  }

  // ============================================================
  // PLACEHOLDER MAP
  // ============================================================
  Widget _buildPlaceholderMap() {
    return Stack(
      children: [
        _buildWorldBackground(),
        _buildWorldGrid(),
        _buildWorldContinents(),
        _buildMarkersLayer(),
        _buildOverlayInfo(),
      ],
    );
  }

  Widget _buildWorldBackground() {
    return const Positioned.fill(
      child: Opacity(
        opacity: 0.10,
        child: Icon(
          Icons.public,
          size: 280,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWorldGrid() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _WorldGridPainter(),
      ),
    );
  }

  Widget _buildWorldContinents() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _WorldContinentsPainter(),
      ),
    );
  }

  Widget _buildMarkersLayer() {
    return Positioned.fill(
      child: Stack(
        children: [
          _MapMarker(
            top: 70,
            left: 80,
            label: 'Roma',
            locationId: 'rome',
            onTap: widget.onLocationSelected,
          ),
          _MapMarker(
            top: 90,
            right: 70,
            label: 'New York',
            locationId: 'new_york',
            onTap: widget.onLocationSelected,
          ),
          _MapMarker(
            bottom: 45,
            left: 140,
            label: 'Tokyo',
            locationId: 'tokyo',
            onTap: widget.onLocationSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayInfo() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Tocca una città per esplorare votazioni e notizie',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SUPPORT CLASSES
// ============================================================
class _MapMarker extends StatelessWidget {
  final double? top, left, right, bottom;
  final String label;
  final String locationId;
  final void Function(String locationId)? onTap;

  const _MapMarker({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.label,
    required this.locationId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: GestureDetector(
        onTap: onTap == null ? null : () => onTap!(locationId),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.redAccent,
              size: 30,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(ui.Offset(x, 0), ui.Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(ui.Offset(0, y), ui.Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WorldContinentsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.fill;

    final path = ui.Path();

    path.addOval(ui.Rect.fromLTWH(
      size.width * 0.10,
      size.height * 0.25,
      size.width * 0.18,
      size.height * 0.35,
    ));

    path.addOval(ui.Rect.fromLTWH(
      size.width * 0.38,
      size.height * 0.28,
      size.width * 0.20,
      size.height * 0.40,
    ));

    path.addOval(ui.Rect.fromLTWH(
      size.width * 0.60,
      size.height * 0.22,
      size.width * 0.25,
      size.height * 0.38,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

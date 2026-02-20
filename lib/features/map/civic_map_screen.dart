import 'package:flutter/material.dart';

import '../../navigation/city_navigation_gate.dart';
import 'civic_map_widget.dart';

/// CivicMapScreen
///
/// Schermata FULLSCREEN dedicata alla mappa civica.
///
/// RUOLO (DEFINITIVO):
/// - Esplorazione geografica
/// - Selezione città / area
///
/// ARCHITETTURA:
/// - Usa CivicMapWidget come motore grafico
/// - Gestisce SOLO lo stato di selezione
/// - NON contiene logica di dominio
/// - NON gestisce autenticazione
/// - NON decide navigazione finale
///
/// 🔒 File CHIUSO: non va riaperto
class CivicMapScreen extends StatefulWidget {
  /// 🔑 Location iniziale (opzionale)
  final String? initialLocationId;

  const CivicMapScreen({
    super.key,
    this.initialLocationId,
  });

  @override
  State<CivicMapScreen> createState() => _CivicMapScreenState();
}

class _CivicMapScreenState extends State<CivicMapScreen> {
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocationId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mappa Civica'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // =========================
          // FULLSCREEN MAP
          // =========================
          Positioned.fill(
            child: CivicMapWidget(
              height: null,
              initialLocationId: widget.initialLocationId,
              onLocationSelected: (locationId) {
                setState(() {
                  _selectedLocation = locationId;
                });
              },
            ),
          ),

          // =========================
          // INFO PANEL (BOTTOM OVERLAY)
          // =========================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: _selectedLocation == null,
              child: _buildInfoPanel(),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // INFO PANEL
  // =========================
  Widget _buildInfoPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: _selectedLocation == null
          ? _buildEmptyState()
          : _buildLocationDetails(),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        '🌍 Seleziona una città sulla mappa\n'
        'per vedere votazioni e notizie locali',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================
  // LOCATION DETAILS
  // =========================
  Widget _buildLocationDetails() {
    final locationId = _selectedLocation!;
    final cityName = _mapLocationToLabel(locationId);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📍 $cityName',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text('• 4 votazioni attive'),
        const Text('• 6 notizie locali'),
        const Text('• 2 discussioni popolari'),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _openCitySection(context, locationId),
            child: const Text('Vai alla sezione città'),
          ),
        ),
      ],
    );
  }

  // =========================
  // CITY ACTION (UNICO EXIT)
  // =========================
  void _openCitySection(BuildContext context, String locationId) {
    CityNavigationGate.openCity(
      context,
      locationId: locationId,
    );
  }

  // =========================
  // LOCATION LABELS
  // =========================
  String _mapLocationToLabel(String locationId) {
    switch (locationId) {
      case 'rome':
        return 'Roma';
      case 'new_york':
        return 'New York';
      case 'tokyo':
        return 'Tokyo';
      default:
        return locationId;
    }
  }
}

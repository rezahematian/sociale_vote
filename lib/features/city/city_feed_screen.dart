import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../poll/poll_feed_controller.dart';
import '../poll/poll_card.dart';
import '../poll/poll_navigation_gate.dart';
import '../../navigation/city_navigation_gate.dart';

/// CityFeedScreen
///
/// ⚠️ NOTA ARCHITETTURALE:
/// Questo schermo rappresenta un **Civic Hub contestuale**.
///
/// Ruolo definitivo:
/// - HUB civico per un contesto geografico
/// - NON carica direttamente News / Discussioni
/// - DELEGA la navigazione a CityNavigationGate
///
/// Supporta:
/// - città
/// - paese
/// - continente
/// - mondo
class CityFeedScreen extends StatefulWidget {
  /// 🔑 ID del contesto civico
  /// Esempi:
  /// - city: rome
  /// - country: italy
  /// - continent: europe
  /// - global: world
  final String locationId;

  const CityFeedScreen({
    super.key,
    required this.locationId,
  });

  @override
  State<CityFeedScreen> createState() => _CityFeedScreenState();
}

class _CityFeedScreenState extends State<CityFeedScreen> {
  late final PollFeedScope _pollScope;

  @override
  void initState() {
    super.initState();

    _pollScope = _mapLocationToPollScope(widget.locationId);

    // Caricamento feed UNA SOLA VOLTA
    Future.microtask(() {
      final controller = context.read<PollFeedController>();

      controller.loadFeed(
        scope: _pollScope,
        locationId:
            _pollScope == PollFeedScope.city ? widget.locationId : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scopeLabel = _mapLocationToLabel(widget.locationId);
    final controller = context.watch<PollFeedController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(scopeLabel),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(scopeLabel),
          const SizedBox(height: 32),

          // =========================
          // VOTAZIONI
          // =========================
          _buildPollSection(controller),

          const SizedBox(height: 32),

          // =========================
          // NOTIZIE
          // =========================
          _buildNewsSection(context),

          const SizedBox(height: 32),

          // =========================
          // DISCUSSIONI (placeholder)
          // =========================
          _buildStaticSection(
            title: '💬 Discussioni',
            subtitle: 'Temi civici aperti',
            items: const [
              'Mobilità sostenibile',
              'Spazi pubblici e quartieri',
            ],
            context: context,
          ),
        ],
      ),
    );
  }

  // =========================
  // POLL SECTION
  // =========================
  Widget _buildPollSection(PollFeedController controller) {
    if (controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Errore nel caricamento delle votazioni',
          style: TextStyle(color: Colors.red.shade600),
        ),
      );
    }

    if (controller.polls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Nessuna votazione attiva per questo contesto.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🗳️ Votazioni attive',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Decisioni civiche aperte alla partecipazione',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        ...controller.polls.map(
          (poll) => PollCard(
            poll: poll,
            onTap: () {
              PollNavigationGate.openPoll(
                context,
                pollId: poll.id,
                scope: _mapPollScopeToNavigationScope(_pollScope),
                locationId:
                    _pollScope == PollFeedScope.city ? widget.locationId : null,
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================
  // NEWS SECTION (NAVIGATION)
  // =========================
  Widget _buildNewsSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CityNavigationGate.openCity(
          context,
          locationId: widget.locationId,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '📰 Notizie',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                'Vedi tutte →',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Aggiornamenti rilevanti per questo contesto civico',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          _buildPlaceholderCard(
            'Le notizie di ${_mapLocationToLabel(widget.locationId)}',
            context,
          ),
        ],
      ),
    );
  }

  // =========================
  // STATIC SECTION
  // =========================
  Widget _buildStaticSection({
    required String title,
    required String subtitle,
    required List<String> items,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildPlaceholderCard(item, context)),
      ],
    );
  }

  Widget _buildPlaceholderCard(String title, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aprirà il dettaglio di: "$title"'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader(String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, size: 36),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // LOCATION → SCOPE / LABEL
  // =========================
  PollFeedScope _mapLocationToPollScope(String locationId) {
    if (locationId == 'world') {
      return PollFeedScope.global;
    }

    // per ora tutto ciò che non è world lo trattiamo come city
    return PollFeedScope.city;
  }

  PollScope _mapPollScopeToNavigationScope(PollFeedScope scope) {
    switch (scope) {
      case PollFeedScope.global:
        return PollScope.global;
      case PollFeedScope.country:
        return PollScope.country;
      case PollFeedScope.city:
        return PollScope.city;
    }
  }

  String _mapLocationToLabel(String locationId) {
    switch (locationId) {
      case 'rome':
        return 'Roma';
      case 'new_york':
        return 'New York';
      case 'tokyo':
        return 'Tokyo';
      case 'italy':
        return 'Italia';
      case 'europe':
        return 'Europa';
      case 'world':
        return 'Mondo';
      default:
        return locationId;
    }
  }
}

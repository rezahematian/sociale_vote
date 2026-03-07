import 'package:flutter/foundation.dart';

import 'package:sociale_vote/features/poll/domain/entities/poll_entity.dart';
import 'poll_service.dart';

/// Ambito del feed dei poll
enum PollFeedScope {
  global,
  country,
  city,
}

class PollFeedController extends ChangeNotifier {
  // =========================
  // DEPENDENCIES
  // =========================
  final PollService pollService;

  PollFeedController(this.pollService);

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<PollEntity> _polls = [];
  List<PollEntity> get polls => List.unmodifiable(_polls);

  PollFeedScope _scope = PollFeedScope.global;
  PollFeedScope get scope => _scope;

  String? _locationId;
  String? get locationId => _locationId;

  // =========================
  // LOAD FEED
  // =========================

  /// Carica il feed dei poll in base allo scope.
  ///
  /// - global  → tutti i poll
  /// - country → (placeholder futuro)
  /// - city    → filtra per locationId (obbligatorio)
  Future<void> loadFeed({
    required PollFeedScope scope,
    String? locationId,
  }) async {
    // =========================
    // GUARDIA DI COERENZA
    // =========================
    if (scope == PollFeedScope.city && locationId == null) {
      throw ArgumentError(
        'PollFeedScope.city richiede un locationId',
      );
    }

    _isLoading = true;
    _error = null;
    _scope = scope;
    _locationId = locationId;
    notifyListeners();

    try {
      final allPolls = await pollService.getActivePolls();

      List<PollEntity> filtered;

      switch (scope) {
        case PollFeedScope.global:
          filtered = allPolls;
          break;

        case PollFeedScope.country:
          // ⚠️ Placeholder: pronto per futura logica country
          filtered = allPolls;
          break;

        case PollFeedScope.city:
          filtered = allPolls
              .where((poll) => poll.locationId == locationId)
              .toList();
          break;
      }

      // =========================
      // ORDINAMENTO STABILE
      // =========================
      filtered.sort((a, b) {
        // Se esiste createdAt usalo, altrimenti fallback su id
        final aTime = a.createdAt;
        final bTime = b.createdAt;

        if (aTime != null && bTime != null) {
          return bTime.compareTo(aTime); // più recenti prima
        }

        return b.id.compareTo(a.id);
      });

      _polls = filtered;
    } catch (e) {
      _polls = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // REFRESH
  // =========================

  Future<void> refresh() async {
    await loadFeed(
      scope: _scope,
      locationId: _locationId,
    );
  }

  // =========================
  // RESET
  // =========================

  void reset() {
    _polls = [];
    _error = null;
    _isLoading = false;
    _scope = PollFeedScope.global;
    _locationId = null;
    notifyListeners();
  }
}
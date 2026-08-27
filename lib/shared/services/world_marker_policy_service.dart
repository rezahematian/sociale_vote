import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';

/// Backend-authoritative visual marker budget for the public Home Globe.
///
/// Density is a presentation policy only. It never changes content coordinates,
/// GeoScope, ranking scores, visibility/RLS, or the Civic Map filter/viewport.
class WorldMarkerPolicyService extends ChangeNotifier {
  WorldMarkerPolicyService._({SupabaseClient? client})
      : _client = client ?? AppSupabase.client;

  static final WorldMarkerPolicyService instance = WorldMarkerPolicyService._();

  static const String _table = 'social_vote_world_surface_settings';
  static const String _rowId = 'global';
  static const String _adminSetRpc = 'admin_set_world_marker_density';

  /// Preserves the pre-feature Home Globe baseline: 30% of 30 = 9 markers.
  static const int defaultDensity = 30;

  /// Hard safety ceiling for the Home Globe. 100 means this maximum visual
  /// saturation, not an unbounded number of content records.
  static const int maxHomeMarkerBudget = 30;

  final SupabaseClient _client;

  int _markerDensity = defaultDensity;
  bool _loaded = false;
  bool _loading = false;
  bool _saving = false;
  String? _lastError;
  Future<void>? _loadFuture;

  int get markerDensity => _markerDensity;
  bool get isLoaded => _loaded;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get lastError => _lastError;

  static int homeMarkerLimitFor(int density) {
    final value = density.clamp(0, 100).toInt();
    if (value == 0) return 0;
    return ((maxHomeMarkerBudget * value) / 100).ceil().clamp(
          1,
          maxHomeMarkerBudget,
        );
  }

  int homeMarkerLimitForDensity([int? density]) {
    return homeMarkerLimitFor(density ?? _markerDensity);
  }

  Future<void> ensureLoaded({bool forceRefresh = false}) {
    if (_loaded && !forceRefresh) return Future<void>.value();
    if (_loadFuture != null) return _loadFuture!;
    return _loadFuture = _load();
  }

  Future<void> _load() async {
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      final row = await _client
          .from(_table)
          .select('marker_density')
          .eq('id', _rowId)
          .maybeSingle();

      if (row == null) {
        throw const FormatException('World marker settings row is missing.');
      }

      final raw = row['marker_density'];
      final parsed = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
      if (parsed == null || parsed < 0 || parsed > 100) {
        throw const FormatException('World marker density is invalid.');
      }

      _markerDensity = parsed;
      _loaded = true;
    } catch (error) {
      // Fail-soft: the Globe remains usable with the approved baseline while
      // the admin/backend setting is unavailable. Never infer marker data.
      _lastError = error.toString();
      if (!_loaded) {
        _markerDensity = defaultDensity;
      }
    } finally {
      _loading = false;
      _loadFuture = null;
      notifyListeners();
    }
  }

  Future<void> setMarkerDensityFromAdmin(int value) async {
    final normalized = value.clamp(0, 100).toInt();
    if (_saving) return;

    _saving = true;
    _lastError = null;
    notifyListeners();

    try {
      await _client.rpc(
        _adminSetRpc,
        params: <String, Object?>{
          'p_density': normalized,
          'p_reason': 'Admin Center World marker density control',
        },
      );

      _markerDensity = normalized;
      _loaded = true;
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}

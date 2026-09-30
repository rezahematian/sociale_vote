import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';

/// Backend-authoritative global controls for the optional Globe cloud layer.
///
/// Safe fallback is OFF: if the setting cannot be read, the existing approved
/// Earth texture remains in use. Client writes are not allowed; Admin changes
/// go through audited RPCs only.
class GlobeCloudsService extends ChangeNotifier {
  GlobeCloudsService._({SupabaseClient? client})
      : _client = client ?? AppSupabase.client;

  static final GlobeCloudsService instance = GlobeCloudsService._();

  static const String _table = 'social_vote_world_surface_settings';
  static const String _rowId = 'global';
  static const String _adminSetRpc = 'admin_set_globe_clouds_enabled';
  static const String _adminSetProfileRpc = 'admin_set_globe_cloud_profile';

  final SupabaseClient _client;

  bool _enabled = false;
  int _densityPercent = 42;
  int _speedPercent = 22;
  int _direction = 1;
  bool _loaded = false;
  bool _loading = false;
  bool _saving = false;
  String? _lastError;
  Future<void>? _loadFuture;

  bool get enabled => _enabled;
  int get densityPercent => _densityPercent;
  int get speedPercent => _speedPercent;
  int get direction => _direction;
  double get density => _densityPercent / 100.0;
  double get speed => _speedPercent / 100.0;
  bool get isLoaded => _loaded;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get lastError => _lastError;

  Future<void> ensureLoaded({bool forceRefresh = false}) {
    if (_loaded && !forceRefresh) {
      return Future<void>.value();
    }

    if (_loadFuture != null) {
      return _loadFuture!;
    }

    return _loadFuture = _load();
  }

  Future<void> _load() async {
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      final row = await _client
          .from(_table)
          .select(
            'globe_clouds_enabled,globe_cloud_density,globe_cloud_speed,globe_cloud_direction',
          )
          .eq('id', _rowId)
          .maybeSingle();

      if (row == null) {
        throw const FormatException(
          'Global Globe clouds setting is missing.',
        );
      }

      final rawEnabled = row['globe_clouds_enabled'];
      if (rawEnabled is! bool) {
        throw const FormatException(
          'Global Globe clouds setting is invalid.',
        );
      }

      _enabled = rawEnabled;
      _densityPercent = _readPercent(
        row['globe_cloud_density'],
        fallback: 42,
      );
      _speedPercent = _readPercent(
        row['globe_cloud_speed'],
        fallback: 22,
      );
      final rawDirection = row['globe_cloud_direction'];
      final parsedDirection = rawDirection is num
          ? rawDirection.toInt()
          : int.tryParse('$rawDirection');
      _direction = parsedDirection == -1 ? -1 : 1;
      _loaded = true;
    } catch (error) {
      _lastError = error.toString();

      if (!_loaded) {
        _enabled = false;
        _densityPercent = 42;
        _speedPercent = 22;
        _direction = 1;
      }
    } finally {
      _loading = false;
      _loadFuture = null;
      notifyListeners();
    }
  }

  Future<void> setEnabledFromAdmin(bool enabled) async {
    if (_saving) return;

    _saving = true;
    _lastError = null;
    notifyListeners();

    try {
      await _client.rpc(
        _adminSetRpc,
        params: <String, Object?>{
          'p_enabled': enabled,
          'p_reason': 'Admin Center Globe clouds control',
        },
      );

      _enabled = enabled;
      _loaded = true;
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> setProfileFromAdmin({
    required int densityPercent,
    required int speedPercent,
    required int direction,
  }) async {
    if (_saving) return;

    final nextDensity = densityPercent.clamp(0, 100).toInt();
    final nextSpeed = speedPercent.clamp(0, 100).toInt();
    final nextDirection = direction < 0 ? -1 : 1;

    _saving = true;
    _lastError = null;
    notifyListeners();

    try {
      await _client.rpc(
        _adminSetProfileRpc,
        params: <String, Object?>{
          'p_density': nextDensity,
          'p_speed': nextSpeed,
          'p_direction': nextDirection,
          'p_reason': 'Admin Center Globe clouds motion control',
        },
      );

      _densityPercent = nextDensity;
      _speedPercent = nextSpeed;
      _direction = nextDirection;
      _loaded = true;
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  static int _readPercent(Object? raw, {required int fallback}) {
    final value = raw is num ? raw.toInt() : int.tryParse('$raw');
    if (value == null) return fallback;
    return value.clamp(0, 100).toInt();
  }
}

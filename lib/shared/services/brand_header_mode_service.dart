import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/shared/branding/social_vote_brand_assets.dart';

enum BrandHeaderMode {
  normal,
  flicker,
}

class BrandHeaderModeService extends ChangeNotifier {
  BrandHeaderModeService._({SupabaseClient? client})
      : _client = client ?? AppSupabase.client;

  static final BrandHeaderModeService instance = BrandHeaderModeService._();

  static const String _table = 'social_vote_world_surface_settings';
  static const String _rowId = 'global';
  static const String _adminSetRpc = 'admin_set_header_brand_mode';
  static const String _adminSetProfileRpc = 'admin_set_header_flicker_profile';

  final SupabaseClient _client;

  BrandHeaderMode _mode = BrandHeaderMode.normal;
  int _flickerIntensityPercent = 100;
  int _flickerSpeedPercent = 100;
  bool _loaded = false;
  bool _loading = false;
  bool _saving = false;
  String? _lastError;
  Future<void>? _loadFuture;

  BrandHeaderMode get mode => _mode;
  int get flickerIntensityPercent => _flickerIntensityPercent;
  int get flickerSpeedPercent => _flickerSpeedPercent;
  double get flickerIntensity => _flickerIntensityPercent / 100.0;
  double get flickerSpeedMultiplier => _flickerSpeedPercent / 100.0;
  bool get isLoaded => _loaded;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get lastError => _lastError;

  SocialVoteBrandEffect get effect => switch (_mode) {
        BrandHeaderMode.normal => SocialVoteBrandEffect.off,
        BrandHeaderMode.flicker => SocialVoteBrandEffect.flicker,
      };

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
            'header_brand_mode,header_flicker_intensity,header_flicker_speed',
          )
          .eq('id', _rowId)
          .maybeSingle();

      if (row == null) {
        throw const FormatException(
          'Global header brand setting is missing.',
        );
      }

      final raw = row['header_brand_mode']?.toString().trim().toLowerCase();

      _mode = switch (raw) {
        'normal' => BrandHeaderMode.normal,
        'flicker' => BrandHeaderMode.flicker,
        _ => throw const FormatException(
            'Header brand mode is invalid.',
          ),
      };

      _flickerIntensityPercent = _readPercent(
        row['header_flicker_intensity'],
        fallback: 100,
        min: 20,
        max: 100,
      );
      _flickerSpeedPercent = _readPercent(
        row['header_flicker_speed'],
        fallback: 100,
        min: 50,
        max: 200,
      );
      _loaded = true;
    } catch (error) {
      _lastError = error.toString();

      if (!_loaded) {
        _mode = BrandHeaderMode.normal;
        _flickerIntensityPercent = 100;
        _flickerSpeedPercent = 100;
      }
    } finally {
      _loading = false;
      _loadFuture = null;
      notifyListeners();
    }
  }

  Future<void> setModeFromAdmin(BrandHeaderMode mode) async {
    if (_saving) return;

    _saving = true;
    _lastError = null;
    notifyListeners();

    try {
      final value = switch (mode) {
        BrandHeaderMode.normal => 'normal',
        BrandHeaderMode.flicker => 'flicker',
      };

      await _client.rpc(
        _adminSetRpc,
        params: <String, Object?>{
          'p_mode': value,
          'p_reason': 'Admin Center Social Vote header brand mode control',
        },
      );

      _mode = mode;
      _loaded = true;
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> setFlickerProfileFromAdmin({
    required int intensityPercent,
    required int speedPercent,
  }) async {
    if (_saving) return;

    final nextIntensity = intensityPercent.clamp(20, 100).toInt();
    final nextSpeed = speedPercent.clamp(50, 200).toInt();

    _saving = true;
    _lastError = null;
    notifyListeners();

    try {
      await _client.rpc(
        _adminSetProfileRpc,
        params: <String, Object?>{
          'p_intensity': nextIntensity,
          'p_speed': nextSpeed,
          'p_reason': 'Admin Center Social Vote header flicker tuning',
        },
      );

      _flickerIntensityPercent = nextIntensity;
      _flickerSpeedPercent = nextSpeed;
      _loaded = true;
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  static int _readPercent(
    Object? raw, {
    required int fallback,
    required int min,
    required int max,
  }) {
    final value = raw is num ? raw.toInt() : int.tryParse('$raw');
    if (value == null) return fallback;
    return value.clamp(min, max).toInt();
  }
}

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

  final SupabaseClient _client;

  BrandHeaderMode _mode = BrandHeaderMode.normal;
  bool _loaded = false;
  bool _loading = false;
  bool _saving = false;
  String? _lastError;
  Future<void>? _loadFuture;

  BrandHeaderMode get mode => _mode;
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
          .select('header_brand_mode')
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

      _loaded = true;
    } catch (error) {
      _lastError = error.toString();

      if (!_loaded) {
        _mode = BrandHeaderMode.normal;
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
}

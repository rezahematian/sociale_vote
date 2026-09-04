import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';

enum EgressMode {
  normal,
  conservative,
  emergency,
}

enum EgressAutomaticTraffic {
  homePolls,
  homeNews,
  homeSocial,
  homeMap,
  homeNotifications,
  pollRealtimeResult,
  sessionPresenter,
  sessionStage,
  sessionParticipant,
}

enum EgressSessionActivity {
  active,
  waiting,
  idle,
}

/// Shared client-side safety policy for automatic network refreshes.
///
/// This is deliberately not used for login, votes, reactions, publishing or
/// user-triggered refreshes. Supabase remains authoritative for data, RLS and
/// RPC enforcement; this service only suppresses avoidable background reads.
class EgressPolicyService extends ChangeNotifier with WidgetsBindingObserver {
  EgressPolicyService._({SupabaseClient? client}) : _clientOverride = client;

  static final EgressPolicyService instance = EgressPolicyService._();

  static const String _settingsTable = 'social_vote_world_surface_settings';
  static const String _settingsRowId = 'global';
  static const String _adminSetModeRpc = 'admin_set_egress_mode';
  // Active clients re-check the remote kill switch before automatic traffic.
  // Two minutes bounds emergency propagation without adding idle polling.
  static const Duration _remoteModeTtl = Duration(minutes: 2);

  static const String _dayPreferenceKey = 'egress_auto_budget_day_v2';
  static const String _usedPreferenceKey = 'egress_auto_budget_used_v2';

  static const int _mib = 1024 * 1024;

  final SupabaseClient? _clientOverride;

  SupabaseClient get _client => _clientOverride ?? AppSupabase.client;

  EgressMode _mode = EgressMode.conservative;
  bool _initialized = false;
  bool _observerAttached = false;
  bool _loadingMode = false;
  bool _savingMode = false;
  bool _appVisible = true;
  String? _lastError;
  DateTime? _lastModeLoadedAt;
  Future<void>? _initializeFuture;
  Future<void>? _modeLoadFuture;
  String _localDayKey = '';
  int _estimatedAutomaticBytesUsed = 0;
  bool _automaticBudgetBlocked = false;

  EgressMode get mode => _mode;
  bool get isInitialized => _initialized;
  bool get isLoadingMode => _loadingMode;
  bool get isSavingMode => _savingMode;
  bool get isAppVisible => _appVisible;
  String? get lastError => _lastError;
  int get estimatedAutomaticBytesUsed => _estimatedAutomaticBytesUsed;
  int get dailyAutomaticBudgetBytes => dailyBudgetBytesFor(_mode);
  int get dailyAutomaticBudgetRemainingBytes =>
      (dailyAutomaticBudgetBytes - _estimatedAutomaticBytesUsed)
          .clamp(0, dailyAutomaticBudgetBytes)
          .toInt();
  bool get automaticBudgetExhausted =>
      _mode == EgressMode.emergency ||
      _automaticBudgetBlocked ||
      _estimatedAutomaticBytesUsed >= dailyAutomaticBudgetBytes;

  static int dailyBudgetBytesFor(EgressMode mode) {
    return switch (mode) {
      EgressMode.normal => 20 * _mib,
      EgressMode.conservative => 8 * _mib,
      EgressMode.emergency => 0,
    };
  }

  static int newsFallbackScanLimitFor(EgressMode mode) {
    return switch (mode) {
      EgressMode.normal => 6,
      EgressMode.conservative => 3,
      EgressMode.emergency => 1,
    };
  }

  static Duration newsMemoryCacheTtlFor(EgressMode mode) {
    // News provider caches are refreshed on the backend at a much slower cadence
    // than the previous 5/15 minute client TTLs. Keeping payloads in memory longer
    // prevents every scope/view from downloading the same large JSON feed again.
    return switch (mode) {
      EgressMode.normal => const Duration(minutes: 30),
      EgressMode.conservative => const Duration(hours: 2),
      EgressMode.emergency => const Duration(hours: 6),
    };
  }

  static Duration removedNewsIdentityCacheTtlFor(EgressMode mode) {
    return switch (mode) {
      EgressMode.normal => const Duration(minutes: 30),
      EgressMode.conservative => const Duration(hours: 2),
      EgressMode.emergency => const Duration(hours: 6),
    };
  }

  static Duration? sessionRefreshDelayFor({
    required EgressMode mode,
    required EgressSessionActivity activity,
  }) {
    if (mode == EgressMode.emergency) {
      return null;
    }

    return switch ((mode, activity)) {
      (EgressMode.normal, EgressSessionActivity.active) =>
        const Duration(seconds: 5),
      (EgressMode.normal, EgressSessionActivity.waiting) =>
        const Duration(seconds: 10),
      (EgressMode.normal, EgressSessionActivity.idle) =>
        const Duration(seconds: 30),
      (EgressMode.conservative, EgressSessionActivity.active) =>
        const Duration(seconds: 15),
      (EgressMode.conservative, EgressSessionActivity.waiting) =>
        const Duration(seconds: 30),
      (EgressMode.conservative, EgressSessionActivity.idle) =>
        const Duration(seconds: 60),
      (EgressMode.emergency, _) => null,
    };
  }

  int get newsFallbackScanLimit => newsFallbackScanLimitFor(_mode);
  Duration get newsMemoryCacheTtl => newsMemoryCacheTtlFor(_mode);
  Duration get removedNewsIdentityCacheTtl =>
      removedNewsIdentityCacheTtlFor(_mode);

  Future<void> initialize() {
    if (_initialized) {
      return ensureModeLoaded();
    }
    return _initializeFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    if (!_observerAttached) {
      WidgetsBinding.instance.addObserver(this);
      _observerAttached = true;
    }

    await _restoreLocalBudget();
    _initialized = true;
    _initializeFuture = null;
    await ensureModeLoaded();
  }

  Future<void> ensureModeLoaded({bool forceRefresh = false}) {
    final loadedAt = _lastModeLoadedAt;
    if (!forceRefresh &&
        loadedAt != null &&
        DateTime.now().toUtc().difference(loadedAt) < _remoteModeTtl) {
      return Future<void>.value();
    }
    if (_modeLoadFuture != null) {
      return _modeLoadFuture!;
    }
    return _modeLoadFuture = _loadMode();
  }

  Future<void> _loadMode() async {
    _loadingMode = true;
    _lastError = null;

    try {
      final row = await _client
          .from(_settingsTable)
          .select('egress_mode')
          .eq('id', _settingsRowId)
          .maybeSingle();
      if (row == null) {
        throw const FormatException('Egress settings row is missing.');
      }

      final parsed = _modeFromBackend(row['egress_mode']);
      if (parsed == null) {
        throw const FormatException('Egress mode is invalid.');
      }

      final changed = _mode != parsed;
      _mode = parsed;
      _lastModeLoadedAt = DateTime.now().toUtc();
      await _rollLocalBudgetIfNeeded();
      _automaticBudgetBlocked =
          _estimatedAutomaticBytesUsed >= dailyAutomaticBudgetBytes;
      if (changed) {
        notifyListeners();
      }
    } catch (error) {
      // Fail-safe: a missing migration or transient backend problem keeps the
      // conservative local policy. It never enables extra background reads.
      _lastError = error.toString();
      if (_lastModeLoadedAt == null) {
        _mode = EgressMode.conservative;
      }
    } finally {
      _loadingMode = false;
      _modeLoadFuture = null;
      notifyListeners();
    }
  }

  Future<void> setModeFromAdmin(EgressMode value) async {
    if (_savingMode) return;

    _savingMode = true;
    _lastError = null;
    notifyListeners();

    try {
      await _client.rpc(
        _adminSetModeRpc,
        params: <String, Object?>{
          'p_mode': value.name,
          'p_reason': 'Admin Center automatic egress control',
        },
      );
      _mode = value;
      _lastModeLoadedAt = DateTime.now().toUtc();
      await _rollLocalBudgetIfNeeded();
      _automaticBudgetBlocked =
          _estimatedAutomaticBytesUsed >= dailyAutomaticBudgetBytes;
    } catch (error) {
      _lastError = error.toString();
      rethrow;
    } finally {
      _savingMode = false;
      notifyListeners();
    }
  }

  Future<bool> tryConsumeAutomatic(EgressAutomaticTraffic traffic) async {
    if (!_initialized) {
      await initialize();
    }
    await ensureModeLoaded();
    await _rollLocalBudgetIfNeeded();

    if (!_appVisible || _mode == EgressMode.emergency) {
      return false;
    }

    final cost = _estimatedBytesFor(traffic);
    final budget = dailyAutomaticBudgetBytes;
    if (budget <= 0 || _estimatedAutomaticBytesUsed + cost > budget) {
      _automaticBudgetBlocked = true;
      return false;
    }

    _estimatedAutomaticBytesUsed += cost;
    unawaited(_persistLocalBudget());
    return true;
  }

  int _estimatedBytesFor(EgressAutomaticTraffic traffic) {
    return switch (traffic) {
      EgressAutomaticTraffic.homePolls => 320 * 1024,
      EgressAutomaticTraffic.homeNews => 768 * 1024,
      EgressAutomaticTraffic.homeSocial => 384 * 1024,
      EgressAutomaticTraffic.homeMap => 512 * 1024,
      EgressAutomaticTraffic.homeNotifications => 24 * 1024,
      EgressAutomaticTraffic.pollRealtimeResult => 32 * 1024,
      EgressAutomaticTraffic.sessionPresenter => 96 * 1024,
      EgressAutomaticTraffic.sessionStage => 96 * 1024,
      EgressAutomaticTraffic.sessionParticipant => 128 * 1024,
    };
  }

  EgressMode? _modeFromBackend(Object? raw) {
    final normalized = raw?.toString().trim().toLowerCase();
    return switch (normalized) {
      'normal' => EgressMode.normal,
      'conservative' => EgressMode.conservative,
      'emergency' => EgressMode.emergency,
      _ => null,
    };
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _restoreLocalBudget() async {
    final today = _todayKey();
    try {
      final preferences = await SharedPreferences.getInstance();
      final storedDay = preferences.getString(_dayPreferenceKey);
      if (storedDay == today) {
        _localDayKey = today;
        _estimatedAutomaticBytesUsed =
            preferences.getInt(_usedPreferenceKey) ?? 0;
        _automaticBudgetBlocked =
            _estimatedAutomaticBytesUsed >= dailyAutomaticBudgetBytes;
        return;
      }
    } catch (_) {
      // Memory-only accounting remains active when local storage is blocked.
    }

    _localDayKey = today;
    _estimatedAutomaticBytesUsed = 0;
    _automaticBudgetBlocked = false;
    unawaited(_persistLocalBudget());
  }

  Future<void> _rollLocalBudgetIfNeeded() async {
    final today = _todayKey();
    if (_localDayKey == today) return;
    _localDayKey = today;
    _estimatedAutomaticBytesUsed = 0;
    _automaticBudgetBlocked = false;
    await _persistLocalBudget();
    notifyListeners();
  }

  Future<void> _persistLocalBudget() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_dayPreferenceKey, _localDayKey);
      await preferences.setInt(
        _usedPreferenceKey,
        _estimatedAutomaticBytesUsed,
      );
    } catch (_) {
      // The in-memory limiter still protects the current app session.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final visible = state == AppLifecycleState.resumed;
    if (_appVisible != visible) {
      _appVisible = visible;
      notifyListeners();
    }

    if (visible) {
      unawaited(ensureModeLoaded(forceRefresh: true));
    }
  }
}

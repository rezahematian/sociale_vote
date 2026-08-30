import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';

enum RadioMondoTrack { classicalOrbit, worldRain, youngPulse }

extension RadioMondoTrackX on RadioMondoTrack {
  String get assetPath => switch (this) {
        RadioMondoTrack.classicalOrbit => 'audio/orbita_classica.ogg',
        RadioMondoTrack.worldRain => 'audio/pioggia_sul_mondo.ogg',
        RadioMondoTrack.youngPulse => 'audio/pulse_giovane.ogg',
      };
}

class RadioMondoStation {
  final String id;
  final String title;
  final RadioMondoTrack? builtInTrack;
  final String? audioUrl;
  final String? attribution;
  final String? licenseUrl;

  const RadioMondoStation({
    required this.id,
    required this.title,
    this.builtInTrack,
    this.audioUrl,
    this.attribution,
    this.licenseUrl,
  }) : assert(builtInTrack != null || audioUrl != null);

  bool get isBuiltIn => builtInTrack != null;
}

/// Player foreground-only condiviso da tutte le route dell'app.
///
/// Non salva una preferenza di auto-avvio, non riparte da solo e si arresta
/// appena l'app va in background, la scheda Web viene nascosta o l'app termina.
class RadioMondoService extends ChangeNotifier with WidgetsBindingObserver {
  RadioMondoService._();

  static final RadioMondoService instance = RadioMondoService._();

  final AudioPlayer _player = AudioPlayer();

  static const List<RadioMondoStation> _builtInStations = [
    RadioMondoStation(
      id: 'builtin-classical-orbit',
      title: 'Classical Orbit',
      builtInTrack: RadioMondoTrack.classicalOrbit,
    ),
    RadioMondoStation(
      id: 'builtin-world-rain',
      title: 'Rain over the World',
      builtInTrack: RadioMondoTrack.worldRain,
    ),
    RadioMondoStation(
      id: 'builtin-young-pulse',
      title: 'Young Pulse',
      builtInTrack: RadioMondoTrack.youngPulse,
    ),
  ];

  bool _initialized = false;
  bool _catalogLoading = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  double _volume = 0.34;
  List<RadioMondoStation> _stations = _builtInStations;
  RadioMondoStation _selectedStation = _builtInStations.first;
  RadioMondoStation? _currentStation;

  bool get isLoading => _isLoading || _catalogLoading;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  List<RadioMondoStation> get stations =>
      List<RadioMondoStation>.unmodifiable(_stations);
  RadioMondoStation get selectedStation => _selectedStation;
  RadioMondoStation? get currentStation => _currentStation;

  // Compatibilità per i test e per eventuali chiamanti legacy.
  RadioMondoTrack get selectedTrack =>
      _selectedStation.builtInTrack ?? RadioMondoTrack.classicalOrbit;
  RadioMondoTrack? get currentTrack => _currentStation?.builtInTrack;

  Future<void> initialize() async {
    final initialized = await _ensureInitialized();
    if (initialized) {
      await reloadCatalog();
    }
  }

  Future<void> reloadCatalog() async {
    if (_catalogLoading) return;
    _catalogLoading = true;
    notifyListeners();

    try {
      final raw = await AppSupabase.client.rpc('radio_mondo_public_catalog');
      final remoteStations = <RadioMondoStation>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          final row = Map<String, dynamic>.from(item);
          final id = row['id']?.toString().trim();
          final title = row['title']?.toString().trim();
          final audioUrl = row['audio_url']?.toString().trim();
          if (id == null ||
              id.isEmpty ||
              title == null ||
              title.isEmpty ||
              audioUrl == null ||
              !audioUrl.startsWith('https://')) {
            continue;
          }
          remoteStations.add(
            RadioMondoStation(
              id: 'remote-$id',
              title: title,
              audioUrl: audioUrl,
              attribution: _nullable(row['attribution']),
              licenseUrl: _nullable(row['license_url']),
            ),
          );
        }
      }

      final nextStations = <RadioMondoStation>[
        ..._builtInStations,
        ...remoteStations,
      ];
      final selectedMatch = _findById(nextStations, _selectedStation.id);
      final currentId = _currentStation?.id;
      final currentMatch =
          currentId == null ? null : _findById(nextStations, currentId);

      _stations = nextStations;
      _selectedStation = selectedMatch ?? nextStations.first;

      if (_currentStation != null && currentMatch == null) {
        await stop();
      } else {
        _currentStation = currentMatch;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Radio Mondo catalog error: $error\n$stackTrace');
      }
      // Le tre tracce integrate restano sempre disponibili offline.
    } finally {
      _catalogLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;

    var observerAdded = false;
    try {
      WidgetsBinding.instance.addObserver(this);
      observerAdded = true;
      await _player.setPlayerMode(PlayerMode.mediaPlayer);
      await _player.setVolume(_volume);
      _initialized = true;
      return true;
    } catch (error, stackTrace) {
      if (observerAdded) {
        WidgetsBinding.instance.removeObserver(this);
      }
      _initialized = false;
      if (kDebugMode) {
        debugPrint('Radio Mondo initialization error: $error\n$stackTrace');
      }
      return false;
    }
  }

  Future<bool> play(RadioMondoTrack track) async {
    final station = _builtInStations.firstWhere(
      (item) => item.builtInTrack == track,
    );
    return playStation(station);
  }

  Future<bool> playStation(RadioMondoStation station) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final initialized = await _ensureInitialized();
      if (!initialized) {
        _currentStation = null;
        _isPlaying = false;
        return false;
      }

      _selectedStation = station;
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);
      final builtInTrack = station.builtInTrack;
      if (builtInTrack != null) {
        await _player.play(AssetSource(builtInTrack.assetPath));
      } else {
        final audioUrl = station.audioUrl;
        if (audioUrl == null || !audioUrl.startsWith('https://')) {
          return false;
        }
        await _player.play(UrlSource(audioUrl));
      }
      _currentStation = station;
      _isPlaying = true;
      return true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Radio Mondo playback error: $error\n$stackTrace');
      }
      _currentStation = null;
      _isPlaying = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (!_initialized) return;
    try {
      // Keep the AudioPlayer reusable during the app lifetime.
      // Releasing on every stop caused unstable native re-entry on some Android devices.
      await _player.stop();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Radio Mondo stop error: $error\n$stackTrace');
      }
    } finally {
      _currentStation = null;
      _isPlaying = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0).toDouble();
    if (_initialized) {
      await _player.setVolume(_volume);
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(stop());
        break;
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> shutdown() async {
    if (!_initialized) return;
    WidgetsBinding.instance.removeObserver(this);
    await stop();
    _initialized = false;
    await _player.dispose();
  }

  static RadioMondoStation? _findById(
    List<RadioMondoStation> stations,
    String id,
  ) {
    for (final station in stations) {
      if (station.id == id) return station;
    }
    return null;
  }

  static String? _nullable(dynamic value) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

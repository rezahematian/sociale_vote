import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum RadioMondoTrack { classicalOrbit, worldRain, youngPulse }

extension RadioMondoTrackX on RadioMondoTrack {
  String get assetPath => switch (this) {
        RadioMondoTrack.classicalOrbit => 'audio/orbita_classica.ogg',
        RadioMondoTrack.worldRain => 'audio/pioggia_sul_mondo.ogg',
        RadioMondoTrack.youngPulse => 'audio/pulse_giovane.ogg',
      };
}

/// Player foreground-only condiviso da tutte le route dell'app.
///
/// Non salva una preferenza di auto-avvio, non riparte da solo e si arresta
/// appena l'app va in background, la scheda Web viene nascosta o l'app termina.
class RadioMondoService extends ChangeNotifier with WidgetsBindingObserver {
  RadioMondoService._();

  static final RadioMondoService instance = RadioMondoService._();

  final AudioPlayer _player = AudioPlayer();

  bool _initialized = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  double _volume = 0.34;
  RadioMondoTrack _selectedTrack = RadioMondoTrack.classicalOrbit;
  RadioMondoTrack? _currentTrack;

  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  RadioMondoTrack get selectedTrack => _selectedTrack;
  RadioMondoTrack? get currentTrack => _currentTrack;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    await _player.setVolume(_volume);
  }

  Future<bool> play(RadioMondoTrack track) async {
    await initialize();
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      _selectedTrack = track;
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);
      await _player.play(AssetSource(track.assetPath));
      _currentTrack = track;
      _isPlaying = true;
      return true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Radio Mondo playback error: $error\n$stackTrace');
      }
      _currentTrack = null;
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
      await _player.stop();
      await _player.release();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Radio Mondo stop error: $error\n$stackTrace');
      }
    } finally {
      _currentTrack = null;
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
}

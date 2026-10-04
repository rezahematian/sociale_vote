import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';

import 'radio_mondo_web_audio.dart';

enum RadioMondoSourceType { audio, stream }

extension RadioMondoSourceTypeX on RadioMondoSourceType {
  static RadioMondoSourceType fromStorageKey(String? value) =>
      value?.trim().toLowerCase() == 'stream'
          ? RadioMondoSourceType.stream
          : RadioMondoSourceType.audio;
}

enum RadioMondoChannelType { worldLive, nature, worldBrief, liveEvent, special }

extension RadioMondoChannelTypeX on RadioMondoChannelType {
  static RadioMondoChannelType fromStorageKey(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'nature' => RadioMondoChannelType.nature,
        'world_brief' => RadioMondoChannelType.worldBrief,
        'live_event' => RadioMondoChannelType.liveEvent,
        'special' => RadioMondoChannelType.special,
        _ => RadioMondoChannelType.worldLive,
      };
}

enum RadioMondoCategory {
  reggae,
  classical,
  house,
  jazzSoul,
  worldMusic,
  soundsAtmospheres,
}

extension RadioMondoCategoryX on RadioMondoCategory {
  String get storageKey => switch (this) {
        RadioMondoCategory.reggae => 'reggae',
        RadioMondoCategory.classical => 'classical',
        RadioMondoCategory.house => 'house',
        RadioMondoCategory.jazzSoul => 'jazz_soul',
        RadioMondoCategory.worldMusic => 'world_music',
        RadioMondoCategory.soundsAtmospheres => 'sounds_atmospheres',
      };

  static RadioMondoCategory fromStorageKey(
    String? value, {
    RadioMondoChannelType? fallbackChannelType,
  }) =>
      switch (value?.trim().toLowerCase()) {
        'reggae' => RadioMondoCategory.reggae,
        'classical' => RadioMondoCategory.classical,
        'house' => RadioMondoCategory.house,
        'jazz_soul' => RadioMondoCategory.jazzSoul,
        'sounds_atmospheres' => RadioMondoCategory.soundsAtmospheres,
        'world_music' => RadioMondoCategory.worldMusic,
        _ => fromChannelType(fallbackChannelType),
      };

  static RadioMondoCategory fromChannelType(
    RadioMondoChannelType? channelType,
  ) =>
      switch (channelType) {
        RadioMondoChannelType.nature ||
        RadioMondoChannelType.special =>
          RadioMondoCategory.soundsAtmospheres,
        _ => RadioMondoCategory.worldMusic,
      };
}

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
  final int sortOrder;
  final RadioMondoTrack? builtInTrack;
  final String? audioUrl;
  final String? attribution;
  final String? licenseUrl;
  final RadioMondoSourceType sourceType;
  final RadioMondoChannelType channelType;
  final RadioMondoCategory category;
  final String? languageCode;
  final String? worldBriefId;
  final bool isDefault;
  final bool isLive;

  const RadioMondoStation({
    required this.id,
    required this.title,
    this.sortOrder = 100,
    this.builtInTrack,
    this.audioUrl,
    this.attribution,
    this.licenseUrl,
    this.sourceType = RadioMondoSourceType.audio,
    this.channelType = RadioMondoChannelType.worldLive,
    this.category = RadioMondoCategory.worldMusic,
    this.languageCode,
    this.worldBriefId,
    this.isDefault = false,
    this.isLive = false,
  }) : assert(builtInTrack != null || audioUrl != null);

  bool get isBuiltIn => builtInTrack != null;
}

/// Player condiviso da tutte le route dell'app.
///
/// Non salva una preferenza di auto-avvio e non riparte da solo.
/// Su Web e Android, dopo un avvio esplicito dell'utente, il playback può
/// continuare quando la pagina/app passa in background o lo schermo si blocca.
class _RadioMondoAudioHandler extends BaseAudioHandler {
  _RadioMondoAudioHandler(this._owner);

  final RadioMondoService _owner;

  @override
  Future<void> play() => _owner._resumeFromMediaSession();

  @override
  Future<void> pause() => _owner._pauseFromMediaSession();

  @override
  Future<void> stop() => _owner._stopFromMediaSession();

  void publishStation(RadioMondoStation station) {
    mediaItem.add(
      MediaItem(
        id: station.id,
        title: station.title,
        album: 'Social Vote · Radio Mondo',
        artist: 'Social Vote',
        extras: <String, dynamic>{
          'attribution': station.attribution,
          'channelType': station.channelType.name,
          'category': station.category.storageKey,
          'isLive': station.isLive,
        },
      ),
    );
  }

  void publishReady({required bool playing}) {
    playbackState.add(
      PlaybackState(
        controls: <MediaControl>[
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const <int>[0, 1],
        processingState: AudioProcessingState.ready,
        playing: playing,
        speed: 1.0,
      ),
    );
  }

  void publishIdle() {
    mediaItem.add(null);
    playbackState.add(
      PlaybackState(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }
}

class RadioMondoService extends ChangeNotifier with WidgetsBindingObserver {
  RadioMondoService._();

  static final RadioMondoService instance = RadioMondoService._();

  final AudioPlayer _player = AudioPlayer();
  final RadioMondoWebAudio _webAudio = RadioMondoWebAudio();
  _RadioMondoAudioHandler? _audioHandler;
  StreamSubscription<void>? _playerCompleteSubscription;
  bool _advancingPlaylist = false;
  bool _previewMode = false;

  static const List<RadioMondoStation> _builtInStations = [
    RadioMondoStation(
      id: 'builtin-classical-orbit',
      title: 'Classical Orbit',
      sortOrder: 100,
      builtInTrack: RadioMondoTrack.classicalOrbit,
      category: RadioMondoCategory.classical,
    ),
    RadioMondoStation(
      id: 'builtin-world-rain',
      title: 'Rain over the World',
      sortOrder: 200,
      builtInTrack: RadioMondoTrack.worldRain,
      category: RadioMondoCategory.soundsAtmospheres,
    ),
    RadioMondoStation(
      id: 'builtin-young-pulse',
      title: 'Young Pulse',
      sortOrder: 300,
      builtInTrack: RadioMondoTrack.youngPulse,
      category: RadioMondoCategory.house,
    ),
  ];

  bool _initialized = false;
  bool _catalogLoading = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  double _volume = 0.34;
  List<RadioMondoStation> _stations = const [];
  RadioMondoStation? _selectedStation;
  RadioMondoStation? _currentStation;
  RadioMondoCategory _selectedCategory = RadioMondoCategory.worldMusic;
  bool _selectionExplicit = false;

  bool get isLoading => _isLoading || _catalogLoading;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  List<RadioMondoStation> get stations =>
      List<RadioMondoStation>.unmodifiable(_stations);
  RadioMondoStation? get selectedStation => _selectedStation;
  RadioMondoStation? get currentStation => _currentStation;
  RadioMondoCategory get selectedCategory => _selectedCategory;

  List<RadioMondoStation> stationsForCategory(RadioMondoCategory category) =>
      List<RadioMondoStation>.unmodifiable(
        _stations.where((station) => station.category == category),
      );

  int stationCountForCategory(RadioMondoCategory category) =>
      _stations.where((station) => station.category == category).length;

  // Compatibilità per i test e per eventuali chiamanti legacy.
  RadioMondoTrack get selectedTrack =>
      _selectedStation?.builtInTrack ?? RadioMondoTrack.classicalOrbit;
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
          final rawSortOrder = row['sort_order'];
          final sortOrder = rawSortOrder is num ? rawSortOrder.toInt() : 100;
          final channelType = RadioMondoChannelTypeX.fromStorageKey(
            _nullable(row['channel_type']),
          );
          remoteStations.add(
            RadioMondoStation(
              id: 'remote-$id',
              title: title,
              sortOrder: sortOrder.clamp(0, 1000).toInt(),
              audioUrl: audioUrl,
              attribution: _nullable(row['attribution']),
              licenseUrl: _nullable(row['license_url']),
              sourceType: RadioMondoSourceTypeX.fromStorageKey(
                _nullable(row['source_type']),
              ),
              channelType: channelType,
              category: RadioMondoCategoryX.fromStorageKey(
                _nullable(row['category_key']),
                fallbackChannelType: channelType,
              ),
              languageCode: _nullable(row['language_code']),
              worldBriefId: _nullable(row['world_brief_id']),
              isDefault: row['is_default'] == true,
              isLive: row['is_live'] == true,
            ),
          );
        }
      }

      final nextStations = <RadioMondoStation>[
        ...remoteStations,
      ]..sort((a, b) {
          final liveOrder = (b.isLive ? 1 : 0).compareTo(a.isLive ? 1 : 0);
          if (liveOrder != 0) return liveOrder;
          final defaultOrder =
              (b.isDefault ? 1 : 0).compareTo(a.isDefault ? 1 : 0);
          if (defaultOrder != 0) return defaultOrder;
          final order = a.sortOrder.compareTo(b.sortOrder);
          if (order != 0) return order;
          return a.id.compareTo(b.id);
        });

      final selectedId = _selectedStation?.id;
      final selectedMatch =
          selectedId == null ? null : _findById(nextStations, selectedId);
      final currentId = _currentStation?.id;
      final currentMatch =
          currentId == null ? null : _findById(nextStations, currentId);

      _stations = nextStations;
      RadioMondoStation? defaultStation;
      for (final station in nextStations) {
        if (station.isDefault) {
          defaultStation = station;
          break;
        }
      }

      final selectedCategoryStations = nextStations
          .where((station) => station.category == _selectedCategory)
          .toList(growable: false);
      RadioMondoStation? selectedCategoryDefault;
      for (final station in selectedCategoryStations) {
        if (station.isDefault) {
          selectedCategoryDefault = station;
          break;
        }
      }

      _selectedStation = nextStations.isEmpty
          ? null
          : (_selectionExplicit
              ? (selectedMatch ??
                  selectedCategoryDefault ??
                  (selectedCategoryStations.isEmpty
                      ? null
                      : selectedCategoryStations.first) ??
                  defaultStation ??
                  nextStations.first)
              : (defaultStation ?? nextStations.first));
      if (_selectedStation != null) {
        _selectedCategory = _selectedStation!.category;
      }

      if (_currentStation != null && currentMatch == null) {
        await stop();
      } else {
        _currentStation = currentMatch;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Radio Mondo catalog error: $error\n$stackTrace');
      }
      // Nessun fallback integrato: Radio Mondo usa il catalogo amministrato.
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
      if (kIsWeb) {
        _webAudio.setOnEnded(() {
          unawaited(_handleTrackCompleted());
        });
        await _webAudio.setVolume(_volume);
      } else {
        await _player.setPlayerMode(PlayerMode.mediaPlayer);
        _playerCompleteSubscription ??= _player.onPlayerComplete.listen((_) {
          unawaited(_handleTrackCompleted());
        });

        if (defaultTargetPlatform == TargetPlatform.android) {
          _audioHandler ??= await AudioService.init<_RadioMondoAudioHandler>(
            builder: () => _RadioMondoAudioHandler(this),
            config: const AudioServiceConfig(
              androidNotificationChannelId:
                  'com.hematianapps.socialvote.radio_mondo',
              androidNotificationChannelName: 'Social Vote · Radio Mondo',
              androidNotificationChannelDescription:
                  'Radio Mondo playback controls',
              androidStopForegroundOnPause: false,
            ),
          );

          await _player.setAudioContext(
            AudioContextConfig(
              stayAwake: true,
            ).build(),
          );
        }

        await _player.setVolume(_volume);
      }
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
    return _playStationInternal(station, preview: false);
  }

  Future<bool> playPreviewStation(RadioMondoStation station) async {
    return _playStationInternal(station, preview: true);
  }

  Future<bool> _playStationInternal(
    RadioMondoStation station, {
    required bool preview,
  }) async {
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

      if (!preview) {
        _selectedStation = station;
        _selectedCategory = station.category;
        _selectionExplicit = true;
      }
      _previewMode = preview;
      final builtInTrack = station.builtInTrack;

      if (kIsWeb) {
        final sourceUrl = builtInTrack != null
            ? 'assets/assets/${builtInTrack.assetPath}'
            : station.audioUrl;

        if (sourceUrl == null ||
            (builtInTrack == null && !sourceUrl.startsWith('https://'))) {
          return false;
        }

        await _webAudio.stop();
        await _webAudio.playUrl(
          sourceUrl,
          loop: false,
          volume: _volume,
        );
      } else {
        await _player.stop();
        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.setVolume(_volume);

        if (builtInTrack != null) {
          await _player.play(AssetSource(builtInTrack.assetPath));
        } else {
          final audioUrl = station.audioUrl;
          if (audioUrl == null || !audioUrl.startsWith('https://')) {
            return false;
          }
          await _player.play(UrlSource(audioUrl));
        }
      }
      _currentStation = station;
      _isPlaying = true;

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        _audioHandler?.publishStation(station);
        _audioHandler?.publishReady(playing: true);
      }

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

  Future<void> selectCategory(RadioMondoCategory category) async {
    if (_selectedCategory == category &&
        _selectedStation?.category == category) {
      return;
    }

    if (_currentStation != null && _currentStation?.category != category) {
      await stop();
    }

    final candidates = _stations
        .where((station) => station.category == category)
        .toList(growable: false);
    _selectedCategory = category;
    _selectionExplicit = true;

    if (candidates.isEmpty) {
      _selectedStation = null;
      notifyListeners();
      return;
    }

    RadioMondoStation? preferred;
    for (final station in candidates) {
      if (station.isDefault) {
        preferred = station;
        break;
      }
    }
    _selectedStation = preferred ?? candidates.first;
    notifyListeners();
  }

  Future<bool> playPrevious() => _playAdjacent(-1);

  Future<bool> playNext() => _playAdjacent(1);

  Future<bool> _playAdjacent(int offset) async {
    final anchor = _currentStation ?? _selectedStation;
    final category = anchor?.category ?? _selectedCategory;
    final catalog = _stations
        .where((station) => station.category == category)
        .toList(growable: false);
    if (catalog.isEmpty) return false;

    var currentIndex = anchor == null
        ? -1
        : catalog.indexWhere((station) => station.id == anchor.id);
    if (currentIndex < 0) {
      currentIndex = offset > 0 ? -1 : 0;
    }
    final nextIndex = (currentIndex + offset) % catalog.length;
    return playStation(catalog[nextIndex]);
  }

  Future<void> _handleTrackCompleted() async {
    final current = _currentStation;
    if (!_initialized ||
        current == null ||
        current.sourceType == RadioMondoSourceType.stream ||
        _advancingPlaylist) {
      return;
    }
    if (_previewMode) {
      await stop();
      return;
    }

    _advancingPlaylist = true;
    try {
      final catalog = _stations
          .where(
            (station) =>
                station.sourceType == RadioMondoSourceType.audio &&
                station.category == current.category,
          )
          .toList(growable: false);
      if (catalog.isEmpty) {
        await stop();
        return;
      }

      var currentIndex = catalog.indexWhere((item) => item.id == current.id);
      if (currentIndex < 0) currentIndex = -1;

      for (var offset = 1; offset <= catalog.length; offset += 1) {
        final next = catalog[(currentIndex + offset) % catalog.length];
        final started = await playStation(next);
        if (started) {
          return;
        }
      }

      await stop();
    } finally {
      _advancingPlaylist = false;
    }
  }

  Future<void> stop() async {
    if (!_initialized) return;
    try {
      // Keep the AudioPlayer reusable during the app lifetime.
      // Releasing on every stop caused unstable native re-entry on some Android devices.
      if (kIsWeb) {
        await _webAudio.stop();
      } else {
        await _player.stop();
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Radio Mondo stop error: $error\n$stackTrace');
      }
    } finally {
      _currentStation = null;
      _isPlaying = false;
      _isLoading = false;
      _previewMode = false;

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        _audioHandler?.publishIdle();
      }

      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (!_initialized || !_isPlaying || _currentStation == null) return;

    try {
      if (kIsWeb) {
        await _webAudio.pause();
      } else {
        await _player.pause();
      }
      _isPlaying = false;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        _audioHandler?.publishReady(playing: false);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Radio Mondo pause error: $error\n$stackTrace');
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> resume() async {
    if (!_initialized || _isPlaying || _currentStation == null) return;

    try {
      if (kIsWeb) {
        await _webAudio.resume();
      } else {
        await _player.resume();
      }
      _isPlaying = true;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        _audioHandler?.publishReady(playing: true);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Radio Mondo resume error: $error\n$stackTrace');
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> _pauseFromMediaSession() => pause();

  Future<void> _resumeFromMediaSession() => resume();

  Future<void> _stopFromMediaSession() async {
    await stop();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0).toDouble();
    if (_initialized) {
      if (kIsWeb) {
        await _webAudio.setVolume(_volume);
      } else {
        await _player.setVolume(_volume);
      }
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // Web and Android Radio are user-started media: keep playback alive
        // while the browser/app is backgrounded or the screen is locked.
        if (!(kIsWeb || defaultTargetPlatform == TargetPlatform.android)) {
          unawaited(stop());
        }
        break;
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
    await _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = null;
    await _webAudio.dispose();
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

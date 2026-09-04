import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GlobeVisualStyle {
  classic,
  realistic,
  bright,
  nightLights,
  techNeon,
  terrainRelief,
  minimalDay,
}

enum RadioVisualStyle {
  vintageClassic,
  oldStyle,
  retroElegant,
  woodMinimal,
  modernVintage,
  steampunk,
  minimalChic,
}

enum GlobeRotationVisualStyle {
  classic,
  minimal,
  subtle,
  neon,
  filled,
  glass,
  premium,
}

/// Device-local appearance preferences for the World experience.
///
/// This service is intentionally presentation-only. It never changes GeoScope,
/// content visibility, marker data, authentication or backend state.
class WorldAppearanceService extends ChangeNotifier {
  WorldAppearanceService._();

  static final WorldAppearanceService instance = WorldAppearanceService._();

  static const String _globeKey = 'world_appearance_globe_v1';
  static const String _radioKey = 'world_appearance_radio_v1';
  static const String _rotationKey = 'world_appearance_rotation_v1';

  static const GlobeVisualStyle defaultGlobeStyle = GlobeVisualStyle.bright;
  static const RadioVisualStyle defaultRadioStyle = RadioVisualStyle.oldStyle;
  static const GlobeRotationVisualStyle defaultRotationStyle =
      GlobeRotationVisualStyle.classic;

  /// Curated release choices. Legacy enum values remain defined so older local
  /// preferences can be migrated safely without widening the public settings UI.
  static const List<GlobeVisualStyle> selectableGlobeStyles =
      <GlobeVisualStyle>[
    GlobeVisualStyle.classic,
    GlobeVisualStyle.realistic,
    GlobeVisualStyle.bright,
    GlobeVisualStyle.nightLights,
    GlobeVisualStyle.techNeon,
    GlobeVisualStyle.terrainRelief,
  ];

  static const List<RadioVisualStyle> selectableRadioStyles =
      <RadioVisualStyle>[
    RadioVisualStyle.vintageClassic,
    RadioVisualStyle.oldStyle,
    RadioVisualStyle.retroElegant,
    RadioVisualStyle.woodMinimal,
  ];

  static const List<GlobeRotationVisualStyle> selectableRotationStyles =
      <GlobeRotationVisualStyle>[
    GlobeRotationVisualStyle.classic,
    GlobeRotationVisualStyle.minimal,
    GlobeRotationVisualStyle.neon,
    GlobeRotationVisualStyle.premium,
  ];

  GlobeVisualStyle _globeStyle = defaultGlobeStyle;
  RadioVisualStyle _radioStyle = defaultRadioStyle;
  GlobeRotationVisualStyle _rotationStyle = defaultRotationStyle;

  bool _loaded = false;
  Future<void>? _loadFuture;

  GlobeVisualStyle get globeStyle => _globeStyle;
  RadioVisualStyle get radioStyle => _radioStyle;
  GlobeRotationVisualStyle get rotationStyle => _rotationStyle;
  bool get isLoaded => _loaded;

  Future<void> ensureLoaded() {
    if (_loaded) return Future<void>.value();
    return _loadFuture ??= _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final storedGlobe = prefs.getString(_globeKey);
    final storedRadio = prefs.getString(_radioKey);
    final storedRotation = prefs.getString(_rotationKey);

    _globeStyle = _readGlobeStyle(storedGlobe);
    _radioStyle = _readRadioStyle(storedRadio);
    _rotationStyle = _readRotationStyle(storedRotation);

    // One-time local migration for choices removed from the compact selector.
    // Existing supported choices remain untouched.
    await Future.wait<void>([
      if (storedGlobe != null && storedGlobe != _globeStyle.name)
        prefs.setString(_globeKey, _globeStyle.name),
      if (storedRadio != null && storedRadio != _radioStyle.name)
        prefs.setString(_radioKey, _radioStyle.name),
      if (storedRotation != null && storedRotation != _rotationStyle.name)
        prefs.setString(_rotationKey, _rotationStyle.name),
    ]);

    _loaded = true;
    _loadFuture = null;
    notifyListeners();
  }

  Future<void> setGlobeStyle(GlobeVisualStyle value) async {
    await ensureLoaded();
    if (_globeStyle == value) return;

    _globeStyle = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_globeKey, value.name);
  }

  Future<void> setRadioStyle(RadioVisualStyle value) async {
    await ensureLoaded();
    if (_radioStyle == value) return;

    _radioStyle = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_radioKey, value.name);
  }

  Future<void> setRotationStyle(GlobeRotationVisualStyle value) async {
    await ensureLoaded();
    if (_rotationStyle == value) return;

    _rotationStyle = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rotationKey, value.name);
  }

  Future<void> reset() async {
    await ensureLoaded();

    _globeStyle = defaultGlobeStyle;
    _radioStyle = defaultRadioStyle;
    _rotationStyle = defaultRotationStyle;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await Future.wait<void>([
      prefs.remove(_globeKey),
      prefs.remove(_radioKey),
      prefs.remove(_rotationKey),
    ]);
  }

  static GlobeVisualStyle _readGlobeStyle(String? stored) {
    if (stored == GlobeVisualStyle.minimalDay.name) {
      return defaultGlobeStyle;
    }
    final value = _readEnum(stored, GlobeVisualStyle.values, defaultGlobeStyle);
    return selectableGlobeStyles.contains(value) ? value : defaultGlobeStyle;
  }

  static RadioVisualStyle _readRadioStyle(String? stored) {
    if (stored == RadioVisualStyle.modernVintage.name ||
        stored == RadioVisualStyle.steampunk.name) {
      return defaultRadioStyle;
    }
    if (stored == RadioVisualStyle.minimalChic.name) {
      return RadioVisualStyle.woodMinimal;
    }
    final value = _readEnum(stored, RadioVisualStyle.values, defaultRadioStyle);
    return selectableRadioStyles.contains(value) ? value : defaultRadioStyle;
  }

  static GlobeRotationVisualStyle _readRotationStyle(String? stored) {
    if (stored == GlobeRotationVisualStyle.subtle.name ||
        stored == GlobeRotationVisualStyle.glass.name) {
      return defaultRotationStyle;
    }
    if (stored == GlobeRotationVisualStyle.filled.name) {
      return GlobeRotationVisualStyle.premium;
    }
    final value = _readEnum(
      stored,
      GlobeRotationVisualStyle.values,
      defaultRotationStyle,
    );
    return selectableRotationStyles.contains(value)
        ? value
        : defaultRotationStyle;
  }

  static T _readEnum<T extends Enum>(
    String? stored,
    List<T> values,
    T fallback,
  ) {
    if (stored == null) return fallback;

    for (final value in values) {
      if (value.name == stored) return value;
    }

    return fallback;
  }
}

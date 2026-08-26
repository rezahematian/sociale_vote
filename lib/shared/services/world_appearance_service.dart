import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GlobeVisualStyle {
  classic,
  realistic,
  bright,
  nightLights,
  techNeon,
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

  GlobeVisualStyle _globeStyle = GlobeVisualStyle.classic;
  RadioVisualStyle _radioStyle = RadioVisualStyle.vintageClassic;
  GlobeRotationVisualStyle _rotationStyle = GlobeRotationVisualStyle.classic;

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

    _globeStyle = _readEnum(
      prefs.getString(_globeKey),
      GlobeVisualStyle.values,
      GlobeVisualStyle.classic,
    );
    _radioStyle = _readEnum(
      prefs.getString(_radioKey),
      RadioVisualStyle.values,
      RadioVisualStyle.vintageClassic,
    );
    _rotationStyle = _readEnum(
      prefs.getString(_rotationKey),
      GlobeRotationVisualStyle.values,
      GlobeRotationVisualStyle.classic,
    );

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

    _globeStyle = GlobeVisualStyle.classic;
    _radioStyle = RadioVisualStyle.vintageClassic;
    _rotationStyle = GlobeRotationVisualStyle.classic;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await Future.wait<void>([
      prefs.remove(_globeKey),
      prefs.remove(_radioKey),
      prefs.remove(_rotationKey),
    ]);
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

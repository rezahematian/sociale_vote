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

/// V1.0.7 presentation contract. Stored enum IDs and the preference key stay
/// unchanged. Native, Web and previews all read this same texture/palette map.
class GlobePresetVisual {
  static const String dayAsset =
      'assets/globe/earth_day_nasa_blue_marble_2048.png';
  static const String satelliteAsset =
      'assets/globe/earth_day_nasa_bmng_august_4096.jpg';
  static const String nightAsset =
      'assets/globe/earth_night_nasa_black_marble_2016_3600.jpg';

  final String code;
  final String name;
  final String asset;
  final int atmosphereRgb;
  final double atmosphereOpacity;
  final double atmosphereBlur;
  final double atmosphereThickness;
  final bool unlit;
  final double lightAngle;
  final double lightIntensity;
  final double ambientLight;
  final double webEmissiveIntensity;
  final double webShininess;

  const GlobePresetVisual({
    required this.code,
    required this.name,
    required this.asset,
    required this.atmosphereRgb,
    required this.atmosphereOpacity,
    this.atmosphereBlur = 16,
    this.atmosphereThickness = 0.009,
    this.unlit = false,
    this.lightAngle = -28,
    this.lightIntensity = 1.18,
    this.ambientLight = 0.68,
    this.webEmissiveIntensity = 0.34,
    this.webShininess = 1.0,
  });

  String get shortLabel => code == 'D' || code == 'E' ? name : code;

  static GlobePresetVisual forName(String name) {
    for (final style in WorldAppearanceService.selectableGlobeStyles) {
      if (style.name == name) return forStyle(style);
    }
    return forStyle(WorldAppearanceService.defaultGlobeStyle);
  }

  static GlobePresetVisual forStyle(GlobeVisualStyle style) {
    return switch (style) {
      GlobeVisualStyle.classic => const GlobePresetVisual(
          code: 'A', name: 'Natural', asset: dayAsset,
          atmosphereRgb: 0x69B5FF, atmosphereOpacity: 0.18,
        ),
      GlobeVisualStyle.realistic => const GlobePresetVisual(
          code: 'B', name: 'Relief', asset: satelliteAsset,
          atmosphereRgb: 0x6FAFFF, atmosphereOpacity: 0.15,
          lightAngle: -42, lightIntensity: 1.36, ambientLight: 0.54,
          webEmissiveIntensity: 0.22, webShininess: 0.6,
        ),
      GlobeVisualStyle.bright || GlobeVisualStyle.minimalDay =>
        const GlobePresetVisual(
          code: 'C', name: 'Civic Blue', asset: satelliteAsset,
          atmosphereRgb: 0x55C8FF, atmosphereOpacity: 0.24,
          atmosphereBlur: 18, atmosphereThickness: 0.011,
          lightAngle: -24, lightIntensity: 0.96, ambientLight: 0.82,
          webEmissiveIntensity: 0.48, webShininess: 0.6,
        ),
      GlobeVisualStyle.nightLights => const GlobePresetVisual(
          code: 'D', name: 'Elias', asset: nightAsset,
          atmosphereRgb: 0x4D7EC8, atmosphereOpacity: 0.15,
          atmosphereBlur: 14, atmosphereThickness: 0.008,
          unlit: true, ambientLight: 1.0,
          webEmissiveIntensity: 1.0, webShininess: 0.0,
        ),
      GlobeVisualStyle.techNeon => const GlobePresetVisual(
          code: 'E', name: 'Elena', asset: dayAsset,
          atmosphereRgb: 0xA78CFF, atmosphereOpacity: 0.24,
          atmosphereBlur: 19, atmosphereThickness: 0.011,
          lightAngle: -20, lightIntensity: 1.08, ambientLight: 0.92,
          webEmissiveIntensity: 0.50, webShininess: 1.0,
        ),
      GlobeVisualStyle.terrainRelief => const GlobePresetVisual(
          code: 'F', name: 'Satellite', asset: satelliteAsset,
          atmosphereRgb: 0x64B7E8, atmosphereOpacity: 0.15,
          lightAngle: -32, lightIntensity: 1.42, ambientLight: 0.56,
          webEmissiveIntensity: 0.12, webShininess: 1.65,
        ),
    };
  }

  Map<String, Object?> webAppearance(String styleName) => <String, Object?>{
        'visualStyle': styleName,
        'textureUrl': 'assets/$asset',
        'nightTextureUrl': 'assets/$nightAsset',
        'material': <String, Object?>{
          // Violet belongs to Elena's rim, never to the entire surface.
          'color': unlit ? 0x000000 : 0xFFFFFF,
          'emissive': 0xFFFFFF,
          'emissiveIntensity': webEmissiveIntensity,
          'shininess': webShininess,
          'specular': unlit ? 0x000000 : 0x020408,
          'toneMapped': !unlit,
          'atmosphereColor': atmosphereRgb,
          'atmosphereStrength': atmosphereOpacity,
        },
      };
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

  /// Fixed product names for branded globe presets.
  /// Enum names stay unchanged to preserve stored preferences.
  static String? brandedGlobeName(GlobeVisualStyle style) {
    return switch (style) {
      GlobeVisualStyle.nightLights => 'Elias',
      GlobeVisualStyle.techNeon => 'Elena',
      _ => null,
    };
  }

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

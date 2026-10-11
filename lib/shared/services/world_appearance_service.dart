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

  // Cloud V2 uses one independent cloud-only layer for every Earth preset.
  // The Earth texture itself stays unchanged when clouds are enabled.
  static const String cloudLayerAsset =
      'assets/globe/earth_clouds_nasa_2048.jpg';

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
  final double webAmbientIntensity;
  final double webHemisphereIntensity;
  final double webSunIntensity;
  final int webSunRgb;
  final int cloudTintRgb;
  final int cloudEmissiveRgb;
  final double cloudEmissiveIntensity;
  final double cloudOpacityMin;
  final double cloudOpacityMax;
  final double cloudThresholdSparse;
  final double cloudThresholdDense;
  final double cloudShellScale;

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
    this.webAmbientIntensity = 0.28,
    this.webHemisphereIntensity = 0.34,
    this.webSunIntensity = 0.98,
    this.webSunRgb = 0xFFF1DC,
    // One neutral Natural cloud profile is shared by every Globe preset.
    // Presets remain distinct through Earth texture, light and atmosphere.
    this.cloudTintRgb = 0xF7FBFF,
    this.cloudEmissiveRgb = 0xF7FBFF,
    this.cloudEmissiveIntensity = 0.18,
    this.cloudOpacityMin = 0.42,
    this.cloudOpacityMax = 0.82,
    this.cloudThresholdSparse = 0.82,
    this.cloudThresholdDense = 0.12,
    this.cloudShellScale = 1.008,
  });

  String get shortLabel => code == 'D' || code == 'E' ? name : code;

  /// Kept for source compatibility with the V1 call sites/tests.
  /// Cloud V2 never mutates the approved Earth texture.
  String assetForClouds({required bool enabled}) => asset;

  static GlobePresetVisual forName(String name) {
    for (final style in WorldAppearanceService.selectableGlobeStyles) {
      if (style.name == name) return forStyle(style);
    }
    return forStyle(WorldAppearanceService.defaultGlobeStyle);
  }

  static GlobePresetVisual forStyle(GlobeVisualStyle style) {
    return switch (style) {
      // A — balanced daylight. Natural ocean/land colour remains the visual
      // anchor; atmosphere and clouds stay restrained and photographic.
      GlobeVisualStyle.classic => const GlobePresetVisual(
          code: 'A',
          name: 'Natural',
          asset: dayAsset,
          atmosphereRgb: 0x63B8FF,
          atmosphereOpacity: 0.16,
          atmosphereBlur: 16,
          atmosphereThickness: 0.0085,
          lightAngle: -30,
          lightIntensity: 1.08,
          ambientLight: 0.62,
          webEmissiveIntensity: 0.20,
          webShininess: 0.80,
          webAmbientIntensity: 0.26,
          webHemisphereIntensity: 0.34,
          webSunIntensity: 0.96,
          webSunRgb: 0xFFF3DF,
        ),

      // B — stronger terrain modelling and lower ambient fill. This is the
      // most sculpted daylight preset rather than another bright satellite.
      GlobeVisualStyle.realistic => const GlobePresetVisual(
          code: 'B',
          name: 'Relief',
          asset: satelliteAsset,
          atmosphereRgb: 0x82BAE8,
          atmosphereOpacity: 0.13,
          atmosphereBlur: 15,
          atmosphereThickness: 0.008,
          lightAngle: -46,
          lightIntensity: 1.44,
          ambientLight: 0.42,
          webEmissiveIntensity: 0.10,
          webShininess: 0.58,
          webAmbientIntensity: 0.18,
          webHemisphereIntensity: 0.24,
          webSunIntensity: 1.12,
          webSunRgb: 0xFFE9CC,
        ),

      // C — clear, modern Social Vote blue. High ambient readability and a
      // cyan rim distinguish it from Relief/Satellite without recolouring land.
      GlobeVisualStyle.bright ||
      GlobeVisualStyle.minimalDay =>
        const GlobePresetVisual(
          code: 'C',
          name: 'Civic Blue',
          asset: satelliteAsset,
          atmosphereRgb: 0x43CFFF,
          atmosphereOpacity: 0.22,
          atmosphereBlur: 18,
          atmosphereThickness: 0.0105,
          lightAngle: -24,
          lightIntensity: 0.92,
          ambientLight: 0.80,
          webEmissiveIntensity: 0.34,
          webShininess: 0.44,
          webAmbientIntensity: 0.36,
          webHemisphereIntensity: 0.50,
          webSunIntensity: 0.78,
          webSunRgb: 0xE8F8FF,
        ),

      // D — Black Marble stays self-lit. The shared neutral cloud layer remains
      // readable above the night texture without changing Elias' identity.
      GlobeVisualStyle.nightLights => const GlobePresetVisual(
          code: 'D',
          name: 'Elias',
          asset: nightAsset,
          atmosphereRgb: 0x315C9A,
          atmosphereOpacity: 0.13,
          atmosphereBlur: 14,
          atmosphereThickness: 0.0075,
          unlit: true,
          ambientLight: 1.0,
          webEmissiveIntensity: 1.0,
          webShininess: 0.0,
          webAmbientIntensity: 0.08,
          webHemisphereIntensity: 0.10,
          webSunIntensity: 0.0,
          webSunRgb: 0xBFD8FF,
        ),

      // E — Elena keeps a neutral Earth texture and the same Natural clouds as
      // every other preset. Violet belongs only to the atmosphere/rim.
      GlobeVisualStyle.techNeon => const GlobePresetVisual(
          code: 'E',
          name: 'Elena',
          asset: dayAsset,
          atmosphereRgb: 0x9B7BFF,
          atmosphereOpacity: 0.21,
          atmosphereBlur: 20,
          atmosphereThickness: 0.0115,
          lightAngle: -20,
          lightIntensity: 0.96,
          ambientLight: 0.84,
          webEmissiveIntensity: 0.36,
          webShininess: 0.72,
          webAmbientIntensity: 0.38,
          webHemisphereIntensity: 0.42,
          webSunIntensity: 0.82,
          webSunRgb: 0xEEF6FF,
        ),

      // F — crisp observational satellite view. Lowest atmospheric veil and
      // strongest directional light keep it distinct from Relief/Civic Blue.
      GlobeVisualStyle.terrainRelief => const GlobePresetVisual(
          code: 'F',
          name: 'Satellite',
          asset: satelliteAsset,
          atmosphereRgb: 0x78A9C4,
          atmosphereOpacity: 0.10,
          atmosphereBlur: 13,
          atmosphereThickness: 0.007,
          lightAngle: -34,
          lightIntensity: 1.52,
          ambientLight: 0.36,
          webEmissiveIntensity: 0.05,
          webShininess: 1.80,
          webAmbientIntensity: 0.16,
          webHemisphereIntensity: 0.20,
          webSunIntensity: 1.18,
          webSunRgb: 0xFFF0D6,
        ),
    };
  }

  Map<String, Object?> webAppearance(
    String styleName, {
    bool cloudsEnabled = false,
    double cloudDensity = 0.42,
    double cloudSpeed = 0.22,
    int cloudDirection = 1,
  }) =>
      <String, Object?>{
        'visualStyle': styleName,
        'textureUrl': 'assets/$asset',
        'nightTextureUrl': 'assets/$nightAsset',
        'clouds': <String, Object?>{
          'enabled': cloudsEnabled,
          'textureUrl': 'assets/$cloudLayerAsset',
          'density': cloudDensity.clamp(0.0, 1.0),
          'speed': cloudSpeed.clamp(0.0, 1.0),
          'direction': cloudDirection < 0 ? -1 : 1,
          'tintColor': cloudTintRgb,
          'emissiveColor': cloudEmissiveRgb,
          'emissiveIntensity': cloudEmissiveIntensity,
          'opacityMin': cloudOpacityMin,
          'opacityMax': cloudOpacityMax,
          'thresholdSparse': cloudThresholdSparse,
          'thresholdDense': cloudThresholdDense,
          'shellScale': cloudShellScale,
        },
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
          'ambientIntensity': webAmbientIntensity,
          'hemisphereIntensity': webHemisphereIntensity,
          'sunIntensity': webSunIntensity,
          'sunColor': webSunRgb,
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

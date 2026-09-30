import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:sociale_vote/shared/branding/social_vote_brand_assets.dart';
import 'package:sociale_vote/shared/services/brand_header_mode_service.dart';

import 'social_vote_header_web_image_stub.dart'
    if (dart.library.html) 'social_vote_header_web_image_web.dart';

/// Canonical Social Vote header.
///
/// OFF     = clean master.
/// GLOW    = stable neon illumination.
/// PULSE   = smooth neon breathing.
/// FLICKER = restrained neon intensity variation; the base logo never hides.
class SocialVoteHeaderBrand extends StatefulWidget {
  static const String lockupAsset = SocialVoteBrandAssets.headerLockup;
  static const String glowAsset = SocialVoteBrandAssets.headerGlowLockup;
  static const double _assetAspectRatio = 2048 / 682;

  final double height;
  final SocialVoteBrandEffect? effect;

  /// Optional preview-only override used by Admin Center. Production header
  /// instances leave this null and continue to use the backend-authoritative
  /// BrandHeaderModeService values.
  final double? flickerIntensityOverride;
  final double? flickerSpeedMultiplierOverride;

  const SocialVoteHeaderBrand({
    super.key,
    this.height = 48,
    this.effect,
    this.flickerIntensityOverride,
    this.flickerSpeedMultiplierOverride,
  });

  @override
  State<SocialVoteHeaderBrand> createState() => _SocialVoteHeaderBrandState();
}

class _SocialVoteHeaderBrandState extends State<SocialVoteHeaderBrand> {
  Timer? _timer;
  double _glowIntensity = 0.0;
  int _flickerStep = 0;

  final BrandHeaderModeService _brandHeaderMode =
      BrandHeaderModeService.instance;

  SocialVoteBrandEffect get _effect =>
      widget.effect ??
      switch (_brandHeaderMode.mode) {
        BrandHeaderMode.normal => SocialVoteBrandEffect.off,
        BrandHeaderMode.flicker => SocialVoteBrandEffect.flicker,
      };

  double get _effectiveFlickerIntensity =>
      (widget.flickerIntensityOverride ?? _brandHeaderMode.flickerIntensity)
          .clamp(0.0, 1.0)
          .toDouble();

  double get _effectiveFlickerSpeed => (widget.flickerSpeedMultiplierOverride ??
          _brandHeaderMode.flickerSpeedMultiplier)
      .clamp(0.5, 2.0)
      .toDouble();

  static const List<_FlickerStep> _flickerSteps = <_FlickerStep>[
    // Real neon rhythm: clearly ON, clearly OFF, then a short tube strike.
    // The clean master always stays visible underneath.
    _FlickerStep(Duration(milliseconds: 2600), 0.0),
    _FlickerStep(Duration(milliseconds: 1200), 1.0),
    _FlickerStep(Duration(milliseconds: 110), 0.0),
    _FlickerStep(Duration(milliseconds: 170), 1.0),
    _FlickerStep(Duration(milliseconds: 90), 0.18),
    _FlickerStep(Duration(milliseconds: 150), 1.0),
    _FlickerStep(Duration(milliseconds: 2400), 0.0),
    _FlickerStep(Duration(milliseconds: 1050), 1.0),
  ];

  @override
  void initState() {
    super.initState();
    _brandHeaderMode.addListener(_handleBrandHeaderModeChanged);
    unawaited(_brandHeaderMode.ensureLoaded());
    _configureEffect();
  }

  void _handleBrandHeaderModeChanged() {
    if (widget.effect != null) return;
    _configureEffect(rebuild: true);
  }

  @override
  void didUpdateWidget(covariant SocialVoteHeaderBrand oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.effect != widget.effect ||
        oldWidget.flickerIntensityOverride != widget.flickerIntensityOverride ||
        oldWidget.flickerSpeedMultiplierOverride !=
            widget.flickerSpeedMultiplierOverride) {
      _configureEffect(rebuild: true);
    }
  }

  void _configureEffect({bool rebuild = false}) {
    _timer?.cancel();
    _timer = null;
    _flickerStep = 0;

    switch (_effect) {
      case SocialVoteBrandEffect.off:
        _glowIntensity = 0.0;

      case SocialVoteBrandEffect.steadyGlow:
        _glowIntensity = 1.0;

      case SocialVoteBrandEffect.pulse:
        _glowIntensity = 0.62;
        _timer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
          if (!mounted || _effect != SocialVoteBrandEffect.pulse) return;
          setState(() {
            _glowIntensity = _glowIntensity > 0.80 ? 0.62 : 1.0;
          });
        });

      case SocialVoteBrandEffect.flicker:
        _glowIntensity = 0.0;
        _scheduleNextFlicker();
    }

    if (rebuild && mounted) {
      setState(() {});
    }
  }

  void _scheduleNextFlicker() {
    final step = _flickerSteps[_flickerStep];
    final speed = _effectiveFlickerSpeed;
    final scaledMilliseconds =
        (step.delay.inMilliseconds / speed).round().clamp(40, 6000).toInt();
    final delay = Duration(milliseconds: scaledMilliseconds);

    _timer = Timer(delay, () {
      if (!mounted || _effect != SocialVoteBrandEffect.flicker) return;

      setState(() {
        _glowIntensity = (step.intensity * _effectiveFlickerIntensity)
            .clamp(0.0, 1.0)
            .toDouble();
      });

      _flickerStep = (_flickerStep + 1) % _flickerSteps.length;
      _scheduleNextFlicker();
    });
  }

  Widget _nativeImage(String assetPath) {
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      alignment: AlignmentDirectional.centerStart,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final snappedHeight =
        (widget.height * devicePixelRatio).roundToDouble() / devicePixelRatio;

    final glowTransitionDuration = switch (_effect) {
      SocialVoteBrandEffect.pulse => const Duration(milliseconds: 900),
      SocialVoteBrandEffect.flicker => const Duration(milliseconds: 55),
      _ => const Duration(milliseconds: 180),
    };

    final header = kIsWeb
        ? SocialVoteHeaderWebImage(
            assetPath: SocialVoteHeaderBrand.lockupAsset,
            glowIntensity: _glowIntensity,
          )
        : Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _nativeImage(SocialVoteHeaderBrand.lockupAsset),
              AnimatedOpacity(
                opacity: _glowIntensity,
                duration: glowTransitionDuration,
                curve: Curves.easeOutCubic,
                child: _nativeImage(SocialVoteHeaderBrand.glowAsset),
              ),
            ],
          );

    return Semantics(
      label: 'Social Vote',
      header: true,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: SizedBox(
            width: snappedHeight * SocialVoteHeaderBrand._assetAspectRatio,
            height: snappedHeight,
            child: header,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _brandHeaderMode.removeListener(_handleBrandHeaderModeChanged);
    _timer?.cancel();
    super.dispose();
  }
}

class _FlickerStep {
  final Duration delay;
  final double intensity;

  const _FlickerStep(this.delay, this.intensity);
}

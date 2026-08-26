import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sociale_vote/shared/services/world_appearance_service.dart';

/// Resolution-independent premium visuals shared by Home and Settings.
/// No data, GeoScope or playback logic lives here.
class PremiumGramophoneVisual extends StatelessWidget {
  final RadioVisualStyle style;
  final bool active;
  final bool loading;
  final double size;

  const PremiumGramophoneVisual({
    super.key,
    required this.style,
    this.active = false,
    this.loading = false,
    this.size = 112,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _PremiumGramophonePainter(
            style: style,
            active: active,
            loading: loading,
            darkSurface: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }
}

class PremiumRadioControlVisual extends StatelessWidget {
  final RadioVisualStyle style;
  final bool active;
  final bool loading;
  final double size;

  const PremiumRadioControlVisual({
    super.key,
    required this.style,
    this.active = false,
    this.loading = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _RadioControlPalette.forStyle(
      context,
      style,
      active: active,
    );

    return SizedBox.square(
      dimension: size,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: palette.gradient,
          color: palette.gradient == null ? palette.background : null,
          border: Border.all(color: palette.border, width: palette.borderWidth),
          boxShadow: palette.shadows,
        ),
        alignment: Alignment.center,
        child: loading
            ? SizedBox.square(
                dimension: size * 0.38,
                child: CircularProgressIndicator(
                  strokeWidth: math.max(1.7, size * 0.04).toDouble(),
                  color: palette.foreground,
                ),
              )
            : Icon(
                _radioIcon(style),
                size: size * 0.48,
                color: palette.foreground,
              ),
      ),
    );
  }

  static IconData _radioIcon(RadioVisualStyle style) {
    return switch (style) {
      RadioVisualStyle.vintageClassic => Icons.music_note_rounded,
      RadioVisualStyle.oldStyle => Icons.radio_rounded,
      RadioVisualStyle.retroElegant => Icons.equalizer_rounded,
      RadioVisualStyle.woodMinimal => Icons.graphic_eq_rounded,
      RadioVisualStyle.modernVintage => Icons.headphones_rounded,
      RadioVisualStyle.steampunk => Icons.album_rounded,
      RadioVisualStyle.minimalChic => Icons.waves_rounded,
    };
  }
}

class PremiumGlobePreview extends StatelessWidget {
  final GlobeVisualStyle style;
  final double size;

  const PremiumGlobePreview({super.key, required this.style, this.size = 154});

  @override
  Widget build(BuildContext context) {
    final config = _GlobePreviewConfig.forStyle(style);

    Widget earth = ClipOval(
      child: Image.asset(
        config.asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        alignment: const Alignment(0.0, 0.02),
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: config.fallback),
          ),
        ),
      ),
    );

    if (config.colorFilter != null) {
      earth = ColorFiltered(colorFilter: config.colorFilter!, child: earth);
    }

    return SizedBox.square(
      dimension: size + 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size + 10,
            height: size + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: config.glow.withValues(alpha: 0.30),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: config.rim.withValues(alpha: 0.76),
                width: 1.4,
              ),
            ),
            child: earth,
          ),
          if (style == GlobeVisualStyle.techNeon)
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _NeonLatitudePainter(color: Color(0xFFB565FF)),
                ),
              ),
            ),
          if (style == GlobeVisualStyle.minimalDay)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE9F7F7).withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PremiumRotationPreview extends StatelessWidget {
  final GlobeRotationVisualStyle style;
  final bool active;
  final double size;

  const PremiumRotationPreview({
    super.key,
    required this.style,
    this.active = true,
    this.size = 58,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _RotationVisualPalette.forStyle(
      context,
      style,
      active: active,
    );

    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: palette.gradient,
            color: palette.gradient == null ? palette.background : null,
            border: Border.all(
              color: palette.border,
              width: palette.borderWidth,
            ),
            boxShadow: palette.shadows,
          ),
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size.square(size * 0.52),
            painter: _PremiumCircularArrowPainter(
              color: palette.foreground,
              strokeWidth: math.max(2.0, size * 0.045).toDouble(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumGramophonePainter extends CustomPainter {
  final RadioVisualStyle style;
  final bool active;
  final bool loading;
  final bool darkSurface;

  const _PremiumGramophonePainter({
    required this.style,
    required this.active,
    required this.loading,
    required this.darkSurface,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = _GramophoneVisualPalette.forStyle(style, active: active);
    final scale = size.shortestSide / 112;
    canvas.save();
    canvas.scale(scale, scale);

    // Grounding shadow: gives the object physical weight without a container.
    canvas.drawOval(
      const Rect.fromLTWH(10, 94, 86, 9),
      Paint()
        ..color = Colors.black.withValues(alpha: darkSurface ? 0.34 : 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Cabinet body with real depth and polished wood/metal face.
    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(16, 68, 58, 27),
      const Radius.circular(7),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.bodyLight, p.body, p.bodyDark],
          stops: const [0, 0.48, 1],
        ).createShader(bodyRect.outerRect),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = p.edge,
    );

    // Cabinet inset / front plate.
    final front = RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, 74, 50, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(front, Paint()..color = p.front.withValues(alpha: 0.76));
    canvas.drawRRect(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = p.metal.withValues(alpha: 0.62),
    );

    // Fine cabinet lines; subtle, not cartoonish.
    for (final y in <double>[77, 86]) {
      canvas.drawLine(
        Offset(23, y),
        Offset(67, y),
        Paint()
          ..strokeWidth = 0.65
          ..color = p.edge.withValues(alpha: 0.36),
      );
    }

    // Turntable platter.
    canvas.drawOval(
      const Rect.fromLTWH(18, 62, 46, 12),
      Paint()
        ..shader = LinearGradient(
          colors: [p.metal, p.metalDark],
        ).createShader(const Rect.fromLTWH(18, 62, 46, 12)),
    );
    canvas.drawOval(
      const Rect.fromLTWH(23, 61, 34, 11),
      Paint()..color = p.record,
    );
    canvas.drawOval(
      const Rect.fromLTWH(26, 63, 28, 7),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = p.recordLine,
    );
    canvas.drawCircle(const Offset(40, 66.5), 2.1, Paint()..color = p.metal);

    // Tone arm.
    final arm = Path()
      ..moveTo(59, 66)
      ..quadraticBezierTo(67, 60, 64, 51)
      ..quadraticBezierTo(63, 45, 70, 42);
    canvas.drawPath(
      arm,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.2
        ..color = p.metalDark,
    );
    canvas.drawCircle(const Offset(70, 42), 2.4, Paint()..color = p.metal);

    // Horn neck.
    final neck = Path()
      ..moveTo(68, 42)
      ..cubicTo(71, 33, 72, 27, 78, 23)
      ..lineTo(83, 29)
      ..cubicTo(77, 33, 76, 39, 75, 46);
    canvas.drawPath(
      neck,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..color = p.hornDark,
    );
    canvas.drawPath(
      neck,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round
        ..color = p.hornMid,
    );

    // Horn, built from layered gradients and highlights.
    final horn = Path()
      ..moveTo(78, 25)
      ..cubicTo(84, 15, 94, 6, 108, 10)
      ..cubicTo(114, 20, 111, 34, 100, 43)
      ..cubicTo(90, 40, 83, 35, 78, 25)
      ..close();
    final hornBounds = horn.getBounds();
    canvas.drawPath(
      horn,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.70, -0.45),
          radius: 1.25,
          colors: [p.hornHighlight, p.hornMid, p.hornDark],
          stops: const [0.05, 0.48, 1],
        ).createShader(hornBounds),
    );
    canvas.drawPath(
      horn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..color = p.hornEdge,
    );

    // Bell rim and internal depth.
    final bell = Path()
      ..moveTo(106, 10)
      ..cubicTo(114, 14, 116, 25, 108, 38);
    canvas.drawPath(
      bell,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = p.hornRim,
    );
    canvas.drawArc(
      const Rect.fromLTWH(92, 12, 16, 25),
      -1.25,
      2.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = p.hornHighlight.withValues(alpha: 0.48),
    );

    // Hardware details vary by style so all seven models are genuinely distinct.
    if (style == RadioVisualStyle.steampunk) {
      _drawGear(canvas, const Offset(28, 82), 6, p.metal);
      _drawGear(canvas, const Offset(60, 82), 4.5, p.metalDark);
    } else if (style == RadioVisualStyle.modernVintage) {
      for (var i = 0; i < 4; i += 1) {
        final h = 3.0 + i * 1.8;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(26 + i * 6, 84 - h, 3, h),
            const Radius.circular(2),
          ),
          Paint()..color = const Color(0xFF57B7FF),
        );
      }
    } else if (style == RadioVisualStyle.minimalChic) {
      canvas.drawCircle(const Offset(45, 82), 3.1, Paint()..color = p.metal);
    } else {
      canvas.drawCircle(
        const Offset(29, 82),
        3.1,
        Paint()..color = p.metalDark,
      );
      canvas.drawCircle(const Offset(60, 82), 2.4, Paint()..color = p.metal);
    }

    if (active && !loading) {
      final wave = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.5
        ..color = p.wave;
      canvas.drawArc(
        const Rect.fromLTWH(101, 4, 9, 39),
        -0.88,
        1.58,
        false,
        wave,
      );
      canvas.drawArc(
        const Rect.fromLTWH(105, 0, 13, 47),
        -0.84,
        1.50,
        false,
        wave..color = p.wave.withValues(alpha: 0.56),
      );
    }

    canvas.restore();
  }

  void _drawGear(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = color;
    canvas.drawCircle(center, radius, paint);
    for (var i = 0; i < 8; i += 1) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        center + Offset(math.cos(a), math.sin(a)) * (radius - 1),
        center + Offset(math.cos(a), math.sin(a)) * (radius + 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumGramophonePainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.active != active ||
        oldDelegate.loading != loading ||
        oldDelegate.darkSurface != darkSurface;
  }
}

class _GramophoneVisualPalette {
  final Color body;
  final Color bodyLight;
  final Color bodyDark;
  final Color front;
  final Color edge;
  final Color metal;
  final Color metalDark;
  final Color hornHighlight;
  final Color hornMid;
  final Color hornDark;
  final Color hornEdge;
  final Color hornRim;
  final Color record;
  final Color recordLine;
  final Color wave;

  const _GramophoneVisualPalette({
    required this.body,
    required this.bodyLight,
    required this.bodyDark,
    required this.front,
    required this.edge,
    required this.metal,
    required this.metalDark,
    required this.hornHighlight,
    required this.hornMid,
    required this.hornDark,
    required this.hornEdge,
    required this.hornRim,
    required this.record,
    required this.recordLine,
    required this.wave,
  });

  static _GramophoneVisualPalette forStyle(
    RadioVisualStyle style, {
    required bool active,
  }) {
    return switch (style) {
      RadioVisualStyle.vintageClassic => const _GramophoneVisualPalette(
          body: Color(0xFF5A321F),
          bodyLight: Color(0xFF8E5935),
          bodyDark: Color(0xFF2B170F),
          front: Color(0xFF3C2015),
          edge: Color(0xFF1C0E09),
          metal: Color(0xFFE7BD67),
          metalDark: Color(0xFF8A5A24),
          hornHighlight: Color(0xFFFFE2A2),
          hornMid: Color(0xFFD5A04E),
          hornDark: Color(0xFF7A481E),
          hornEdge: Color(0xFF5A3215),
          hornRim: Color(0xFFF4CD78),
          record: Color(0xFF111216),
          recordLine: Color(0xFF41434A),
          wave: Color(0xFFEBC36F),
        ),
      RadioVisualStyle.oldStyle => const _GramophoneVisualPalette(
          body: Color(0xFF32221A),
          bodyLight: Color(0xFF594033),
          bodyDark: Color(0xFF160E0A),
          front: Color(0xFF241712),
          edge: Color(0xFF100907),
          metal: Color(0xFFB47B49),
          metalDark: Color(0xFF624023),
          hornHighlight: Color(0xFFD2A071),
          hornMid: Color(0xFF875437),
          hornDark: Color(0xFF3C251A),
          hornEdge: Color(0xFF26160F),
          hornRim: Color(0xFFB77A4D),
          record: Color(0xFF0D0E11),
          recordLine: Color(0xFF2D3035),
          wave: Color(0xFFB77A4D),
        ),
      RadioVisualStyle.retroElegant => const _GramophoneVisualPalette(
          body: Color(0xFFE4D7C2),
          bodyLight: Color(0xFFFFF7E7),
          bodyDark: Color(0xFF9E8765),
          front: Color(0xFFCDBA9C),
          edge: Color(0xFF8C7452),
          metal: Color(0xFFD5AC66),
          metalDark: Color(0xFF826338),
          hornHighlight: Color(0xFFFFF4D8),
          hornMid: Color(0xFFE0C08C),
          hornDark: Color(0xFF9A794B),
          hornEdge: Color(0xFF765832),
          hornRim: Color(0xFFD7B16E),
          record: Color(0xFF232429),
          recordLine: Color(0xFF55575F),
          wave: Color(0xFFDAB66F),
        ),
      RadioVisualStyle.woodMinimal => const _GramophoneVisualPalette(
          body: Color(0xFF76472E),
          bodyLight: Color(0xFFA76B45),
          bodyDark: Color(0xFF3B2318),
          front: Color(0xFF5C3624),
          edge: Color(0xFF352015),
          metal: Color(0xFFE3B56E),
          metalDark: Color(0xFF8D5C2E),
          hornHighlight: Color(0xFFF2D08D),
          hornMid: Color(0xFFBC7C3D),
          hornDark: Color(0xFF68401F),
          hornEdge: Color(0xFF4C2D18),
          hornRim: Color(0xFFE6BC72),
          record: Color(0xFF16171B),
          recordLine: Color(0xFF41434A),
          wave: Color(0xFFE2B46C),
        ),
      RadioVisualStyle.modernVintage => const _GramophoneVisualPalette(
          body: Color(0xFF151B25),
          bodyLight: Color(0xFF2C3543),
          bodyDark: Color(0xFF05080D),
          front: Color(0xFF0D121A),
          edge: Color(0xFF020305),
          metal: Color(0xFFE0B263),
          metalDark: Color(0xFF8D672F),
          hornHighlight: Color(0xFF64758A),
          hornMid: Color(0xFF283646),
          hornDark: Color(0xFF0A1018),
          hornEdge: Color(0xFFE0B263),
          hornRim: Color(0xFFE2BB72),
          record: Color(0xFF030406),
          recordLine: Color(0xFF343C48),
          wave: Color(0xFF58B8FF),
        ),
      RadioVisualStyle.steampunk => const _GramophoneVisualPalette(
          body: Color(0xFF34231A),
          bodyLight: Color(0xFF65402B),
          bodyDark: Color(0xFF120B08),
          front: Color(0xFF241711),
          edge: Color(0xFF0E0806),
          metal: Color(0xFFC8793E),
          metalDark: Color(0xFF70401F),
          hornHighlight: Color(0xFFE0A36B),
          hornMid: Color(0xFF8A5031),
          hornDark: Color(0xFF3F261A),
          hornEdge: Color(0xFF2A1710),
          hornRim: Color(0xFFD18A4C),
          record: Color(0xFF111216),
          recordLine: Color(0xFF413630),
          wave: Color(0xFFC8793E),
        ),
      RadioVisualStyle.minimalChic => const _GramophoneVisualPalette(
          body: Color(0xFFF0EAE0),
          bodyLight: Color(0xFFFFFFFF),
          bodyDark: Color(0xFFB5A88F),
          front: Color(0xFFE3D8C5),
          edge: Color(0xFFA99777),
          metal: Color(0xFFC5A066),
          metalDark: Color(0xFF806949),
          hornHighlight: Color(0xFFFFFFFF),
          hornMid: Color(0xFFE7DCC7),
          hornDark: Color(0xFFB0A083),
          hornEdge: Color(0xFF8B7B61),
          hornRim: Color(0xFFC8A56D),
          record: Color(0xFF2B2C31),
          recordLine: Color(0xFF62636A),
          wave: Color(0xFFB99861),
        ),
    };
  }
}

class _RadioControlPalette {
  final Color foreground;
  final Color background;
  final Color border;
  final double borderWidth;
  final Gradient? gradient;
  final List<BoxShadow> shadows;

  const _RadioControlPalette({
    required this.foreground,
    required this.background,
    required this.border,
    required this.borderWidth,
    required this.gradient,
    required this.shadows,
  });

  static _RadioControlPalette forStyle(
    BuildContext context,
    RadioVisualStyle style, {
    required bool active,
  }) {
    final c = Theme.of(context).colorScheme;
    final shadow = c.shadow;

    return switch (style) {
      RadioVisualStyle.vintageClassic => _RadioControlPalette(
          foreground: active ? c.primary : c.onSurfaceVariant,
          background: c.surface.withValues(alpha: 0.96),
          border: active ? c.primary : c.outline.withValues(alpha: 0.55),
          borderWidth: active ? 2 : 1.2,
          gradient: null,
          shadows: [
            BoxShadow(
              color: shadow.withValues(alpha: active ? 0.20 : 0.10),
              blurRadius: active ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      RadioVisualStyle.oldStyle => _RadioControlPalette(
          foreground: c.onSurface,
          background: Colors.transparent,
          border: c.outlineVariant.withValues(alpha: 0.75),
          borderWidth: 1,
          gradient: null,
          shadows: const [],
        ),
      RadioVisualStyle.retroElegant => _RadioControlPalette(
          foreground:
              active ? const Color(0xFF7B4E16) : const Color(0xFF8C6B3D),
          background: const Color(0xFFFFF6E7),
          border: const Color(0xFFD5B27A),
          borderWidth: active ? 1.8 : 1.1,
          gradient: null,
          shadows: [
            BoxShadow(
              color: const Color(0xFF8C6B3D).withValues(alpha: 0.16),
              blurRadius: 8,
            ),
          ],
        ),
      RadioVisualStyle.woodMinimal => _RadioControlPalette(
          foreground: const Color(0xFFF0C47B),
          background: const Color(0xFF332219),
          border: const Color(0xFF9B673C),
          borderWidth: 1.2,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF583A28), Color(0xFF241811)],
          ),
          shadows: [
            BoxShadow(
              color: const Color(0xFF241811).withValues(alpha: 0.24),
              blurRadius: 8,
            ),
          ],
        ),
      RadioVisualStyle.modernVintage => _RadioControlPalette(
          foreground:
              active ? const Color(0xFF6CC6FF) : const Color(0xFF9CB3C8),
          background: const Color(0xFF111822),
          border: active ? const Color(0xFF58B8FF) : const Color(0xFF445467),
          borderWidth: active ? 1.8 : 1.1,
          gradient: null,
          shadows: [
            BoxShadow(
              color: const Color(
                0xFF58B8FF,
              ).withValues(alpha: active ? 0.30 : 0.10),
              blurRadius: active ? 12 : 7,
            ),
          ],
        ),
      RadioVisualStyle.steampunk => _RadioControlPalette(
          foreground: const Color(0xFFF0B16E),
          background: const Color(0xFF281A13),
          border: const Color(0xFFC8793E),
          borderWidth: 1.3,
          gradient: const RadialGradient(
            colors: [Color(0xFF4D2E1D), Color(0xFF21140F)],
          ),
          shadows: [
            BoxShadow(
              color: const Color(
                0xFFC8793E,
              ).withValues(alpha: active ? 0.30 : 0.14),
              blurRadius: active ? 12 : 7,
            ),
          ],
        ),
      RadioVisualStyle.minimalChic => _RadioControlPalette(
          foreground: active ? c.primary : c.onSurfaceVariant,
          background: c.surface.withValues(alpha: 0.58),
          border: c.outline.withValues(alpha: 0.36),
          borderWidth: 1.1,
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.18),
              c.surface.withValues(alpha: 0.24),
            ],
          ),
          shadows: [
            BoxShadow(color: shadow.withValues(alpha: 0.08), blurRadius: 12),
          ],
        ),
    };
  }
}

class _GlobePreviewConfig {
  final String asset;
  final Color glow;
  final Color rim;
  final List<Color> fallback;
  final ColorFilter? colorFilter;

  const _GlobePreviewConfig({
    required this.asset,
    required this.glow,
    required this.rim,
    required this.fallback,
    this.colorFilter,
  });

  static _GlobePreviewConfig forStyle(GlobeVisualStyle style) {
    const day = 'assets/globe/earth_day_nasa_blue_marble_2048.png';
    const realistic = 'assets/globe/earth_day_nasa_bmng_august_4096.jpg';
    const night = 'assets/globe/earth_night_nasa_black_marble_2016_3600.jpg';

    return switch (style) {
      GlobeVisualStyle.classic => const _GlobePreviewConfig(
          asset: day,
          glow: Color(0xFF376FA9),
          rim: Color(0xFFB8D6F3),
          fallback: [Color(0xFF4F8B62), Color(0xFF17395F)],
        ),
      GlobeVisualStyle.realistic => const _GlobePreviewConfig(
          asset: realistic,
          glow: Color(0xFF92764E),
          rim: Color(0xFFD6C6A1),
          fallback: [Color(0xFF8A744B), Color(0xFF0C2744)],
        ),
      GlobeVisualStyle.bright => const _GlobePreviewConfig(
          asset: day,
          glow: Color(0xFF38A4FF),
          rim: Color(0xFF7ED0FF),
          fallback: [Color(0xFF60B77A), Color(0xFF257DD4)],
          colorFilter: ColorFilter.mode(Color(0x334AB8FF), BlendMode.screen),
        ),
      GlobeVisualStyle.nightLights => const _GlobePreviewConfig(
          asset: night,
          glow: Color(0xFFF2B84C),
          rim: Color(0xFFE1BE72),
          fallback: [Color(0xFFF2B84C), Color(0xFF071326)],
        ),
      GlobeVisualStyle.techNeon => const _GlobePreviewConfig(
          asset: night,
          glow: Color(0xFFB552FF),
          rim: Color(0xFFB565FF),
          fallback: [Color(0xFF9A5BFF), Color(0xFF111738)],
          colorFilter: ColorFilter.mode(Color(0x55372F9D), BlendMode.color),
        ),
      GlobeVisualStyle.minimalDay => const _GlobePreviewConfig(
          asset: day,
          glow: Color(0xFF79C8D3),
          rim: Color(0xFFA4DCE4),
          fallback: [Color(0xFFE8E1B8), Color(0xFF8FD0E5)],
          colorFilter: ColorFilter.mode(Color(0x66D8F2ED), BlendMode.screen),
        ),
    };
  }
}

class _NeonLatitudePainter extends CustomPainter {
  final Color color;
  const _NeonLatitudePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = color.withValues(alpha: 0.42);
    final rect = Rect.fromLTWH(9, 9, size.width - 18, size.height - 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: rect.center,
        width: rect.width,
        height: rect.height * 0.38,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: rect.center,
        width: rect.width * 0.45,
        height: rect.height,
      ),
      paint,
    );
    canvas.drawCircle(
      rect.center,
      rect.width / 2,
      paint..color = color.withValues(alpha: 0.26),
    );
  }

  @override
  bool shouldRepaint(covariant _NeonLatitudePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _RotationVisualPalette {
  final Color foreground;
  final Color background;
  final Color border;
  final double borderWidth;
  final Gradient? gradient;
  final List<BoxShadow> shadows;

  const _RotationVisualPalette({
    required this.foreground,
    required this.background,
    required this.border,
    required this.borderWidth,
    required this.gradient,
    required this.shadows,
  });

  static _RotationVisualPalette forStyle(
    BuildContext context,
    GlobeRotationVisualStyle style, {
    required bool active,
  }) {
    final c = Theme.of(context).colorScheme;
    return switch (style) {
      GlobeRotationVisualStyle.classic => _RotationVisualPalette(
          foreground: active ? c.primary : c.onSurfaceVariant,
          background: c.surface,
          border: active ? c.primary : c.outlineVariant,
          borderWidth: 1.6,
          gradient: null,
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      GlobeRotationVisualStyle.minimal => _RotationVisualPalette(
          foreground: c.onSurface,
          background: Colors.transparent,
          border: c.outlineVariant,
          borderWidth: 1,
          gradient: null,
          shadows: const [],
        ),
      GlobeRotationVisualStyle.subtle => _RotationVisualPalette(
          foreground: c.onSurfaceVariant,
          background: c.surfaceContainerLow.withValues(alpha: 0.76),
          border: c.outlineVariant.withValues(alpha: 0.45),
          borderWidth: 1,
          gradient: null,
          shadows: const [],
        ),
      GlobeRotationVisualStyle.neon => _RotationVisualPalette(
          foreground: const Color(0xFFE5A3FF),
          background: const Color(0xFF151124),
          border: const Color(0xFFB84DFF),
          borderWidth: 1.5,
          gradient: null,
          shadows: [
            BoxShadow(
              color: const Color(0xFFB84DFF).withValues(alpha: 0.34),
              blurRadius: 14,
            ),
          ],
        ),
      GlobeRotationVisualStyle.filled => const _RotationVisualPalette(
          foreground: Color(0xFF2A1B0C),
          background: Color(0xFFD6A44D),
          border: Color(0xFFF0C777),
          borderWidth: 1.4,
          gradient: LinearGradient(
            colors: [Color(0xFFF0C777), Color(0xFFB97921)],
          ),
          shadows: [BoxShadow(color: Color(0x55B97921), blurRadius: 12)],
        ),
      GlobeRotationVisualStyle.glass => _RotationVisualPalette(
          foreground: c.onSurface,
          background: c.surface.withValues(alpha: 0.50),
          border: Colors.white.withValues(alpha: 0.40),
          borderWidth: 1,
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.18),
              c.surface.withValues(alpha: 0.24),
            ],
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
            ),
          ],
        ),
      GlobeRotationVisualStyle.premium => const _RotationVisualPalette(
          foreground: Color(0xFFFFD991),
          background: Color(0xFF19130E),
          border: Color(0xFFD9A64D),
          borderWidth: 1.5,
          gradient: RadialGradient(
            colors: [Color(0xFF332416), Color(0xFF110D09)],
          ),
          shadows: [BoxShadow(color: Color(0x66D9A64D), blurRadius: 16)],
        ),
    };
  }
}

class _PremiumCircularArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _PremiumCircularArrowPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -2.75,
      4.65,
      false,
      paint,
    );
    const tipAngle = 1.90;
    final tip =
        center + Offset(math.cos(tipAngle), math.sin(tipAngle)) * radius;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - 6, tip.dy - 1)
      ..lineTo(tip.dx - 1, tip.dy - 6)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PremiumCircularArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

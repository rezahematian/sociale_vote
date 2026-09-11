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
    final appearance = WorldAppearanceService.instance;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: WorldRoundControl(
          icon: _radioIcon(style), label: 'Radio', active: active,
          loading: loading, globeStyle: appearance.globeStyle,
          visualStyle: appearance.rotationStyle, onTap: null, size: size,
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

/// A bounded texture preview of the same family used by the live renderers.
/// No independent recolouring or decorative network layer is applied here.
class PremiumGlobePreview extends StatelessWidget {
  final GlobeVisualStyle style;
  final double size;

  const PremiumGlobePreview({super.key, required this.style, this.size = 154});

  @override
  Widget build(BuildContext context) {
    final preset = GlobePresetVisual.forStyle(style);
    final rim = Color(0xFF000000 | preset.atmosphereRgb);
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: rim.withValues(alpha: preset.atmosphereOpacity),
                blurRadius: size * 0.16,
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  preset.asset,
                  cacheWidth: math.max(96,
                    (size * MediaQuery.devicePixelRatioOf(context)).ceil()),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
                if (!preset.unlit)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 1 - preset.ambientLight),
                        ],
                      ),
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: rim.withValues(alpha: 0.50)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home-only sizing; content and gestures remain in the existing globe widget.
class WorldHomeGlobeGeometry {
  static const double controlSize = 48;
  static const double controlInset = 12;
  // PerspectiveCamera fov=38 degrees, Home distance=3.50, Earth radius=1.
  static const double webSphereFraction = 0.865868392463662;

  static double frameSize(double width, double height) =>
      math.max(1.0, math.min(width, height) - 4);

  static double sphereDiameter(double width, double frame) => math.min(
        (width * 0.72).clamp(218.0, 390.0).toDouble(),
        frame * 0.86,
      );
}

/// Identical hit target, ink feedback, border, icon size and active-state
/// language for Radio and Rotate. Existing control-style preferences apply to
/// the pair; the globe supplies a restrained colour accent.
class WorldRoundControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool loading;
  final GlobeVisualStyle globeStyle;
  final GlobeRotationVisualStyle visualStyle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;

  const WorldRoundControl({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.globeStyle,
    required this.visualStyle,
    required this.onTap,
    this.onLongPress,
    this.loading = false,
    this.size = WorldHomeGlobeGeometry.controlSize,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _RotationVisualPalette.forStyle(context, visualStyle,
        active: active);
    final accent = Color(0xFF000000 |
        GlobePresetVisual.forStyle(globeStyle).atmosphereRgb);
    final foreground = active ? accent : palette.foreground;
    return Semantics(
      button: true,
      toggled: active,
      label: label,
      child: Tooltip(
        message: label,
        child: SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: palette.shadows,
            ),
            child: Material(
              color: palette.background,
              clipBehavior: Clip.antiAlias,
              shape: CircleBorder(side: BorderSide(
                color: active ? accent : palette.border,
                width: palette.borderWidth,
              )),
              child: Ink(
                decoration: BoxDecoration(gradient: palette.gradient),
                child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: accent.withValues(alpha: 0.22),
                hoverColor: accent.withValues(alpha: 0.12),
                focusColor: accent.withValues(alpha: 0.16),
                onTap: loading ? null : onTap,
                onLongPress: loading ? null : onLongPress,
                child: Center(
                  child: loading
                      ? SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: foreground),
                        )
                      : Icon(icon, size: 24, color: foreground),
                ),
              ),
              ),
            ),
          ),
        ),
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
    return IgnorePointer(
      child: ExcludeSemantics(
        child: WorldRoundControl(
          icon: Icons.rotate_right_rounded, label: 'Rotate', active: active,
          globeStyle: WorldAppearanceService.instance.globeStyle,
          visualStyle: style, onTap: null, size: size,
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


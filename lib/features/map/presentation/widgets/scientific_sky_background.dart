import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// GPU-rendered celestial sphere for Social Vote.
///
/// Data source:
/// ESA/Gaia/DPAC — Gaia EDR3 all-sky colour map, equirectangular projection.
/// Licence: CC BY-SA 3.0 IGO.
/// Acknowledgement: A. Moitinho.
///
/// This v1 is scientifically grounded in two ways:
/// 1. the texture is a real all-sky astronomical dataset/visualisation;
/// 2. the texture is sampled as an equirectangular celestial sphere using
///    perspective rays, rather than being panned/tiled as a flat photograph.
///
/// The orientation supplied by WorldGlobeWidget is the inverse visual camera
/// attitude of the Earth renderer, so the sky reacts coherently when the user
/// rotates the globe.
///
/// This is not yet a full planetarium solution: v1 does not apply UTC,
/// observer position, precession/nutation or local sidereal time.
class ScientificSkyBackground extends StatefulWidget {
  static const String assetPath =
      'assets/globe/gaia_edr3_sky_equirectangular_2160.png';

  static const String credit = 'Gaia EDR3 · ESA/Gaia/DPAC · CC BY-SA 3.0 IGO';

  final ValueListenable<Offset> orientationListenable;
  final double fieldOfViewDegrees;
  final double exposure;

  const ScientificSkyBackground({
    super.key,
    required this.orientationListenable,
    this.fieldOfViewDegrees = 92.0,
    this.exposure = 0.82,
  });

  @override
  State<ScientificSkyBackground> createState() =>
      _ScientificSkyBackgroundState();
}

class _ScientificSkyBackgroundState extends State<ScientificSkyBackground> {
  ui.FragmentShader? _shader;
  ui.Image? _skyImage;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _loadWebImage();
    } else {
      _loadResources();
    }
  }

  Future<void> _loadWebImage() async {
    ui.Image? decodedImage;

    try {
      final data = await rootBundle.load(ScientificSkyBackground.assetPath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        ),
      );

      final frame = await codec.getNextFrame();
      decodedImage = frame.image;
      codec.dispose();

      if (!mounted) {
        decodedImage.dispose();
        return;
      }

      setState(() {
        _skyImage = decodedImage;
        _loadError = null;
      });
    } catch (error) {
      decodedImage?.dispose();

      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error;
      });

      if (kDebugMode) {
        debugPrint('[ScientificSky Web] image load failed: $error');
      }
    }
  }

  Future<void> _loadResources() async {
    ui.Image? decodedImage;
    ui.FragmentShader? shader;

    try {
      final results = await Future.wait<Object>([
        ui.FragmentProgram.fromAsset('shaders/scientific_sky.frag'),
        rootBundle.load(ScientificSkyBackground.assetPath),
      ]);

      final program = results[0] as ui.FragmentProgram;
      final data = results[1] as ByteData;

      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        ),
      );

      final frame = await codec.getNextFrame();
      decodedImage = frame.image;
      codec.dispose();

      shader = program.fragmentShader();
      shader.setImageSampler(
        0,
        decodedImage,
        filterQuality: ui.FilterQuality.medium,
      );

      if (!mounted) {
        shader.dispose();
        decodedImage.dispose();
        return;
      }

      setState(() {
        _shader = shader;
        _skyImage = decodedImage;
        _loadError = null;
      });
    } catch (error) {
      shader?.dispose();
      decodedImage?.dispose();

      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error;
      });

      if (kDebugMode) {
        debugPrint('[ScientificSky] load failed: $error');
      }
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    _skyImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Fragment shaders can lose their WebGL context behind the independent
      // Three.js globe. Web therefore draws the decoded Gaia image directly,
      // repeating it horizontally and moving it from the real globe attitude.
      // This preserves coherent sky motion without a second WebGL context.
      final skyImage = _skyImage;
      if (skyImage == null || _loadError != null) {
        return const ColoredBox(color: Color(0xFF02040A));
      }

      return ValueListenableBuilder<Offset>(
        valueListenable: widget.orientationListenable,
        builder: (context, orientation, _) {
          return RepaintBoundary(
            child: CustomPaint(
              painter: _WebScientificSkyPainter(
                skyImage: skyImage,
                yaw: orientation.dx,
                pitch: orientation.dy,
                exposure: widget.exposure,
              ),
              isComplex: true,
              willChange: true,
              size: Size.infinite,
            ),
          );
        },
      );
    }

    final shader = _shader;

    if (shader == null || _loadError != null) {
      return const ColoredBox(
        color: Color(0xFF02040A),
      );
    }

    return ValueListenableBuilder<Offset>(
      valueListenable: widget.orientationListenable,
      builder: (context, orientation, _) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: _ScientificSkyPainter(
              shader: shader,
              yaw: orientation.dx,
              pitch: orientation.dy,
              fieldOfViewRadians: widget.fieldOfViewDegrees * math.pi / 180.0,
              exposure: widget.exposure,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _WebScientificSkyPainter extends CustomPainter {
  final ui.Image skyImage;
  final double yaw;
  final double pitch;
  final double exposure;

  const _WebScientificSkyPainter({
    required this.skyImage,
    required this.yaw,
    required this.pitch,
    required this.exposure,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF02040A),
    );

    final sourceSize = Size(
      skyImage.width.toDouble(),
      skyImage.height.toDouble(),
    );

    // Overscan keeps the viewport covered while pitch follows the globe.
    final coverScale = math.max(
      size.width / sourceSize.width,
      size.height / sourceSize.height,
    );
    final scale = coverScale * 1.18;
    final destinationWidth = sourceSize.width * scale;
    final destinationHeight = sourceSize.height * scale;

    // Matches the native shader convention: positive globe yaw moves the
    // celestial texture right, so the visible centre samples inverse yaw.
    final yawShift = yaw / (math.pi * 2.0) * destinationWidth;
    final baseLeft = (size.width - destinationWidth) * 0.5 + yawShift;
    var tileLeft = baseLeft % destinationWidth;
    if (tileLeft > 0.0) {
      tileLeft -= destinationWidth;
    }

    final baseTop = (size.height - destinationHeight) * 0.5;
    final requestedTop =
        baseTop + (pitch / math.pi * destinationHeight);
    final top = requestedTop
        .clamp(size.height - destinationHeight, 0.0)
        .toDouble();

    final opacity = (0.55 + exposure * 0.45).clamp(0.35, 1.0).toDouble();
    final imagePaint = Paint()
      ..filterQuality = ui.FilterQuality.medium
      ..color = Color.fromRGBO(255, 255, 255, opacity);

    final sourceRect = Offset.zero & sourceSize;
    while (tileLeft < size.width) {
      final destinationRect = Rect.fromLTWH(
        tileLeft,
        top,
        destinationWidth,
        destinationHeight,
      );

      canvas.drawImageRect(
        skyImage,
        sourceRect,
        destinationRect,
        imagePaint,
      );

      tileLeft += destinationWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _WebScientificSkyPainter oldDelegate) {
    return skyImage != oldDelegate.skyImage ||
        (yaw - oldDelegate.yaw).abs() > 0.0005 ||
        (pitch - oldDelegate.pitch).abs() > 0.0005 ||
        (exposure - oldDelegate.exposure).abs() > 0.0005;
  }
}

class _ScientificSkyPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double yaw;
  final double pitch;
  final double fieldOfViewRadians;
  final double exposure;

  const _ScientificSkyPainter({
    required this.shader,
    required this.yaw,
    required this.pitch,
    required this.fieldOfViewRadians,
    required this.exposure,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    // Float uniforms follow GLSL declaration order; sampler uniforms are
    // indexed independently and were bound once when the resource loaded.
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, yaw)
      ..setFloat(3, pitch)
      ..setFloat(4, fieldOfViewRadians)
      ..setFloat(5, exposure);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _ScientificSkyPainter oldDelegate) {
    return (yaw - oldDelegate.yaw).abs() > 0.0005 ||
        (pitch - oldDelegate.pitch).abs() > 0.0005 ||
        (fieldOfViewRadians - oldDelegate.fieldOfViewRadians).abs() > 0.0005 ||
        (exposure - oldDelegate.exposure).abs() > 0.0005 ||
        shader != oldDelegate.shader;
  }
}

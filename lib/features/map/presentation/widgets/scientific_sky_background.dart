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
    _loadResources();
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

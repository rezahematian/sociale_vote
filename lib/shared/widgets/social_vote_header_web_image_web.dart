import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:web/web.dart' as web;

/// Web-only renderer for the Social Vote header.
///
/// The same native HTML image stays mounted at every neon intensity. Only its
/// CSS filter changes, so flicker never swaps or hides the logo bitmap.
class SocialVoteHeaderWebImage extends StatefulWidget {
  final String assetPath;
  final double glowIntensity;

  const SocialVoteHeaderWebImage({
    super.key,
    required this.assetPath,
    required this.glowIntensity,
  });

  @override
  State<SocialVoteHeaderWebImage> createState() =>
      _SocialVoteHeaderWebImageState();
}

class _SocialVoteHeaderWebImageState extends State<SocialVoteHeaderWebImage> {
  web.HTMLImageElement? _image;

  @override
  void didUpdateWidget(covariant SocialVoteHeaderWebImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assetPath != widget.assetPath && _image != null) {
      _image!.src = 'assets/${widget.assetPath}';
    }
    if (oldWidget.glowIntensity != widget.glowIntensity) {
      _applyVisualState();
    }
  }

  void _applyVisualState() {
    final image = _image;
    if (image == null) return;

    final intensity = widget.glowIntensity.clamp(0.0, 1.0);
    final style = image.style;

    style.setProperty(
      'transition',
      'filter 55ms cubic-bezier(0.22, 1, 0.36, 1)',
    );

    if (intensity <= 0.001) {
      style.setProperty('filter', 'none');
      return;
    }

    final brightness = (1.0 + (0.12 * intensity)).toStringAsFixed(3);
    final saturation = (1.0 + (0.18 * intensity)).toStringAsFixed(3);
    final whiteAlpha = (0.20 * intensity).toStringAsFixed(3);
    final cyanAlpha = (0.32 * intensity).toStringAsFixed(3);
    final violetAlpha = (0.24 * intensity).toStringAsFixed(3);
    final tightBlur = (1.2 + (2.0 * intensity)).toStringAsFixed(1);
    final mediumBlur = (3.0 + (4.5 * intensity)).toStringAsFixed(1);
    final wideBlur = (5.0 + (6.5 * intensity)).toStringAsFixed(1);

    style.setProperty(
      'filter',
      'brightness($brightness) '
          'saturate($saturation) '
          'drop-shadow(0 0 ${tightBlur}px rgba(255,255,255,$whiteAlpha)) '
          'drop-shadow(0 0 ${mediumBlur}px rgba(55,210,255,$cyanAlpha)) '
          'drop-shadow(0 0 ${wideBlur}px rgba(183,70,255,$violetAlpha))',
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'img',
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
      onElementCreated: (Object element) {
        final image = element as web.HTMLImageElement;
        _image = image;

        image
          ..src = 'assets/${widget.assetPath}'
          ..alt = ''
          ..draggable = false;

        image.style
          ..width = '100%'
          ..height = '100%'
          ..display = 'block'
          ..objectFit = 'contain'
          ..objectPosition = 'left center'
          ..pointerEvents = 'none'
          ..userSelect = 'none'
          ..imageRendering = 'auto';

        _applyVisualState();
      },
    );
  }
}

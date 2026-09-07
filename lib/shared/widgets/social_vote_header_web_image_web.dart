import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:web/web.dart' as web;

/// Web-only renderer for the frozen Social Vote header PNG.
///
/// A native HTML image keeps browser zoom tied to the original source pixels
/// instead of zooming a previously rasterized Flutter canvas layer.
class SocialVoteHeaderWebImage extends StatelessWidget {
  final String assetPath;

  const SocialVoteHeaderWebImage({
    super.key,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'img',
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
      onElementCreated: (Object element) {
        final image = element as web.HTMLImageElement;
        image
          ..src = 'assets/$assetPath'
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
      },
    );
  }
}

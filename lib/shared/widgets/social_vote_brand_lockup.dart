import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'social_vote_header_web_image_stub.dart'
    if (dart.library.html) 'social_vote_header_web_image_web.dart';

/// Single runtime Social Vote lockup for the global Home header.
///
/// The whole mark (symbol + coloured Social Vote wordmark) is one frozen,
/// transparent PNG so Flutter cannot substitute typography or recolour it.
///
/// On Web the exact PNG is rendered by the browser as a native <img> element.
/// This avoids enlarging a CanvasKit/WebGL raster snapshot when the browser is
/// zoomed and lets Chrome resample the original 2095x496 source directly.
/// Android/other Flutter targets keep the normal high-quality Image.asset path.
class SocialVoteHeaderBrand extends StatelessWidget {
  static const String lockupAsset =
      'assets/branding/social_vote_header_neon_lockup.png';
  static const double _assetAspectRatio = 2095 / 496;

  final double height;

  const SocialVoteHeaderBrand({
    super.key,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final snappedHeight =
        (height * devicePixelRatio).roundToDouble() / devicePixelRatio;
    final width = snappedHeight * _assetAspectRatio;

    final image = kIsWeb
        ? const SocialVoteHeaderWebImage(assetPath: lockupAsset)
        : Image.asset(
            lockupAsset,
            fit: BoxFit.contain,
            alignment: AlignmentDirectional.centerStart,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
            gaplessPlayback: true,
            excludeFromSemantics: true,
          );

    return Semantics(
      label: 'Social Vote',
      header: true,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: SizedBox(
            width: width,
            height: snappedHeight,
            child: image,
          ),
        ),
      ),
    );
  }
}

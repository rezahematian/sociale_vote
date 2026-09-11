import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:sociale_vote/shared/branding/social_vote_brand_assets.dart';

import 'social_vote_header_web_image_stub.dart'
    if (dart.library.html) 'social_vote_header_web_image_web.dart';

/// One static, canonical lockup. Neon is suspended on every platform.
class SocialVoteHeaderBrand extends StatelessWidget {
  static const String lockupAsset = SocialVoteBrandAssets.headerLockup;
  static const double _assetAspectRatio = 2048 / 682;

  final double height;

  /// Retained for source compatibility; all effects are deliberately ignored.
  final SocialVoteBrandEffect? effect;

  const SocialVoteHeaderBrand({
    super.key,
    this.height = 48,
    this.effect,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final snappedHeight =
        (height * devicePixelRatio).roundToDouble() / devicePixelRatio;

    return Semantics(
      label: 'Social Vote',
      header: true,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: SizedBox(
            width: snappedHeight * _assetAspectRatio,
            height: snappedHeight,
            child: kIsWeb
                ? const SocialVoteHeaderWebImage(assetPath: lockupAsset)
                : Image.asset(
                    lockupAsset,
                    fit: BoxFit.contain,
                    alignment: AlignmentDirectional.centerStart,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                  ),
          ),
        ),
      ),
    );
  }
}

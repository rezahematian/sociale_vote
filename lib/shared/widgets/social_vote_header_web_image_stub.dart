import 'package:flutter/material.dart';

/// Non-Web compile-time stub. The actual Android/native header rendering is
/// handled by SocialVoteHeaderBrand; this keeps the conditional import typed.
class SocialVoteHeaderWebImage extends StatelessWidget {
  final String assetPath;
  final double glowIntensity;

  const SocialVoteHeaderWebImage({
    super.key,
    required this.assetPath,
    required this.glowIntensity,
  });

  @override
  Widget build(BuildContext context) {
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
}

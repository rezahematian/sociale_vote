import 'package:flutter/material.dart';

/// Non-Web compile-time stub. It is not selected at runtime when kIsWeb=false,
/// but keeps the conditional import type-safe for Android and other targets.
class SocialVoteHeaderWebImage extends StatelessWidget {
  final String assetPath;

  const SocialVoteHeaderWebImage({
    super.key,
    required this.assetPath,
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

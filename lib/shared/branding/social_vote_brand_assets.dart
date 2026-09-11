/// Social Vote global brand asset registry.
///
/// This file is the single Dart-level source of truth for official brand
/// runtime paths. Artwork refreshes must keep these stable filenames.
class SocialVoteBrandAssets {
  SocialVoteBrandAssets._();

  /// Symbol only: favicon, launcher, avatar, small icon.
  static const String symbol = 'assets/branding/social_vote_symbol_master.png';

  /// Canonical coloured horizontal lockup used by Home/App/Web headers.
  static const String headerLockup =
      'assets/branding/social_vote_header_lockup_master.png';

  /// Optional high-glow variant of the same approved horizontal lockup.
  static const String headerGlowLockup =
      'assets/branding/social_vote_header_neon_glow_lockup.png';

  /// Formal Social Vote signature for verified documents/certificates.
  /// The runtime file is the same approved coloured wordmark as headerLockup.
  static const String officialSignature =
      'assets/branding/social_vote_official_signature_master.png';

  /// Verified Result seal. Render only when report.hashValid == true.
  static const String verifiedResultSeal =
      'assets/branding/social_vote_verified_result_seal_master.png';
}

/// Optional presentation effect for the canonical Home header lockup.
///
/// [off] is the release-safe standard.
/// [steadyGlow] shows the approved glow asset continuously.
/// [pulse] fades the glow layer smoothly.
/// [flicker] produces a restrained neon-tube on/off sequence.
enum SocialVoteBrandEffect {
  off,
  steadyGlow,
  pulse,
  flicker,
}

/// One central switch for the Home header effect.
///
/// Neon is suspended. The header renderer is static even with an override.
/// Keep [SocialVoteBrandEffect.off] for the standard static brand.
class SocialVoteBrandPresentation {
  SocialVoteBrandPresentation._();

  static const SocialVoteBrandEffect homeHeaderEffect =
      SocialVoteBrandEffect.off;
}

import 'package:flutter/material.dart';
import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';

class UserIdentityMark extends StatelessWidget {
  final ActorType actorType;
  final VerificationLevel verificationLevel;
  final InstitutionLevel? institutionLevel;
  final double size;
  final bool showTooltip;

  const UserIdentityMark({
    super.key,
    required this.actorType,
    required this.verificationLevel,
    this.institutionLevel,
    this.size = 16,
    this.showTooltip = true,
  });

  factory UserIdentityMark.fromProfile(
    UserProfile profile, {
    Key? key,
    double size = 16,
    bool showTooltip = true,
  }) {
    return UserIdentityMark(
      key: key,
      actorType: profile.actorType,
      verificationLevel: profile.verificationLevel,
      institutionLevel: profile.institutionLevel,
      size: size,
      showTooltip: showTooltip,
    );
  }

  static bool shouldShowForProfile(UserProfile profile) {
    return shouldShow(
      actorType: profile.actorType,
      verificationLevel: profile.verificationLevel,
      institutionLevel: profile.institutionLevel,
    );
  }

  static bool shouldShow({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    InstitutionLevel? institutionLevel,
  }) {
    return _resolveMarkKind(
          actorType: actorType,
          verificationLevel: verificationLevel,
          institutionLevel: institutionLevel,
        ) !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    final kind = _resolveMarkKind(
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    );

    if (kind == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _paletteFor(kind, isDark: isDark);
    final markSize = size.clamp(12.0, 24.0);
    final iconSize = markSize * 0.72;

    Widget child = Container(
      width: markSize,
      height: markSize,
      decoration: BoxDecoration(
        color: palette.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: palette.borderColor,
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        _iconFor(kind),
        size: iconSize,
        color: palette.foregroundColor,
      ),
    );

    if (showTooltip) {
      child = Tooltip(
        message: _tooltipFor(kind),
        child: child,
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6),
      child: child,
    );
  }

  static _UserIdentityMarkKind? _resolveMarkKind({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    InstitutionLevel? institutionLevel,
  }) {
    if (actorType == ActorType.institution &&
        verificationLevel == VerificationLevel.level2 &&
        institutionLevel != null) {
      return _UserIdentityMarkKind.institution;
    }

    if (actorType == ActorType.publicOfficial &&
        verificationLevel == VerificationLevel.level2) {
      return _UserIdentityMarkKind.publicOfficial;
    }

    if (actorType == ActorType.citizen &&
        verificationLevel == VerificationLevel.level2) {
      return _UserIdentityMarkKind.verifiedLv2;
    }

    if (actorType == ActorType.citizen &&
        verificationLevel == VerificationLevel.level1) {
      return _UserIdentityMarkKind.verifiedLv1;
    }

    return null;
  }

  static IconData _iconFor(_UserIdentityMarkKind kind) {
    switch (kind) {
      case _UserIdentityMarkKind.verifiedLv1:
        return Icons.verified_outlined;
      case _UserIdentityMarkKind.verifiedLv2:
        return Icons.verified_rounded;
      case _UserIdentityMarkKind.publicOfficial:
        return Icons.badge_rounded;
      case _UserIdentityMarkKind.institution:
        return Icons.account_balance_rounded;
    }
  }

  static String _tooltipFor(_UserIdentityMarkKind kind) {
    switch (kind) {
      case _UserIdentityMarkKind.verifiedLv1:
        return 'Verified Lv1';
      case _UserIdentityMarkKind.verifiedLv2:
        return 'Verified Lv2';
      case _UserIdentityMarkKind.publicOfficial:
        return 'Public Official';
      case _UserIdentityMarkKind.institution:
        return 'Institution';
    }
  }

  static _UserIdentityMarkPalette _paletteFor(
    _UserIdentityMarkKind kind, {
    required bool isDark,
  }) {
    switch (kind) {
      case _UserIdentityMarkKind.verifiedLv1:
        return _UserIdentityMarkPalette(
          foregroundColor: isDark
              ? AppColors.identityVerifiedLv1ForegroundDark
              : AppColors.identityVerifiedLv1Foreground,
          backgroundColor: isDark
              ? AppColors.identityVerifiedLv1BackgroundDark
              : AppColors.identityVerifiedLv1Background,
          borderColor: isDark
              ? AppColors.identityVerifiedLv1BorderDark
              : AppColors.identityVerifiedLv1Border,
        );

      case _UserIdentityMarkKind.verifiedLv2:
        return _UserIdentityMarkPalette(
          foregroundColor: isDark
              ? AppColors.identityVerifiedLv2ForegroundDark
              : AppColors.identityVerifiedLv2Foreground,
          backgroundColor: isDark
              ? AppColors.identityVerifiedLv2BackgroundDark
              : AppColors.identityVerifiedLv2Background,
          borderColor: isDark
              ? AppColors.identityVerifiedLv2BorderDark
              : AppColors.identityVerifiedLv2Border,
        );

      case _UserIdentityMarkKind.publicOfficial:
        return _UserIdentityMarkPalette(
          foregroundColor: isDark
              ? AppColors.identityPublicOfficialForegroundDark
              : AppColors.identityPublicOfficialForeground,
          backgroundColor: isDark
              ? AppColors.identityPublicOfficialBackgroundDark
              : AppColors.identityPublicOfficialBackground,
          borderColor: isDark
              ? AppColors.identityPublicOfficialBorderDark
              : AppColors.identityPublicOfficialBorder,
        );

      case _UserIdentityMarkKind.institution:
        return _UserIdentityMarkPalette(
          foregroundColor: isDark
              ? AppColors.identityInstitutionForegroundDark
              : AppColors.identityInstitutionForeground,
          backgroundColor: isDark
              ? AppColors.identityInstitutionBackgroundDark
              : AppColors.identityInstitutionBackground,
          borderColor: isDark
              ? AppColors.identityInstitutionBorderDark
              : AppColors.identityInstitutionBorder,
        );
    }
  }
}

enum _UserIdentityMarkKind {
  verifiedLv1,
  verifiedLv2,
  publicOfficial,
  institution,
}

class _UserIdentityMarkPalette {
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _UserIdentityMarkPalette({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
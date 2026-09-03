import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

enum SocialVoteContentKind {
  vote,
  voce,
  news,
}

enum PublisherSignatureDensity {
  compact,
  regular,
}

/// Vocabolario visuale condiviso per contenuti e publisher.
///
/// I colori e i simboli definiti qui devono restare coerenti tra card,
/// dettagli, Civic Map e Globe.
abstract final class SocialVoteSymbols {
  static const Color voteColor = Color(0xFF2EAD68);
  static const Color voceColor = Color(0xFF2F80ED);
  static const Color newsColor = Color(0xFFE45151);

  static const Color organizationColor = Color(0xFF805AD5);
  static const Color institutionColor = Color(0xFF5D6FC8);
  static const Color publicOfficialColor = Color(0xFFD97757);
  static const Color personColor = Color(0xFF2F8F78);
  static const Color verifiedColor = Color(0xFF18A66B);

  static IconData contentIcon(SocialVoteContentKind kind) {
    return switch (kind) {
      SocialVoteContentKind.vote => Icons.how_to_vote_rounded,
      SocialVoteContentKind.voce => Icons.mode_comment_outlined,
      SocialVoteContentKind.news => Icons.newspaper_outlined,
    };
  }

  static Color contentColor(SocialVoteContentKind kind) {
    return switch (kind) {
      SocialVoteContentKind.vote => voteColor,
      SocialVoteContentKind.voce => voceColor,
      SocialVoteContentKind.news => newsColor,
    };
  }

  static String contentHex(SocialVoteContentKind kind) {
    return switch (kind) {
      SocialVoteContentKind.vote => '#2EAD68',
      SocialVoteContentKind.voce => '#2F80ED',
      SocialVoteContentKind.news => '#E45151',
    };
  }

  static IconData publisherIcon(ActorType actorType) {
    return switch (actorType) {
      ActorType.organization => Icons.groups_rounded,
      ActorType.institution => Icons.account_balance_rounded,
      ActorType.publicOfficial => Icons.badge_rounded,
      ActorType.citizen => Icons.person_rounded,
    };
  }

  static Color publisherColor(ActorType actorType) {
    return switch (actorType) {
      ActorType.organization => organizationColor,
      ActorType.institution => institutionColor,
      ActorType.publicOfficial => publicOfficialColor,
      ActorType.citizen => personColor,
    };
  }

  static String contentLabel(SocialVoteContentKind kind) {
    return switch (kind) {
      SocialVoteContentKind.vote => 'Vote',
      SocialVoteContentKind.voce => 'Voce',
      SocialVoteContentKind.news => 'News',
    };
  }

  static String publisherLabel(BuildContext context, ActorType actorType) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();

    return switch (actorType) {
      ActorType.organization => switch (language) {
          'it' => 'Organizzazione',
          'de' => 'Organisation',
          'fa' => 'سازمان',
          'es' => 'Organización',
          'pt' => 'Organização',
          'fr' => 'Organisation',
          'ar' => 'منظمة',
          'ro' => 'Organizație',
          _ => 'Organization',
        },
      ActorType.institution => switch (language) {
          'it' => 'Istituzione pubblica',
          'de' => 'Öffentliche Institution',
          'fa' => 'نهاد عمومی',
          'es' => 'Institución pública',
          'pt' => 'Instituição pública',
          'fr' => 'Institution publique',
          'ar' => 'مؤسسة عامة',
          'ro' => 'Instituție publică',
          _ => 'Public institution',
        },
      ActorType.publicOfficial => switch (language) {
          'it' => 'Funzionario pubblico',
          'de' => 'Amtsperson',
          'fa' => 'مقام عمومی',
          'es' => 'Cargo público',
          'pt' => 'Agente público',
          'fr' => 'Responsable public',
          'ar' => 'مسؤول عام',
          'ro' => 'Oficial public',
          _ => 'Public official',
        },
      ActorType.citizen => switch (language) {
          'it' => 'Cittadino',
          'de' => 'Bürgerkonto',
          'fa' => 'شهروند',
          'es' => 'Ciudadano',
          'pt' => 'Cidadão',
          'fr' => 'Citoyen',
          'ar' => 'مواطن',
          'ro' => 'Cetățean',
          _ => 'Citizen',
        },
    };
  }

  static String verificationLabel(
    BuildContext context, {
    required ActorType actorType,
    required VerificationLevel verificationLevel,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return switch (actorType) {
      ActorType.organization => l10n.identityBadgeVerifiedOrganization,
      ActorType.institution => l10n.identityBadgePublicInstitution,
      ActorType.publicOfficial => l10n.identityBadgePublicOfficial,
      ActorType.citizen => switch (verificationLevel) {
          VerificationLevel.level2 => l10n.identityBadgeLevel2,
          VerificationLevel.level1 => l10n.identityBadgeLevel1,
          VerificationLevel.none => l10n.identityVerificationNotVerified,
        },
    };
  }

  static String openProfileLabel(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    return switch (language) {
      'it' => 'Apri profilo',
      'de' => 'Profil öffnen',
      'fa' => 'باز کردن پروفایل',
      'es' => 'Abrir perfil',
      'pt' => 'Abrir perfil',
      'fr' => 'Ouvrir le profil',
      'ar' => 'فتح الملف الشخصي',
      'ro' => 'Deschide profilul',
      _ => 'Open profile',
    };
  }

}

class ContentTypeMark extends StatelessWidget {
  final SocialVoteContentKind kind;
  final double size;
  final bool showTooltip;

  const ContentTypeMark({
    super.key,
    required this.kind,
    this.size = 32,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = SocialVoteSymbols.contentColor(kind);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.48 : 0.26),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        SocialVoteSymbols.contentIcon(kind),
        size: size * 0.50,
        color: color,
      ),
    );

    if (!showTooltip) return mark;

    return Tooltip(
      message: SocialVoteSymbols.contentLabel(kind),
      child: mark,
    );
  }
}

/// Marker compatto usato sulle superfici 3D native.
///
/// Mantiene lo stesso simbolo/colore di card, dettagli e mappa 2D. I cluster
/// usano un unico simbolo neutro e mostrano il numero di contenuti aggregati.
class GlobeContentMarker extends StatelessWidget {
  final SocialVoteContentKind kind;
  final double size;
  final int clusterCount;

  const GlobeContentMarker({
    super.key,
    required this.kind,
    this.size = 28,
    this.clusterCount = 1,
  });

  bool get _isCluster => clusterCount > 1;

  @override
  Widget build(BuildContext context) {
    final color = _isCluster
        ? SocialVoteSymbols.organizationColor
        : SocialVoteSymbols.contentColor(kind);
    final label = clusterCount > 99 ? '99+' : '$clusterCount';
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    final clusterDescription = switch (language) {
      'it' => '$label contenuti',
      'de' => '$label Inhalte',
      'fa' => '$label محتوا',
      'es' => '$label contenidos',
      'pt' => '$label conteúdos',
      'fr' => '$label contenus',
      'ar' => '$label عناصر',
      'ro' => '$label elemente',
      _ => '$label items',
    };

    // Android/native visual recovery: keep the original layout footprint so
    // geographic anchoring and hit-target math remain unchanged, while the
    // visible glyph is deliberately quieter than the 24-34 px V9 surface.
    // The Web renderer does not instantiate GlobeContentMarker.
    final visualSize = (size * 0.72).clamp(16.0, 24.5).toDouble();

    return IgnorePointer(
      child: Semantics(
        image: true,
        label: _isCluster
            ? clusterDescription
            : SocialVoteSymbols.contentLabel(kind),
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: Container(
              width: visualSize,
              height: visualSize,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1020),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: visualSize >= 23 ? 2.5 : 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.30),
                    blurRadius: visualSize * 0.34,
                    spreadRadius: 0.5,
                  ),
                  const BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 4,
                    offset: Offset(0, 1.5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _isCluster
                  ? Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: label.length > 2
                                ? visualSize * 0.27
                                : visualSize * 0.32,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                    )
                  : Icon(
                      SocialVoteSymbols.contentIcon(kind),
                      color: Colors.white,
                      size: visualSize * 0.48,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class PublisherAvatar extends StatelessWidget {
  final String displayName;
  final String? imageUrl;
  final ActorType actorType;
  final VerificationLevel verificationLevel;
  final InstitutionLevel? institutionLevel;
  final double size;
  final bool showTooltip;

  const PublisherAvatar({
    super.key,
    required this.displayName,
    required this.actorType,
    this.imageUrl,
    this.verificationLevel = VerificationLevel.none,
    this.institutionLevel,
    this.size = 30,
    this.showTooltip = true,
  });

  bool get _isVerified =>
      actorType != ActorType.citizen ||
      verificationLevel != VerificationLevel.none;

  bool get _isTriangle =>
      actorType == ActorType.institution ||
      actorType == ActorType.publicOfficial;

  bool get _isSquare => actorType == ActorType.organization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = SocialVoteSymbols.publisherColor(actorType);
    final normalizedImageUrl = imageUrl?.trim();
    final canShowImage =
        normalizedImageUrl != null && normalizedImageUrl.isNotEmpty;
    final initial = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().characters.first.toUpperCase();
    final actorBackgroundColor = color.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.20 : 0.11,
    );
    final actorBorderColor = color.withValues(alpha: _isVerified ? 0.88 : 0.52);

    // Una foto/logo reale deve essere la superficie dell'avatar, non stare
    // dentro una cornice colorata che lascia bande laterali visibili. Tipo e
    // verifica sono già comunicati dalla forma e dal sigillo sovrapposto.
    final backgroundColor =
        canShowImage ? theme.colorScheme.surface : actorBackgroundColor;
    final borderColor = canShowImage
        ? theme.colorScheme.outlineVariant.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.72 : 0.56,
          )
        : actorBorderColor;
    final borderWidth = canShowImage ? 1.0 : (_isVerified ? 2.0 : 1.25);
    final imageScale = switch (actorType) {
      ActorType.organization => 1.14,
      ActorType.institution => 1.10,
      ActorType.publicOfficial => 1.06,
      ActorType.citizen => 1.04,
    };

    final imageChild = SizedBox.expand(
      child: canShowImage
          ? Transform.scale(
              scale: imageScale,
              child: Image.network(
                normalizedImageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Center(
                  child: _fallback(
                    context,
                    color: color,
                    initial: initial,
                  ),
                ),
              ),
            )
          : Center(
              child: _fallback(
                context,
                color: color,
                initial: initial,
              ),
            ),
    );

    final avatar = _buildAvatarContainer(
      child: imageChild,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
    );

    final sealPalette = _sealPalette(context);
    final sealSize = (size * 0.52).clamp(14.0, 19.0).toDouble();
    final child = SizedBox(
      width: size + 3,
      height: size + 3,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (_isVerified)
            PositionedDirectional(
              end: -2,
              bottom: -2,
              child: Container(
                width: sealSize,
                height: sealSize,
                decoration: BoxDecoration(
                  color: sealPalette.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: sealPalette.border,
                    width: 1.25,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  _sealIcon,
                  size: sealSize * 0.68,
                  color: sealPalette.foreground,
                ),
              ),
            ),
        ],
      ),
    );

    final semanticAvatar = Semantics(
      image: true,
      label: '${SocialVoteSymbols.publisherLabel(context, actorType)}: '
          '$displayName. ${_tooltip(context)}',
      child: child,
    );

    if (!showTooltip) return semanticAvatar;

    return Tooltip(
      message: _tooltip(context),
      child: semanticAvatar,
    );
  }

  Widget _buildAvatarContainer({
    required Widget child,
    required Color backgroundColor,
    required Color borderColor,
    required double borderWidth,
  }) {
    if (_isTriangle) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _TriangleFramePainter(
                  fillColor: backgroundColor,
                  borderColor: borderColor,
                  borderWidth: borderWidth,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(borderWidth + 0.2),
                child: ClipPath(
                  clipper: const _TriangleClipper(),
                  child: ColoredBox(
                    color: backgroundColor,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: _isSquare ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: _isSquare ? BorderRadius.circular(size * 0.24) : null,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: _isVerified
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.18),
                  blurRadius: size * 0.22,
                  spreadRadius: 0.4,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: ColoredBox(
        color: backgroundColor,
        child: child,
      ),
    );
  }

  IconData get _sealIcon {
    return switch (actorType) {
      ActorType.organization => Icons.groups_rounded,
      ActorType.institution => Icons.account_balance_rounded,
      ActorType.publicOfficial => Icons.badge_rounded,
      ActorType.citizen => verificationLevel == VerificationLevel.level2
          ? Icons.verified_rounded
          : Icons.verified_outlined,
    };
  }

  _PublisherSealPalette _sealPalette(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (actorType == ActorType.citizen &&
        verificationLevel == VerificationLevel.level2) {
      return _PublisherSealPalette(
        foreground: isDark
            ? AppColors.identityVerifiedLv2ForegroundDark
            : AppColors.identityVerifiedLv2Foreground,
        background: isDark
            ? AppColors.identityVerifiedLv2BackgroundDark
            : AppColors.identityVerifiedLv2Background,
        border: isDark
            ? AppColors.identityVerifiedLv2BorderDark
            : AppColors.identityVerifiedLv2Border,
      );
    }

    if (actorType == ActorType.citizen) {
      return _PublisherSealPalette(
        foreground: isDark
            ? AppColors.identityVerifiedLv1ForegroundDark
            : AppColors.identityVerifiedLv1Foreground,
        background: isDark
            ? AppColors.identityVerifiedLv1BackgroundDark
            : AppColors.identityVerifiedLv1Background,
        border: isDark
            ? AppColors.identityVerifiedLv1BorderDark
            : AppColors.identityVerifiedLv1Border,
      );
    }

    if (actorType == ActorType.publicOfficial) {
      return _PublisherSealPalette(
        foreground: isDark
            ? AppColors.identityPublicOfficialForegroundDark
            : AppColors.identityPublicOfficialForeground,
        background: isDark
            ? AppColors.identityPublicOfficialBackgroundDark
            : AppColors.identityPublicOfficialBackground,
        border: isDark
            ? AppColors.identityPublicOfficialBorderDark
            : AppColors.identityPublicOfficialBorder,
      );
    }

    return _PublisherSealPalette(
      foreground: isDark
          ? AppColors.identityInstitutionForegroundDark
          : AppColors.identityInstitutionForeground,
      background: isDark
          ? AppColors.identityInstitutionBackgroundDark
          : AppColors.identityInstitutionBackground,
      border: isDark
          ? AppColors.identityInstitutionBorderDark
          : AppColors.identityInstitutionBorder,
    );
  }

  Widget _fallback(
    BuildContext context, {
    required Color color,
    required String initial,
  }) {
    if (actorType != ActorType.citizen) {
      return Icon(
        SocialVoteSymbols.publisherIcon(actorType),
        size: size * 0.50,
        color: color,
      );
    }

    return Text(
      initial,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
    );
  }

  String _tooltip(BuildContext context) {
    return SocialVoteSymbols.verificationLabel(
      context,
      actorType: actorType,
      verificationLevel: verificationLevel,
    );
  }
}

/// Firma pubblica unica di Social Vote.
///
/// L'avatar/logo comunica chi pubblica, l'anello comunica il tipo di attore e
/// il sigillo comunica il livello di identità. Le superfici che possono aprire
/// il profilo passano [onTap], rendendo cliccabile l'intera firma e non soltanto
/// una parte del nome.
class PublisherSignature extends StatelessWidget {
  final String displayName;
  final String? username;
  final String? imageUrl;
  final ActorType actorType;
  final VerificationLevel verificationLevel;
  final InstitutionLevel? institutionLevel;
  final PublisherSignatureDensity density;
  final VoidCallback? onTap;
  final double maxWidth;

  const PublisherSignature({
    super.key,
    required this.displayName,
    required this.actorType,
    this.username,
    this.imageUrl,
    this.verificationLevel = VerificationLevel.none,
    this.institutionLevel,
    this.density = PublisherSignatureDensity.compact,
    this.onTap,
    this.maxWidth = 300,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = SocialVoteSymbols.publisherColor(actorType);
    final normalizedName = displayName.trim().isEmpty
        ? SocialVoteSymbols.publisherLabel(context, actorType)
        : displayName.trim();
    final normalizedUsername = username?.trim();
    final handle = normalizedUsername == null || normalizedUsername.isEmpty
        ? null
        : (normalizedUsername.startsWith('@')
            ? normalizedUsername
            : '@$normalizedUsername');
    // `density` resta nell'API per compatibilità, ma la firma pubblica deve
    // avere una sola metrica in ogni superficie dell'app.
    const avatarSize = 32.0;
    final foreground = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.92 : 0.86,
    );
    final secondaryForeground = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.68 : 0.56,
    );
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PublisherAvatar(
              displayName: normalizedName,
              imageUrl: imageUrl,
              actorType: actorType,
              verificationLevel: verificationLevel,
              institutionLevel: institutionLevel,
              size: avatarSize,
              showTooltip: false,
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    normalizedName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  if (handle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryForeground,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final profileAction = SocialVoteSymbols.openProfileLabel(context);
    final identityDescription = SocialVoteSymbols.verificationLabel(
      context,
      actorType: actorType,
      verificationLevel: verificationLevel,
    );
    final publisherName =
        handle == null ? normalizedName : '$normalizedName, $handle';
    final semanticsLabel = onTap == null
        ? '$publisherName. $identityDescription'
        : '$profileAction: $publisherName. $identityDescription';

    Widget result = content;

    if (onTap != null) {
      result = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: accent.withValues(alpha: isDark ? 0.10 : 0.06),
          focusColor: accent.withValues(alpha: isDark ? 0.12 : 0.08),
          splashColor: accent.withValues(alpha: 0.14),
          mouseCursor: SystemMouseCursors.click,
          excludeFromSemantics: true,
          onTap: onTap,
          child: result,
        ),
      );
    }

    result = Semantics(
      button: onTap != null,
      label: semanticsLabel,
      onTap: onTap,
      child: result,
    );

    return Tooltip(
      message: onTap == null
          ? identityDescription
          : '$profileAction · $identityDescription',
      child: result,
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  const _TriangleClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _TriangleClipper oldClipper) => false;
}

class _TriangleFramePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  const _TriangleFramePainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 1)
      ..lineTo(size.width - 1, size.height - 1)
      ..lineTo(1, size.height - 1)
      ..close();

    canvas.drawShadow(
      path,
      borderColor.withValues(alpha: 0.16),
      2,
      false,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TriangleFramePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

class _PublisherSealPalette {
  final Color foreground;
  final Color background;
  final Color border;

  const _PublisherSealPalette({
    required this.foreground,
    required this.background,
    required this.border,
  });
}

import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';

/// Card di base riutilizzabile per tutta l'app.
///
/// Obiettivi:
/// - Usare radius / colori / spacing del design system
/// - Evitare duplicazione di Card "custom" sparse ovunque
/// - Fornire un contenitore cliccabile con ripple consistente
class AppCard extends StatelessWidget {
  /// Contenuto interno della card.
  final Widget child;

  /// Padding interno della card.
  ///
  /// Default: [AppSpacing.card].
  final EdgeInsetsGeometry? padding;

  /// Margine esterno.
  ///
  /// Default: nessuno (lo gestisce il layout padre).
  final EdgeInsetsGeometry? margin;

  /// Callback opzionale per tap.
  ///
  /// Se non è null, abilita InkWell e ripple.
  final VoidCallback? onTap;

  /// Se true, usa una leggera elevazione visiva.
  ///
  /// Default: false (card "flat" con solo bordo soft).
  final bool elevated;

  /// Se true, evidenzia la card (es. selezione / stato attivo).
  ///
  /// Default: false.
  final bool selected;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevated = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final EdgeInsetsGeometry effectivePadding = padding ?? AppSpacing.card;

    final Color baseBackgroundColor = theme.cardColor;
    final Color backgroundColor = selected
        ? (isDark
            ? AppColors.primarySoftBackgroundDark
            : AppColors.primarySoftBackground)
        : baseBackgroundColor;

    final BorderSide borderSide = BorderSide(
      color: selected
          ? (isDark
              ? AppColors.primaryLight.withValues(alpha: 0.52)
              : AppColors.primary.withValues(alpha: 0.42))
          : (isDark ? AppColors.borderSoftDark : AppColors.borderSoft),
      width: selected ? 1.2 : 1,
    );

    final List<Color> gradientColors = selected
        ? <Color>[
            backgroundColor,
            backgroundColor,
          ]
        : isDark
            ? <Color>[
                _blend(baseBackgroundColor, Colors.white, 0.035),
                _blend(baseBackgroundColor, const Color(0xFF020617), 0.16),
              ]
            : <Color>[
                _blend(baseBackgroundColor, Colors.white, 0.72),
                _blend(baseBackgroundColor, AppColors.backgroundAlt, 0.30),
              ];

    final List<BoxShadow> shadows = elevated
        ? <BoxShadow>[
            BoxShadow(
              blurRadius: isDark ? 28 : 20,
              offset: const Offset(0, 10),
              color: isDark
                  ? Colors.black.withValues(alpha: 0.24)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              blurRadius: isDark ? 16 : 12,
              offset: const Offset(0, 4),
              color: isDark
                  ? Colors.black.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.028),
            ),
          ];

    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.cardRadius,
      side: borderSide,
    );

    final Color overlayColor = isDark
        ? AppColors.primarySoftBackgroundDark.withValues(alpha: 0.34)
        : AppColors.primarySoftBackground.withValues(alpha: 0.72);

    Widget cardChild = Padding(
      padding: effectivePadding,
      child: child,
    );

    if (onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        splashColor: overlayColor,
        highlightColor: overlayColor.withValues(alpha: 0.75),
        hoverColor: overlayColor.withValues(alpha: 0.45),
        child: cardChild,
      );
    }

    Widget content = Material(
      color: Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: AppRadius.cardRadius,
          border: Border.fromBorderSide(borderSide),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: shadows,
        ),
        child: cardChild,
      ),
    );

    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }

    return content;
  }

  Color _blend(Color base, Color other, double amount) {
    return Color.lerp(base, other, amount) ?? base;
  }
}

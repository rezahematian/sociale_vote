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

    final EdgeInsetsGeometry effectivePadding = padding ?? AppSpacing.card;

    Color backgroundColor = theme.cardColor;
    final BorderSide borderSide;

    if (selected) {
      backgroundColor = AppColors.primarySoftBackground;
      borderSide = BorderSide(
        color: AppColors.primary.withOpacity(0.7),
        width: 1.2,
      );
    } else {
      borderSide = const BorderSide(
        color: AppColors.borderSoft,
        width: 1,
      );
    }

    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.cardRadius,
      side: borderSide,
    );

    final double elevationValue = elevated ? 3.0 : 0.0;

    Widget cardChild = Padding(
      padding: effectivePadding,
      child: child,
    );

    if (onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        splashColor: AppColors.primarySoftBackground,
        highlightColor: AppColors.primarySoftBackground.withOpacity(0.4),
        child: cardChild,
      );
    }

    Widget content = Material(
      color: backgroundColor,
      elevation: elevationValue,
      shadowColor: elevated ? AppColors.shadow : Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: cardChild,
    );

    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }

    return content;
  }
}
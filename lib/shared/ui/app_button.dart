import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/spacing.dart';

/// Sistema centralizzato per i bottoni di Sociale_Vote.
///
/// Obiettivi:
/// - Nessun ElevatedButton/OutlinedButton/TextButton sparso nel codice
/// - Stati coerenti (normal / disabled / loading)
/// - Radius coerente
/// - Altezza minima coerente
///
/// Variante:
/// - primary
/// - secondary (outlined)
/// - text
///
/// Uso:
/// AppButton.primary(...)
/// AppButton.secondary(...)
/// AppButton.text(...)
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;
  final _AppButtonVariant variant;
  final IconData? icon;

  const AppButton._({
    required this.label,
    required this.variant,
    this.onPressed,
    this.isLoading = false,
    this.expanded = false,
    this.icon,
  });

  factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool expanded = false,
    IconData? icon,
  }) {
    return AppButton._(
      label: label,
      variant: _AppButtonVariant.primary,
      onPressed: onPressed,
      isLoading: isLoading,
      expanded: expanded,
      icon: icon,
    );
  }

  factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool expanded = false,
    IconData? icon,
  }) {
    return AppButton._(
      label: label,
      variant: _AppButtonVariant.secondary,
      onPressed: onPressed,
      isLoading: isLoading,
      expanded: expanded,
      icon: icon,
    );
  }

  factory AppButton.text({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool expanded = false,
    IconData? icon,
  }) {
    return AppButton._(
      label: label,
      variant: _AppButtonVariant.text,
      onPressed: onPressed,
      isLoading: isLoading,
      expanded: expanded,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool disabled = onPressed == null || isLoading;

    Widget child;

    if (isLoading) {
      child = SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == _AppButtonVariant.primary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text(label),
        ],
      );
    } else {
      child = Text(label);
    }

    final double height =
        variant == _AppButtonVariant.text ? 40 : 44;

    Widget button;

    switch (variant) {
      case _AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: disabled ? null : onPressed,
          child: child,
        );
        break;

      case _AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: disabled ? null : onPressed,
          child: child,
        );
        break;

      case _AppButtonVariant.text:
        button = TextButton(
          onPressed: disabled ? null : onPressed,
          child: child,
        );
        break;
    }

    return SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: button,
    );
  }
}

enum _AppButtonVariant {
  primary,
  secondary,
  text,
}
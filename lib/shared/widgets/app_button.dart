import 'package:flutter/material.dart';

/// Sistema centralizzato per i bottoni di Sociale_Vote.
///
/// Obiettivi:
/// - Nessun ElevatedButton/OutlinedButton/TextButton sparso nel codice
/// - Stati coerenti (normal / disabled / loading)
/// - Radius coerente (10)
/// - Altezza minima coerente (44)
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
  final _AppButtonVariant variant;
  final IconData? icon;

  const AppButton._({
    required this.label,
    required this.variant,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  // ================= PRIMARY =================

  factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return AppButton._(
      label: label,
      variant: _AppButtonVariant.primary,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }

  // ================= SECONDARY =================

  factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return AppButton._(
      label: label,
      variant: _AppButtonVariant.secondary,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }

  // ================= TEXT =================

  factory AppButton.text({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return AppButton._(
      label: label,
      variant: _AppButtonVariant.text,
      onPressed: onPressed,
      isLoading: isLoading,
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
          const SizedBox(width: 6),
          Text(label),
        ],
      );
    } else {
      child = Text(label);
    }

    switch (variant) {
      case _AppButtonVariant.primary:
        return SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            child: child,
          ),
        );

      case _AppButtonVariant.secondary:
        return SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: disabled ? null : onPressed,
            child: child,
          ),
        );

      case _AppButtonVariant.text:
        return SizedBox(
          height: 40,
          child: TextButton(
            onPressed: disabled ? null : onPressed,
            child: child,
          ),
        );
    }
  }
}

enum _AppButtonVariant {
  primary,
  secondary,
  text,
}
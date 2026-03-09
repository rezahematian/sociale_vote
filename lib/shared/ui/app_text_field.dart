import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/spacing.dart';

/// Text field standard dell'app.
///
/// Obiettivi:
/// - evitare TextField sparsi nel codice
/// - usare InputDecorationTheme globale
/// - gestione semplice di label / hint / error / icon
///
/// Supporta:
/// - controller
/// - onChanged
/// - onSubmitted
/// - multiline
/// - icon prefix
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;

  final String? label;
  final String? hint;
  final String? errorText;

  final IconData? prefixIcon;

  final bool enabled;
  final bool obscureText;

  final int maxLines;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          prefixIcon:
              prefixIcon != null ? Icon(prefixIcon) : null,
        ),
      ),
    );
  }
}
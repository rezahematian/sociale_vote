import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/spacing.dart';

/// Indicatore di caricamento standard dell'app.
///
/// Uso:
/// - inline dentro card / sezioni
/// - centrato in pagina
/// - con messaggio opzionale
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final double strokeWidth;
  final EdgeInsetsGeometry padding;
  final bool centered;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.padding = const EdgeInsets.all(AppSpacing.m),
    this.centered = true,
  });

  const LoadingIndicator.inline({
    super.key,
    this.message,
    this.size = 20,
    this.strokeWidth = 2.2,
    this.padding = const EdgeInsets.symmetric(
      vertical: AppSpacing.m,
    ),
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
            ),
          ),
          if (message != null && message!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );

    if (centered) {
      content = Center(child: content);
    }

    return content;
  }
}

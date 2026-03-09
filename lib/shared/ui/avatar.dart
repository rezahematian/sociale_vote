import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/radius.dart';

/// Avatar standard dell'app.
///
/// Uso:
/// - avatar utente
/// - placeholder con iniziale
/// - icona fallback
class Avatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const Avatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 36,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primarySoftBackground;
    final fg = foregroundColor ?? AppColors.primary;

    final String initial = _extractInitial(name);

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(bg, fg, initial),
        ),
      );
    }

    return _buildFallback(bg, fg, initial);
  }

  Widget _buildFallback(Color bg, Color fg, String initial) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: AppColors.borderSoft,
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: initial.isNotEmpty
          ? Text(
              initial,
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            )
          : Icon(
              fallbackIcon,
              size: size * 0.5,
              color: fg,
            ),
    );
  }

  String _extractInitial(String? value) {
    if (value == null) return '';
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.characters.first.toUpperCase();
  }
}
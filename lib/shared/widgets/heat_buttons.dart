import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';

enum HeatState {
  none,
  hot,
  cold,
}

/// CivicHeatButtons
///
/// Stateless – stato reale gestito dal controller chiamante
///
/// Comportamento:
/// - tap hot → toggle gestito dal caller
/// - tap cold → toggle gestito dal caller
/// - nessuna logica locale sui contatori
class CivicHeatButtons extends StatelessWidget {
  final int hotCount;
  final int coldCount;
  final HeatState userVote;

  final VoidCallback? onHot;
  final VoidCallback? onCold;
  final VoidCallback? onReset;

  const CivicHeatButtons({
    super.key,
    required this.hotCount,
    required this.coldCount,
    required this.userVote,
    this.onHot,
    this.onCold,
    this.onReset,
  });

  void _handleHot() {
    onHot?.call();
  }

  void _handleCold() {
    onCold?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isHot = userVote == HeatState.hot;
    final isCold = userVote == HeatState.cold;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeatButton(
          icon: Icons.local_fire_department,
          label: hotCount.toString(),
          active: isHot,
          activeColor: AppColors.heat,
          softColor: AppColors.heatSoftBackground,
          onTap: onHot != null ? _handleHot : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        _HeatButton(
          icon: Icons.ac_unit,
          label: coldCount.toString(),
          active: isCold,
          activeColor: AppColors.cool,
          softColor: AppColors.coolSoftBackground,
          onTap: onCold != null ? _handleCold : null,
        ),
      ],
    );
  }
}

class _HeatButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final Color softColor;
  final VoidCallback? onTap;

  const _HeatButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.softColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = active ? activeColor : AppColors.icon;
    final Color background = active ? softColor : Colors.transparent;

    return InkWell(
      borderRadius: AppRadius.pillRadius,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.pillRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
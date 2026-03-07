import 'package:flutter/material.dart';
import '../../features/news/news_item.dart';

/// CivicHeatButtons
///
/// Stateless – stato reale gestito dal NewsController
///
/// Comportamento:
/// - tap hot → toggle gestito dal controller
/// - tap cold → toggle gestito dal controller
/// - nessuna logica locale sui contatori
class CivicHeatButtons extends StatelessWidget {
  final int hotCount;
  final int coldCount;
  final HeatVote userVote;

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
    final isHot = userVote == HeatVote.hot;
    final isCold = userVote == HeatVote.cold;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeatButton(
          icon: Icons.local_fire_department,
          label: hotCount.toString(),
          active: isHot,
          activeColor: Colors.deepOrange,
          onTap: _handleHot,
        ),
        const SizedBox(width: 10),
        _HeatButton(
          icon: Icons.ac_unit,
          label: coldCount.toString(),
          active: isCold,
          activeColor: Colors.lightBlue,
          onTap: _handleCold,
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
  final VoidCallback onTap;

  const _HeatButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : Colors.grey.shade600;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

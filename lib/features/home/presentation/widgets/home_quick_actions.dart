import 'package:flutter/material.dart';

class HomeQuickActions extends StatelessWidget {
  final VoidCallback? onOpenPolls;
  final VoidCallback? onOpenNews;
  final VoidCallback? onOpenSocial;
  final VoidCallback? onOpenMap;

  const HomeQuickActions({
    super.key,
    this.onOpenPolls,
    this.onOpenNews,
    this.onOpenSocial,
    this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _QuickActionChip(
          icon: Icons.how_to_vote,
          label: 'Polls',
          onTap: onOpenPolls,
        ),
        _QuickActionChip(
          icon: Icons.article_outlined,
          label: 'News',
          onTap: onOpenNews,
        ),
        _QuickActionChip(
          icon: Icons.forum_outlined,
          label: 'Social',
          onTap: onOpenSocial,
        ),
        _QuickActionChip(
          icon: Icons.map_outlined,
          label: 'Map',
          onTap: onOpenMap,
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class HomeScopeHeader extends StatelessWidget {
  final GeoScope scope;
  final String scopeLabel;
  final bool isFollowed;

  final VoidCallback onToggleFollow;
  final VoidCallback onSetWorld;
  final VoidCallback onSetItaly;
  final VoidCallback onSetTorino;

  const HomeScopeHeader({
    super.key,
    required this.scope,
    required this.scopeLabel,
    required this.isFollowed,
    required this.onToggleFollow,
    required this.onSetWorld,
    required this.onSetItaly,
    required this.onSetTorino,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isWorld = scope.level == GeoScopeLevel.world;

    final isItaly = scope.level == GeoScopeLevel.country &&
        (scope.countryCode ?? '').toUpperCase() == 'IT';

    final isTorino = scope.level == GeoScopeLevel.city &&
        (scope.cityId ?? '').toUpperCase() == 'TORINO';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.public,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scopeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FollowScopeButton(
                    isFollowed: isFollowed,
                    onToggle: onToggleFollow,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n.homeScopeChipWorld),
                    selected: isWorld,
                    onSelected: (_) => onSetWorld(),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n.homeScopeChipItaly),
                    selected: isItaly,
                    onSelected: (_) => onSetItaly(),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n.homeScopeChipTorino),
                    selected: isTorino,
                    onSelected: (_) => onSetTorino(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FollowScopeButton extends StatelessWidget {
  final bool isFollowed;
  final VoidCallback onToggle;

  const FollowScopeButton({
    super.key,
    required this.isFollowed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return OutlinedButton.icon(
      onPressed: onToggle,
      icon: Icon(
        isFollowed ? Icons.check : Icons.add_location_alt_outlined,
        size: 18,
      ),
      label: Text(
        isFollowed
            ? l10n.followScopeButtonFollowed
            : l10n.followScopeButtonFollow,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isFollowed
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        side: BorderSide(
          color: isFollowed
              ? theme.colorScheme.primary
              : theme.dividerColor.withOpacity(0.6),
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
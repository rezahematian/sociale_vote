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

  const HomeScopeHeader({
    super.key,
    required this.scope,
    required this.scopeLabel,
    required this.isFollowed,
    required this.onToggleFollow,
    required this.onSetWorld,
    required this.onSetItaly,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final isWorld = scope.level == GeoScopeLevel.world;
    final isItaly = scope.level == GeoScopeLevel.country &&
        (scope.countryCode ?? '').toUpperCase() == 'IT';

    final extraScopeChipLabel = _extraScopeChipLabel();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
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
                    _scopeIcon(),
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
                  if (!isWorld) ...[
                    const SizedBox(width: 8),
                    FollowScopeButton(
                      isFollowed: isFollowed,
                      onToggle: onToggleFollow,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildScopeChip(
                      context,
                      label: l10n.homeScopeChipWorld,
                      selected: isWorld,
                      onTap: onSetWorld,
                    ),
                    _buildScopeChip(
                      context,
                      label: l10n.homeScopeChipItaly,
                      selected: isItaly,
                      onTap: onSetItaly,
                    ),
                    if (extraScopeChipLabel != null)
                      _buildScopeChip(
                        context,
                        label: extraScopeChipLabel,
                        selected: true,
                        onTap: null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScopeChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: onTap == null ? null : (_) => onTap(),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.82),
      ),
      backgroundColor: theme.colorScheme.surface.withOpacity(0.82),
      selectedColor: theme.colorScheme.primary.withOpacity(0.12),
      side: BorderSide(
        color: selected
            ? theme.colorScheme.primary.withOpacity(0.45)
            : theme.dividerColor.withOpacity(0.6),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  String? _extraScopeChipLabel() {
    if (scope.level == GeoScopeLevel.world || isItalyScope) {
      return null;
    }

    final label = scopeLabel.trim();
    if (label.isEmpty) {
      return null;
    }

    return label;
  }

  IconData _scopeIcon() {
    if (scope.level == GeoScopeLevel.world) {
      return Icons.public;
    }

    if (scope.level == GeoScopeLevel.country) {
      return Icons.flag_outlined;
    }

    if (scope.level == GeoScopeLevel.city) {
      return Icons.location_city_outlined;
    }

    return Icons.place_outlined;
  }

  bool get isItalyScope =>
      scope.level == GeoScopeLevel.country &&
      (scope.countryCode ?? '').toUpperCase() == 'IT';
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

import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';

class HomeUserStatus extends StatelessWidget {
  final bool isLoggedIn;
  final String? currentUserId;

  const HomeUserStatus({
    super.key,
    required this.isLoggedIn,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isLoggedIn
                  ? l10n.homeUserStatusLoggedIn(currentUserId!)
                  : l10n.homeUserStatusGuest,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

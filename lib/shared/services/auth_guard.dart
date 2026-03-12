import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/ui/ui.dart';

/// Guard centrale per azioni protette (vote, comment, react, createPoll, ecc).
///
/// Tutta la UI deve passare da qui prima di eseguire
/// un’azione di partecipazione.
class AuthGuard {
  static const ParticipationPolicy _policy = ParticipationPolicy();

  /// Verifica se l’utente può eseguire [action].
  ///
  /// - Se sì → ritorna true
  /// - Se no (guest) → mostra bottom sheet login/registrazione
  /// - Dopo il flow auth ricontrolla lo stato reale della sessione
  static Future<bool> ensureCanPerformAction(
    BuildContext context,
    ParticipationAction action,
  ) async {
    final userId = AppDI.instance.currentUserId;

    if (_policy.canPerform(userId: userId, action: action)) {
      return true;
    }

    await _showLoginRequiredSheet(context, action);

    final newUserId = AppDI.instance.currentUserId;
    return _policy.canPerform(userId: newUserId, action: action);
  }

  static Future<void> _showLoginRequiredSheet(
    BuildContext context,
    ParticipationAction action,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetRadius,
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final actionLabel = _actionLabel(action);

        Future<void> openAuthFlow(String routeName) async {
          Navigator.of(sheetContext).pop();

          await Navigator.of(context).pushNamed(routeName);
        }

        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.m,
            right: AppSpacing.m,
            top: AppSpacing.m,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                AppSpacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.s),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: AppRadius.pillRadius,
                ),
              ),
              Text(
                'Vuoi partecipare?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Per $actionLabel devi accedere o registrarti. '
                'Come ospite puoi solo visualizzare contenuti.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Accedi',
                      onPressed: () => openAuthFlow(AppRouter.login),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: AppButton.primary(
                      label: 'Registrati',
                      onPressed: () => openAuthFlow(AppRouter.register),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton.text(
                label: 'Continua come ospite',
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String _actionLabel(ParticipationAction action) {
    switch (action) {
      case ParticipationAction.vote:
        return 'votare';
      case ParticipationAction.createPoll:
        return 'creare una votazione';
      case ParticipationAction.react:
        return 'reagire con 🔥 o ❄';
      case ParticipationAction.comment:
        return 'commentare';
      case ParticipationAction.createPost:
        return 'creare un post';
      case ParticipationAction.followScope:
        return 'seguire quest\'area geografica';
    }
  }
}
import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
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
  /// - Se guest → mostra bottom sheet login/registrazione
  /// - Se loggato ma non autorizzato → mostra dialog di accesso negato
  ///
  /// I parametri identity aggiuntivi sono opzionali e servono per
  /// estendere il sistema in futuro senza cambiare di nuovo la firma.
  static Future<bool> ensureCanPerformAction(
    BuildContext context,
    ParticipationAction action, {
    Role role = Role.user,
    ActorType actorType = ActorType.citizen,
    VerificationLevel verificationLevel = VerificationLevel.none,
    InstitutionLevel? institutionLevel,
  }) async {
    final userId = AppDI.instance.currentUserId;

    if (_policy.canPerform(
      userId: userId,
      action: action,
      role: role,
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    )) {
      return true;
    }

    if (userId == null) {
      await _showLoginRequiredSheet(context, action);

      final newUserId = AppDI.instance.currentUserId;
      return _policy.canPerform(
        userId: newUserId,
        action: action,
        role: role,
        actorType: actorType,
        verificationLevel: verificationLevel,
        institutionLevel: institutionLevel,
      );
    }

    await _showPermissionDeniedDialog(context, action);
    return false;
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
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.m,
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

  static Future<void> _showPermissionDeniedDialog(
    BuildContext context,
    ParticipationAction action,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Accesso negato'),
          content: Text(_permissionDeniedMessage(action)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static String _permissionDeniedMessage(ParticipationAction action) {
    switch (action) {
      case ParticipationAction.reviewVerificationRequests:
        return 'Questa area è riservata a moderator/admin.';
      case ParticipationAction.vote:
      case ParticipationAction.createPoll:
      case ParticipationAction.react:
      case ParticipationAction.comment:
      case ParticipationAction.createPost:
      case ParticipationAction.followScope:
      case ParticipationAction.reportContent:
        return 'Non hai i permessi necessari per questa azione.';
    }
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
      case ParticipationAction.reportContent:
        return 'segnalare un contenuto';
      case ParticipationAction.reviewVerificationRequests:
        return 'revisionare richieste di verifica';
    }
  }
}
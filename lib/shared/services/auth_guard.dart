import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';

enum _AuthGuardResult {
  loggedIn,
  cancelled,
}

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
  ///   - Se dopo il flow è loggato → true
  ///   - Se annulla → false
  static Future<bool> ensureCanPerformAction(
    BuildContext context,
    ParticipationAction action,
  ) async {
    final userId = AppDI.instance.currentUserId;

    // 1️⃣ Controllo policy
    if (_policy.canPerform(userId: userId, action: action)) {
      return true;
    }

    // 2️⃣ Guest → mostra login sheet
    final result = await _showLoginRequiredSheet(context, action);

    if (result != _AuthGuardResult.loggedIn) {
      return false;
    }

    // 3️⃣ Dopo login, ricontrolliamo
    final newUserId = AppDI.instance.currentUserId;
    return _policy.canPerform(userId: newUserId, action: action);
  }

  static Future<_AuthGuardResult?> _showLoginRequiredSheet(
    BuildContext context,
    ParticipationAction action,
  ) {
    return showModalBottomSheet<_AuthGuardResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        String actionLabel;
        switch (action) {
          case ParticipationAction.vote:
            actionLabel = 'votare';
            break;
          case ParticipationAction.createPoll:
            actionLabel = 'creare una votazione';
            break;
          case ParticipationAction.react:
            actionLabel = 'reagire con 🔥 o ❄';
            break;
          case ParticipationAction.comment:
            actionLabel = 'commentare';
            break;
          case ParticipationAction.createPost:
            actionLabel = 'creare un post';
            break;
          case ParticipationAction.followScope:
            actionLabel = 'seguire quest\'area geografica';
            break;
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                'Vuoi partecipare?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Per $actionLabel devi accedere o registrarti. '
                'Come ospite puoi solo visualizzare contenuti.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // LOGIN
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await AppDI.instance.sessionRepository
                            .saveCurrentUserId('user-1');
                        if (!sheetContext.mounted) return;
                        Navigator.of(sheetContext)
                            .pop(_AuthGuardResult.loggedIn);
                      },
                      child: const Text('Accedi'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newUserId =
                            'user-${DateTime.now().millisecondsSinceEpoch}';
                        await AppDI.instance.sessionRepository
                            .saveCurrentUserId(newUserId);
                        if (!sheetContext.mounted) return;
                        Navigator.of(sheetContext)
                            .pop(_AuthGuardResult.loggedIn);
                      },
                      child: const Text('Registrati'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  Navigator.of(sheetContext)
                      .pop(_AuthGuardResult.cancelled);
                },
                child: const Text('Continua come ospite'),
              ),
            ],
          ),
        );
      },
    );
  }
}
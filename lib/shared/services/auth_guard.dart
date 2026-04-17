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
  /// I parametri identity aggiuntivi sono opzionali:
  /// se non vengono passati, la guard prova a risolverli automaticamente
  /// da sessione e profilo corrente.
  static Future<bool> ensureCanPerformAction(
    BuildContext context,
    ParticipationAction action, {
    Role? role,
    ActorType? actorType,
    VerificationLevel? verificationLevel,
    InstitutionLevel? institutionLevel,
  }) async {
    var resolvedIdentity = await _resolveIdentityContext(
      role: role,
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    );

    if (_policy.canPerform(
      userId: resolvedIdentity.userId,
      action: action,
      role: resolvedIdentity.role,
      actorType: resolvedIdentity.actorType,
      verificationLevel: resolvedIdentity.verificationLevel,
      institutionLevel: resolvedIdentity.institutionLevel,
    )) {
      return true;
    }

    if (resolvedIdentity.userId == null) {
      await _showLoginRequiredSheet(context, action);

      resolvedIdentity = await _resolveIdentityContext(
        role: role,
        actorType: actorType,
        verificationLevel: verificationLevel,
        institutionLevel: institutionLevel,
      );

      return _policy.canPerform(
        userId: resolvedIdentity.userId,
        action: action,
        role: resolvedIdentity.role,
        actorType: resolvedIdentity.actorType,
        verificationLevel: resolvedIdentity.verificationLevel,
        institutionLevel: resolvedIdentity.institutionLevel,
      );
    }

    await _showPermissionDeniedDialog(context, action);
    return false;
  }

  /// Wrapper centrale per ruolo reviewer/admin.
  static bool canReviewVerificationRequests({
    required Role role,
  }) {
    return _policy.canReviewVerificationRequests(role: role);
  }

  /// Wrapper centrale per feature prodotto disponibili a identità verified.
  static bool canUseVerifiedIdentityFeatures({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return _policy.canUseVerifiedIdentityFeatures(
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    );
  }

  /// Wrapper centrale per feature che richiedono level2 pieno.
  static bool canUseLevel2IdentityFeatures({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return _policy.canUseLevel2IdentityFeatures(
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    );
  }

  /// Wrapper centrale per feature da attore rappresentativo
  /// (public official / institution).
  static bool canUseRepresentativeIdentityFeatures({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return _policy.canUseRepresentativeIdentityFeatures(
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    );
  }

  /// Wrapper centrale per feature strettamente istituzionali.
  static bool canUseInstitutionIdentityFeatures({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return _policy.canUseInstitutionIdentityFeatures(
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    );
  }

  static Future<_ResolvedAuthIdentity> _resolveIdentityContext({
    Role? role,
    ActorType? actorType,
    VerificationLevel? verificationLevel,
    InstitutionLevel? institutionLevel,
  }) async {
    final userId = AppDI.instance.currentUserId;

    Role resolvedRole = role ?? Role.user;
    ActorType resolvedActorType = actorType ?? ActorType.citizen;
    VerificationLevel resolvedVerificationLevel =
        verificationLevel ?? VerificationLevel.none;
    InstitutionLevel? resolvedInstitutionLevel = institutionLevel;

    if (userId != null && role == null) {
      try {
        final session = await AppDI.instance.sessionRepository.getCurrentSession();
        resolvedRole = session?.role ?? Role.user;
      } catch (_) {
        resolvedRole = Role.user;
      }
    }

    final needsProfileLookup = userId != null &&
        (actorType == null ||
            verificationLevel == null ||
            institutionLevel == null);

    if (needsProfileLookup) {
      try {
        final profile = await AppDI.instance.getUserProfile(userId!);
        if (profile != null) {
          resolvedActorType = actorType ?? profile.actorType;
          resolvedVerificationLevel =
              verificationLevel ?? profile.verificationLevel;
          resolvedInstitutionLevel =
              institutionLevel ?? profile.institutionLevel;
        }
      } catch (_) {
        // Manteniamo i fallback safe già impostati sopra.
      }
    }

    return _ResolvedAuthIdentity(
      userId: userId,
      role: resolvedRole,
      actorType: resolvedActorType,
      verificationLevel: resolvedVerificationLevel,
      institutionLevel: resolvedInstitutionLevel,
    );
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

class _ResolvedAuthIdentity {
  final String? userId;
  final Role role;
  final ActorType actorType;
  final VerificationLevel verificationLevel;
  final InstitutionLevel? institutionLevel;

  const _ResolvedAuthIdentity({
    required this.userId,
    required this.role,
    required this.actorType,
    required this.verificationLevel,
    required this.institutionLevel,
  });
}
import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/shared/ui/ui.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';

/// Guard centrale per azioni protette (vote, comment, react, createPoll, ecc).
///
/// Tutta la UI deve passare da qui prima di eseguire
/// un’azione di partecipazione.
class AuthGuard {
  static const ParticipationPolicy _policy = ParticipationPolicy();

  static bool _isItalian(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'it';

  /// Verifica che esista una sessione autenticata valida per una feature
  /// protetta che non è rappresentata da una ParticipationAction.
  ///
  /// Non usare questo metodo per semplice esplorazione pubblica come
  /// cambio GeoScope o apertura della Civic Map.
  /// Guest -> mostra login/registrazione e ritorna true solo se, al rientro,
  /// esiste davvero un utente autenticato.
  static Future<bool> ensureAuthenticated(
    BuildContext context, {
    required String actionLabel,
  }) async {
    final hasValidSession = await _ensureCurrentSessionIsValid(context);
    if (!hasValidSession) {
      return false;
    }

    final currentUserId = AppDI.instance.currentUserId?.trim();
    if (currentUserId != null && currentUserId.isNotEmpty) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

    await _showFeatureLoginRequiredSheet(
      context,
      actionLabel: actionLabel,
    );

    final resolvedUserId = AppDI.instance.currentUserId?.trim();
    return resolvedUserId != null && resolvedUserId.isNotEmpty;
  }

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
    final hasValidSession = await _ensureCurrentSessionIsValid(context);
    if (!hasValidSession) {
      return false;
    }

    // Per le azioni Admin Center il ruolo deve provenire sempre dalla
    // sessione corrente, mai da un valore fornito dalla UI chiamante.
    final roleForResolution = _isAdminCenterAction(action) ? null : role;

    var resolvedIdentity = await _resolveIdentityContext(
      role: roleForResolution,
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

    if (!context.mounted) {
      return false;
    }

    if (resolvedIdentity.userId == null) {
      await _showLoginRequiredSheet(context, action);

      resolvedIdentity = await _resolveIdentityContext(
        role: roleForResolution,
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

  static Future<bool> _ensureCurrentSessionIsValid(
    BuildContext context,
  ) async {
    if (AppDI.instance.currentUserId == null) {
      return true;
    }

    bool isValid;
    try {
      final result = await AppSupabase.client.rpc(
        'is_current_auth_user_active',
      );
      isValid = result == true;
    } catch (_) {
      // Un errore di rete non deve causare un logout falso.
      // Le policy RLS continuano comunque a proteggere il backend.
      return true;
    }

    if (isValid) {
      return true;
    }

    try {
      await AppDI.instance.logoutCurrentUser();
    } catch (_) {
      // logoutCurrentUser pulisce comunque la sessione locale nel finally.
    }

    if (!context.mounted) {
      return false;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _isItalian(dialogContext)
                ? 'Sessione terminata'
                : deOrEnglish(context,
                    english: 'Session ended', german: 'Sitzung beendet'),
          ),
          content: Text(
            _isItalian(dialogContext)
                ? 'Questo account è stato aperto su un altro dispositivo oppure non è più disponibile. Accedi di nuovo per continuare.'
                : deOrEnglish(context,
                    english:
                        'This account was opened on another device or is no longer available. Sign in again to continue.',
                    german:
                        'Dieses Konto wurde auf einem anderen Gerät geöffnet oder ist nicht mehr verfügbar. Melde dich erneut an, um fortzufahren.'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.home,
        (route) => false,
      );
    }

    return false;
  }

  /// Accesso alla shell Admin Center per moderator/admin.
  static bool canAccessAdminCenter({
    required Role role,
  }) {
    return _policy.canAccessAdminCenter(role: role);
  }

  /// Wrapper centrale per ruolo reviewer/admin.
  static bool canReviewVerificationRequests({
    required Role role,
  }) {
    return _policy.canReviewVerificationRequests(role: role);
  }

  /// Gestione delle segnalazioni per moderator/admin.
  static bool canReviewReports({
    required Role role,
  }) {
    return _policy.canReviewReports(role: role);
  }

  /// Gestione dei ruoli tecnici riservata agli admin.
  static bool canManageSystemRoles({
    required Role role,
  }) {
    return _policy.canManageSystemRoles(role: role);
  }

  /// Azioni amministrative sugli account riservate agli admin.
  static bool canManageAccounts({
    required Role role,
  }) {
    return _policy.canManageAccounts(role: role);
  }

  /// Consultazione dell'audit amministrativo riservata agli admin.
  static bool canViewAdminAuditLog({
    required Role role,
  }) {
    return _policy.canViewAdminAuditLog(role: role);
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

  static bool _isAdminCenterAction(ParticipationAction action) {
    switch (action) {
      case ParticipationAction.accessAdminCenter:
      case ParticipationAction.reviewVerificationRequests:
      case ParticipationAction.reviewReports:
      case ParticipationAction.manageSystemRoles:
      case ParticipationAction.manageAccounts:
      case ParticipationAction.viewAdminAuditLog:
        return true;
      case ParticipationAction.vote:
      case ParticipationAction.createPoll:
      case ParticipationAction.react:
      case ParticipationAction.comment:
      case ParticipationAction.createPost:
      case ParticipationAction.followScope:
      case ParticipationAction.reportContent:
        return false;
    }
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
        final session =
            await AppDI.instance.sessionRepository.getCurrentSession();
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
        final profile = await AppDI.instance.getUserProfile(userId);
        resolvedActorType = actorType ?? profile.actorType;
        resolvedVerificationLevel =
            verificationLevel ?? profile.verificationLevel;
        resolvedInstitutionLevel = institutionLevel ?? profile.institutionLevel;
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

  static Future<void> _showFeatureLoginRequiredSheet(
    BuildContext context, {
    required String actionLabel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetRadius,
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        Future<void> openAuthFlow(String routeName) async {
          // Keep the sheet alive while login/register is open. Closing it
          // first would let the caller resume before authentication finishes.
          await Navigator.of(context).pushNamed(routeName);

          if (sheetContext.mounted) {
            Navigator.of(sheetContext).pop();
          }
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
                _isItalian(sheetContext)
                    ? 'Accesso richiesto'
                    : deOrEnglish(context,
                        english: 'Sign-in required',
                        german: 'Anmeldung erforderlich'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _isItalian(sheetContext)
                    ? 'Per $actionLabel devi accedere o registrarti. Come ospite puoi consultare i contenuti pubblici.'
                    : deOrEnglish(context,
                        english:
                            'To $actionLabel, sign in or create an account. As a guest you can browse public content.',
                        german:
                            'Um $actionLabel, melde dich an oder erstelle ein Konto. Als Gast kannst du öffentliche Inhalte ansehen.'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: _isItalian(sheetContext)
                          ? 'Accedi'
                          : deOrEnglish(context,
                              english: 'Log in', german: 'Anmelden'),
                      onPressed: () => openAuthFlow(AppRouter.login),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: AppButton.primary(
                      label: _isItalian(sheetContext)
                          ? 'Registrati'
                          : deOrEnglish(context,
                              english: 'Sign up', german: 'Registrieren'),
                      onPressed: () => openAuthFlow(AppRouter.register),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton.text(
                label: _isItalian(sheetContext)
                    ? 'Continua come ospite'
                    : deOrEnglish(context,
                        english: 'Continue as guest',
                        german: 'Als Gast fortfahren'),
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
        final actionLabel = _actionLabel(sheetContext, action);

        Future<void> openAuthFlow(String routeName) async {
          // Keep the sheet alive while login/register is open so the protected
          // action resumes only after the auth route has completed.
          await Navigator.of(context).pushNamed(routeName);

          if (sheetContext.mounted) {
            Navigator.of(sheetContext).pop();
          }
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
                _isItalian(sheetContext)
                    ? 'Vuoi partecipare?'
                    : deOrEnglish(context,
                        english: 'Want to participate?',
                        german: 'Möchtest du teilnehmen?'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _isItalian(sheetContext)
                    ? 'Per $actionLabel devi accedere o registrarti. Come ospite puoi solo visualizzare contenuti.'
                    : deOrEnglish(context,
                        english:
                            'To $actionLabel, sign in or create an account. As a guest you can only view content.',
                        german:
                            'Um $actionLabel, melde dich an oder erstelle ein Konto. Als Gast kannst du Inhalte nur ansehen.'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: _isItalian(sheetContext)
                          ? 'Accedi'
                          : deOrEnglish(context,
                              english: 'Log in', german: 'Anmelden'),
                      onPressed: () => openAuthFlow(AppRouter.login),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: AppButton.primary(
                      label: _isItalian(sheetContext)
                          ? 'Registrati'
                          : deOrEnglish(context,
                              english: 'Sign up', german: 'Registrieren'),
                      onPressed: () => openAuthFlow(AppRouter.register),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton.text(
                label: _isItalian(sheetContext)
                    ? 'Continua come ospite'
                    : deOrEnglish(context,
                        english: 'Continue as guest',
                        german: 'Als Gast fortfahren'),
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
          title: Text(
            _isItalian(dialogContext)
                ? 'Accesso negato'
                : deOrEnglish(context,
                    english: 'Access denied', german: 'Zugriff verweigert'),
          ),
          content: Text(_permissionDeniedMessage(dialogContext, action)),
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

  static String _permissionDeniedMessage(
    BuildContext context,
    ParticipationAction action,
  ) {
    final isItalian = _isItalian(context);
    switch (action) {
      case ParticipationAction.accessAdminCenter:
      case ParticipationAction.reviewVerificationRequests:
      case ParticipationAction.reviewReports:
        return isItalian
            ? 'Questa area è riservata a moderator/admin.'
            : deOrEnglish(context,
                english: 'This area is restricted to moderators and admins.',
                german:
                    'Dieser Bereich ist Moderatoren und Administratoren vorbehalten.');
      case ParticipationAction.manageSystemRoles:
      case ParticipationAction.manageAccounts:
      case ParticipationAction.viewAdminAuditLog:
        return isItalian
            ? 'Questa azione è riservata agli admin.'
            : deOrEnglish(context,
                english: 'This action is restricted to admins.',
                german: 'Diese Aktion ist Administratoren vorbehalten.');
      case ParticipationAction.vote:
      case ParticipationAction.createPoll:
      case ParticipationAction.react:
      case ParticipationAction.comment:
      case ParticipationAction.createPost:
      case ParticipationAction.followScope:
      case ParticipationAction.reportContent:
        return isItalian
            ? 'Non hai i permessi necessari per questa azione.'
            : deOrEnglish(context,
                english: 'You do not have permission to perform this action.',
                german:
                    'Du hast keine Berechtigung, diese Aktion auszuführen.');
    }
  }

  static String _actionLabel(
    BuildContext context,
    ParticipationAction action,
  ) {
    final isItalian = _isItalian(context);
    switch (action) {
      case ParticipationAction.vote:
        return isItalian
            ? 'votare'
            : deOrEnglish(context, english: 'vote', german: 'abzustimmen');
      case ParticipationAction.createPoll:
        return isItalian
            ? 'creare un sondaggio'
            : deOrEnglish(context,
                english: 'create a poll', german: 'eine Umfrage zu erstellen');
      case ParticipationAction.react:
        return isItalian
            ? 'reagire con 🔥 o ❄'
            : deOrEnglish(context,
                english: 'react with 🔥 or ❄',
                german: 'mit 🔥 oder ❄ zu reagieren');
      case ParticipationAction.comment:
        return isItalian
            ? 'commentare'
            : deOrEnglish(context,
                english: 'comment', german: 'zu kommentieren');
      case ParticipationAction.createPost:
        return isItalian
            ? 'creare un post'
            : deOrEnglish(context,
                english: 'create a post', german: 'einen Beitrag zu erstellen');
      case ParticipationAction.followScope:
        return isItalian
            ? 'seguire quest\'area geografica'
            : deOrEnglish(context,
                english: 'follow this geographic area',
                german: 'diesem geografischen Bereich zu folgen');
      case ParticipationAction.reportContent:
        return isItalian
            ? 'segnalare un contenuto'
            : deOrEnglish(context,
                english: 'report content', german: 'Inhalte zu melden');
      case ParticipationAction.accessAdminCenter:
        return isItalian
            ? 'accedere all\'Admin Center'
            : deOrEnglish(context,
                english: 'open the Admin Center',
                german: 'das Admin Center zu öffnen');
      case ParticipationAction.reviewVerificationRequests:
        return isItalian
            ? 'revisionare richieste di verifica'
            : deOrEnglish(context,
                english: 'review verification requests',
                german: 'Verifizierungsanfragen zu prüfen');
      case ParticipationAction.reviewReports:
        return isItalian
            ? 'gestire le segnalazioni'
            : deOrEnglish(context,
                english: 'review reports', german: 'Meldungen zu prüfen');
      case ParticipationAction.manageSystemRoles:
        return isItalian
            ? 'gestire i ruoli di sistema'
            : deOrEnglish(context,
                english: 'manage system roles',
                german: 'Systemrollen zu verwalten');
      case ParticipationAction.manageAccounts:
        return isItalian
            ? 'gestire gli account'
            : deOrEnglish(context,
                english: 'manage accounts', german: 'Konten zu verwalten');
      case ParticipationAction.viewAdminAuditLog:
        return isItalian
            ? 'consultare il registro amministrativo'
            : deOrEnglish(context,
                english: 'view the admin activity log',
                german: 'das Admin-Aktivitätsprotokoll anzuzeigen');
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

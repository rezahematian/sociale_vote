import 'dart:async';

import 'package:flutter/material.dart';

// R3_ACCOUNT_GROUPED_LAYOUT_V2
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';
import 'package:sociale_vote/features/profile/application/profile_controller.dart';
import 'package:sociale_vote/features/profile/application/verification_requests_controller.dart';
import 'package:sociale_vote/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_comments_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_favorites_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_followed_scopes_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_polls_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_posts_page.dart';
import 'package:sociale_vote/shared/services/biometric_unlock_service.dart';
import 'package:sociale_vote/shared/widgets/user_identity_mark.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String? currentUserId = AppDI.instance.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.homeAccountMenuLabel),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.profileLoginRequiredMessage,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileController(
            getUserProfile: AppDI.instance.getUserProfile,
            updateUserProfile: AppDI.instance.updateUserProfile,
          )..loadProfile(currentUserId),
        ),
        ChangeNotifierProvider(
          create: (_) => AppDI.instance.createVerificationRequestsController()
            ..load(currentUserId),
        ),
      ],
      child: _MyProfileView(currentUserId: currentUserId),
    );
  }
}

class _MyProfileView extends StatefulWidget {
  final String currentUserId;

  const _MyProfileView({
    required this.currentUserId,
  });

  @override
  State<_MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<_MyProfileView> {
  late Future<int> _unreadNotificationsFuture;
  final BiometricUnlockService _biometricService = BiometricUnlockService();

  bool _isDeletingAccount = false;
  bool _biometricLoading = true;
  bool _biometricBusy = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _rememberMeEnabled = false;

  String get currentUserId => widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _unreadNotificationsFuture = _loadUnreadNotificationsCount();
    unawaited(_loadBiometricState());
  }

  Future<int> _loadUnreadNotificationsCount() {
    return AppDI.instance.getUnreadNotificationsCount(currentUserId);
  }

  void _refreshUnreadNotificationsCount() {
    setState(() {
      _unreadNotificationsFuture = _loadUnreadNotificationsCount();
    });
  }

  Future<void> _loadBiometricState() async {
    final storage = AppDI.instance.storageService;

    try {
      final rememberMe = await storage.readRememberMe();
      var enabled = await storage.readBiometricUnlockEnabled();
      final available = await _biometricService.canUseBiometrics();

      // Biometric unlock has no session to protect when Remember Me is off.
      if (!rememberMe && enabled) {
        await storage.writeBiometricUnlockEnabled(false);
        enabled = false;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _rememberMeEnabled = rememberMe;
        _biometricAvailable = available;
        _biometricEnabled = enabled;
        _biometricLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _biometricAvailable = false;
        _biometricEnabled = false;
        _biometricLoading = false;
      });
    }
  }

  Future<void> _setBiometricEnabled(bool value) async {
    if (_biometricBusy || _biometricLoading) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final storage = AppDI.instance.storageService;

    if (!value) {
      setState(() {
        _biometricBusy = true;
      });

      try {
        await storage.writeBiometricUnlockEnabled(false);
      } finally {
        if (mounted) {
          setState(() {
            _biometricBusy = false;
            _biometricEnabled = false;
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileBiometricDisabledMessage),
          ),
        );
      }
      return;
    }

    if (!_rememberMeEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileBiometricRequiresRememberMe),
        ),
      );
      return;
    }

    if (!_biometricAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileBiometricUnavailable),
        ),
      );
      return;
    }

    setState(() {
      _biometricBusy = true;
    });

    final authenticated = await _biometricService.authenticate(
      localizedReason: l10n.profileBiometricEnableReason,
    );

    if (!mounted) {
      return;
    }

    if (!authenticated) {
      setState(() {
        _biometricBusy = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileBiometricAuthFailedMessage),
        ),
      );
      return;
    }

    await storage.writeBiometricUnlockEnabled(true);

    if (!mounted) {
      return;
    }

    setState(() {
      _biometricBusy = false;
      _biometricEnabled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.profileBiometricEnabledMessage),
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final controller = context.read<ProfileController>();

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditProfilePage(),
      ),
    );

    if (result == true && mounted) {
      await controller.loadProfile(currentUserId);
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).pushNamed(AppRouter.notifications);

    if (!mounted) return;
    _refreshUnreadNotificationsCount();
  }

  Future<void> _showThemeModeSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final currentMode = AppThemeModeController.themeMode.value;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: RadioGroup<ThemeMode>(
            groupValue: currentMode,
            onChanged: (value) {
              if (value == null) return;
              AppThemeModeController.setThemeMode(value);
              Navigator.of(sheetContext).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(l10n.profileThemeSystem),
                  subtitle: Text(l10n.profileThemeSystemDescription),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text(l10n.profileThemeLight),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text(l10n.profileThemeDark),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showAppLanguageSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguageCode =
        AppLocaleController.locale.value?.languageCode ?? 'system';

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: RadioGroup<String>(
            groupValue: currentLanguageCode,
            onChanged: (value) {
              if (value == null) return;

              final locale = switch (value) {
                'it' => const Locale('it'),
                'en' => const Locale('en'),
                _ => null,
              };

              unawaited(AppLocaleController.setLocale(locale));
              Navigator.of(sheetContext).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: 'system',
                  title: Text(l10n.profileAppLanguageSystem),
                  subtitle: Text(
                    l10n.profileAppLanguageSystemDescription,
                  ),
                ),
                RadioListTile<String>(
                  value: 'it',
                  title: Text(l10n.profileAppLanguageItalian),
                ),
                RadioListTile<String>(
                  value: 'en',
                  title: Text(l10n.profileAppLanguageEnglish),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showVerificationCenter({
    required UserProfile? profile,
    required VerificationRequest? pendingRequest,
    required VerificationRequest? latestRejectedRequest,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final actorType = profile?.actorType ?? ActorType.citizen;
    final verificationLevel =
        profile?.verificationLevel ?? VerificationLevel.none;
    final verificationStatus =
        profile?.verificationStatus ?? VerificationStatus.none;
    final institutionLevel = profile?.institutionLevel;

    final actorTypeLabel = _formatActorTypeLabel(l10n, actorType);
    final verificationLevelLabel =
        _formatVerificationLevelLabel(l10n, verificationLevel);
    final institutionLevelLabel =
        _formatInstitutionLevelLabel(l10n, institutionLevel);
    final identityDetailLabel = profile?.identityDetailLabel;
    final primaryIdentityBadgeLabel =
        profile == null ? null : _primaryIdentityBadgeLabel(l10n, profile);
    final secondaryIdentityBadgeLabel =
        profile?.isInstitutionActor == true ? institutionLevelLabel : null;
    final hasIdentityBadges = primaryIdentityBadgeLabel != null ||
        secondaryIdentityBadgeLabel != null;

    final hasPendingRequest = pendingRequest != null;
    final hasRejectedState = !hasPendingRequest &&
        verificationStatus == VerificationStatus.rejected &&
        latestRejectedRequest != null;
    final hasPendingState =
        hasPendingRequest || verificationStatus == VerificationStatus.pending;
    final rejectionNote = latestRejectedRequest?.reviewNote?.trim();

    final canRequestCitizenLevel1 = actorType == ActorType.citizen &&
        verificationLevel == VerificationLevel.none;
    final canRequestCitizenLevel2 = actorType == ActorType.citizen &&
        verificationLevel != VerificationLevel.level2;
    final canRequestPublicOfficial = actorType == ActorType.citizen;
    final canRequestInstitution = actorType == ActorType.citizen;
    final canRequestOrganization = actorType == ActorType.citizen;

    final hasAvailableUpgradeActions = !hasPendingState &&
        (canRequestCitizenLevel1 ||
            canRequestCitizenLevel2 ||
            canRequestPublicOfficial ||
            canRequestInstitution ||
            canRequestOrganization);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.verificationCenterTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.verificationCurrentAccountSection,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(l10n.verificationAccountTypeValue(actorTypeLabel)),
                    if (profile != null &&
                        UserIdentityMark.shouldShowForProfile(profile))
                      UserIdentityMark.fromProfile(
                        profile,
                        size: 16,
                      ),
                  ],
                ),
                if (actorType == ActorType.citizen)
                  Text(
                    l10n.verificationLevelValue(verificationLevelLabel),
                  ),
                if (identityDetailLabel != null)
                  Text(
                    switch (actorType) {
                      ActorType.publicOfficial =>
                        l10n.verificationOfficialTitleValue(
                          identityDetailLabel,
                        ),
                      ActorType.institution =>
                        l10n.verificationInstitutionNameValue(
                          identityDetailLabel,
                        ),
                      ActorType.organization =>
                        l10n.verificationOrganizationNameValue(
                          identityDetailLabel,
                        ),
                      ActorType.citizen => identityDetailLabel,
                    },
                  ),
                if (institutionLevelLabel != null)
                  Text(
                    l10n.verificationInstitutionLevelValue(
                      institutionLevelLabel,
                    ),
                  ),
                if (hasIdentityBadges) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (primaryIdentityBadgeLabel != null)
                        _IdentityBadgeChip(
                          label: primaryIdentityBadgeLabel,
                          isPrimary: true,
                        ),
                      if (secondaryIdentityBadgeLabel != null)
                        _IdentityBadgeChip(
                          label: secondaryIdentityBadgeLabel,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (hasPendingState) ...[
                  Text(
                    l10n.verificationActiveRequestSection,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (pendingRequest != null) ...[
                    Text(
                      _formatVerificationRequestTypeLabel(
                        l10n,
                        pendingRequest.requestType,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.verificationProfileUnchangedUntilApproval,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          await _confirmCancelPendingRequest();
                        },
                        icon: const Icon(Icons.close_rounded),
                        label: Text(l10n.verificationCancelPendingAction),
                      ),
                    ),
                  ] else ...[
                    Text(
                      l10n.verificationPendingBlocksNewRequests,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ] else ...[
                  Text(
                    l10n.verificationNoActiveRequestSection,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.verificationNoActiveRequestDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (hasRejectedState) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.verificationLastRejectedSection,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.verificationLastRejectedDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (rejectionNote != null && rejectionNote.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${l10n.verificationReviewRequiredNoteLabel}: ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(text: rejectionNote),
                          ],
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      l10n.verificationRejectedCanResubmit,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                Text(
                  l10n.verificationAvailableRequestsSection,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                if (hasAvailableUpgradeActions) ...[
                  if (canRequestCitizenLevel1)
                    _VerificationActionTile(
                      title: l10n.verificationRequestLevel1Title,
                      subtitle: l10n.verificationRequestLevel1Subtitle,
                      icon: Icons.verified_outlined,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _submitCitizenVerificationRequest(
                          VerificationRequestType.citizenLevel1,
                        );
                      },
                    ),
                  if (canRequestCitizenLevel2)
                    _VerificationActionTile(
                      title: l10n.verificationRequestLevel2Title,
                      subtitle: l10n.verificationRequestLevel2Subtitle,
                      icon: Icons.verified_user_outlined,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _submitCitizenVerificationRequest(
                          VerificationRequestType.citizenLevel2,
                        );
                      },
                    ),
                  if (canRequestPublicOfficial)
                    _VerificationActionTile(
                      title: l10n.verificationRequestPublicOfficialTitle,
                      subtitle: l10n.verificationRequestPublicOfficialSubtitle,
                      icon: Icons.badge_outlined,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _promptPublicOfficialRequest();
                      },
                    ),
                  if (canRequestInstitution)
                    _VerificationActionTile(
                      title: l10n.verificationRequestPublicInstitutionTitle,
                      subtitle:
                          l10n.verificationRequestPublicInstitutionSubtitle,
                      icon: Icons.account_balance_outlined,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _promptInstitutionRequest();
                      },
                    ),
                  if (canRequestOrganization)
                    _VerificationActionTile(
                      title: l10n.verificationRequestOrganizationTitle,
                      subtitle: l10n.verificationRequestOrganizationSubtitle,
                      icon: Icons.corporate_fare_outlined,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _promptOrganizationRequest();
                      },
                    ),
                ] else if (hasPendingState) ...[
                  Text(
                    l10n.verificationPendingBlocksNewRequests,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ] else ...[
                  Text(
                    l10n.verificationNoSelfServiceUpgrade,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitCitizenVerificationRequest(
    VerificationRequestType requestType,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<VerificationRequestsController>();
    final success = await controller.createRequest(
      userId: currentUserId,
      requestType: requestType,
    );

    if (!mounted) return;

    final message = success
        ? l10n.verificationRequestSubmitSuccess
        : (controller.errorMessage ?? l10n.verificationRequestSubmitFailure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _promptPublicOfficialRequest() async {
    final l10n = AppLocalizations.of(context)!;
    var officialTitle = '';

    final submittedTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.verificationOfficialTitleDialogTitle),
          content: TextField(
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.verificationOfficialTitleLabel,
              hintText: l10n.verificationOfficialTitleHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              officialTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancelButton),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(officialTitle.trim());
              },
              child: Text(l10n.verificationSubmitRequestAction),
            ),
          ],
        );
      },
    );

    if (!mounted || submittedTitle == null) return;

    final controller = context.read<VerificationRequestsController>();
    final success = await controller.createRequest(
      userId: currentUserId,
      requestType: VerificationRequestType.publicOfficial,
      officialTitle: submittedTitle,
    );

    if (!mounted) return;

    final message = success
        ? l10n.verificationRequestSubmitSuccess
        : (controller.errorMessage ?? l10n.verificationRequestSubmitFailure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _promptInstitutionRequest() async {
    final l10n = AppLocalizations.of(context)!;
    var institutionName = '';

    final draft = await showDialog<_InstitutionRequestDraft>(
      context: context,
      builder: (dialogContext) {
        InstitutionLevel? selectedLevel;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(l10n.verificationInstitutionDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.verificationInstitutionNameLabel,
                      hintText: l10n.verificationInstitutionNameHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      institutionName = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<InstitutionLevel>(
                    initialValue: selectedLevel,
                    decoration: InputDecoration(
                      labelText: l10n.verificationInstitutionLevelLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: InstitutionLevel.values
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(
                              _formatInstitutionLevelLabel(l10n, level)!,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setLocalState(() {
                        selectedLevel = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.commonCancelButton),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(
                      _InstitutionRequestDraft(
                        institutionName: institutionName.trim(),
                        institutionLevel: selectedLevel,
                      ),
                    );
                  },
                  child: Text(l10n.verificationSubmitRequestAction),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || draft == null) return;

    final controller = context.read<VerificationRequestsController>();
    final success = await controller.createRequest(
      userId: currentUserId,
      requestType: VerificationRequestType.institution,
      institutionName: draft.institutionName,
      targetInstitutionLevel: draft.institutionLevel,
    );

    if (!mounted) return;

    final message = success
        ? l10n.verificationRequestSubmitSuccess
        : (controller.errorMessage ?? l10n.verificationRequestSubmitFailure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _promptOrganizationRequest() async {
    final l10n = AppLocalizations.of(context)!;
    var organizationName = '';

    final submittedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.verificationOrganizationDialogTitle),
          content: TextField(
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.identityOrganizationNameLabel,
              hintText: l10n.verificationOrganizationNameHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              organizationName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancelButton),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(organizationName.trim());
              },
              child: Text(l10n.verificationSubmitRequestAction),
            ),
          ],
        );
      },
    );

    if (!mounted || submittedName == null) return;

    final controller = context.read<VerificationRequestsController>();
    final success = await controller.createRequest(
      userId: currentUserId,
      requestType: VerificationRequestType.organization,
      organizationName: submittedName,
    );

    if (!mounted) return;

    final message = success
        ? l10n.verificationRequestSubmitSuccess
        : (controller.errorMessage ?? l10n.verificationRequestSubmitFailure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmCancelPendingRequest() async {
    final l10n = AppLocalizations.of(context)!;
    final verificationController =
        context.read<VerificationRequestsController>();

    final shouldCancel = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(l10n.verificationCancelDialogTitle),
              content: Text(l10n.verificationCancelDialogBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.commonCancelButton),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.verificationCancelPendingAction),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldCancel) return;

    final success =
        await verificationController.cancelPendingRequest(currentUserId);

    if (!mounted) return;

    final message = success
        ? l10n.verificationCancelSuccess
        : (verificationController.errorMessage ??
            l10n.verificationCancelFailure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(l10n.profileLogoutDialogTitle),
              content: Text(l10n.profileLogoutDialogMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.profileLogoutCancelButton),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.profileLogoutConfirmButton),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLogout) return;

    await AppDI.instance.logoutCurrentUser();
    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    var confirmationMatches = false;

    final shouldDelete = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                return AlertDialog(
                  title: Text(l10n.profileDeleteAccountDialogTitle),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.profileDeleteAccountDialogMessage),
                      const SizedBox(height: 16),
                      TextField(
                        autofocus: true,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: l10n.profileDeleteAccountConfirmationLabel,
                          hintText: l10n.profileDeleteAccountConfirmationHint,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            confirmationMatches = value.trim() == 'DELETE';
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(l10n.profileDeleteAccountCancelButton),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(dialogContext).colorScheme.error,
                        foregroundColor:
                            Theme.of(dialogContext).colorScheme.onError,
                      ),
                      onPressed: confirmationMatches
                          ? () => Navigator.of(dialogContext).pop(true)
                          : null,
                      child: Text(l10n.profileDeleteAccountConfirmButton),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;

    if (!shouldDelete || !mounted) return;

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      await AppDI.instance.deleteCurrentUser();

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileDeleteAccountFailureMessage),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<ProfileController>();
    final verificationController =
        context.watch<VerificationRequestsController>();
    final profile = controller.profile;

    final avatarUrl = profile?.avatarUrl?.trim() ?? '';
    final displayName = profile?.displayName?.trim() ?? '';
    final username = profile?.username?.trim() ?? '';
    final bio = profile?.bio?.trim() ?? '';
    final country = profile?.country?.trim() ?? '';
    final city = profile?.city?.trim() ?? '';
    final accountEmail =
        Supabase.instance.client.auth.currentUser?.email?.trim() ?? '';

    final actorType = profile?.actorType ?? ActorType.citizen;
    final verificationLevel =
        profile?.verificationLevel ?? VerificationLevel.none;
    final institutionLevel = profile?.institutionLevel;
    final verificationStatus =
        profile?.verificationStatus ?? VerificationStatus.none;
    final pendingRequest = verificationController.pendingRequest;
    final rejectedRequests =
        verificationController.requests.where((request) => request.isRejected);
    final latestRejectedRequest =
        rejectedRequests.isEmpty ? null : rejectedRequests.first;

    final accountStatusLabel = _accountStatusLabel(
      l10n: l10n,
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    );
    final verificationTileSubtitle = _verificationTileSubtitle(
      l10n: l10n,
      accountStatusLabel: accountStatusLabel,
      verificationStatus: verificationStatus,
      pendingRequest: pendingRequest,
    );
    final locationLabel = finalLocation(city: city, country: country);
    final identityDetailLabel = profile?.identityDetailLabel;
    final primaryIdentityBadgeLabel =
        profile == null ? null : _primaryIdentityBadgeLabel(l10n, profile);
    final secondaryIdentityBadgeLabel = profile?.isInstitutionActor == true
        ? _formatInstitutionLevelLabel(l10n, institutionLevel)
        : null;
    final hasIdentityBadges = primaryIdentityBadgeLabel != null ||
        secondaryIdentityBadgeLabel != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeAccountMenuLabel),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait<void>([
            context.read<ProfileController>().loadProfile(currentUserId),
            context.read<VerificationRequestsController>().load(currentUserId),
          ]);
          _refreshUnreadNotificationsCount();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _SectionTitle(l10n.profilePublicProfileSectionTitle),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: controller.isLoading && profile == null
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundImage: avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 32)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          displayName.isNotEmpty
                                              ? displayName
                                              : l10n.notificationsUserFallback,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (profile != null &&
                                            UserIdentityMark
                                                .shouldShowForProfile(profile))
                                          UserIdentityMark.fromProfile(
                                            profile,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    if (username.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '@$username',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    if (identityDetailLabel != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        identityDetailLabel,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (primaryIdentityBadgeLabel != null)
                                          _IdentityBadgeChip(
                                            label: primaryIdentityBadgeLabel,
                                            isPrimary: true,
                                          ),
                                        if (secondaryIdentityBadgeLabel != null)
                                          _IdentityBadgeChip(
                                            label: secondaryIdentityBadgeLabel,
                                          ),
                                        if (!hasIdentityBadges)
                                          _StatusChip(
                                            icon: Icons.shield_outlined,
                                            label: accountStatusLabel,
                                          ),
                                        if (locationLabel != null)
                                          _StatusChip(
                                            icon: Icons.location_on_outlined,
                                            label: locationLabel,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (bio.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              bio,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: controller.isSaving
                                      ? null
                                      : _openEditProfile,
                                  icon: controller.isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.edit_outlined),
                                  label: Text(l10n.profileEditPageTitle),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    controller.errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
            if (verificationController.errorMessage != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    verificationController.errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            _SectionTitle(l10n.profileIdentityVerificationSectionTitle),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  title: l10n.verificationCenterTitle,
                  subtitle: verificationTileSubtitle,
                  icon: Icons.verified_user_outlined,
                  trailing: verificationController.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: () => _showVerificationCenter(
                    profile: profile,
                    pendingRequest: pendingRequest,
                    latestRejectedRequest: latestRejectedRequest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle(l10n.profilePreferencesSectionTitle),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: AppThemeModeController.themeMode,
              builder: (context, mode, _) {
                return _SettingsGroup(
                  children: [
                    _SettingsTile(
                      title: l10n.profileThemeTitle,
                      subtitle: _themeModeLabel(l10n, mode),
                      icon: Icons.palette_outlined,
                      onTap: _showThemeModeSheet,
                    ),
                    const Divider(height: 1),
                    ValueListenableBuilder<Locale?>(
                      valueListenable: AppLocaleController.locale,
                      builder: (context, locale, _) {
                        return _SettingsTile(
                          title: l10n.profileAppLanguageTitle,
                          subtitle: _appLocaleLabel(l10n, locale),
                          icon: Icons.language_outlined,
                          onTap: _showAppLanguageSheet,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            _SectionTitle(l10n.profileNotificationsSectionTitle),
            FutureBuilder<int>(
              future: _unreadNotificationsFuture,
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;

                return _SettingsGroup(
                  children: [
                    _SettingsTile(
                      title: l10n.notificationsPageTitle,
                      icon: Icons.notifications_none,
                      trailing: _NotificationsTrailingBadge(
                        unreadCount: unreadCount,
                      ),
                      onTap: _openNotifications,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            _SectionTitle(l10n.profileActivitySectionTitle),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  title: l10n.profileMyPollsTitle,
                  icon: Icons.how_to_vote,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyPollsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: l10n.profileMyPostsTitle,
                  icon: Icons.forum_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyPostsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: l10n.profileMyCommentsTitle,
                  icon: Icons.comment_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyCommentsPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: l10n.profileMyFavoritesTitle,
                  icon: Icons.star_border_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyFavoritesPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: l10n.profileMyFollowedScopesTitle,
                  icon: Icons.public,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyFollowedScopesPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle(l10n.profileSecurityAccountSectionTitle),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  title: accountEmail.isNotEmpty
                      ? accountEmail
                      : l10n.authEmailLabel,
                  subtitle: l10n.profileAccountEmailHelper,
                  icon: Icons.email_outlined,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: l10n.profileChangePasswordAction,
                  subtitle: l10n.profileChangePasswordDescription,
                  icon: Icons.lock_reset_outlined,
                  onTap: _isDeletingAccount
                      ? null
                      : () {
                          Navigator.of(context).pushNamed(
                            AppRouter.resetPassword,
                          );
                        },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: l10n.profileBiometricUnlockTitle,
                  subtitle: _biometricLoading
                      ? l10n.profileBiometricUnlockDescription
                      : !_rememberMeEnabled
                          ? l10n.profileBiometricRequiresRememberMe
                          : !_biometricAvailable
                              ? l10n.profileBiometricUnavailable
                              : l10n.profileBiometricUnlockDescription,
                  icon: Icons.fingerprint_rounded,
                  trailing: _biometricLoading || _biometricBusy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Switch.adaptive(
                          value: _biometricEnabled,
                          onChanged: !_rememberMeEnabled || !_biometricAvailable
                              ? null
                              : _setBiometricEnabled,
                        ),
                  onTap: _biometricLoading || _biometricBusy
                      ? null
                      : () {
                          if (!_rememberMeEnabled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.profileBiometricRequiresRememberMe,
                                ),
                              ),
                            );
                            return;
                          }

                          if (!_biometricAvailable) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.profileBiometricUnavailable,
                                ),
                              ),
                            );
                            return;
                          }

                          unawaited(
                            _setBiometricEnabled(!_biometricEnabled),
                          );
                        },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: l10n.profileLogoutAction,
                  subtitle: l10n.profileLogoutDescription,
                  icon: Icons.logout_rounded,
                  iconColor: theme.colorScheme.error,
                  textColor: theme.colorScheme.error,
                  onTap: _isDeletingAccount ? null : _confirmLogout,
                ),
                const Divider(height: 1),
                _SettingsTile(
                  title: l10n.profileDeleteAccountAction,
                  subtitle: l10n.profileDeleteAccountDescription,
                  icon: Icons.delete_forever_outlined,
                  iconColor: theme.colorScheme.error,
                  textColor: theme.colorScheme.error,
                  trailing: _isDeletingAccount
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isDeletingAccount ? null : _confirmDeleteAccount,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatActorTypeLabel(
    AppLocalizations l10n,
    ActorType value,
  ) {
    switch (value) {
      case ActorType.citizen:
        return l10n.identityActorTypePerson;
      case ActorType.publicOfficial:
        return l10n.identityActorTypePublicOfficial;
      case ActorType.institution:
        return l10n.identityActorTypePublicInstitution;
      case ActorType.organization:
        return l10n.identityActorTypeVerifiedOrganization;
    }
  }

  String _formatVerificationRequestTypeLabel(
    AppLocalizations l10n,
    VerificationRequestType value,
  ) {
    switch (value) {
      case VerificationRequestType.citizenLevel1:
        return l10n.verificationRequestPersonLevel1;
      case VerificationRequestType.citizenLevel2:
        return l10n.verificationRequestPersonLevel2;
      case VerificationRequestType.publicOfficial:
        return l10n.verificationRequestPublicOfficial;
      case VerificationRequestType.institution:
        return l10n.verificationRequestPublicInstitution;
      case VerificationRequestType.organization:
        return l10n.verificationRequestVerifiedOrganization;
    }
  }

  String? _formatInstitutionLevelLabel(
    AppLocalizations l10n,
    InstitutionLevel? value,
  ) {
    switch (value) {
      case InstitutionLevel.municipality:
        return l10n.identityInstitutionLevelMunicipality;
      case InstitutionLevel.province:
        return l10n.identityInstitutionLevelProvince;
      case InstitutionLevel.region:
        return l10n.identityInstitutionLevelRegion;
      case InstitutionLevel.ministry:
        return l10n.identityInstitutionLevelMinistry;
      case InstitutionLevel.government:
        return l10n.identityInstitutionLevelGovernment;
      case InstitutionLevel.publicAgency:
        return l10n.identityInstitutionLevelPublicAgency;
      case InstitutionLevel.otherPublicBody:
        return l10n.identityInstitutionLevelOtherPublicBody;
      case null:
        return null;
    }
  }

  String _formatVerificationLevelLabel(
    AppLocalizations l10n,
    VerificationLevel value,
  ) {
    switch (value) {
      case VerificationLevel.none:
        return l10n.identityVerificationNotVerified;
      case VerificationLevel.level1:
        return l10n.identityVerificationLevel1;
      case VerificationLevel.level2:
        return l10n.identityVerificationLevel2;
    }
  }

  String? _primaryIdentityBadgeLabel(
    AppLocalizations l10n,
    UserProfile profile,
  ) {
    if (profile.isPublicOfficial) {
      return l10n.identityBadgePublicOfficial;
    }
    if (profile.isInstitutionActor) {
      return l10n.identityBadgePublicInstitution;
    }
    if (profile.isOrganizationActor) {
      return l10n.identityBadgeVerifiedOrganization;
    }

    switch (profile.verificationLevel) {
      case VerificationLevel.none:
        return null;
      case VerificationLevel.level1:
        return l10n.identityBadgeLevel1;
      case VerificationLevel.level2:
        return l10n.identityBadgeLevel2;
    }
  }

  String _accountStatusLabel({
    required AppLocalizations l10n,
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    final parts = <String>[
      _formatActorTypeLabel(l10n, actorType),
    ];

    final institutionLevelLabel =
        _formatInstitutionLevelLabel(l10n, institutionLevel);
    if (actorType == ActorType.institution && institutionLevelLabel != null) {
      parts.add(institutionLevelLabel);
    }

    if (actorType == ActorType.citizen) {
      parts.add(_formatVerificationLevelLabel(l10n, verificationLevel));
    }
    return parts.join(' · ');
  }

  String _verificationTileSubtitle({
    required AppLocalizations l10n,
    required String accountStatusLabel,
    required VerificationStatus verificationStatus,
    required VerificationRequest? pendingRequest,
  }) {
    if (pendingRequest != null ||
        verificationStatus == VerificationStatus.pending) {
      return '$accountStatusLabel · ${l10n.verificationStatusPendingSuffix}';
    }

    if (verificationStatus == VerificationStatus.rejected) {
      return '$accountStatusLabel · ${l10n.verificationStatusRejectedSuffix}';
    }

    return accountStatusLabel;
  }

  String _themeModeLabel(
    AppLocalizations l10n,
    ThemeMode mode,
  ) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.profileThemeSystem;
      case ThemeMode.light:
        return l10n.profileThemeLight;
      case ThemeMode.dark:
        return l10n.profileThemeDark;
    }
  }

  String _appLocaleLabel(AppLocalizations l10n, Locale? locale) {
    switch (locale?.languageCode) {
      case 'it':
        return l10n.profileAppLanguageItalian;
      case 'en':
        return l10n.profileAppLanguageEnglish;
      default:
        return l10n.profileAppLanguageSystem;
    }
  }

  String? finalLocation({
    required String city,
    required String country,
  }) {
    if (city.isNotEmpty && country.isNotEmpty) {
      return '$city, $country';
    }
    if (city.isNotEmpty) {
      return city;
    }
    if (country.isNotEmpty) {
      return country;
    }
    return null;
  }
}

class _InstitutionRequestDraft {
  final String institutionName;
  final InstitutionLevel? institutionLevel;

  const _InstitutionRequestDraft({
    required this.institutionName,
    required this.institutionLevel,
  });
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityBadgeChip extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _IdentityBadgeChip({
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isPrimary
        ? theme.colorScheme.primary.withValues(alpha: 0.10)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final borderColor = isPrimary
        ? theme.colorScheme.primary.withValues(alpha: 0.22)
        : theme.colorScheme.outline.withValues(alpha: 0.14);
    final textColor =
        isPrimary ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _VerificationActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _VerificationActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsTile({
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
        style: textColor != null
            ? theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              )
            : theme.textTheme.bodyLarge,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _NotificationsTrailingBadge extends StatelessWidget {
  final int unreadCount;

  const _NotificationsTrailingBadge({
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (unreadCount <= 0) {
      return const Icon(Icons.chevron_right);
    }

    final label = unreadCount > 99 ? '99+' : unreadCount.toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right),
      ],
    );
  }
}

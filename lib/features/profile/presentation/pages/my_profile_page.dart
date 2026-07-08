import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
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
import 'package:sociale_vote/shared/widgets/user_identity_mark.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AppDI.instance.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'You must be logged in to open your account.\n\n'
              'Accedi o registrati dalla home per gestire profilo, notifiche e impostazioni.',
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

  String get currentUserId => widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _unreadNotificationsFuture = _loadUnreadNotificationsCount();
  }

  Future<int> _loadUnreadNotificationsCount() {
    return AppDI.instance.getUnreadNotificationsCount(currentUserId);
  }

  void _refreshUnreadNotificationsCount() {
    setState(() {
      _unreadNotificationsFuture = _loadUnreadNotificationsCount();
    });
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
    final currentMode = AppThemeModeController.themeMode.value;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: currentMode,
                title: const Text('Sistema'),
                subtitle: const Text('Segue il tema del dispositivo'),
                onChanged: (value) {
                  if (value == null) return;
                  AppThemeModeController.setThemeMode(value);
                  Navigator.of(sheetContext).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: currentMode,
                title: const Text('Chiaro'),
                onChanged: (value) {
                  if (value == null) return;
                  AppThemeModeController.setThemeMode(value);
                  Navigator.of(sheetContext).pop();
                },
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: currentMode,
                title: const Text('Scuro'),
                onChanged: (value) {
                  if (value == null) return;
                  AppThemeModeController.setThemeMode(value);
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showVerificationCenter({
    required UserProfile? profile,
    required VerificationRequest? pendingRequest,
  }) async {
    final actorType = profile?.actorType ?? ActorType.citizen;
    final verificationLevel =
        profile?.verificationLevel ?? VerificationLevel.none;
    final verificationStatus =
        profile?.verificationStatus ?? VerificationStatus.none;
    final institutionLevel = profile?.institutionLevel;

    final actorTypeLabel =
        profile?.actorTypeLabel ?? _formatActorTypeLabel(actorType);
    final verificationLevelLabel = profile?.verificationLevelLabel ??
        _formatVerificationLevelLabel(verificationLevel);
    final institutionLevelLabel = profile?.institutionLevelLabel ??
        _formatInstitutionLevelLabel(institutionLevel);
    final identityDetailLabel = profile?.identityDetailLabel;
    final primaryIdentityBadgeLabel = profile?.primaryIdentityBadgeLabel;
    final secondaryIdentityBadgeLabel = profile?.secondaryIdentityBadgeLabel;
    final hasIdentityBadges = primaryIdentityBadgeLabel != null ||
        secondaryIdentityBadgeLabel != null;

    final hasPendingRequest = pendingRequest != null;
    final hasRejectedState =
        !hasPendingRequest && verificationStatus == VerificationStatus.rejected;
    final hasPendingState =
        hasPendingRequest || verificationStatus == VerificationStatus.pending;

    final canRequestCitizenLevel1 = actorType == ActorType.citizen &&
        verificationLevel == VerificationLevel.none;
    final canRequestCitizenLevel2 = actorType == ActorType.citizen &&
        verificationLevel != VerificationLevel.level2;
    final canRequestPublicOfficial = actorType == ActorType.citizen;
    final canRequestInstitution = actorType == ActorType.citizen;

    final hasAvailableUpgradeActions = !hasPendingState &&
        (canRequestCitizenLevel1 ||
            canRequestCitizenLevel2 ||
            canRequestPublicOfficial ||
            canRequestInstitution);

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
                  'Verification & account type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Current account',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('- Tipo account: $actorTypeLabel'),
                    if (profile != null &&
                        UserIdentityMark.shouldShowForProfile(profile)) ...[
                      const SizedBox(width: 4),
                      UserIdentityMark.fromProfile(
                        profile,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text('- Livello verifica: $verificationLevelLabel'),
                if (identityDetailLabel != null)
                  Text(
                    actorType == ActorType.institution
                        ? '- Ente: $identityDetailLabel'
                        : '- Titolo ufficiale: $identityDetailLabel',
                  ),
                if (institutionLevelLabel != null)
                  Text('- Livello istituzionale: $institutionLevelLabel'),
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
                    'Active request',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (pendingRequest != null) ...[
                    Text(
                      _formatVerificationRequestTypeLabel(
                        pendingRequest.requestType,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Il tuo profilo attuale non cambia finché la review non viene approvata.',
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
                        label: const Text('Annulla richiesta pending'),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Hai una richiesta in review. Finché resta pending non puoi inviarne una nuova.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ] else ...[
                  Text(
                    'No active request',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Al momento non hai richieste in review.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (hasRejectedState) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Last rejected request',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La tua ultima richiesta è stata respinta.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Il profilo attuale non è cambiato. Puoi correggere i dati e inviarne una nuova.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                Text(
                  'Available requests',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                if (hasAvailableUpgradeActions) ...[
                  if (canRequestCitizenLevel1)
                    _VerificationActionTile(
                      title: 'Request Verified Lv1',
                      subtitle: 'Verifica base per account citizen',
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
                      title: 'Request Verified Lv2',
                      subtitle: 'Verifica avanzata per account citizen',
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
                      title: 'Request Public Official account',
                      subtitle: 'Richiede title ufficiale e review',
                      icon: Icons.badge_outlined,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _promptPublicOfficialRequest();
                      },
                    ),
                  if (canRequestInstitution)
                    _VerificationActionTile(
                      title: 'Request Institution account',
                      subtitle: 'Richiede nome ente, livello e review',
                      icon: Icons.account_balance_outlined,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await _promptInstitutionRequest();
                      },
                    ),
                ] else if (hasPendingState) ...[
                  Text(
                    'Finché hai una richiesta pending non puoi inviarne una nuova.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ] else ...[
                  Text(
                    'Non ci sono upgrade self-service disponibili per lo stato attuale del tuo account.',
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
    final controller = context.read<VerificationRequestsController>();
    final success = await controller.createRequest(
      userId: currentUserId,
      requestType: requestType,
    );

    if (!mounted) return;

    final message = success
        ? 'Richiesta inviata con successo.'
        : (controller.errorMessage ?? 'Impossibile inviare la richiesta.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _promptPublicOfficialRequest() async {
    final titleController = TextEditingController();

    try {
      final officialTitle = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Request Public Official account'),
            content: TextField(
              controller: titleController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Official title',
                hintText: 'es. Sindaco, Assessore, Ministro',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(
                    titleController.text.trim(),
                  );
                },
                child: const Text('Invia richiesta'),
              ),
            ],
          );
        },
      );

      if (!mounted || officialTitle == null) return;

      final controller = context.read<VerificationRequestsController>();
      final success = await controller.createRequest(
        userId: currentUserId,
        requestType: VerificationRequestType.publicOfficial,
        officialTitle: officialTitle,
      );

      if (!mounted) return;

      final message = success
          ? 'Richiesta inviata con successo.'
          : (controller.errorMessage ?? 'Impossibile inviare la richiesta.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      titleController.dispose();
    }
  }

  Future<void> _promptInstitutionRequest() async {
    final nameController = TextEditingController();

    try {
      final draft = await showDialog<_InstitutionRequestDraft>(
        context: context,
        builder: (dialogContext) {
          InstitutionLevel? selectedLevel;

          return StatefulBuilder(
            builder: (context, setLocalState) {
              return AlertDialog(
                title: const Text('Request Institution account'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Institution name',
                        hintText: 'es. Comune di Roma',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<InstitutionLevel>(
                      initialValue: selectedLevel,
                      decoration: const InputDecoration(
                        labelText: 'Institution level',
                        border: OutlineInputBorder(),
                      ),
                      items: InstitutionLevel.values
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(
                                _formatStaticInstitutionLevelLabel(level),
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
                    child: const Text('Annulla'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(
                        _InstitutionRequestDraft(
                          institutionName: nameController.text.trim(),
                          institutionLevel: selectedLevel,
                        ),
                      );
                    },
                    child: const Text('Invia richiesta'),
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
          ? 'Richiesta inviata con successo.'
          : (controller.errorMessage ?? 'Impossibile inviare la richiesta.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _confirmCancelPendingRequest() async {
    final verificationController =
        context.read<VerificationRequestsController>();

    final shouldCancel = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Annulla richiesta'),
              content: const Text(
                'Vuoi davvero annullare la richiesta di verifica attualmente pending?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('No'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Annulla richiesta'),
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
        ? 'Richiesta annullata.'
        : (verificationController.errorMessage ??
            'Impossibile annullare la richiesta.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Logout'),
              content: const Text('Vuoi davvero uscire dal tuo account?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Annulla'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Logout'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    final actorType = profile?.actorType ?? ActorType.citizen;
    final verificationLevel =
        profile?.verificationLevel ?? VerificationLevel.none;
    final institutionLevel = profile?.institutionLevel;
    final verificationStatus =
        profile?.verificationStatus ?? VerificationStatus.none;
    final pendingRequest = verificationController.pendingRequest;

    final accountStatusLabel = profile?.accountStatusLabel ??
        _accountStatusLabel(
          actorType: actorType,
          verificationLevel: verificationLevel,
          institutionLevel: institutionLevel,
        );
    final verificationTileSubtitle = _verificationTileSubtitle(
      accountStatusLabel: accountStatusLabel,
      verificationStatus: verificationStatus,
      pendingRequest: pendingRequest,
    );
    final locationLabel = finalLocation(city: city, country: country);
    final identityDetailLabel = profile?.identityDetailLabel;
    final primaryIdentityBadgeLabel = profile?.primaryIdentityBadgeLabel;
    final secondaryIdentityBadgeLabel = profile?.secondaryIdentityBadgeLabel;
    final hasIdentityBadges = primaryIdentityBadgeLabel != null ||
        secondaryIdentityBadgeLabel != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
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
          padding: const EdgeInsets.all(16),
          children: [
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
                                              : 'User',
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
                                  label: const Text('Edit Profile'),
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
            const SizedBox(height: 24),
            const _SectionTitle('Profile'),
            _ProfileSectionTile(
              title: 'Edit Profile',
              subtitle: 'Nome, username, avatar, bio, paese e città',
              icon: Icons.edit_outlined,
              onTap: _openEditProfile,
            ),
            _ProfileSectionTile(
              title: 'Verification & account type',
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
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('App'),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: AppThemeModeController.themeMode,
              builder: (context, mode, _) {
                return _ProfileSectionTile(
                  title: 'Theme',
                  subtitle: _themeModeLabel(mode),
                  icon: Icons.palette_outlined,
                  onTap: _showThemeModeSheet,
                );
              },
            ),
            FutureBuilder<int>(
              future: _unreadNotificationsFuture,
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;

                return _ProfileSectionTile(
                  title: 'Notifications',
                  subtitle: unreadCount > 0
                      ? '$unreadCount non lette'
                      : 'Nessuna notifica non letta',
                  icon: Icons.notifications_none,
                  trailing: _NotificationsTrailingBadge(
                    unreadCount: unreadCount,
                  ),
                  onTap: _openNotifications,
                );
              },
            ),
            const SizedBox(height: 24),
            const _SectionTitle('My activity'),
            _ProfileSectionTile(
              title: 'My Polls',
              icon: Icons.how_to_vote,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyPollsPage(),
                  ),
                );
              },
            ),
            _ProfileSectionTile(
              title: 'My Posts',
              icon: Icons.forum_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyPostsPage(),
                  ),
                );
              },
            ),
            _ProfileSectionTile(
              title: 'My Comments',
              icon: Icons.comment_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyCommentsPage(),
                  ),
                );
              },
            ),
            _ProfileSectionTile(
              title: 'My Favorites',
              icon: Icons.star_border_rounded,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyFavoritesPage(),
                  ),
                );
              },
            ),
            _ProfileSectionTile(
              title: 'My Followed Scopes',
              icon: Icons.public,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyFollowedScopesPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const _SectionTitle('Account'),
            _ProfileSectionTile(
              title: 'Account ID',
              subtitle: currentUserId,
              icon: Icons.badge_outlined,
              trailing: const SizedBox.shrink(),
              onTap: null,
            ),
            _ProfileSectionTile(
              title: 'Logout',
              subtitle: 'Esci dall’account corrente',
              icon: Icons.logout_rounded,
              iconColor: theme.colorScheme.error,
              textColor: theme.colorScheme.error,
              onTap: _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }

  String _formatActorTypeLabel(ActorType value) {
    switch (value) {
      case ActorType.citizen:
        return 'Citizen';
      case ActorType.publicOfficial:
        return 'Public Official';
      case ActorType.institution:
        return 'Institution';
    }
  }

  String _formatVerificationRequestTypeLabel(VerificationRequestType value) {
    switch (value) {
      case VerificationRequestType.citizenLevel1:
        return 'Verified Lv1 request';
      case VerificationRequestType.citizenLevel2:
        return 'Verified Lv2 request';
      case VerificationRequestType.publicOfficial:
        return 'Public Official request';
      case VerificationRequestType.institution:
        return 'Institution request';
    }
  }

  String? _formatInstitutionLevelLabel(InstitutionLevel? value) {
    switch (value) {
      case InstitutionLevel.municipality:
        return 'Municipality';
      case InstitutionLevel.province:
        return 'Province';
      case InstitutionLevel.region:
        return 'Region';
      case InstitutionLevel.ministry:
        return 'Ministry';
      case InstitutionLevel.government:
        return 'Government';
      case InstitutionLevel.publicAgency:
        return 'Public Agency';
      case InstitutionLevel.otherPublicBody:
        return 'Other Public Body';
      case null:
        return null;
    }
  }

  static String _formatStaticInstitutionLevelLabel(InstitutionLevel value) {
    switch (value) {
      case InstitutionLevel.municipality:
        return 'Municipality';
      case InstitutionLevel.province:
        return 'Province';
      case InstitutionLevel.region:
        return 'Region';
      case InstitutionLevel.ministry:
        return 'Ministry';
      case InstitutionLevel.government:
        return 'Government';
      case InstitutionLevel.publicAgency:
        return 'Public Agency';
      case InstitutionLevel.otherPublicBody:
        return 'Other Public Body';
    }
  }

  String _formatVerificationLevelLabel(VerificationLevel value) {
    switch (value) {
      case VerificationLevel.none:
        return 'Standard';
      case VerificationLevel.level1:
        return 'Verified Lv1';
      case VerificationLevel.level2:
        return 'Verified Lv2';
    }
  }

  String _accountStatusLabel({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    final parts = <String>[
      _formatActorTypeLabel(actorType),
    ];

    final institutionLevelLabel =
        _formatInstitutionLevelLabel(institutionLevel);
    if (institutionLevelLabel != null) {
      parts.add(institutionLevelLabel);
    }

    parts.add(_formatVerificationLevelLabel(verificationLevel));
    return parts.join(' · ');
  }

  String _verificationTileSubtitle({
    required String accountStatusLabel,
    required VerificationStatus verificationStatus,
    required VerificationRequest? pendingRequest,
  }) {
    if (pendingRequest != null) {
      return '$accountStatusLabel · richiesta in review';
    }

    if (verificationStatus == VerificationStatus.pending) {
      return '$accountStatusLabel · richiesta in review';
    }

    if (verificationStatus == VerificationStatus.rejected) {
      return '$accountStatusLabel · ultima richiesta respinta';
    }

    return accountStatusLabel;
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sistema';
      case ThemeMode.light:
        return 'Chiaro';
      case ThemeMode.dark:
        return 'Scuro';
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
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.18),
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
        ? theme.colorScheme.primary.withOpacity(0.10)
        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.45);
    final borderColor = isPrimary
        ? theme.colorScheme.primary.withOpacity(0.22)
        : theme.colorScheme.outline.withOpacity(0.14);
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

class _ProfileSectionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;

  const _ProfileSectionTile({
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

    return Card(
      child: ListTile(
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
              : null,
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
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

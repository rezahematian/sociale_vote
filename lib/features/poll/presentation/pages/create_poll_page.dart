import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/features/poll/application/create_poll_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';
import 'package:sociale_vote/shared/widgets/user_identity_mark.dart';

class CreatePollPage extends StatelessWidget {
  const CreatePollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppDI.instance.createCreatePollController(),
      child: const _CreatePollView(),
    );
  }
}

class _CreatePollView extends StatefulWidget {
  const _CreatePollView();

  @override
  State<_CreatePollView> createState() => _CreatePollViewState();
}

class _CreatePollViewState extends State<_CreatePollView> {
  final TextEditingController _contentCityController = TextEditingController();

  UserProfile? _currentUserProfile;
  bool _publishingIdentityLoaded = false;
  bool _showAdvancedOptions = false;
  bool _showManualContentLocationFields = false;

  @override
  void initState() {
    super.initState();
    _loadPublishingIdentity();
  }

  @override
  void dispose() {
    _contentCityController.dispose();
    super.dispose();
  }

  bool get _isItalian =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'it';

  Future<void> _loadPublishingIdentity() async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _publishingIdentityLoaded = true;
      });
      return;
    }

    try {
      final profile = await AppDI.instance.getUserProfile(userId);
      if (!mounted) return;

      setState(() {
        _currentUserProfile = profile;
        _publishingIdentityLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _publishingIdentityLoaded = true;
      });
    }
  }

  String _pollTypeLabel(PollType type) {
    final l10n = AppLocalizations.of(context)!;

    switch (type) {
      case PollType.yesNo:
        return l10n.createPollPollTypeYesNoLabel;
      case PollType.singleChoice:
        return l10n.createPollPollTypeSingleChoiceLabel;
      case PollType.multipleChoice:
        return l10n.createPollPollTypeMultipleChoiceLabel;
      case PollType.approval:
        return l10n.createPollPollTypeApprovalLabel;
      case PollType.ranked:
        return l10n.createPollPollTypeRankedLabel;
      case PollType.score:
        return l10n.createPollPollTypeScoreLabel;
    }
  }

  String _pollTypeDescription(PollType type) {
    switch (type) {
      case PollType.yesNo:
        return _isItalian
            ? 'Per una domanda con due sole risposte: Sì oppure No.'
            : 'For a question with exactly two answers: Yes or No.';
      case PollType.singleChoice:
        return _isItalian
            ? 'Consigliato nella maggior parte dei casi: ogni persona sceglie una sola risposta.'
            : 'Recommended for most polls: each person selects one answer.';
      case PollType.multipleChoice:
        return _isItalian
            ? 'Usalo quando più risposte possono essere valide insieme.'
            : 'Use this when more than one answer can be valid at the same time.';
      case PollType.approval:
        return _isItalian
            ? 'Modalità avanzata non disponibile per nuovi sondaggi.'
            : 'Advanced mode is not available for new polls.';
      case PollType.ranked:
        return _isItalian
            ? 'Modalità avanzata non disponibile per nuovi sondaggi.'
            : 'Advanced mode is not available for new polls.';
      case PollType.score:
        return _isItalian
            ? 'Modalità avanzata non disponibile per nuovi sondaggi.'
            : 'Advanced mode is not available for new polls.';
    }
  }

  String _selectionSummary(CreatePollController controller) {
    if (controller.type == PollType.yesNo ||
        controller.type == PollType.singleChoice) {
      return _isItalian
          ? 'Chi vota può selezionare una sola risposta.'
          : 'Voters can select one answer.';
    }

    return _isItalian
        ? 'Chi vota può selezionare da 1 a ${controller.maxSelections} risposte.'
        : 'Voters can select from 1 to ${controller.maxSelections} answers.';
  }

  void _selectPollType(CreatePollController controller, PollType type) {
    controller.setType(type);

    if (type == PollType.yesNo) {
      while (controller.options.length > 2) {
        controller.removeOption(controller.options.length - 1);
      }
      controller.setOptionText(0, _isItalian ? 'Sì' : 'Yes');
      controller.setOptionText(1, 'No');
    }
  }

  Widget _buildPollTypeChoice(
    BuildContext context, {
    required CreatePollController controller,
    required PollType type,
    required IconData icon,
    required bool enabled,
  }) {
    final theme = Theme.of(context);
    final selected = controller.type == type;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? () => _selectPollType(controller, type) : null,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.34)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.75)
                    : colorScheme.outline.withValues(alpha: 0.22),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    icon,
                    size: 22,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pollTypeLabel(type),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _pollTypeDescription(type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _localizedControllerError(CreatePollController controller) {
    final raw = controller.errorMessage?.trim();
    if (raw == null || raw.isEmpty) {
      return _isItalian
          ? 'Impossibile completare l’operazione.'
          : 'Unable to complete the operation.';
    }

    final messages = <String, List<String>>{
      'Device location is not available.': [
        'La posizione del dispositivo non è disponibile.',
        'Device location is not available.',
      ],
      'Location services are disabled.': [
        'I servizi di localizzazione sono disattivati.',
        'Location services are disabled.',
      ],
      'Location permission was denied.': [
        'Il permesso di localizzazione è stato negato.',
        'Location permission was denied.',
      ],
      'Unable to read current device location.': [
        'Impossibile leggere la posizione attuale.',
        'Unable to read the current device location.',
      ],
      'Unable to access device location.': [
        'Impossibile accedere alla posizione del dispositivo.',
        'Unable to access the device location.',
      ],
      'Location validation is not available.': [
        'La verifica della località non è disponibile.',
        'Location validation is not available.',
      ],
      'Please select a country before entering a city.': [
        'Seleziona un Paese prima di inserire una città.',
        'Select a country before entering a city.',
      ],
      'Unable to validate the selected location.': [
        'Impossibile verificare la località selezionata.',
        'Unable to validate the selected location.',
      ],
      'Title is required.': ['Inserisci un titolo.', 'Enter a title.'],
      'At least two options are required.': [
        'Inserisci almeno due risposte.',
        'Enter at least two answers.',
      ],
      'Start and end dates are required.': [
        'Seleziona la data di inizio e la data di fine.',
        'Select a start date and an end date.',
      ],
      'End date must be after start date.': [
        'La data di fine deve essere successiva alla data di inizio.',
        'The end date must be after the start date.',
      ],
      'Poll duration cannot exceed 31 days.': [
        'Il sondaggio non può durare più di 31 giorni.',
        'The poll cannot last more than 31 days.',
      ],
      'Please select a country for this poll.': [
        'Seleziona un Paese per questo sondaggio.',
        'Select a country for this poll.',
      ],
    };

    final localized = messages[raw];
    if (localized != null) {
      return localized[_isItalian ? 0 : 1];
    }

    return raw;
  }

  String _formatDate(DateTime dt) {
    return MaterialLocalizations.of(context).formatMediumDate(dt.toLocal());
  }

  String _participationScopeLabel(ParticipationScope scope) {
    final l10n = AppLocalizations.of(context)!;

    switch (scope) {
      case ParticipationScope.everyone:
        return l10n.createPollParticipationScopeEveryoneLabel;
      case ParticipationScope.geoScopeOnly:
        return l10n.createPollParticipationScopeGeoScopeOnlyLabel;
    }
  }

  String _minimumVerificationLevelLabel(VerificationLevel level) {
    final l10n = AppLocalizations.of(context)!;

    switch (level) {
      case VerificationLevel.none:
        return l10n.adminCenterVerificationStatusNone;
      case VerificationLevel.level1:
        return l10n.adminCenterVerificationLevel1;
      case VerificationLevel.level2:
        return l10n.adminCenterVerificationLevel2;
    }
  }

  String _anonymityLabel(AnonymityLevel level) {
    final l10n = AppLocalizations.of(context)!;

    switch (level) {
      case AnonymityLevel.anonymous:
        return l10n.createPollAnonymityLevelAnonymousLabel;
      case AnonymityLevel.public:
        return l10n.createPollAnonymityLevelPublicLabel;
    }
  }

  String _resultsVisibilityLabel(ResultsVisibilityMode mode) {
    final l10n = AppLocalizations.of(context)!;

    switch (mode) {
      case ResultsVisibilityMode.always:
        return l10n.createPollResultsVisibilityAlwaysLabel;
      case ResultsVisibilityMode.afterVote:
        return l10n.createPollResultsVisibilityAfterVoteLabel;
      case ResultsVisibilityMode.afterClose:
        return l10n.createPollResultsVisibilityAfterCloseLabel;
    }
  }

  String _contentLocationSourceLabel(ContentLocationSource source) {
    switch (source) {
      case ContentLocationSource.manual:
        return _isItalian ? 'Manuale' : 'Manual';
      case ContentLocationSource.device:
        return _isItalian ? 'Posizione attuale' : 'Current location';
      case ContentLocationSource.profile:
        return _isItalian ? 'Profilo' : 'Profile';
      case ContentLocationSource.geoScopeFallback:
        return _isItalian ? 'Ambito corrente' : 'Current scope';
    }
  }

  String _contentLocationSummary(ContentLocation location) {
    final parts = <String>[];

    if (location.cityName != null && location.cityName!.trim().isNotEmpty) {
      parts.add(location.cityName!.trim());
    }

    if (location.countryCode != null &&
        location.countryCode!.trim().isNotEmpty) {
      parts.add(location.countryCode!.trim().toUpperCase());
    }

    if (parts.isEmpty) {
      if (_showManualContentLocationFields) {
        return _isItalian ? 'Seleziona una località' : 'Select a location';
      }
      if (location.source == ContentLocationSource.geoScopeFallback) {
        return _isItalian ? 'Globale' : 'Global';
      }
      if (location.source == ContentLocationSource.device &&
          location.hasExactPoint) {
        return _isItalian
            ? 'Coordinate GPS disponibili'
            : 'GPS coordinates available';
      }
      if (location.hasCenter) {
        return _isItalian ? 'Coordinate disponibili' : 'Coordinates available';
      }
      return _isItalian ? 'Globale / nessuna località' : 'Global / no location';
    }

    return parts.join(', ');
  }

  void _applyManualContentLocation(
    CreatePollController controller, {
    String? countryCode,
  }) {
    controller.setManualContentLocation(
      countryCode: countryCode ?? controller.contentLocation?.countryCode,
      cityName: _contentCityController.text.trim().isEmpty
          ? null
          : _contentCityController.text.trim(),
    );
  }

  bool _isTimingTooLong(CreatePollController controller) {
    if (!controller.hasExplicitTimeWindow) {
      return false;
    }
    return controller.endAt.difference(controller.startAt) >
        const Duration(days: 31);
  }

  String? _submitHintText(CreatePollController controller) {
    if (!controller.hasExplicitTimeWindow) {
      return _isItalian
          ? 'Imposta data di inizio e data di fine prima di creare il sondaggio.'
          : 'Set a start date and an end date before creating the poll.';
    }

    if (controller.endAt.isBefore(controller.startAt)) {
      return _isItalian
          ? 'La data di fine deve essere successiva alla data di inizio.'
          : 'The end date must be after the start date.';
    }

    if (_isTimingTooLong(controller)) {
      return _isItalian
          ? 'La votazione non può durare più di 31 giorni.'
          : 'The poll cannot last more than 31 days.';
    }

    return null;
  }

  bool _canPublishAsRepresentative(UserProfile? profile) {
    if (profile == null) {
      return false;
    }

    return AuthGuard.canUseRepresentativeIdentityFeatures(
      actorType: profile.actorType,
      verificationLevel: profile.verificationLevel,
      institutionLevel: profile.institutionLevel,
    );
  }

  String? _publishingIdentityTypeLabel(UserProfile? profile) {
    if (profile == null) {
      return null;
    }

    if (profile.isPublicOfficial) {
      return _isItalian ? 'Funzionario pubblico' : 'Public official';
    }

    if (profile.isInstitutionActor) {
      return _isItalian ? 'Istituzione' : 'Institution';
    }

    return null;
  }

  Widget _buildRepresentativePublishingCard(BuildContext context) {
    if (!_publishingIdentityLoaded) {
      return const SizedBox.shrink();
    }

    final profile = _currentUserProfile;
    if (!_canPublishAsRepresentative(profile)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final identityTypeLabel = _publishingIdentityTypeLabel(profile);
    final identityDetailLabel = profile?.identityDetailLabel;
    final institutionLevelLabel = profile?.institutionLevelLabel;

    return _buildSectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (profile != null &&
                  UserIdentityMark.shouldShowForProfile(profile))
                UserIdentityMark.fromProfile(profile, size: 18)
              else
                Icon(
                  Icons.campaign_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isItalian
                      ? 'Pubblicazione rappresentativa'
                      : 'Representative publishing',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            identityTypeLabel == null
                ? (_isItalian
                      ? 'Questo sondaggio verrà pubblicato con la tua identità verificata.'
                      : 'This poll will be published with your verified identity.')
                : (_isItalian
                      ? 'Questo sondaggio verrà pubblicato come $identityTypeLabel.'
                      : 'This poll will be published as $identityTypeLabel.'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (identityDetailLabel != null &&
              identityDetailLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              profile!.isInstitutionActor
                  ? (_isItalian
                        ? 'Ente verificato: $identityDetailLabel'
                        : 'Verified institution: $identityDetailLabel')
                  : (_isItalian
                        ? 'Titolo verificato: $identityDetailLabel'
                        : 'Verified title: $identityDetailLabel'),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (institutionLevelLabel != null &&
              institutionLevelLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _isItalian
                  ? 'Livello istituzionale: $institutionLevelLabel'
                  : 'Institution level: $institutionLevelLabel',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 10),
          Text(
            _isItalian
                ? 'Non puoi cambiare manualmente questa identità qui: viene dal profilo già verificato.'
                : 'You cannot change this identity here: it comes from your verified profile.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineErrorBox(BuildContext context, {required String text}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineInfoBox(BuildContext context, {required String text}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: isDark ? 0.05 : 0.014),
      colorScheme.surface,
    );

    final borderColor = colorScheme.outline.withValues(
      alpha: isDark ? 0.26 : 0.12,
    );

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.045);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(color: Colors.transparent, child: child),
    );
  }

  void _showSnackBarMessage(String message, {SnackBarBehavior? behavior}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(behavior: behavior, content: Text(message)));
  }

  void _applyCurrentDeviceLocation(CreatePollController controller) {
    final location = controller.contentLocation;
    _contentCityController.text = location?.cityName ?? '';
    setState(() {});
  }

  void _showCurrentDeviceLocationError(CreatePollController controller) {
    final message = controller.errorMessage == null
        ? (_isItalian
              ? 'Impossibile recuperare la posizione attuale.'
              : 'Unable to retrieve the current location.')
        : _localizedControllerError(controller);
    _showSnackBarMessage(message);
  }

  Future<void> _useCurrentDeviceLocation(
    CreatePollController controller,
  ) async {
    final success = await controller.useCurrentDeviceLocation();
    if (!mounted) return;

    if (success) {
      _applyCurrentDeviceLocation(controller);
      return;
    }

    _showCurrentDeviceLocationError(controller);
  }

  void _completePollSubmission(PollId pollId, String successMessage) {
    _showSnackBarMessage(successMessage, behavior: SnackBarBehavior.floating);
    Navigator.of(context).pop(pollId);
  }

  Future<void> _submitPoll(
    CreatePollController controller,
    String successMessage,
  ) async {
    FocusScope.of(context).unfocus();

    final pollId = await controller.submit();
    if (!mounted || pollId == null) return;

    _completePollSubmission(pollId, successMessage);
  }

  Widget _buildContentLocationCard(
    BuildContext context,
    CreatePollController controller,
    bool isSubmitting,
  ) {
    final theme = Theme.of(context);
    final effectiveLocation = controller.effectiveContentLocation;
    final explicitLocation = controller.contentLocation;
    final selectedContentCountryCode = explicitLocation?.countryCode;
    final selectedSource = explicitLocation?.source;
    final isDeviceSelected = selectedSource == ContentLocationSource.device;
    final isGlobalSelected =
        controller.isContentLocationGlobal && !_showManualContentLocationFields;

    return _buildSectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isItalian ? 'Località del contenuto' : 'Content location',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isItalian
                ? 'Scegli se il sondaggio è globale, associato a una località oppure alla tua posizione attuale. L’ambito di navigazione non modifica questa scelta.'
                : 'Choose whether the poll is global, linked to a location, or linked to your current location. Navigation scope does not change this choice.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isItalian ? 'Località attiva' : 'Active location',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _contentLocationSummary(effectiveLocation),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_isItalian ? 'Origine' : 'Source'}: ${isGlobalSelected
                      ? (_isItalian ? 'Globale' : 'Global')
                      : _showManualContentLocationFields
                      ? (_isItalian ? 'Manuale' : 'Manual')
                      : _contentLocationSourceLabel(effectiveLocation.source)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            controller.clearContentLocation();
                            _contentCityController.clear();
                            setState(() {
                              _showManualContentLocationFields = false;
                            });
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: isGlobalSelected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      foregroundColor: isGlobalSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : null,
                      side: BorderSide(
                        color: isGlobalSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                    ),
                    icon: const Icon(Icons.public, size: 16),
                    label: Text(_isItalian ? 'Globale' : 'Global'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            _applyManualContentLocation(controller);
                            setState(() {
                              _showManualContentLocationFields = true;
                            });
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: _showManualContentLocationFields
                          ? theme.colorScheme.primaryContainer
                          : null,
                      foregroundColor: _showManualContentLocationFields
                          ? theme.colorScheme.onPrimaryContainer
                          : null,
                      side: BorderSide(
                        color: _showManualContentLocationFields
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                    ),
                    icon: const Icon(Icons.place_outlined, size: 16),
                    label: Text(
                      _isItalian ? 'Scegli località' : 'Choose location',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        isSubmitting || controller.isResolvingContentLocation
                        ? null
                        : () async {
                            await _useCurrentDeviceLocation(controller);
                            if (!mounted) return;
                            if (controller.contentLocation?.source ==
                                ContentLocationSource.device) {
                              setState(() {
                                _showManualContentLocationFields = false;
                              });
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: isDeviceSelected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      foregroundColor: isDeviceSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : null,
                      side: BorderSide(
                        color: isDeviceSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                    ),
                    icon: controller.isResolvingContentLocation
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, size: 16),
                    label: Text(
                      controller.isResolvingContentLocation
                          ? (compact
                                ? (_isItalian ? 'Attendo...' : 'Please wait...')
                                : (_isItalian
                                      ? 'Ricavo posizione...'
                                      : 'Getting location...'))
                          : (compact
                                ? (_isItalian
                                      ? 'Posizione attuale'
                                      : 'Current location')
                                : (_isItalian
                                      ? 'Usa posizione attuale'
                                      : 'Use current location')),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
          if (_showManualContentLocationFields) ...[
            const SizedBox(height: 16),
            CountrySelectorField(
              key: ValueKey(
                'content-country-${selectedContentCountryCode ?? 'none'}',
              ),
              selectedCountryCode: selectedContentCountryCode,
              onCountrySelected: (code) {
                _applyManualContentLocation(controller, countryCode: code);
                setState(() {});
              },
              label: _isItalian ? 'Paese del contenuto' : 'Content country',
              required: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCityController,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                labelText: _isItalian ? 'Città del contenuto' : 'Content city',
                border: const OutlineInputBorder(),
                helperText: _isItalian
                    ? 'Facoltativo. Serve per posizionare meglio il sondaggio.'
                    : 'Optional. Helps place the poll more accurately.',
              ),
              onChanged: (_) => _applyManualContentLocation(controller),
            ),
          ],
          if (explicitLocation != null) ...[
            const SizedBox(height: 8),
            Text(
              _isItalian
                  ? 'Località personalizzata pronta per la pubblicazione.'
                  : 'Custom location ready for publishing.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final pageBackground = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: isDark ? 0.035 : 0.012),
      theme.scaffoldBackgroundColor,
    );

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.createPollPageTitle),
            const SizedBox(height: 2),
            Text(
              l10n.createPollPageSubtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
      body: ColoredBox(
        color: pageBackground,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Consumer<CreatePollController>(
                builder: (context, controller, _) {
                  final isSubmitting = controller.isSubmitting;
                  final selectedParticipationCountryCode =
                      controller.countryCodeForParticipation;
                  final submitHintText = _submitHintText(controller);
                  final canSubmitPoll =
                      controller.canSubmit &&
                      controller.hasExplicitTimeWindow &&
                      !_isTimingTooLong(controller);

                  return AbsorbPointer(
                    absorbing: isSubmitting,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionCard(
                            context,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollBasicInfoTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollBasicInfoSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  enabled: !isSubmitting,
                                  decoration: InputDecoration(
                                    labelText: l10n.createPollTitleFieldLabel,
                                    border: const OutlineInputBorder(),
                                    helperText: l10n.createPollTitleFieldHelper,
                                  ),
                                  onChanged: controller.setTitle,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  enabled: !isSubmitting,
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n.createPollDescriptionFieldLabel,
                                    border: const OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 3,
                                  onChanged: controller.setDescription,
                                ),
                              ],
                            ),
                          ),
                          if (_canPublishAsRepresentative(
                            _currentUserProfile,
                          )) ...[
                            const SizedBox(height: 16),
                            _buildRepresentativePublishingCard(context),
                          ],
                          const SizedBox(height: 16),
                          _buildContentLocationCard(
                            context,
                            controller,
                            isSubmitting,
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            context,
                            child: SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              value: _showAdvancedOptions,
                              onChanged: isSubmitting
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _showAdvancedOptions = value;
                                      });
                                    },
                              secondary: const Icon(Icons.tune_rounded),
                              title: Text(
                                l10n.createPollAdvancedOptionsTitle,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                l10n.createPollAdvancedOptionsSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            context,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollVotingModelTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollVotingModelSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildPollTypeChoice(
                                  context,
                                  controller: controller,
                                  type: PollType.yesNo,
                                  icon: Icons.thumbs_up_down_outlined,
                                  enabled: !isSubmitting,
                                ),
                                _buildPollTypeChoice(
                                  context,
                                  controller: controller,
                                  type: PollType.singleChoice,
                                  icon: Icons.radio_button_checked,
                                  enabled: !isSubmitting,
                                ),
                                _buildPollTypeChoice(
                                  context,
                                  controller: controller,
                                  type: PollType.multipleChoice,
                                  icon: Icons.check_box_outlined,
                                  enabled: !isSubmitting,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectionSummary(controller),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withValues(alpha: 0.8),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_showAdvancedOptions) ...[
                                  const SizedBox(height: 8),
                                  SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      l10n.createPollAllowVoteChangeTitle,
                                    ),
                                    subtitle: Text(
                                      l10n.createPollAllowVoteChangeSubtitle,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withValues(alpha: 0.8),
                                          ),
                                    ),
                                    value: controller.allowVoteChange,
                                    onChanged: isSubmitting
                                        ? null
                                        : controller.setAllowVoteChange,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            context,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollOptionsTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.type == PollType.yesNo
                                      ? (_isItalian
                                            ? 'Le due risposte sono impostate automaticamente.'
                                            : 'The two answers are set automatically.')
                                      : l10n.createPollOptionsSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (controller.type == PollType.yesNo)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Chip(
                                        avatar: const Icon(
                                          Icons.check_circle_outline,
                                          size: 18,
                                        ),
                                        label: Text(_isItalian ? 'Sì' : 'Yes'),
                                      ),
                                      const Chip(
                                        avatar: Icon(
                                          Icons.cancel_outlined,
                                          size: 18,
                                        ),
                                        label: Text('No'),
                                      ),
                                    ],
                                  )
                                else ...[
                                  Column(
                                    children: List.generate(
                                      controller.options.length,
                                      (index) {
                                        final optionLabel = l10n
                                            .createPollOptionLabel(
                                              index + 1,
                                              index < 2 ? ' *' : '',
                                            );
                                        final canRemove =
                                            controller.options.length > 2;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  enabled: !isSubmitting,
                                                  decoration: InputDecoration(
                                                    labelText: optionLabel,
                                                    border:
                                                        const OutlineInputBorder(),
                                                  ),
                                                  onChanged: (value) =>
                                                      controller.setOptionText(
                                                        index,
                                                        value,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (canRemove)
                                                IconButton(
                                                  tooltip: l10n
                                                      .createPollRemoveOptionTooltip,
                                                  onPressed: isSubmitting
                                                      ? null
                                                      : () => controller
                                                            .removeOption(
                                                              index,
                                                            ),
                                                  icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: isSubmitting
                                          ? null
                                          : controller.addOption,
                                      icon: const Icon(Icons.add),
                                      label: Text(
                                        l10n.createPollAddOptionButton,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSectionCard(
                            context,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollParticipationPrivacyTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollParticipationPrivacySubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.createPollWhoCanVoteLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RadioGroup<ParticipationScope>(
                                  groupValue: controller.participationScope,
                                  onChanged: (value) {
                                    if (isSubmitting || value == null) return;

                                    controller.setParticipationScope(value);
                                    controller.setCountryCodeForParticipation(
                                      value == ParticipationScope.geoScopeOnly
                                          ? selectedParticipationCountryCode
                                          : null,
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      RadioListTile<ParticipationScope>(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          _participationScopeLabel(
                                            ParticipationScope.everyone,
                                          ),
                                        ),
                                        subtitle: Text(
                                          l10n.createPollParticipationEveryoneSubtitle,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color
                                                    ?.withValues(alpha: 0.8),
                                              ),
                                        ),
                                        value: ParticipationScope.everyone,
                                      ),
                                      RadioListTile<ParticipationScope>(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          _participationScopeLabel(
                                            ParticipationScope.geoScopeOnly,
                                          ),
                                        ),
                                        subtitle: Text(
                                          l10n.createPollParticipationGeoScopeSubtitle,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color
                                                    ?.withValues(alpha: 0.8),
                                              ),
                                        ),
                                        value: ParticipationScope.geoScopeOnly,
                                      ),
                                    ],
                                  ),
                                ),
                                if (controller.participationScope ==
                                    ParticipationScope.geoScopeOnly) ...[
                                  const SizedBox(height: 12),
                                  CountrySelectorField(
                                    key: ValueKey(
                                      'participation-country-${selectedParticipationCountryCode ?? 'none'}',
                                    ),
                                    selectedCountryCode:
                                        selectedParticipationCountryCode,
                                    onCountrySelected: (code) {
                                      controller.setCountryCodeForParticipation(
                                        code,
                                      );
                                      setState(() {});
                                    },
                                    label: l10n.createPollCountryFieldLabel,
                                    required: true,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.createPollCountryFieldHelper,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                                const Divider(height: 24),
                                Text(
                                  l10n.adminCenterVerificationLevelLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RadioGroup<VerificationLevel>(
                                  groupValue:
                                      controller.minimumVerificationLevel,
                                  onChanged: (value) {
                                    if (isSubmitting || value == null) return;
                                    controller.setMinimumVerificationLevel(
                                      value,
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      RadioListTile<VerificationLevel>(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          _minimumVerificationLevelLabel(
                                            VerificationLevel.none,
                                          ),
                                        ),
                                        value: VerificationLevel.none,
                                      ),
                                      RadioListTile<VerificationLevel>(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          _minimumVerificationLevelLabel(
                                            VerificationLevel.level1,
                                          ),
                                        ),
                                        value: VerificationLevel.level1,
                                      ),
                                      RadioListTile<VerificationLevel>(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          _minimumVerificationLevelLabel(
                                            VerificationLevel.level2,
                                          ),
                                        ),
                                        value: VerificationLevel.level2,
                                      ),
                                    ],
                                  ),
                                ),
                                if (_showAdvancedOptions) ...[
                                  const Divider(height: 24),
                                  Text(
                                    l10n.createPollVoteAnonymityTitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RadioGroup<AnonymityLevel>(
                                    groupValue: controller.anonymityLevel,
                                    onChanged: (value) {
                                      if (isSubmitting || value == null) return;
                                      controller.setAnonymityLevel(value);
                                    },
                                    child: Column(
                                      children: [
                                        RadioListTile<AnonymityLevel>(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            _anonymityLabel(
                                              AnonymityLevel.anonymous,
                                            ),
                                          ),
                                          subtitle: Text(
                                            l10n.createPollAnonymityAnonymousSubtitle,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color
                                                      ?.withValues(alpha: 0.8),
                                                ),
                                          ),
                                          value: AnonymityLevel.anonymous,
                                        ),
                                        RadioListTile<AnonymityLevel>(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            _anonymityLabel(
                                              AnonymityLevel.public,
                                            ),
                                          ),
                                          subtitle: Text(
                                            l10n.createPollAnonymityPublicSubtitle,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color
                                                      ?.withValues(alpha: 0.8),
                                                ),
                                          ),
                                          value: AnonymityLevel.public,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_showAdvancedOptions) ...[
                            _buildSectionCard(
                              context,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.createPollResultsValidityTitle,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.createPollResultsValiditySubtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: l10n
                                          .createPollResultsVisibilityFieldLabel,
                                      border: const OutlineInputBorder(),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child:
                                          DropdownButton<ResultsVisibilityMode>(
                                            isExpanded: true,
                                            value: controller.resultsVisibility,
                                            onChanged: isSubmitting
                                                ? null
                                                : (value) {
                                                    if (value != null) {
                                                      controller
                                                          .setResultsVisibility(
                                                            value,
                                                          );
                                                    }
                                                  },
                                            items: ResultsVisibilityMode.values
                                                .map(
                                                  (mode) => DropdownMenuItem(
                                                    value: mode,
                                                    child: Text(
                                                      _resultsVisibilityLabel(
                                                        mode,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.createPollQuorumTitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.createPollQuorumSubtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    enabled: !isSubmitting,
                                    initialValue:
                                        controller.minQuorumVotes?.toString() ??
                                        '',
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: l10n
                                          .createPollQuorumMinVotesFieldLabel,
                                    ),
                                    onChanged: (value) {
                                      if (value.trim().isEmpty) {
                                        controller.setMinQuorumVotes(null);
                                      } else {
                                        final parsed = int.tryParse(
                                          value.trim(),
                                        );
                                        controller.setMinQuorumVotes(parsed);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildSectionCard(
                            context,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollTimingTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollTimingSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.play_circle_outline,
                                  ),
                                  title: Text(l10n.createPollStartDateLabel),
                                  subtitle: Text(
                                    controller.hasExplicitStartAt
                                        ? _formatDate(controller.startAt)
                                        : (_isItalian
                                              ? 'Non impostata'
                                              : 'Not set'),
                                  ),
                                  trailing: TextButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () async {
                                            final now = DateTime.now();
                                            final baseDate = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                            );
                                            final initialDate =
                                                controller.hasExplicitStartAt
                                                ? controller.startAt
                                                : now;

                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  initialDate.isBefore(baseDate)
                                                  ? now
                                                  : initialDate,
                                              firstDate: now.subtract(
                                                const Duration(days: 365),
                                              ),
                                              lastDate: now.add(
                                                const Duration(days: 365 * 5),
                                              ),
                                            );
                                            if (picked != null) {
                                              final current =
                                                  controller.startAt;
                                              controller.setStartAt(
                                                DateTime(
                                                  picked.year,
                                                  picked.month,
                                                  picked.day,
                                                  current.hour,
                                                  current.minute,
                                                ),
                                              );
                                            }
                                          },
                                    child: Text(
                                      controller.hasExplicitStartAt
                                          ? l10n.createPollChangeDateButtonLabel
                                          : (_isItalian
                                                ? 'Seleziona'
                                                : 'Select'),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.stop_circle_outlined,
                                  ),
                                  title: Text(l10n.createPollEndDateLabel),
                                  subtitle: Text(
                                    controller.hasExplicitEndAt
                                        ? _formatDate(controller.endAt)
                                        : (_isItalian
                                              ? 'Non impostata'
                                              : 'Not set'),
                                  ),
                                  trailing: TextButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () async {
                                            final now = DateTime.now();
                                            final baseDate = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                            );
                                            final initialDate =
                                                controller.hasExplicitEndAt
                                                ? controller.endAt
                                                : now;

                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  initialDate.isBefore(baseDate)
                                                  ? now
                                                  : initialDate,
                                              firstDate: now.subtract(
                                                const Duration(days: 365),
                                              ),
                                              lastDate: now.add(
                                                const Duration(days: 365 * 5),
                                              ),
                                            );
                                            if (picked != null) {
                                              final current = controller.endAt;
                                              controller.setEndAt(
                                                DateTime(
                                                  picked.year,
                                                  picked.month,
                                                  picked.day,
                                                  current.hour,
                                                  current.minute,
                                                ),
                                              );
                                            }
                                          },
                                    child: Text(
                                      controller.hasExplicitEndAt
                                          ? l10n.createPollChangeDateButtonLabel
                                          : (_isItalian
                                                ? 'Seleziona'
                                                : 'Select'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollTimingStatusInfo,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.8),
                                  ),
                                ),
                                if (submitHintText != null) ...[
                                  const SizedBox(height: 12),
                                  _buildInlineInfoBox(
                                    context,
                                    text: submitHintText,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (controller.errorMessage != null) ...[
                            _buildInlineErrorBox(
                              context,
                              text: _localizedControllerError(controller),
                            ),
                            const SizedBox(height: 12),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: canSubmitPoll && !isSubmitting
                                  ? () => _submitPoll(
                                      controller,
                                      l10n.createPollSuccessMessage,
                                    )
                                  : null,
                              icon: isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(
                                isSubmitting
                                    ? l10n.createPollSubmitCreatingLabel
                                    : l10n.createPollSubmitLabel,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                textStyle: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

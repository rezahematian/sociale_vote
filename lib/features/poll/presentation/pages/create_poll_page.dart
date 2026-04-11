import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/features/poll/application/create_poll_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';

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

  @override
  void dispose() {
    _contentCityController.dispose();
    super.dispose();
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
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
        return 'Manuale';
      case ContentLocationSource.device:
        return 'Posizione attuale';
      case ContentLocationSource.profile:
        return 'Profilo';
      case ContentLocationSource.geoScopeFallback:
        return 'Scope corrente';
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
      if (location.hasCenter) {
        return 'Coordinate scope disponibili';
      }
      return 'Località non definita';
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
      return 'Imposta data di inizio e data di fine prima di creare il poll.';
    }

    if (controller.endAt.isBefore(controller.startAt)) {
      return 'La data di fine deve essere successiva alla data di inizio.';
    }

    if (_isTimingTooLong(controller)) {
      return 'La votazione non può durare più di 31 giorni.';
    }

    return null;
  }

  Widget _buildInlineErrorBox(
    BuildContext context, {
    required String text,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 18,
            color: theme.colorScheme.error,
          ),
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

  Widget _buildInlineInfoBox(
    BuildContext context, {
    required String text,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.primary,
          ),
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

  Widget _buildContentLocationCard(
    BuildContext context,
    CreatePollController controller,
    bool isSubmitting,
  ) {
    final theme = Theme.of(context);
    final effectiveLocation = controller.effectiveContentLocation;
    final explicitLocation = controller.contentLocation;
    final selectedContentCountryCode = controller.contentLocation?.countryCode;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Località contenuto',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Definisce dove appartiene il poll sulla mappa. Puoi usare lo scope corrente, la posizione attuale oppure impostare manualmente paese e città.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Località attiva',
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
                    'Origine: ${_contentLocationSourceLabel(effectiveLocation.source)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;

                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                controller.useGeoScopeAsContentLocation();
                                final location = controller.contentLocation;
                                _contentCityController.text =
                                    location?.cityName ?? '';
                                setState(() {});
                              },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.public, size: 16),
                        label: Text(
                          compact ? 'Scope corrente' : 'Usa scope corrente',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            isSubmitting || controller.isResolvingContentLocation
                                ? null
                                : () async {
                                    final success =
                                        await controller.useCurrentDeviceLocation();
                                    if (!mounted) return;

                                    if (success) {
                                      final location = controller.contentLocation;
                                      _contentCityController.text =
                                          location?.cityName ?? '';
                                      setState(() {});
                                    }
                                  },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: controller.isResolvingContentLocation
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location, size: 16),
                        label: Text(
                          controller.isResolvingContentLocation
                              ? (compact
                                  ? 'Attendo...'
                                  : 'Ricavo posizione...')
                              : (compact
                                  ? 'Posizione attuale'
                                  : 'Usa posizione attuale'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              controller.clearContentLocation();
                              _contentCityController.clear();
                              setState(() {});
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.restart_alt, size: 16),
                      label: const Text('Reset'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            CountrySelectorField(
              key: ValueKey(
                'content-country-${selectedContentCountryCode ?? 'none'}',
              ),
              selectedCountryCode: selectedContentCountryCode,
              onCountrySelected: (code) {
                _applyManualContentLocation(
                  controller,
                  countryCode: code,
                );
                setState(() {});
              },
              label: 'Paese del contenuto',
              required: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCityController,
              enabled: !isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Città del contenuto',
                border: OutlineInputBorder(),
                helperText:
                    'Facoltativo. Serve per posizionare meglio il poll.',
              ),
              onChanged: (_) => _applyManualContentLocation(controller),
            ),
            if (explicitLocation != null) ...[
              const SizedBox(height: 8),
              Text(
                'Località personalizzata pronta per il submit.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.createPollPageTitle),
            const SizedBox(height: 2),
            Text(
              l10n.createPollPageSubtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720,
            ),
            child: Consumer<CreatePollController>(
              builder: (context, controller, _) {
                final isSubmitting = controller.isSubmitting;
                final selectedParticipationCountryCode =
                    controller.countryCodeForParticipation;
                final submitHintText = _submitHintText(controller);
                final canSubmitPoll = controller.canSubmit &&
                    controller.hasExplicitTimeWindow &&
                    !_isTimingTooLong(controller);

                return AbsorbPointer(
                  absorbing: isSubmitting,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollBasicInfoTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollBasicInfoSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
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
                        ),
                        const SizedBox(height: 16),
                        _buildContentLocationCard(
                          context,
                          controller,
                          isSubmitting,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollVotingModelTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollVotingModelSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.createPollTypeFieldLabel,
                                    border: const OutlineInputBorder(),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<PollType>(
                                      isExpanded: true,
                                      value: controller.type,
                                      onChanged: isSubmitting
                                          ? null
                                          : (value) {
                                              if (value != null) {
                                                controller.setType(value);
                                              }
                                            },
                                      items: PollType.values
                                          .map(
                                            (type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(
                                                _pollTypeLabel(type),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.rule,
                                      size: 18,
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.createPollSelectionRules(
                                          controller.minSelections,
                                          controller.maxSelections,
                                        ),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.textTheme.bodySmall?.color
                                              ?.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    l10n.createPollAllowVoteChangeTitle,
                                  ),
                                  subtitle: Text(
                                    l10n.createPollAllowVoteChangeSubtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: controller.allowVoteChange,
                                  onChanged: isSubmitting
                                      ? null
                                      : controller.setAllowVoteChange,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollOptionsTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollOptionsSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  children: List.generate(
                                    controller.options.length,
                                    (index) {
                                      final optionLabel =
                                          l10n.createPollOptionLabel(
                                        index + 1,
                                        index < 2 ? ' *' : '',
                                      );
                                      final canRemove =
                                          controller.options.length > 2;

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
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
                                                        .removeOption(index),
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
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollParticipationPrivacyTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollParticipationPrivacySubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
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
                                RadioListTile<ParticipationScope>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _participationScopeLabel(
                                      ParticipationScope.everyone,
                                    ),
                                  ),
                                  subtitle: Text(
                                    l10n.createPollParticipationEveryoneSubtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: ParticipationScope.everyone,
                                  groupValue: controller.participationScope,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            controller
                                                .setParticipationScope(value);
                                            controller
                                                .setCountryCodeForParticipation(
                                              null,
                                            );
                                          }
                                        },
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
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: ParticipationScope.geoScopeOnly,
                                  groupValue: controller.participationScope,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            controller
                                                .setParticipationScope(value);
                                            controller
                                                .setCountryCodeForParticipation(
                                              selectedParticipationCountryCode,
                                            );
                                          }
                                        },
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
                                      controller
                                          .setCountryCodeForParticipation(code);
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
                                          ?.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                                const Divider(height: 24),
                                Text(
                                  l10n.createPollVoteAnonymityTitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RadioListTile<AnonymityLevel>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _anonymityLabel(
                                      AnonymityLevel.anonymous,
                                    ),
                                  ),
                                  subtitle: Text(
                                    l10n.createPollAnonymityAnonymousSubtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: AnonymityLevel.anonymous,
                                  groupValue: controller.anonymityLevel,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            controller.setAnonymityLevel(value);
                                          }
                                        },
                                ),
                                RadioListTile<AnonymityLevel>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _anonymityLabel(AnonymityLevel.public),
                                  ),
                                  subtitle: Text(
                                    l10n.createPollAnonymityPublicSubtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: AnonymityLevel.public,
                                  groupValue: controller.anonymityLevel,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            controller.setAnonymityLevel(value);
                                          }
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollResultsValidityTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollResultsValiditySubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
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
                                                _resultsVisibilityLabel(mode),
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
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  enabled: !isSubmitting,
                                  initialValue:
                                      controller.minQuorumVotes?.toString() ?? '',
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
                                      final parsed =
                                          int.tryParse(value.trim());
                                      controller.setMinQuorumVotes(parsed);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.createPollTimingTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollTimingSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading:
                                      const Icon(Icons.play_circle_outline),
                                  title: Text(
                                    l10n.createPollStartDateLabel,
                                  ),
                                  subtitle: Text(
                                    controller.hasExplicitStartAt
                                        ? _formatDate(controller.startAt)
                                        : 'Non impostata',
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
                                              final current = controller.startAt;
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
                                          : 'Seleziona',
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading:
                                      const Icon(Icons.stop_circle_outlined),
                                  title: Text(
                                    l10n.createPollEndDateLabel,
                                  ),
                                  subtitle: Text(
                                    controller.hasExplicitEndAt
                                        ? _formatDate(controller.endAt)
                                        : 'Non impostata',
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
                                          : 'Seleziona',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.createPollTimingStatusInfo,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
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
                        ),
                        const SizedBox(height: 24),
                        if (controller.errorMessage != null) ...[
                          _buildInlineErrorBox(
                            context,
                            text: controller.errorMessage!,
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: canSubmitPoll && !isSubmitting
                                ? () async {
                                    FocusScope.of(context).unfocus();

                                    final pollId = await controller.submit();
                                    if (!context.mounted) return;
                                    if (pollId != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          behavior:
                                              SnackBarBehavior.floating,
                                          content: Text(
                                            l10n.createPollSuccessMessage,
                                          ),
                                        ),
                                      );
                                      Navigator.of(context).pop(pollId);
                                    }
                                  }
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
    );
  }
}
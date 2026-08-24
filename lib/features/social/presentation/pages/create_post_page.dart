import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/analytics/analytics_service.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/domain/organization/entities/organization_models.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';

class CreatePostPage extends StatefulWidget {
  final bool preferOrganizationPublisher;

  const CreatePostPage({
    super.key,
    this.preferOrganizationPublisher = false,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isSubmitting = false;
  bool _isResolvingLocation = false;
  String? _submitError;

  String? _selectedCountryCode;
  ContentLocation? _contentLocation;
  bool _showManualLocationFields = false;

  OrganizationContext? _organizationContext;
  bool _organizationPublishingLoaded = false;
  bool _publishAsOrganization = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizationPublishing();
  }

  Future<void> _loadOrganizationPublishing() async {
    try {
      final contextValue =
          await AppDI.instance.organizationRepository.getMyOrganization();
      if (!mounted) return;

      final canPublish = contextValue != null &&
          contextValue.canManageProfile &&
          contextValue.organization.isVerified &&
          contextValue.workspace.status == 'active';

      setState(() {
        _organizationContext = canPublish ? contextValue : null;
        _publishAsOrganization =
            widget.preferOrganizationPublisher && canPublish;
        _organizationPublishingLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _organizationPublishingLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  bool get _isItalian =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'it';

  void _setManualLocation() {
    setState(() {
      _showManualLocationFields = true;
      _contentLocation = ContentLocation(
        source: ContentLocationSource.manual,
        countryCode: _normalizeString(_selectedCountryCode),
        cityName: _normalizeString(_cityController.text),
      );
    });
  }

  String? _normalizeString(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  String _sourceLabel(ContentLocationSource source) {
    switch (source) {
      case ContentLocationSource.manual:
        return _isItalian
            ? 'Manuale'
            : deOrEnglish(context, english: 'Manual', german: 'Manuell');
      case ContentLocationSource.device:
        return _isItalian
            ? 'Posizione attuale'
            : deOrEnglish(context,
                english: 'Current location', german: 'Aktueller Standort');
      case ContentLocationSource.profile:
        return _isItalian
            ? 'Profilo'
            : deOrEnglish(context, english: 'Profile', german: 'Profil');
      case ContentLocationSource.geoScopeFallback:
        return _isItalian
            ? 'Ambito corrente'
            : deOrEnglish(context,
                english: 'Current scope', german: 'Aktueller Bereich');
    }
  }

  String _locationSummary(ContentLocation? location) {
    if (location == null || location.isEmpty) {
      if (_showManualLocationFields) {
        return _isItalian
            ? 'Seleziona una località'
            : deOrEnglish(context,
                english: 'Select a location', german: 'Standort auswählen');
      }
      return _isItalian
          ? 'Globale / nessuna località specifica'
          : deOrEnglish(context,
              english: 'Global / no specific location',
              german: 'Global / kein bestimmter Standort');
    }

    final parts = <String>[];

    if ((location.cityName ?? '').trim().isNotEmpty) {
      parts.add(location.cityName!.trim());
    }
    if ((location.countryCode ?? '').trim().isNotEmpty) {
      parts.add(location.countryCode!.trim().toUpperCase());
    }

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    final hasCoordinates = location.latitude != null &&
        location.longitude != null &&
        location.latitude!.isFinite &&
        location.longitude!.isFinite;

    if (hasCoordinates) {
      return _isItalian
          ? 'Coordinate disponibili'
          : deOrEnglish(context,
              english: 'Coordinates available',
              german: 'Koordinaten verfügbar');
    }
    if (location.hasCenter) {
      return _isItalian
          ? 'Centro geografico disponibile'
          : deOrEnglish(context,
              english: 'Geographic center available',
              german: 'Geografischer Mittelpunkt verfügbar');
    }

    return _isItalian
        ? 'Località non definita'
        : deOrEnglish(context,
            english: 'Location not defined',
            german: 'Standort nicht festgelegt');
  }

  Future<void> _useCurrentDeviceLocation() async {
    setState(() {
      _isResolvingLocation = true;
    });

    try {
      final repository = AppDI.instance.deviceLocationRepository;
      final serviceEnabled = await repository.isLocationServiceEnabled();

      if (!mounted) return;

      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isItalian
                  ? 'Attiva i servizi di localizzazione e riprova.'
                  : deOrEnglish(context,
                      english: 'Turn on location services and try again.',
                      german:
                          'Aktiviere die Standortdienste und versuche es erneut.'),
            ),
          ),
        );
        return;
      }

      final hasPermission = await repository.hasPermission();

      if (!mounted) return;

      if (!hasPermission) {
        final permissionGranted = await repository.requestPermission();

        if (!mounted) return;

        if (!permissionGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isItalian
                    ? 'Permesso posizione non concesso. Abilitalo nelle impostazioni di sistema.'
                    : deOrEnglish(context,
                        english:
                            'Location permission was not granted. Enable it in system settings.',
                        german:
                            'Die Standortberechtigung wurde nicht erteilt. Aktiviere sie in den Systemeinstellungen.'),
              ),
            ),
          );
          return;
        }
      }

      final location = await repository.getCurrentContentLocation();

      if (!mounted) return;

      if (location == null || location.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isItalian
                  ? 'Impossibile determinare la posizione attuale.'
                  : deOrEnglish(context,
                      english: 'Unable to determine the current location.',
                      german:
                          'Der aktuelle Standort konnte nicht bestimmt werden.'),
            ),
          ),
        );
        return;
      }

      setState(() {
        _showManualLocationFields = false;
        _contentLocation = location;
        _selectedCountryCode = location.countryCode;
        _cityController.text = location.cityName ?? '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isItalian
                ? 'Posizione attuale applicata: ${_locationSummary(location)}.'
                : deOrEnglish(context,
                    english:
                        'Current location applied: ${_locationSummary(location)}.',
                    german:
                        'Aktueller Standort angewendet: ${_locationSummary(location)}.'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isItalian
              ? 'Errore accesso posizione: $e'
              : deOrEnglish(context,
                  english: 'Location access error: $e',
                  german: 'Fehler beim Standortzugriff: $e')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingLocation = false;
        });
      }
    }
  }

  Future<ContentLocation?> _resolveLocationBeforeSubmit() async {
    final currentLocation = _contentLocation;

    if (currentLocation == null || currentLocation.isEmpty) {
      return null;
    }

    if (currentLocation.source != ContentLocationSource.manual) {
      return currentLocation;
    }

    final rawLocation = ContentLocation(
      source: ContentLocationSource.manual,
      countryCode: _normalizeString(_selectedCountryCode),
      cityName: _normalizeString(_cityController.text),
    );

    if (rawLocation.isEmpty) {
      return null;
    }

    final geocoded = await AppDI.instance.geocodingRepository
        .geocodeContentLocation(rawLocation);

    if (geocoded == null) {
      throw StateError(
        'Paese o città non validi. Controlla la località inserita.',
      );
    }

    return geocoded;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.createPost,
    );
    if (!mounted || !allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      setState(() {
        _submitError = _isItalian
            ? 'Errore: utente non disponibile nella sessione.'
            : deOrEnglish(context,
                english: 'Error: user is not available in the current session.',
                german:
                    'Fehler: Der Benutzer ist in der aktuellen Sitzung nicht verfügbar.');
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      final authorName = 'User $userId';

      final effectiveLocation = await _resolveLocationBeforeSubmit();

      final countryCode = effectiveLocation?.countryCode;
      final cityId = effectiveLocation?.cityId;

      await AppDI.instance.createPost(
        authorId: userId,
        authorName: authorName,
        title: title,
        content: content,
        countryCode: countryCode,
        cityId: cityId,
        contentLocation: effectiveLocation,
        publisherOrganizationId: _publishAsOrganization
            ? _organizationContext?.organization.id
            : null,
      );

      await _trackPostCreated(
        title: title,
        content: content,
        contentLocation: effectiveLocation,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            effectiveLocation == null
                ? (_isItalian
                    ? 'Voce globale creata con successo.'
                    : deOrEnglish(context,
                        english: 'Global Voce created successfully.',
                        german: 'Globale Voce erfolgreich erstellt.'))
                : effectiveLocation.hasExactPoint || effectiveLocation.hasCenter
                    ? (_isItalian
                        ? 'Voce creata con successo.'
                        : deOrEnglish(context,
                            english: 'Voce created successfully.',
                            german: 'Voce erfolgreich erstellt.'))
                    : (_isItalian
                        ? 'Voce creata con successo. Località salvata senza coordinate precise.'
                        : deOrEnglish(context,
                            english:
                                'Voce created successfully. Location saved without precise coordinates.',
                            german:
                                'Voce erfolgreich erstellt. Standort ohne genaue Koordinaten gespeichert.')),
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      final languageCode =
          Localizations.localeOf(context).languageCode.toLowerCase();
      setState(() {
        _submitError = languageCode == 'it'
            ? 'Impossibile pubblicare la Voce. Controlla la connessione e riprova.'
            : deOrEnglish(
                context,
                english:
                    'Unable to publish the Voce. Check your connection and try again.',
                german:
                    'Die Voce konnte nicht veröffentlicht werden. Prüfe die Verbindung und versuche es erneut.',
              );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _trackPostCreated({
    required String title,
    required String content,
    required ContentLocation? contentLocation,
  }) async {
    await AnalyticsService.instance.logEvent(
      'post_created',
      parameters: <String, Object?>{
        'title_length': title.length,
        'content_length': content.length,
        'has_content_country': contentLocation?.hasCountry == true ? 1 : 0,
        'has_content_city': contentLocation?.hasCityName == true ? 1 : 0,
        'has_exact_point': contentLocation?.hasExactPoint == true ? 1 : 0,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = _contentLocation;
    final isDeviceSelected = location?.source == ContentLocationSource.device;
    final isGlobalSelected =
        (location == null || location.isEmpty) && !_showManualLocationFields;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isItalian
            ? 'Crea Voce'
            : deOrEnglish(context,
                english: 'Create Voce', german: 'Voce erstellen')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  _isItalian
                      ? 'Nuova Voce'
                      : deOrEnglish(context,
                          english: 'New Voce', german: 'Neue Voce'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isItalian
                      ? 'Condividi una proposta, un’idea o un commento per quest’area geografica.'
                      : deOrEnglish(context,
                          english:
                              'Share a proposal, an idea, or a comment for this geographic area.',
                          german:
                              'Teile einen Vorschlag, eine Idee oder einen Kommentar für diesen geografischen Bereich.'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 20),
                if (_organizationPublishingLoaded &&
                    _organizationContext != null) ...[
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SwitchListTile.adaptive(
                      value: _publishAsOrganization,
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _publishAsOrganization = value;
                              });
                            },
                      secondary: const Icon(Icons.business_rounded),
                      title: Text(
                        _isItalian
                            ? 'Pubblica come ${_organizationContext!.organization.publicName}'
                            : deOrEnglish(
                                context,
                                english:
                                    'Publish as ${_organizationContext!.organization.publicName}',
                                german:
                                    'Als ${_organizationContext!.organization.publicName} veröffentlichen',
                              ),
                      ),
                      subtitle: Text(
                        _isItalian
                            ? 'La Voce apparirà come contenuto ufficiale dell’organizzazione verificata.'
                            : deOrEnglish(
                                context,
                                english:
                                    'The Voce will appear as official content from the verified Organization.',
                                german:
                                    'Die Voce erscheint als offizieller Inhalt der verifizierten Organisation.',
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: _isItalian
                        ? 'Titolo'
                        : deOrEnglish(context,
                            english: 'Title', german: 'Titel'),
                    border: const OutlineInputBorder(),
                  ),
                  maxLength: 120,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _isItalian
                          ? 'Inserisci un titolo'
                          : deOrEnglish(context,
                              english: 'Enter a title',
                              german: 'Titel eingeben');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: _isItalian
                        ? 'Contenuto'
                        : deOrEnglish(context,
                            english: 'Content', german: 'Inhalt'),
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  minLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _isItalian
                          ? 'Inserisci il contenuto della Voce'
                          : deOrEnglish(context,
                              english: 'Enter the Voce content',
                              german: 'Voce-Inhalt eingeben');
                    }
                    if (value.trim().length < 10) {
                      return _isItalian
                          ? 'Il contenuto è troppo corto (minimo 10 caratteri)'
                          : deOrEnglish(context,
                              english:
                                  'The content is too short (minimum 10 characters)',
                              german:
                                  'Der Inhalt ist zu kurz (mindestens 10 Zeichen).');
                    }
                    return null;
                  },
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
                          _isItalian
                              ? 'Località del contenuto'
                              : deOrEnglish(context,
                                  english: 'Content location',
                                  german: 'Inhaltsstandort'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isItalian
                              ? 'Scegli se la Voce è globale, associata a una località oppure alla tua posizione attuale.'
                              : deOrEnglish(context,
                                  english:
                                      'Choose whether the Voce is global, linked to a location, or linked to your current location.',
                                  german:
                                      'Wähle, ob die Voce global, mit einem Standort oder mit deinem aktuellen Standort verknüpft ist.'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isItalian
                                    ? 'Località attiva'
                                    : deOrEnglish(context,
                                        english: 'Active location',
                                        german: 'Aktiver Standort'),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _locationSummary(location),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_isItalian ? 'Origine' : deOrEnglish(context, english: 'Source', german: 'Quelle')}: ${isGlobalSelected ? (_isItalian ? 'Globale' : deOrEnglish(context, english: 'Global', german: 'Global')) : _showManualLocationFields ? (_isItalian ? 'Manuale' : deOrEnglish(context, english: 'Manual', german: 'Manuell')) : location == null || location.isEmpty ? (_isItalian ? 'Globale' : deOrEnglish(context, english: 'Global', german: 'Global')) : _sourceLabel(location.source)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      setState(() {
                                        _showManualLocationFields = false;
                                        _contentLocation = null;
                                        _selectedCountryCode = null;
                                        _cityController.clear();
                                      });
                                    },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isGlobalSelected
                                    ? theme.colorScheme.primaryContainer
                                    : null,
                                foregroundColor: isGlobalSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : null,
                              ),
                              icon: const Icon(Icons.public),
                              label: Text(_isItalian
                                  ? 'Globale'
                                  : deOrEnglish(context,
                                      english: 'Global', german: 'Global')),
                            ),
                            OutlinedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      setState(() {
                                        _showManualLocationFields = true;
                                        _contentLocation = ContentLocation(
                                          source: ContentLocationSource.manual,
                                          countryCode: _normalizeString(
                                            _selectedCountryCode,
                                          ),
                                          cityName: _normalizeString(
                                            _cityController.text,
                                          ),
                                        );
                                      });
                                    },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _showManualLocationFields
                                    ? theme.colorScheme.primaryContainer
                                    : null,
                                foregroundColor: _showManualLocationFields
                                    ? theme.colorScheme.onPrimaryContainer
                                    : null,
                              ),
                              icon: const Icon(Icons.place_outlined),
                              label: Text(_isItalian
                                  ? 'Scegli località'
                                  : deOrEnglish(context,
                                      english: 'Choose location',
                                      german: 'Standort auswählen')),
                            ),
                            OutlinedButton.icon(
                              onPressed: _isSubmitting || _isResolvingLocation
                                  ? null
                                  : _useCurrentDeviceLocation,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isDeviceSelected
                                    ? theme.colorScheme.primaryContainer
                                    : null,
                                foregroundColor: isDeviceSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : null,
                              ),
                              icon: _isResolvingLocation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.my_location),
                              label: Text(
                                _isResolvingLocation
                                    ? (_isItalian
                                        ? 'Ricavo posizione...'
                                        : deOrEnglish(context,
                                            english: 'Getting location...',
                                            german:
                                                'Standort wird ermittelt...'))
                                    : (_isItalian
                                        ? 'Usa posizione attuale'
                                        : deOrEnglish(context,
                                            english: 'Use current location',
                                            german:
                                                'Aktuellen Standort verwenden')),
                              ),
                            ),
                          ],
                        ),
                        if (_showManualLocationFields) ...[
                          const SizedBox(height: 14),
                          CountrySelectorField(
                            selectedCountryCode: _selectedCountryCode,
                            onCountrySelected: (code) {
                              setState(() {
                                final countryChanged =
                                    _selectedCountryCode != code;
                                _selectedCountryCode = code;

                                if (countryChanged) {
                                  _cityController.clear();
                                }
                              });
                              _setManualLocation();
                            },
                            label: _isItalian
                                ? 'Paese del contenuto'
                                : deOrEnglish(context,
                                    english: 'Content country',
                                    german: 'Land des Inhalts'),
                            required: false,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              labelText: _isItalian
                                  ? 'Città del contenuto'
                                  : deOrEnglish(context,
                                      english: 'Content city',
                                      german: 'Stadt des Inhalts'),
                              border: const OutlineInputBorder(),
                              helperText: _isItalian
                                  ? 'Facoltativo. Puoi indicare solo il Paese oppure anche la città.'
                                  : deOrEnglish(context,
                                      english:
                                          'Optional. You can specify only the country or also the city.',
                                      german:
                                          'Optional. Du kannst nur das Land oder zusätzlich die Stadt angeben.'),
                            ),
                            onChanged: (_) => _setManualLocation(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_submitError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .errorContainer
                          .withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _submitError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: _isSubmitting ? null : _onSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isItalian
                          ? 'Pubblica Voce'
                          : deOrEnglish(context,
                              english: 'Publish Voce',
                              german: 'Voce veröffentlichen')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

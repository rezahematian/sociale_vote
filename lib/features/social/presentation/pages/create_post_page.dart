import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/analytics/analytics_service.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

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
        return _isItalian ? 'Manuale' : 'Manual';
      case ContentLocationSource.device:
        return _isItalian ? 'Posizione attuale' : 'Current location';
      case ContentLocationSource.profile:
        return _isItalian ? 'Profilo' : 'Profile';
      case ContentLocationSource.geoScopeFallback:
        return _isItalian ? 'Ambito corrente' : 'Current scope';
    }
  }

  String _locationSummary(ContentLocation? location) {
    if (location == null || location.isEmpty) {
      if (_showManualLocationFields) {
        return _isItalian ? 'Seleziona una località' : 'Select a location';
      }
      return _isItalian
          ? 'Globale / nessuna località specifica'
          : 'Global / no specific location';
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

    final hasCoordinates =
        location.latitude != null &&
        location.longitude != null &&
        location.latitude!.isFinite &&
        location.longitude!.isFinite;

    if (hasCoordinates) {
      return _isItalian ? 'Coordinate disponibili' : 'Coordinates available';
    }
    if (location.hasCenter) {
      return _isItalian
          ? 'Centro geografico disponibile'
          : 'Geographic center available';
    }

    return _isItalian ? 'Località non definita' : 'Location not defined';
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
                  : 'Turn on location services and try again.',
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
                    : 'Location permission was not granted. Enable it in system settings.',
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
                  : 'Unable to determine the current location.',
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
                : 'Current location applied: ${_locationSummary(location)}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isItalian
                ? 'Errore accesso posizione: $e'
                : 'Location access error: $e',
          ),
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
            : 'Error: user is not available in the current session.';
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
                      ? 'Post globale creato con successo.'
                      : 'Global post created successfully.')
                : effectiveLocation.hasExactPoint || effectiveLocation.hasCenter
                ? (_isItalian
                      ? 'Post creato con successo.'
                      : 'Post created successfully.')
                : (_isItalian
                      ? 'Post creato con successo. Località salvata senza coordinate precise.'
                      : 'Post created successfully. Location saved without precise coordinates.'),
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      final languageCode = Localizations.localeOf(context).languageCode;
      setState(() {
        _submitError = languageCode == 'it'
            ? 'Impossibile pubblicare il post. Controlla la connessione e riprova.'
            : 'Unable to publish the post. Check your connection and try again.';
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
      appBar: AppBar(title: Text(_isItalian ? 'Crea post' : 'Create post')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  _isItalian ? 'Nuovo post' : 'New post',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isItalian
                      ? 'Condividi una proposta, un’idea o un commento per quest’area geografica.'
                      : 'Share a proposal, an idea, or a comment for this geographic area.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: _isItalian ? 'Titolo' : 'Title',
                    border: const OutlineInputBorder(),
                  ),
                  maxLength: 120,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _isItalian
                          ? 'Inserisci un titolo'
                          : 'Enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: _isItalian ? 'Contenuto' : 'Content',
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  minLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _isItalian
                          ? 'Inserisci il contenuto del post'
                          : 'Enter the post content';
                    }
                    if (value.trim().length < 10) {
                      return _isItalian
                          ? 'Il contenuto è troppo corto (minimo 10 caratteri)'
                          : 'The content is too short (minimum 10 characters)';
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
                              : 'Content location',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isItalian
                              ? 'Scegli se il post è globale, associato a una località oppure alla tua posizione attuale.'
                              : 'Choose whether the post is global, linked to a location, or linked to your current location.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
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
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.15,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isItalian
                                    ? 'Località attiva'
                                    : 'Active location',
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
                                '${_isItalian ? 'Origine' : 'Source'}: ${isGlobalSelected
                                    ? (_isItalian ? 'Globale' : 'Global')
                                    : _showManualLocationFields
                                    ? (_isItalian ? 'Manuale' : 'Manual')
                                    : location == null || location.isEmpty
                                    ? (_isItalian ? 'Globale' : 'Global')
                                    : _sourceLabel(location.source)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
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
                              label: Text(_isItalian ? 'Globale' : 'Global'),
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
                              label: Text(
                                _isItalian
                                    ? 'Scegli località'
                                    : 'Choose location',
                              ),
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
                                          : 'Getting location...')
                                    : (_isItalian
                                          ? 'Usa posizione attuale'
                                          : 'Use current location'),
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
                                : 'Content country',
                            required: false,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              labelText: _isItalian
                                  ? 'Città del contenuto'
                                  : 'Content city',
                              border: const OutlineInputBorder(),
                              helperText: _isItalian
                                  ? 'Facoltativo. Puoi indicare solo il Paese oppure anche la città.'
                                  : 'Optional. You can specify only the country or also the city.',
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
                      color: Theme.of(
                        context,
                      ).colorScheme.errorContainer.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.35),
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
                      : Text(_isItalian ? 'Pubblica post' : 'Publish post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

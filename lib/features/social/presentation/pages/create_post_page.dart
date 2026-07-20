import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/analytics/analytics_service.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
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

  String? _selectedCountryCode;
  ContentLocation? _contentLocation;

  @override
  void initState() {
    super.initState();
    _applyScopeAsDefaultLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _applyScopeAsDefaultLocation({bool showFeedback = false}) {
    final scope = AppDI.instance.geoScopeController.scope;
    final location = _contentLocationFromScope(scope);

    setState(() {
      _contentLocation = location;
      _selectedCountryCode = location?.countryCode;
      _cityController.text = location?.cityName ?? '';
    });

    if (!showFeedback || !mounted) {
      return;
    }

    final message = location == null
        ? 'Scope World applicato: il post sarà globale.'
        : 'Scope corrente applicato: ${_locationSummary(location)}.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  ContentLocation? _contentLocationFromScope(GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return null;
      case GeoScopeLevel.country:
        return ContentLocation(
          source: ContentLocationSource.geoScopeFallback,
          countryCode: scope.countryCode,
          centerLat: scope.centerLat,
          centerLng: scope.centerLng,
        );
      case GeoScopeLevel.city:
        return ContentLocation(
          source: ContentLocationSource.geoScopeFallback,
          countryCode: scope.countryCode,
          cityId: scope.cityId,
          cityName: scope.cityId,
          centerLat: scope.centerLat,
          centerLng: scope.centerLng,
        );
    }
  }

  void _setManualLocation() {
    setState(() {
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
        return 'Manuale';
      case ContentLocationSource.device:
        return 'Posizione attuale';
      case ContentLocationSource.profile:
        return 'Profilo';
      case ContentLocationSource.geoScopeFallback:
        return 'Scope corrente';
    }
  }

  String _locationSummary(ContentLocation? location) {
    if (location == null || location.isEmpty) {
      return 'Globale / nessuna località specifica';
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
      return 'Coordinate disponibili';
    }
    if (location.hasCenter) {
      return 'Centro geografico disponibile';
    }

    return 'Località non definita';
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
          const SnackBar(
            content: Text(
              'Attiva i servizi di localizzazione e riprova.',
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
            const SnackBar(
              content: Text(
                'Permesso posizione non concesso. Abilitalo nelle impostazioni di sistema.',
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
          const SnackBar(
            content: Text(
              'Impossibile determinare la posizione attuale.',
            ),
          ),
        );
        return;
      }

      setState(() {
        _contentLocation = location;
        _selectedCountryCode = location.countryCode;
        _cityController.text = location.cityName ?? '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Posizione attuale applicata: ${_locationSummary(location)}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore accesso posizione: $e'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore: utente non disponibile nella sessione.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
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
                ? 'Post globale creato con successo.'
                : effectiveLocation.hasExactPoint || effectiveLocation.hasCenter
                    ? 'Post creato con successo.'
                    : 'Post creato con successo. Località salvata senza coordinate precise.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella creazione del post: $e'),
        ),
      );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create post'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'New post',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Condividi una proposta, un’idea o un commento per quest’area geografica.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 120,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci un titolo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  minLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci il contenuto del post';
                    }
                    if (value.trim().length < 10) {
                      return 'Il contenuto è troppo corto (min 10 caratteri)';
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
                          'Località contenuto',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Definisce dove il post deve apparire sulla mappa.',
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
                                'Località attiva',
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
                                'Origine: ${location == null || location.isEmpty ? 'Globale' : _sourceLabel(location.source)}',
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
                                  : () => _applyScopeAsDefaultLocation(
                                        showFeedback: true,
                                      ),
                              icon: const Icon(Icons.public),
                              label: const Text('Usa scope corrente'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _isSubmitting || _isResolvingLocation
                                  ? null
                                  : _useCurrentDeviceLocation,
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
                                    ? 'Ricavo posizione...'
                                    : 'Usa posizione attuale',
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      setState(() {
                                        _contentLocation = null;
                                        _selectedCountryCode = null;
                                        _cityController.clear();
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Il post è impostato come globale.',
                                          ),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.public_off_outlined),
                              label: const Text('Rendi globale'),
                            ),
                          ],
                        ),
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
                          label: 'Paese del contenuto',
                          required: false,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Città del contenuto',
                            border: OutlineInputBorder(),
                            helperText:
                                'Facoltativo. Lascia paese e città vuoti per un post globale.',
                          ),
                          onChanged: (_) => _setManualLocation(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSubmitting ? null : _onSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publish post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/geo/repositories/device_location_repository.dart';
import 'package:sociale_vote/domain/geo/repositories/geocoding_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/usecases/create_poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/quorum_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

class CreatePollController extends ChangeNotifier {
  final CreatePoll _createPollUseCase;
  final GeoScopeController _geoScopeController;
  final DeviceLocationRepository? _deviceLocationRepository;
  final GeocodingRepository? _geocodingRepository;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  final String? _createdByUserId;

  CreatePollController({
    required CreatePoll createPollUseCase,
    required GeoScopeController geoScopeController,
    required String? createdByUserId,
    DeviceLocationRepository? deviceLocationRepository,
    GeocodingRepository? geocodingRepository,
  })  : _createPollUseCase = createPollUseCase,
        _geoScopeController = geoScopeController,
        _createdByUserId = createdByUserId,
        _deviceLocationRepository = deviceLocationRepository,
        _geocodingRepository = geocodingRepository;

  String _title = '';
  String _description = '';
  final List<String> _options = ['', ''];

  PollType _type = PollType.singleChoice;
  int _minSelections = 1;
  int _maxSelections = 1;
  bool _allowVoteChange = false;

  DateTime _startAt = DateTime.now();
  DateTime _endAt = DateTime.now().add(const Duration(days: 7));

  ParticipationScope _participationScope = ParticipationScope.everyone;
  AnonymityLevel _anonymityLevel = AnonymityLevel.anonymous;
  ResultsVisibilityMode _resultsVisibility = ResultsVisibilityMode.always;
  int? _minQuorumVotes;

  String? _countryCodeForParticipation;

  ContentLocation? _contentLocation;
  bool _isResolvingContentLocation = false;

  bool _isSubmitting = false;
  String? _errorMessage;

  String get title => _title;
  String get description => _description;
  List<String> get options => List.unmodifiable(_options);

  PollType get type => _type;
  int get minSelections => _minSelections;
  int get maxSelections => _maxSelections;
  bool get allowVoteChange => _allowVoteChange;

  DateTime get startAt => _startAt;
  DateTime get endAt => _endAt;

  ParticipationScope get participationScope => _participationScope;
  AnonymityLevel get anonymityLevel => _anonymityLevel;
  ResultsVisibilityMode get resultsVisibility => _resultsVisibility;
  int? get minQuorumVotes => _minQuorumVotes;

  String? get countryCodeForParticipation => _countryCodeForParticipation;

  ContentLocation? get contentLocation => _contentLocation;
  bool get hasExplicitContentLocation => _contentLocation != null;
  bool get isResolvingContentLocation => _isResolvingContentLocation;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  int get _validNonEmptyOptionsCount =>
      _options.where((o) => o.trim().isNotEmpty).length;

  bool get _hasValidDates => !_endAt.isBefore(_startAt);

  bool get canSubmit =>
      !_isSubmitting &&
      _title.trim().isNotEmpty &&
      _validNonEmptyOptionsCount >= 2 &&
      _hasValidDates;

  ContentLocation get effectiveContentLocation {
    if (_contentLocation != null && !_contentLocation!.isEmpty) {
      return _contentLocation!;
    }

    return _locationFromScope(_geoScopeController.scope);
  }

  void setTitle(String value) {
    _title = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setOptionText(int index, String value) {
    if (index < 0 || index >= _options.length) return;
    _options[index] = value;
    _errorMessage = null;
    notifyListeners();
  }

  void addOption() {
    _options.add('');
    notifyListeners();
  }

  void removeOption(int index) {
    if (_options.length <= 2) {
      return;
    }
    if (index < 0 || index >= _options.length) return;
    _options.removeAt(index);
    notifyListeners();
  }

  void setType(PollType type) {
    _type = type;

    switch (type) {
      case PollType.yesNo:
      case PollType.singleChoice:
        _minSelections = 1;
        _maxSelections = 1;
        break;
      case PollType.multipleChoice:
        _minSelections = 1;
        _maxSelections =
            _validNonEmptyOptionsCount > 0 ? _validNonEmptyOptionsCount : 2;
        break;
      case PollType.approval:
        _minSelections = 0;
        _maxSelections =
            _validNonEmptyOptionsCount > 0 ? _validNonEmptyOptionsCount : 2;
        break;
      case PollType.ranked:
      case PollType.score:
        _minSelections = 1;
        _maxSelections =
            _validNonEmptyOptionsCount > 0 ? _validNonEmptyOptionsCount : 2;
        break;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void setMinSelections(int value) {
    if (value < 0) return;
    if (value > _maxSelections) {
      _maxSelections = value;
    }
    _minSelections = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setMaxSelections(int value) {
    if (value < _minSelections) return;
    _maxSelections = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setAllowVoteChange(bool value) {
    _allowVoteChange = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setParticipationScope(ParticipationScope scope) {
    _participationScope = scope;
    _errorMessage = null;
    notifyListeners();
  }

  void setCountryCodeForParticipation(String? code) {
    _countryCodeForParticipation = code;
    _errorMessage = null;
    notifyListeners();
  }

  void setAnonymityLevel(AnonymityLevel level) {
    _anonymityLevel = level;
    _errorMessage = null;
    notifyListeners();
  }

  void setResultsVisibility(ResultsVisibilityMode mode) {
    _resultsVisibility = mode;
    _errorMessage = null;
    notifyListeners();
  }

  void setMinQuorumVotes(int? value) {
    if (value != null && value <= 0) {
      _minQuorumVotes = null;
    } else {
      _minQuorumVotes = value;
    }
    _errorMessage = null;
    notifyListeners();
  }

  void setStartAt(DateTime value) {
    _startAt = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setEndAt(DateTime value) {
    _endAt = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setManualContentLocation({
    required String? countryCode,
    String? cityId,
    String? cityName,
    double? centerLat,
    double? centerLng,
    double? latitude,
    double? longitude,
  }) {
    _contentLocation = ContentLocation(
      source: ContentLocationSource.manual,
      countryCode: _normalizeString(countryCode),
      cityId: _normalizeString(cityId),
      cityName: _normalizeString(cityName),
      centerLat: centerLat,
      centerLng: centerLng,
      latitude: latitude,
      longitude: longitude,
    );

    _errorMessage = null;
    notifyListeners();
  }

  void setContentLocation(ContentLocation? location) {
    _contentLocation = location;
    _errorMessage = null;
    notifyListeners();
  }

  void clearContentLocation() {
    _contentLocation = null;
    _errorMessage = null;
    notifyListeners();
  }

  void useGeoScopeAsContentLocation() {
    _contentLocation = _locationFromScope(_geoScopeController.scope);
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> useCurrentDeviceLocation() async {
    if (_isResolvingContentLocation) {
      return false;
    }

    if (_deviceLocationRepository == null) {
      _errorMessage = 'Device location is not available.';
      notifyListeners();
      return false;
    }

    _isResolvingContentLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final location =
          await _deviceLocationRepository!.getCurrentContentLocation();

      if (location == null || location.isEmpty) {
        _isResolvingContentLocation = false;
        _errorMessage = 'Unable to read current device location.';
        notifyListeners();
        return false;
      }

      _contentLocation = location;
      _isResolvingContentLocation = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error resolving device location: $e');
        debugPrint('$stackTrace');
      }

      _isResolvingContentLocation = false;
      _errorMessage = 'Unable to access device location.';
      notifyListeners();
      return false;
    }
  }

  Future<ContentLocation> _resolveLocationBeforeSubmit() async {
    final rawLocation = effectiveContentLocation;

    if (rawLocation.source != ContentLocationSource.manual) {
      return rawLocation;
    }

    if (rawLocation.hasExactPoint || rawLocation.hasCenter) {
      return rawLocation;
    }

    if (_geocodingRepository == null) {
      return rawLocation;
    }

    final hasEnoughData = rawLocation.hasCountry || rawLocation.hasCityName;
    if (!hasEnoughData) {
      return rawLocation;
    }

    try {
      final geocoded =
          await _geocodingRepository!.geocodeContentLocation(rawLocation);
      return geocoded ?? rawLocation;
    } catch (_) {
      return rawLocation;
    }
  }

  Future<PollId?> submit() async {
    if (_isSubmitting) return null;

    final trimmedTitle = _title.trim();
    final trimmedDescription = _description.trim();
    final nonEmptyOptions =
        _options.map((o) => o.trim()).where((o) => o.isNotEmpty).toList();

    if (trimmedTitle.isEmpty) {
      _errorMessage = 'Title is required.';
      notifyListeners();
      return null;
    }

    if (nonEmptyOptions.length < 2) {
      _errorMessage = 'At least two options are required.';
      notifyListeners();
      return null;
    }

    if (_endAt.isBefore(_startAt)) {
      _errorMessage = 'End date must be after start date.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final scope = _geoScopeController.scope;
      final effectiveLocation = await _resolveLocationBeforeSubmit();

      String? geoCountryCode = effectiveLocation.countryCode;
      String? cityId = effectiveLocation.cityId;

      if (geoCountryCode == null || geoCountryCode.trim().isEmpty) {
        if (scope.level == GeoScopeLevel.country ||
            scope.level == GeoScopeLevel.city) {
          geoCountryCode = scope.countryCode;
        }
      }

      if ((cityId == null || cityId.trim().isEmpty) &&
          scope.level == GeoScopeLevel.city) {
        cityId = scope.cityId;
      }

      final effectiveParticipationCountry =
          _participationScope == ParticipationScope.geoScopeOnly
              ? (_countryCodeForParticipation ?? geoCountryCode)
              : null;

      if (_participationScope == ParticipationScope.geoScopeOnly &&
          effectiveParticipationCountry == null) {
        _isSubmitting = false;
        _errorMessage = 'Please select a country for this poll.';
        notifyListeners();
        return null;
      }

      final temporaryId = PollId(
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      final pollOptions = <PollOption>[];
      for (var i = 0; i < nonEmptyOptions.length; i++) {
        pollOptions.add(
          PollOption(
            id: 'opt_${i + 1}',
            label: nonEmptyOptions[i],
          ),
        );
      }

      final participationRules = ParticipationRules(
        scope: _participationScope,
        countryCode: effectiveParticipationCountry,
      );

      final configuration = PollConfiguration(
        minSelections: _minSelections,
        maxSelections: _maxSelections,
        allowVoteChange: _allowVoteChange,
        participationRules: participationRules,
        anonymityRules: AnonymityRules(level: _anonymityLevel),
        visibilityRules:
            VisibilityRules(resultsVisibility: _resultsVisibility),
        quorumRules: QuorumRules(minAbsoluteVotes: _minQuorumVotes),
      );

      final now = DateTime.now();
      late PollStatus status;

      if (_startAt.isAfter(now)) {
        status = PollStatus.scheduled;
      } else if (_endAt.isBefore(now)) {
        status = PollStatus.closed;
      } else {
        status = PollStatus.open;
      }

      final poll = Poll(
        id: temporaryId,
        title: trimmedTitle,
        description: trimmedDescription.isEmpty ? null : trimmedDescription,
        type: _type,
        status: status,
        options: pollOptions,
        configuration: configuration,
        startAt: _startAt,
        endAt: _endAt,
        countryCode: geoCountryCode,
        cityId: cityId,
        contentLocation: effectiveLocation,
        createdByUserId: _createdByUserId,
      );

      final createdPoll = await _createPollUseCase(poll);

      await _trackPollCreated(
        createdPoll: createdPoll,
        optionCount: nonEmptyOptions.length,
        hasDescription: trimmedDescription.isNotEmpty,
        contentLocation: effectiveLocation,
      );

      _isSubmitting = false;
      notifyListeners();
      return createdPoll.id;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error creating poll: $e');
        debugPrint('$stackTrace');
      }

      _isSubmitting = false;
      _errorMessage = kDebugMode
          ? 'Create poll failed: $e'
          : 'Unable to create poll at the moment.';
      notifyListeners();
      return null;
    }
  }

  Future<void> _trackPollCreated({
    required Poll createdPoll,
    required int optionCount,
    required bool hasDescription,
    required ContentLocation contentLocation,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'create_poll',
        parameters: <String, Object>{
          'poll_id': createdPoll.id.value,
          'poll_type': _type.name,
          'option_count': optionCount,
          'participation_scope': _participationScope.name,
          'has_description': hasDescription,
          'has_content_country': contentLocation.hasCountry,
          'has_content_city': contentLocation.hasCityName,
        },
      );
    } catch (_) {
      // Best effort: analytics must never break poll creation.
    }
  }

  ContentLocation _locationFromScope(GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        return ContentLocation(
          source: ContentLocationSource.geoScopeFallback,
          centerLat: scope.centerLat ?? 20.0,
          centerLng: scope.centerLng ?? 0.0,
        );

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
          centerLat: scope.centerLat,
          centerLng: scope.centerLng,
        );
    }
  }

  String? _normalizeString(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}
import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/usecases/create_poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/quorum_rules.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

class CreatePollController extends ChangeNotifier {
  final CreatePoll _createPollUseCase;
  final GeoScopeController _geoScopeController;

  CreatePollController({
    required CreatePoll createPollUseCase,
    required GeoScopeController geoScopeController,
  })  : _createPollUseCase = createPollUseCase,
        _geoScopeController = geoScopeController;

  // ===== BASIC =====
  String _title = '';
  String _description = '';
  final List<String> _options = ['', '']; // almeno 2

  // ===== MODELLO DI VOTO =====
  PollType _type = PollType.singleChoice;
  int _minSelections = 1;
  int _maxSelections = 1;
  bool _allowVoteChange = false;

  // ===== TEMPI =====
  DateTime _startAt = DateTime.now();
  DateTime _endAt = DateTime.now().add(const Duration(days: 7));

  // ===== REGOLE AVANZATE =====
  ParticipationScope _participationScope = ParticipationScope.everyone;
  AnonymityLevel _anonymityLevel = AnonymityLevel.anonymous;
  ResultsVisibilityMode _resultsVisibility = ResultsVisibilityMode.always;
  int? _minQuorumVotes;

  // ===== STATO UI =====
  bool _isSubmitting = false;
  String? _errorMessage;

  // ===== GETTER =====
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

  // ===== MUTATORI BASE =====
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
      // mai meno di 2 opzioni
      return;
    }
    if (index < 0 || index >= _options.length) return;
    _options.removeAt(index);
    notifyListeners();
  }

  // ===== MODELLO DI VOTO =====

  void setType(PollType type) {
    _type = type;

    // default sensati per min/max in base al tipo
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

  // ===== REGOLE AVANZATE =====
  void setParticipationScope(ParticipationScope scope) {
    _participationScope = scope;
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

  // ===== TEMPI =====
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

  // ===== SUBMIT =====
  /// Ritorna il [PollId] del poll creato se va tutto bene,
  /// altrimenti `null` in caso di errore o validazione fallita.
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
      // GeoScope → country / city
      final scope = _geoScopeController.scope;
      String? countryCode;
      String? cityId;

      if (scope.level == GeoScopeLevel.country) {
        countryCode = scope.countryCode;
      } else if (scope.level == GeoScopeLevel.city) {
        countryCode = scope.countryCode;
        cityId = scope.cityId;
      }

      // ID mock
      final id = PollId(DateTime.now().millisecondsSinceEpoch.toString());

      // Opzioni
      final pollOptions = <PollOption>[];
      for (var i = 0; i < nonEmptyOptions.length; i++) {
        pollOptions.add(
          PollOption(
            id: 'opt_${i + 1}',
            label: nonEmptyOptions[i],
          ),
        );
      }

      // Configurazione completa
      final configuration = PollConfiguration(
        minSelections: _minSelections,
        maxSelections: _maxSelections,
        allowVoteChange: _allowVoteChange,
        participationRules: ParticipationRules(scope: _participationScope),
        anonymityRules: AnonymityRules(level: _anonymityLevel),
        visibilityRules:
            VisibilityRules(resultsVisibility: _resultsVisibility),
        quorumRules: QuorumRules(minAbsoluteVotes: _minQuorumVotes),
      );

      // Status iniziale
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
        id: id,
        title: trimmedTitle,
        description: trimmedDescription.isEmpty ? null : trimmedDescription,
        type: _type,
        status: status,
        options: pollOptions,
        configuration: configuration,
        startAt: _startAt,
        endAt: _endAt,
        countryCode: countryCode,
        cityId: cityId,
      );

      await _createPollUseCase(poll);

      _isSubmitting = false;
      notifyListeners();
      return id;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error creating poll: $e');
        debugPrint('$stackTrace');
      }

      _isSubmitting = false;
      _errorMessage = 'Unable to create poll at the moment.';
      notifyListeners();
      return null;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/usecases/get_polls.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

class PollListController extends ChangeNotifier {
  final GetPolls getPollsUseCase;
  final GeoScopeController geoScopeController;

  // Engagement
  final ToggleReaction toggleReaction;
  final GetReactionSummary getReactionSummary;

  late final VoidCallback _geoScopeListener;

  PollListController({
    required this.getPollsUseCase,
    required this.geoScopeController,
    required this.toggleReaction,
    required this.getReactionSummary,
  }) {
    // Quando cambia lo scope geografico, ricarichiamo automaticamente i poll.
    _geoScopeListener = () {
      loadPolls();
    };
    geoScopeController.addListener(_geoScopeListener);
  }

  bool _isLoading = false;
  List<Poll> _polls = [];

  /// Reaction summary per pollId (poll.id.value).
  Map<String, ReactionSummary> _reactionSummaries = {};

  bool get isLoading => _isLoading;
  List<Poll> get polls => _polls;

  /// Carica i poll in base allo scope geografico corrente.
  ///
  /// Legge:
  /// - scope.level == world  -> nessun filtro (poll globali)
  /// - scope.level == country -> filtra per countryCode
  /// - scope.level == city    -> filtra per countryCode + cityId
  Future<void> loadPolls() async {
    _isLoading = true;
    notifyListeners();

    final scope = geoScopeController.scope;

    String? countryCode;
    String? cityId;

    switch (scope.level) {
      case GeoScopeLevel.world:
        countryCode = null;
        cityId = null;
        break;
      case GeoScopeLevel.country:
        countryCode = scope.countryCode;
        cityId = null;
        break;
      case GeoScopeLevel.city:
        countryCode = scope.countryCode;
        cityId = scope.cityId;
        break;
    }

    _polls = await getPollsUseCase(
      countryCode: countryCode,
      cityId: cityId,
    );

    // Dopo aver caricato i poll, carichiamo i reaction summary associati.
    await _loadReactionSummariesForPolls();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadReactionSummariesForPolls() async {
    if (_polls.isEmpty) {
      _reactionSummaries = {};
      return;
    }

    final targets = _polls
        .map(
          (poll) => TargetRef.poll(poll.id.value),
        )
        .toList();

    final summaries = await getReactionSummary(targets);

    _reactionSummaries = {
      for (final summary in summaries) summary.target.id: summary,
    };
  }

  ReactionSummary? _summaryForPoll(Poll poll) {
    return _reactionSummaries[poll.id.value];
  }

  int likeCountForPoll(Poll poll) {
    return _summaryForPoll(poll)?.likeCount ?? 0;
  }

  int dislikeCountForPoll(Poll poll) {
    return _summaryForPoll(poll)?.dislikeCount ?? 0;
  }

  /// Toggle 🔥 per un poll.
  ///
  /// userId: per ora può essere 'demo-user', in futuro userId reale da identity.
  Future<void> toggleFireForPoll({
    required String userId,
    required Poll poll,
  }) async {
    final target = TargetRef.poll(poll.id.value);

    final summary = await toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    _reactionSummaries[poll.id.value] = summary;
    notifyListeners();
  }

  /// Toggle ❄ per un poll.
  Future<void> toggleIceForPoll({
    required String userId,
    required Poll poll,
  }) async {
    final target = TargetRef.poll(poll.id.value);

    final summary = await toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    _reactionSummaries[poll.id.value] = summary;
    notifyListeners();
  }

  @override
  void dispose() {
    geoScopeController.removeListener(_geoScopeListener);
    super.dispose();
  }
}
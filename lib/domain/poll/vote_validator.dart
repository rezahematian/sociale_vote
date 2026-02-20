import 'poll_entity.dart';
import 'vote_entity.dart';
import 'poll_type.dart';

class VoteValidator {
  void validate({
    required PollEntity poll,
    required List<VoteSelection> selections,
  }) {
    if (!poll.isOpen) {
      throw Exception('Poll is not open');
    }

    if (selections.isEmpty) {
      throw Exception('At least one selection is required');
    }

    switch (poll.type) {
      case PollType.singleChoice:
        _validateSingleChoice(poll, selections);
        break;

      case PollType.multipleChoice:
        _validateMultipleChoice(poll, selections);
        break;

      case PollType.rankedChoice:
        _validateRankedChoice(poll, selections);
        break;

      case PollType.weighted:
        _validateWeighted(poll, selections);
        break;
    }
  }

  // =========================
  // SINGLE
  // =========================

  void _validateSingleChoice(
    PollEntity poll,
    List<VoteSelection> selections,
  ) {
    if (selections.length != 1) {
      throw Exception('Single choice poll requires exactly one selection');
    }

    _validateOptionsExist(poll, selections);
  }

  // =========================
  // MULTI
  // =========================

  void _validateMultipleChoice(
    PollEntity poll,
    List<VoteSelection> selections,
  ) {
    _validateOptionsExist(poll, selections);

    final min = poll.configuration.minSelections;
    final max = poll.configuration.maxSelections;

    if (min != null && selections.length < min) {
      throw Exception('Minimum $min selections required');
    }

    if (max != null && selections.length > max) {
      throw Exception('Maximum $max selections allowed');
    }
  }

  // =========================
  // RANKED
  // =========================

  void _validateRankedChoice(
    PollEntity poll,
    List<VoteSelection> selections,
  ) {
    _validateOptionsExist(poll, selections);

    final ranks = selections.map((e) => e.rank).toList();

    if (ranks.contains(null)) {
      throw Exception('Ranked poll requires rank for each selection');
    }

    final uniqueRanks = ranks.toSet();
    if (uniqueRanks.length != ranks.length) {
      throw Exception('Duplicate ranks are not allowed');
    }
  }

  // =========================
  // WEIGHTED
  // =========================

  void _validateWeighted(
    PollEntity poll,
    List<VoteSelection> selections,
  ) {
    _validateOptionsExist(poll, selections);

    for (final s in selections) {
      if (s.weight == null) {
        throw Exception('Weighted poll requires weight for each selection');
      }

      if (s.weight! <= 0) {
        throw Exception('Weight must be positive');
      }
    }
  }

  // =========================
  // COMMON
  // =========================

  void _validateOptionsExist(
    PollEntity poll,
    List<VoteSelection> selections,
  ) {
    final optionIds = poll.options.map((o) => o.id).toSet();

    for (final selection in selections) {
      if (!optionIds.contains(selection.optionId)) {
        throw Exception(
          'Invalid option selected: ${selection.optionId}',
        );
      }
    }
  }
}

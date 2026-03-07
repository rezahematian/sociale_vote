import 'poll_entity.dart';

enum PollVoteType {
  single,
  multiple,
  ranked,
  score,
  yesNo,
  approval,
}

enum PollResultsVisibility {
  immediate,
  afterVote,
  afterExpiry,
  creatorOnly,
}

enum PollAnonymity {
  anonymous,
  public,
  publicAfterExpiry,
}

class PollConfiguration {
  final PollVoteType voteType;

  // Selection rules
  final int? minSelections;
  final int? maxSelections;

  // Score rules
  final int? minScore;
  final int? maxScore;

  // Duration
  final DateTime? startAt;
  final DateTime? expiresAt;
  final bool allowNoExpiry;

  // Vote editing
  final bool allowVoteChange;

  // Results visibility
  final PollResultsVisibility resultsVisibility;

  // Privacy
  final PollAnonymity anonymity;

  // Quorum
  final int? minimumQuorum;

  const PollConfiguration({
    required this.voteType,
    this.minSelections,
    this.maxSelections,
    this.minScore,
    this.maxScore,
    this.startAt,
    this.expiresAt,
    this.allowNoExpiry = false,
    this.allowVoteChange = false,
    this.resultsVisibility = PollResultsVisibility.afterVote,
    this.anonymity = PollAnonymity.anonymous,
    this.minimumQuorum,
  });
}

class PollRules {
  const PollRules._();

  // =========================
  // STRUCTURE VALIDATION
  // =========================

  static void validatePollStructure(PollEntity poll) {
    if (poll.options.isEmpty) {
      throw PollRuleException(
        'Il sondaggio non ha opzioni di voto',
      );
    }

    if (poll.options.length < 2) {
      throw PollRuleException(
        'Il sondaggio deve avere almeno due opzioni',
      );
    }

    final optionIds = poll.options.map((o) => o.id).toSet();
    if (optionIds.length != poll.options.length) {
      throw PollRuleException(
        'Le opzioni devono avere ID univoci',
      );
    }
  }

  // =========================
  // DATE VALIDATION
  // =========================

  static void validateConfigurationDates(PollConfiguration config) {
    if (!config.allowNoExpiry) {
      if (config.expiresAt == null) {
        throw PollRuleException(
          'La data di scadenza è obbligatoria',
        );
      }

      if (config.startAt != null &&
          config.expiresAt!.isBefore(config.startAt!)) {
        throw PollRuleException(
          'La scadenza deve essere successiva alla data di inizio',
        );
      }

      if (config.expiresAt!.isBefore(DateTime.now())) {
        throw PollRuleException(
          'La scadenza non può essere nel passato',
        );
      }
    }
  }

  // =========================
  // STATE VALIDATION
  // =========================

  static void validatePollIsOpen(
    PollEntity poll,
    PollConfiguration config,
  ) {
    if (poll.isClosed) {
      throw PollRuleException(
        'Il sondaggio è chiuso',
      );
    }

    if (!config.allowNoExpiry &&
        config.expiresAt != null &&
        DateTime.now().isAfter(config.expiresAt!)) {
      throw PollRuleException(
        'Il sondaggio è scaduto',
      );
    }

    if (config.startAt != null &&
        DateTime.now().isBefore(config.startAt!)) {
      throw PollRuleException(
        'Il sondaggio non è ancora iniziato',
      );
    }
  }

  // =========================
  // VOTE VALIDATION
  // =========================

  static void validateVoteSelection({
    required PollConfiguration config,
    required int selectedCount,
  }) {
    switch (config.voteType) {
      case PollVoteType.single:
        if (selectedCount != 1) {
          throw PollRuleException(
            'Devi selezionare una sola opzione',
          );
        }
        break;

      case PollVoteType.multiple:
      case PollVoteType.approval:
        if (config.minSelections != null &&
            selectedCount < config.minSelections!) {
          throw PollRuleException(
            'Numero minimo di selezioni non rispettato',
          );
        }

        if (config.maxSelections != null &&
            selectedCount > config.maxSelections!) {
          throw PollRuleException(
            'Numero massimo di selezioni superato',
          );
        }
        break;

      case PollVoteType.ranked:
        if (selectedCount < 2) {
          throw PollRuleException(
            'Devi ordinare almeno due opzioni',
          );
        }
        break;

      case PollVoteType.score:
        break;

      case PollVoteType.yesNo:
        if (selectedCount != 1) {
          throw PollRuleException(
            'Devi scegliere sì o no',
          );
        }
        break;
    }
  }

  // =========================
  // QUORUM VALIDATION
  // =========================

  static bool isQuorumReached({
    required PollConfiguration config,
    required int totalVotes,
  }) {
    if (config.minimumQuorum == null) return true;

    return totalVotes >= config.minimumQuorum!;
  }
}

class PollRuleException implements Exception {
  final String message;

  PollRuleException(this.message);

  @override
  String toString() => message;
}

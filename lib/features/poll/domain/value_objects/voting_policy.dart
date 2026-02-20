import '../entities/poll_entity.dart';
import '../entities/vote_request.dart';
import 'poll_configuration.dart';

class VotingPolicy {
  /// 1 utente = 1 voto (default true)
  final bool oneVotePerUser;

  /// Possibile estensione futura (cooldown, premium, ecc.)
  final bool enforceSelectionIntegrity;

  const VotingPolicy({
    this.oneVotePerUser = true,
    this.enforceSelectionIntegrity = true,
  });

  // =========================
  // CHECK PRINCIPALE
  // =========================
  void checkVoteAllowed({
    required PollEntity poll,
    required VoteRequest request,
  }) {
    final config = poll.configuration;

    // 1️⃣ Regola un voto per utente
    if (oneVotePerUser && poll.userHasVoted) {
      throw VotingPolicyException('Hai già votato');
    }

    // 2️⃣ Deve avere almeno una selezione
    if (request.isEmpty) {
      throw VotingPolicyException(
        'Devi selezionare almeno un’opzione',
      );
    }

    // 3️⃣ Validazione per tipo di voto
    switch (config.votingType) {
      case VotingType.singleChoice:
      case VotingType.yesNo:
        _validateSingle(request);
        break;

      case VotingType.multipleChoice:
      case VotingType.approval:
        _validateSelectionLimits(config, request);
        break;

      case VotingType.ranked:
        _validateRanking(config, request);
        break;

      case VotingType.score:
        _validateScore(config, request);
        break;
    }
  }

  // =========================
  // VALIDAZIONI PRIVATE
  // =========================

  void _validateSingle(VoteRequest request) {
    if (request.selectedCount != 1) {
      throw VotingPolicyException(
        'Puoi selezionare una sola opzione',
      );
    }
  }

  void _validateSelectionLimits(
    PollConfiguration config,
    VoteRequest request,
  ) {
    if (config.minSelections != null &&
        request.selectedCount < config.minSelections!) {
      throw VotingPolicyException(
        'Numero selezioni inferiore al minimo consentito',
      );
    }

    if (config.maxSelections != null &&
        request.selectedCount > config.maxSelections!) {
      throw VotingPolicyException(
        'Numero selezioni superiore al massimo consentito',
      );
    }
  }

  void _validateRanking(
    PollConfiguration config,
    VoteRequest request,
  ) {
    if (!request.containsRanking) {
      throw VotingPolicyException(
        'Devi specificare il ranking',
      );
    }

    final ranks = request.ranks;

    if (ranks.isEmpty) {
      throw VotingPolicyException(
        'Ranking vuoto non consentito',
      );
    }

    // Controllo duplicati
    final uniqueRanks = ranks.toSet();
    if (uniqueRanks.length != ranks.length) {
      throw VotingPolicyException(
        'Ranking duplicato non valido',
      );
    }

    // Se non è permesso ranking parziale
    if (!config.allowPartialRanking &&
        ranks.length != request.selectedCount) {
      throw VotingPolicyException(
        'Ranking incompleto non consentito',
      );
    }
  }

  void _validateScore(
    PollConfiguration config,
    VoteRequest request,
  ) {
    if (!request.containsScore) {
      throw VotingPolicyException(
        'Devi assegnare un punteggio',
      );
    }

    for (final selection in request.selections) {
      final score = selection.score;

      if (score == null) {
        throw VotingPolicyException(
          'Punteggio mancante',
        );
      }

      if (config.minScore != null &&
          score < config.minScore!) {
        throw VotingPolicyException(
          'Punteggio inferiore al minimo consentito',
        );
      }

      if (config.maxScore != null &&
          score > config.maxScore!) {
        throw VotingPolicyException(
          'Punteggio superiore al massimo consentito',
        );
      }
    }
  }
}

class VotingPolicyException implements Exception {
  final String message;

  VotingPolicyException(this.message);

  @override
  String toString() => message;
}

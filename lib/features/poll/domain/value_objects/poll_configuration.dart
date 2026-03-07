class PollConfiguration {
  // =========================
  // 1️⃣ Tipo di voto
  // =========================
  final VotingType votingType;

  // =========================
  // 2️⃣ Regole di selezione
  // =========================
  final int? minSelections;
  final int? maxSelections;

  final int? minScore;
  final int? maxScore;

  final bool allowPartialRanking;

  // =========================
  // 3️⃣ Visibilità risultati
  // =========================
  final ResultVisibility resultVisibility;

  // =========================
  // 4️⃣ Anonimato
  // =========================
  final AnonymityType anonymityType;

  // =========================
  // 5️⃣ Modifica voto
  // =========================
  final VoteModificationType modificationType;
  final int? modificationMinutes;

  // =========================
  // 6️⃣ Durata
  // =========================
  final DateTime? startDate;
  final DateTime? endDate;
  final bool closeManually;

  const PollConfiguration({
    required this.votingType,

    this.minSelections,
    this.maxSelections,
    this.minScore,
    this.maxScore,
    this.allowPartialRanking = false,

    required this.resultVisibility,
    required this.anonymityType,

    required this.modificationType,
    this.modificationMinutes,

    this.startDate,
    this.endDate,
    this.closeManually = false,
  });

  bool get isActive {
    final now = DateTime.now();

    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    return true;
  }

  bool canModifyVote(DateTime voteTime) {
    final now = DateTime.now();

    switch (modificationType) {
      case VoteModificationType.always:
        return true;

      case VoteModificationType.untilEnd:
        if (endDate == null) return true;
        return now.isBefore(endDate!);

      case VoteModificationType.withinMinutes:
        if (modificationMinutes == null) return false;
        return now.difference(voteTime).inMinutes <= modificationMinutes!;

      case VoteModificationType.never:
        return false;
    }
  }
}

// =======================================================
// ENUM DEFINITIONS (inclusi qui, nessun file esterno)
// =======================================================

enum VotingType {
  singleChoice,
  multipleChoice,
  ranked,
  score,
  yesNo,
  approval,
}

enum ResultVisibility {
  immediate,
  afterVote,
  afterEnd,
  creatorOnlyLive,
  moderatorsOnly,
  countOnly,
  percentageOnly,
}

enum AnonymityType {
  anonymous,
  public,
  pseudonymous,
  creatorOnly,
  publicAfterEnd,
}

enum VoteModificationType {
  always,
  untilEnd,
  withinMinutes,
  never,
}

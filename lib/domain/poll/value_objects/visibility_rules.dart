/// Quando e come i risultati del poll sono visibili.
enum ResultsVisibilityMode {
  /// Risultati sempre visibili (anche a poll aperto).
  always,

  /// Risultati visibili solo a chi ha già votato.
  afterVote,

  /// Risultati visibili solo dopo la chiusura del poll.
  afterClose,
}

class VisibilityRules {
  final ResultsVisibilityMode resultsVisibility;

  const VisibilityRules({
    this.resultsVisibility = ResultsVisibilityMode.always,
  });

  bool get isAlwaysVisible =>
      resultsVisibility == ResultsVisibilityMode.always;

  bool get isVisibleOnlyAfterVote =>
      resultsVisibility == ResultsVisibilityMode.afterVote;

  bool get isVisibleOnlyAfterClose =>
      resultsVisibility == ResultsVisibilityMode.afterClose;

  VisibilityRules copyWith({
    ResultsVisibilityMode? resultsVisibility,
  }) {
    return VisibilityRules(
      resultsVisibility: resultsVisibility ?? this.resultsVisibility,
    );
  }
}
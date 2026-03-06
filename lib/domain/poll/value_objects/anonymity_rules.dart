/// Regole di anonimato del voto per un singolo poll.
enum AnonymityLevel {
  /// I voti sono anonimi (solo aggregati).
  anonymous,

  /// I voti non sono anonimi (in futuro potremo mostrarli
  /// a ruoli specifici / audit log, ecc.).
  public,
}

class AnonymityRules {
  final AnonymityLevel level;

  const AnonymityRules({
    this.level = AnonymityLevel.anonymous,
  });

  bool get isAnonymous => level == AnonymityLevel.anonymous;

  AnonymityRules copyWith({
    AnonymityLevel? level,
  }) {
    return AnonymityRules(
      level: level ?? this.level,
    );
  }
}
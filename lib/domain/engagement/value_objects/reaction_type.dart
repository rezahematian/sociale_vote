/// Tipo di reazione di base.
/// 
/// v1: solo like / dislike (heat / cold).
/// In futuro puoi estendere con:
/// - applause
/// - insightful
/// - angry
/// ecc.
///
/// IMPORTANTE:
/// niente dipendenze da Flutter qui, solo dart:core.
enum ReactionType {
  like,
  dislike,
}

extension ReactionTypeX on ReactionType {
  /// +1 per like, -1 per dislike.
  int get score {
    switch (this) {
      case ReactionType.like:
        return 1;
      case ReactionType.dislike:
        return -1;
    }
  }
}
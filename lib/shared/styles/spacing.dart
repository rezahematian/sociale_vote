import 'package:sociale_vote/app/theme/spacing.dart';

/// Alias / ponte per il sistema di spacing centrale.
///
/// Per evitare duplicazioni, tutta la logica di spacing
/// è definita in:
///   - lib/app/theme/spacing.dart -> [AppSpacing]
///
/// Questo file esiste solo come punto di import "storico"
/// per il codice che usava `shared/styles/spacing.dart`,
/// e ora reindirizza verso [AppSpacing].
export 'package:sociale_vote/app/theme/spacing.dart' show AppSpacing;
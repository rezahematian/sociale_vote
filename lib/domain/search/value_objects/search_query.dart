import 'package:meta/meta.dart';

/// Tipologie di contenuti ricercabili.
///
/// V1: ci concentriamo su Poll / News / Post.
/// [all] significa "qualunque tipo", sarà il default.
enum SearchContentType {
  all,
  poll,
  news,
  post,
}

/// Value object che rappresenta la query di ricerca
/// inserita dall’utente.
///
/// Componenti principali:
/// - [rawText]: stringa così come digitata dall’utente
/// - [type]: filtro sul tipo di contenuto (Poll / News / Post / All)
///
/// In futuro:
/// - potremo arricchirlo con filtri più complessi (data range, autore, ecc.)
@immutable
class SearchQuery {
  /// Testo così come inserito dall’utente (non normalizzato).
  final String rawText;

  /// Tipo di contenuto che l’utente vuole cercare.
  /// Di default [SearchContentType.all].
  final SearchContentType type;

  const SearchQuery({
    required this.rawText,
    this.type = SearchContentType.all,
  });

  /// Factory di comodo quando hai solo la stringa della query
  /// e vuoi cercare su tutti i tipi di contenuto.
  factory SearchQuery.simple(String input) {
    return SearchQuery(
      rawText: input,
      type: SearchContentType.all,
    );
  }

  /// Testo normalizzato:
  /// - trim
  /// - minuscolo
  String get normalizedText => rawText.trim().toLowerCase();

  /// True se la query è vuota (dopo trim).
  bool get isEmpty => normalizedText.isEmpty;

  /// True se la query contiene almeno un carattere utile.
  bool get isNotEmpty => !isEmpty;

  /// Copia con qualche campo modificato.
  SearchQuery copyWith({
    String? rawText,
    SearchContentType? type,
  }) {
    return SearchQuery(
      rawText: rawText ?? this.rawText,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'SearchQuery(rawText: "$rawText", type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchQuery &&
        other.rawText == rawText &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(rawText, type);
}
import 'package:meta/meta.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/search/value_objects/search_query.dart';

/// Entità dominio che rappresenta un singolo risultato
/// restituito da una ricerca.
///
/// È volutamente generica:
/// - Non dipende da Poll / News / Post direttamente.
/// - Usa [TargetRef] come asse centrale dei contenuti.
/// - Espone solo i dati minimi necessari per una preview
///   + alcuni segnali generici per ranking/filtri.
///
/// In questo modo:
/// - Il dominio Search resta disaccoppiato dalle feature.
/// - La UI e i controller possono decidere come ordinare/filtrare.
@immutable
class SearchResultItem {
  /// Riferimento generico al contenuto (poll/news/post).
  final TargetRef target;

  /// Tipo di contenuto (coerente con SearchContentType).
  final SearchContentType contentType;

  /// Titolo principale da mostrare nella preview.
  final String title;

  /// Testo breve opzionale (summary, excerpt, ecc.).
  final String? snippet;

  /// Data principale associata al contenuto (per compatibilità storica):
  /// - createdAt per Post
  /// - publishedAt per News
  /// - createdAt per Poll
  ///
  /// Conservata per non rompere eventuale codice esistente.
  final DateTime? date;

  /// Segnale di "heat" associato al contenuto (se disponibile).
  ///
  /// Esempi:
  /// - numero like - dislike
  /// - heatScore normalizzato
  ///
  /// Può essere null se il dato non è noto o non rilevante
  /// per quel tipo di contenuto.
  final int? heat;

  /// Data di creazione/pubblicazione usata per sorting "latest".
  ///
  /// Per coerenza con gli algoritmi di discovery:
  /// - per Post → createdAt
  /// - per News → publishedAt
  /// - per Poll → createdAt
  ///
  /// Se null, il controller userà un fallback neutro.
  final DateTime? createdAt;

  /// Stato del Poll (solo per contentType = poll).
  ///
  /// Tipo generico per non accoppiare Search al dominio Poll:
  /// - può essere una enum PollStatus
  /// - può essere una stringa
  ///
  /// I controller usano `toString().toLowerCase()` per
  /// decidere open/closed in modo robusto.
  final Object? pollStatus;

  const SearchResultItem({
    required this.target,
    required this.contentType,
    required this.title,
    this.snippet,
    this.date,
    this.heat,
    this.createdAt,
    this.pollStatus,
  });

  /// True se esiste uno snippet non vuoto.
  bool get hasSnippet =>
      snippet != null && snippet!.trim().isNotEmpty;

  /// Copia immutabile con override selettivi.
  SearchResultItem copyWith({
    TargetRef? target,
    SearchContentType? contentType,
    String? title,
    String? snippet,
    DateTime? date,
    int? heat,
    DateTime? createdAt,
    Object? pollStatus,
  }) {
    return SearchResultItem(
      target: target ?? this.target,
      contentType: contentType ?? this.contentType,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
      date: date ?? this.date,
      heat: heat ?? this.heat,
      createdAt: createdAt ?? this.createdAt,
      pollStatus: pollStatus ?? this.pollStatus,
    );
  }

  @override
  String toString() {
    return 'SearchResultItem('
        'type: $contentType, '
        'title: "$title", '
        'target: $target, '
        'heat: $heat, '
        'createdAt: $createdAt, '
        'pollStatus: $pollStatus'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchResultItem &&
        other.target == target &&
        other.contentType == contentType &&
        other.title == title &&
        other.snippet == snippet &&
        other.date == date &&
        other.heat == heat &&
        other.createdAt == createdAt &&
        other.pollStatus == pollStatus;
  }

  @override
  int get hashCode => Object.hash(
        target,
        contentType,
        title,
        snippet,
        date,
        heat,
        createdAt,
        pollStatus,
      );
}
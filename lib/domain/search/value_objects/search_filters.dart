import 'package:meta/meta.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/search/value_objects/search_query.dart';

/// Ordinamento applicabile ai risultati di ricerca.
enum SearchSort {
  latest,
  hottest,
}

/// Filtro stato Poll (applicato solo quando contentType = poll).
enum PollStatusFilter {
  all,
  open,
  closed,
}

/// Value object che rappresenta i filtri applicati alla ricerca.
///
/// Responsabilità:
/// - incapsulare lo scope geografico
/// - incapsulare il tipo di contenuto (Poll / News / Post / All)
/// - gestire parametri di paginazione
/// - gestire ordinamento (Latest / Hottest)
/// - gestire filtro stato Poll (All / Open / Closed)
///
/// Nota:
/// - Il testo della query NON è qui dentro: è responsabilità di [SearchQuery].
@immutable
class SearchFilters {
  /// Scope geografico su cui limitare la ricerca.
  final GeoScope scope;

  /// Tipo di contenuto (derivato normalmente da [SearchQuery.type],
  /// ma lo manteniamo qui per flessibilità futura).
  final SearchContentType contentType;

  /// Ordinamento risultati.
  ///
  /// Default: hottest (coerente con home e discovery).
  final SearchSort sort;

  /// Filtro stato Poll.
  ///
  /// Applicato solo se contentType == poll.
  /// Default: all.
  final PollStatusFilter pollStatus;

  /// Numero massimo di risultati.
  final int limit;

  /// Offset per paginazione.
  final int offset;

  const SearchFilters({
    required this.scope,
    this.contentType = SearchContentType.all,
    this.sort = SearchSort.hottest,
    this.pollStatus = PollStatusFilter.all,
    this.limit = 20,
    this.offset = 0,
  });

  /// Factory di comodo per creare filtri a partire
  /// da una [SearchQuery] e uno [GeoScope].
  factory SearchFilters.fromQuery({
    required SearchQuery query,
    required GeoScope scope,
    int limit = 20,
    int offset = 0,
    SearchSort sort = SearchSort.hottest,
    PollStatusFilter pollStatus = PollStatusFilter.all,
  }) {
    return SearchFilters(
      scope: scope,
      contentType: query.type,
      sort: sort,
      pollStatus: pollStatus,
      limit: limit,
      offset: offset,
    );
  }

  /// True se la ricerca è globale (world).
  bool get isWorld => scope.level == GeoScopeLevel.world;

  /// True se la ricerca è nazionale.
  bool get isCountry => scope.level == GeoScopeLevel.country;

  /// True se la ricerca è locale (city).
  bool get isCity => scope.level == GeoScopeLevel.city;

  /// True se filtro Poll aperti.
  bool get isOpenOnly => pollStatus == PollStatusFilter.open;

  /// True se filtro Poll chiusi.
  bool get isClosedOnly => pollStatus == PollStatusFilter.closed;

  /// Copia con campi modificati (immutabilità preservata).
  SearchFilters copyWith({
    GeoScope? scope,
    SearchContentType? contentType,
    SearchSort? sort,
    PollStatusFilter? pollStatus,
    int? limit,
    int? offset,
  }) {
    return SearchFilters(
      scope: scope ?? this.scope,
      contentType: contentType ?? this.contentType,
      sort: sort ?? this.sort,
      pollStatus: pollStatus ?? this.pollStatus,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  String toString() {
    return 'SearchFilters('
        'scope: $scope, '
        'contentType: $contentType, '
        'sort: $sort, '
        'pollStatus: $pollStatus, '
        'limit: $limit, '
        'offset: $offset'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchFilters &&
        other.scope == scope &&
        other.contentType == contentType &&
        other.sort == sort &&
        other.pollStatus == pollStatus &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode =>
      Object.hash(scope, contentType, sort, pollStatus, limit, offset);
}
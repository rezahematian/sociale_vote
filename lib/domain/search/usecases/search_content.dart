import 'package:meta/meta.dart';

import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/search/entities/search_result_item.dart';
import 'package:sociale_vote/domain/search/repositories/search_repository.dart';
import 'package:sociale_vote/domain/search/value_objects/search_filters.dart';
import 'package:sociale_vote/domain/search/value_objects/search_query.dart';

/// Use case applicativo per la ricerca di contenuti.
///
/// Ponte tra:
/// - input “grezzo” dell’applicazione (stringa query, tipo, scope)
/// - dominio Search (SearchQuery, SearchFilters, SearchResultItem).
///
/// V1:
/// - delega tutta la logica al [SearchRepository]
///   usando [SearchRepositoryInMemory] come implementazione concreta.
@immutable
class SearchContent {
  final SearchRepository _searchRepository;

  const SearchContent(this._searchRepository);

  /// Esegue una ricerca di contenuti.
  ///
  /// Parametri:
  /// - [rawQuery]: stringa così come inserita dall’utente
  /// - [type]: tipo di contenuto (Poll / News / Post / All)
  /// - [scope]: GeoScope corrente (world / country / city)
  /// - [sort]: ordinamento (Latest / Hottest)
  /// - [pollStatus]: filtro stato Poll (All / Open / Closed) — applicato solo se type=poll
  /// - [limit], [offset]: parametri base per la paginazione
  ///
  /// Ritorno:
  /// - Lista di [SearchResultItem] già pronti per la UI.
  Future<List<SearchResultItem>> call({
    required String rawQuery,
    SearchContentType type = SearchContentType.all,
    required GeoScope scope,
    SearchSort sort = SearchSort.hottest,
    PollStatusFilter pollStatus = PollStatusFilter.all,
    int limit = 20,
    int offset = 0,
  }) async {
    final query = SearchQuery(
      rawText: rawQuery,
      type: type,
    );

    final filters = SearchFilters.fromQuery(
      query: query,
      scope: scope,
      sort: sort,
      pollStatus: pollStatus,
      limit: limit,
      offset: offset,
    );

    return _searchRepository.search(
      query: query,
      filters: filters,
    );
  }
}
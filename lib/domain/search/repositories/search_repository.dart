import 'package:sociale_vote/domain/search/entities/search_result_item.dart';
import 'package:sociale_vote/domain/search/value_objects/search_query.dart';
import 'package:sociale_vote/domain/search/value_objects/search_filters.dart';

/// Repository astratto per la ricerca contenuti.
///
/// Responsabilità:
/// - Esporre un'operazione di ricerca unica e tipizzata.
/// - Restituire risultati già mappati a [SearchResultItem].
/// - Nascondere il dettaglio della sorgente dati (in-memory, HTTP, ecc.).
///
/// Implementazioni concrete vivranno in:
///   infrastructure/search/repositories/...
abstract class SearchRepository {
  /// Esegue una ricerca di contenuti in base a:
  /// - [query]: testo + tipo contenuto
  /// - [filters]: scope geografico + paginazione + tipo contenuto
  ///
  /// V1:
  /// - Restituisce una lista di [SearchResultItem] già ordinati
  ///   secondo una logica semplice (es. per data decrescente
  ///   o per match rilevanza basic).
  ///
  /// Nota:
  /// - Se [query.isEmpty] l'implementazione può restituire
  ///   una lista vuota o un fallback (es. trending) a seconda
  ///   della decisione applicativa.
  Future<List<SearchResultItem>> search({
    required SearchQuery query,
    required SearchFilters filters,
  });
}
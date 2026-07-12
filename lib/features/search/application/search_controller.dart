import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/search/entities/search_result_item.dart';
import 'package:sociale_vote/domain/search/usecases/search_content.dart';
import 'package:sociale_vote/domain/search/value_objects/search_filters.dart';
import 'package:sociale_vote/domain/search/value_objects/search_query.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

/// Controller applicativo per la ricerca globale.
///
/// Responsabilità:
/// - leggere lo scope corrente da [GeoScopeController]
/// - orchestrare il use case [SearchContent]
/// - esporre lo stato (query, risultati, loading, errore)
/// - gestire filtri (Scope / Latest-Hottest / Poll open-closed)
class SearchController extends ChangeNotifier {
  final SearchContent _searchContent;
  final GeoScopeController _geoScopeController;

  SearchController({
    required SearchContent searchContent,
    required GeoScopeController geoScopeController,
  })  : _searchContent = searchContent,
        _geoScopeController = geoScopeController {
    _filters = SearchFilters(scope: _geoScopeController.scope);
  }

  /// Ultima query eseguita (value object di dominio).
  SearchQuery? _currentQuery;
  SearchQuery? get currentQuery => _currentQuery;

  /// Scope usato per l’ultima ricerca.
  GeoScope? _lastScope;
  GeoScope? get lastScope => _lastScope;

  /// Filtri correnti della ricerca (dominio).
  late SearchFilters _filters;
  SearchFilters get filters => _filters;

  /// Risultati correnti della ricerca.
  List<SearchResultItem> _results = [];
  List<SearchResultItem> get results => List.unmodifiable(_results);

  /// Stato di caricamento.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Eventuale messaggio di errore.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;
  int _searchOperationId = 0;

  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  bool get hasResults => _results.isNotEmpty;

  /// True se non c’è nessuna query o risultati (stato “idle”).
  bool get isIdle => _currentQuery == null && _results.isEmpty && !isLoading;

  /// Aggiorna lo scope filtro (normalmente da UI).
  ///
  /// Nota: per default la ricerca usa lo scope corrente.
  void setScope(GeoScope scope) {
    if (_isDisposed) return;
    _filters = _filters.copyWith(scope: scope);
    _safeNotifyListeners();
  }

  /// Aggiorna il sort (Latest / Hottest).
  void setSort(SearchSort sort) {
    if (_isDisposed) return;
    _filters = _filters.copyWith(sort: sort);
    _safeNotifyListeners();
  }

  /// Aggiorna il filtro stato Poll (All / Open / Closed).
  ///
  /// Applicato solo se contentType == poll.
  void setPollStatus(PollStatusFilter status) {
    if (_isDisposed) return;
    _filters = _filters.copyWith(pollStatus: status);
    _safeNotifyListeners();
  }

  /// Aggiorna il tipo contenuto (Poll / News / Post / All).
  void setContentType(SearchContentType type) {
    if (_isDisposed) return;
    _filters = _filters.copyWith(contentType: type);
    _safeNotifyListeners();
  }

  /// Esegue una ricerca globale in base a:
  /// - [rawQuery]: stringa digitata dall’utente
  /// - [type]: tipo di contenuto (Poll / News / Post / All)
  ///
  /// Usa sempre lo [GeoScope] corrente del [GeoScopeController],
  /// salvo override tramite [_filters.scope] (se UI lo imposta).
  Future<void> search({
    required String rawQuery,
    SearchContentType type = SearchContentType.all,
  }) async {
    if (_isDisposed) return;

    final operationId = ++_searchOperationId;
    final query = SearchQuery(
      rawText: rawQuery,
      type: type,
    );

    _currentQuery = query;

    // Sync filtri con lo scope corrente se non è stato mai impostato diversamente.
    // (Manteniamo comportamento backward-compatible: di default segue GeoScopeController.)
    final currentScope = _geoScopeController.scope;
    if (_filters.scope != currentScope && _lastScope == null) {
      // caso raro: controller inizializzato con scope diverso
      _filters = _filters.copyWith(scope: currentScope);
    } else if (_filters.scope == _lastScope || _lastScope == null) {
      // segue lo scope corrente (default)
      _filters = _filters.copyWith(scope: currentScope);
    }

    // Sync content type anche nei filtri (dominio).
    _filters = _filters.copyWith(contentType: query.type);

    _lastScope = _filters.scope;

    if (query.isEmpty) {
      // Se query vuota → svuotiamo i risultati e non chiamiamo il use case.
      _results = [];
      _errorMessage = null;
      _isLoading = false;
      _safeNotifyListeners();
      return;
    }

    final appliedFilters = _filters;

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final items = await _searchContent(
        rawQuery: query.rawText,
        type: appliedFilters.contentType,
        scope: appliedFilters.scope,
        // V1: limiti base. In futuro parametri configurabili.
        limit: appliedFilters.limit,
        offset: appliedFilters.offset,
      );

      if (!_isOperationCurrent(operationId)) {
        return;
      }

      // Applichiamo i filtri mancanti lato app (in-memory):
      // - sort latest/hottest
      // - poll status open/closed (solo per contentType poll)
      var filtered = items;

      filtered = _applyPollStatusFilter(filtered, appliedFilters);
      filtered = _applySort(filtered, appliedFilters);

      _results = filtered;
    } catch (e, _) {
      if (_isOperationCurrent(operationId)) {
        _errorMessage = e.toString();
      }
    } finally {
      if (_isOperationCurrent(operationId)) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  /// Ripete l’ultima ricerca, ad esempio in caso di retry
  /// dopo un errore o dopo cambio scope (se deciderai così).
  Future<void> retry() async {
    final q = _currentQuery;
    if (q == null) return;

    await search(
      rawQuery: q.rawText,
      type: q.type,
    );
  }

  /// Svuota lo stato di ricerca (usato, per esempio,
  /// quando l’utente cancella completamente la query).
  void clear() {
    if (_isDisposed) return;

    _searchOperationId++;
    _currentQuery = null;
    _lastScope = null;
    _results = [];
    _errorMessage = null;
    _isLoading = false;

    // Reset filtri al solo scope corrente.
    _filters = SearchFilters(scope: _geoScopeController.scope);

    _safeNotifyListeners();
  }

  bool _isOperationCurrent(int operationId) {
    return !_isDisposed && operationId == _searchOperationId;
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchOperationId++;
    super.dispose();
  }

  List<SearchResultItem> _applySort(
    List<SearchResultItem> items,
    SearchFilters filters,
  ) {
    final sorted = [...items];

    switch (filters.sort) {
      case SearchSort.hottest:
        // In assenza di un campo standard nel dominio search,
        // assumiamo che SearchResultItem esponga "heat" (int) o simile.
        // Se il tuo SearchResultItem usa un nome diverso, lo sistemiamo nello step successivo.
        sorted.sort((a, b) => _safeHeat(b).compareTo(_safeHeat(a)));
        break;

      case SearchSort.latest:
        // Assumiamo che SearchResultItem esponga "createdAt" (DateTime) o simile.
        sorted.sort((a, b) => _safeCreatedAt(b).compareTo(_safeCreatedAt(a)));
        break;
    }

    return sorted;
  }

  List<SearchResultItem> _applyPollStatusFilter(
    List<SearchResultItem> items,
    SearchFilters filters,
  ) {
    if (filters.contentType != SearchContentType.poll) {
      return items;
    }

    switch (filters.pollStatus) {
      case PollStatusFilter.all:
        return items;

      case PollStatusFilter.open:
        return items.where(_isPollOpen).toList();

      case PollStatusFilter.closed:
        return items.where(_isPollClosed).toList();
    }
  }

  // ---- Helpers "safe" per non crashare se mancano campi nel SearchResultItem.
  // Nel prossimo step, se necessario, allineiamo SearchResultItem in modo pulito.

  int _safeHeat(SearchResultItem item) {
    try {
      // ignore: avoid_dynamic_calls
      final v = (item as dynamic).heat;
      if (v is int) return v;
      if (v is double) return v.round();
      return 0;
    } catch (_) {
      return 0;
    }
  }

  DateTime _safeCreatedAt(SearchResultItem item) {
    try {
      // ignore: avoid_dynamic_calls
      final v = (item as dynamic).createdAt;
      if (v is DateTime) return v;
      return DateTime.fromMillisecondsSinceEpoch(0);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  bool _isPollOpen(SearchResultItem item) {
    try {
      // ignore: avoid_dynamic_calls
      final v = (item as dynamic).pollStatus;
      final s = v?.toString().toLowerCase() ?? '';
      return s.contains('open');
    } catch (_) {
      return false;
    }
  }

  bool _isPollClosed(SearchResultItem item) {
    try {
      // ignore: avoid_dynamic_calls
      final v = (item as dynamic).pollStatus;
      final s = v?.toString().toLowerCase() ?? '';
      return s.contains('closed');
    } catch (_) {
      return false;
    }
  }
}

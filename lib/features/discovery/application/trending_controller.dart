import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/discovery/usecases/get_trending_content.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/home/application/feed_item.dart';

/// Controller applicativo per la sezione Trending.
///
/// Responsabilità:
/// - leggere lo scope corrente dal GeoScopeController
/// - usare GetTrendingContent
/// - esporre lista trending cross-content
/// - gestire loading/error
class TrendingController extends ChangeNotifier {
  final GetTrendingContent _getTrendingContent;
  final GeoScopeController _geoScopeController;
  final String? _userId;

  TrendingController({
    required GetTrendingContent getTrendingContent,
    required GeoScopeController geoScopeController,
    required String? userId,
  })  : _getTrendingContent = getTrendingContent,
        _geoScopeController = geoScopeController,
        _userId = userId {
    _geoScopeController.addListener(_onScopeChanged);
    loadTrending();
  }

  final List<FeedItem> _items = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isDisposed = false;
  int _requestId = 0;

  List<FeedItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> loadTrending() async {
    final requestId = ++_requestId;

    _isLoading = true;
    _hasError = false;
    _safeNotifyListeners();

    try {
      final scope = _geoScopeController.scope;

      final result = await _getTrendingContent(
        userId: _userId,
        currentScope: scope,
      );

      if (!_isRequestStillValid(requestId)) {
        return;
      }

      _items
        ..clear()
        ..addAll(result);
    } catch (_) {
      if (!_isRequestStillValid(requestId)) {
        return;
      }
      _hasError = true;
    } finally {
      if (!_isRequestStillValid(requestId)) {
        return;
      }

      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void _onScopeChanged() {
    loadTrending();
  }

  bool _isRequestStillValid(int requestId) {
    return !_isDisposed && requestId == _requestId;
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _geoScopeController.removeListener(_onScopeChanged);
    super.dispose();
  }
}
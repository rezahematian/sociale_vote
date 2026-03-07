import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/discovery/usecases/get_trending_content.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

/// Controller applicativo per la sezione Trending.
///
/// Responsabilità:
/// - leggere lo scope corrente dal GeoScopeController
/// - usare GetTrendingContent
/// - esporre lista post trending
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

  final List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<Post> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> loadTrending() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final scope = _geoScopeController.scope;

      final result = await _getTrendingContent(
        userId: _userId,
        currentScope: scope,
      );

      _posts
        ..clear()
        ..addAll(result);
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onScopeChanged() {
    loadTrending();
  }

  @override
  void dispose() {
    _geoScopeController.removeListener(_onScopeChanged);
    super.dispose();
  }
}
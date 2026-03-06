import 'package:flutter/foundation.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/usecases/get_news_feed.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

class NewsController extends ChangeNotifier {
  final GetNewsFeed _getNewsFeed;
  final ToggleReaction _toggleReaction;
  final GetReactionSummary _getReactionSummary;

  NewsController(
    this._getNewsFeed,
    this._toggleReaction,
    this._getReactionSummary,
  );

  bool _isLoading = false;
  String? _errorMessage;
  List<NewsItem> _news = [];

  /// Reaction summary per newsId.
  Map<String, ReactionSummary> _reactionSummaries =
      const <String, ReactionSummary>{};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  List<NewsItem> get news => _news;

  /// Ritorna il summary per una news, se presente.
  ReactionSummary? summaryForNews(NewsItem newsItem) {
    final id = _newsId(newsItem);
    return _reactionSummaries[id];
  }

  int likeCountForNews(NewsItem newsItem) {
    return summaryForNews(newsItem)?.likeCount ?? 0;
  }

  int dislikeCountForNews(NewsItem newsItem) {
    return summaryForNews(newsItem)?.dislikeCount ?? 0;
  }

  String _newsId(NewsItem newsItem) {
    // NewsItem.id è un EntityId → usiamo il suo value stringa.
    return newsItem.id.value;
  }

  TargetRef _targetForNews(NewsItem newsItem) {
    return TargetRef.news(_newsId(newsItem));
  }

  /// Carica le news in base al GeoScope corrente.
  ///
  /// In caso di errore:
  /// - `news` viene svuotato
  /// - `errorMessage` viene valorizzato
  Future<void> loadNews() async {
    // Loading iniziale
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final geoScope = AppDI.instance.geoScopeController.scope;

      String? countryCode;
      String? cityId;

      switch (geoScope.level) {
        case GeoScopeLevel.world:
          countryCode = null;
          cityId = null;
          break;
        case GeoScopeLevel.country:
          countryCode = geoScope.countryCode;
          cityId = null;
          break;
        case GeoScopeLevel.city:
          countryCode = geoScope.countryCode;
          cityId = geoScope.cityId;
          break;
      }

      final result = await _getNewsFeed(
        countryCode: countryCode,
        cityId: cityId,
      );

      _news = result;
      _errorMessage = null;

      // Carichiamo anche i summary delle reazioni per le news.
      await _loadReactionSummariesForNews(result);
    } catch (e, stackTrace) {
      // In un contesto enterprise si logga sempre
      if (kDebugMode) {
        debugPrint('Error loading news: $e');
        debugPrint('$stackTrace');
      }

      _news = [];
      _reactionSummaries = const {};
      _errorMessage = 'Unable to load news at the moment.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadReactionSummariesForNews(List<NewsItem> items) async {
    if (items.isEmpty) {
      _reactionSummaries = const {};
      return;
    }

    final targets = items.map(_targetForNews).toList();
    final summaries = await _getReactionSummary(targets);

    final map = <String, ReactionSummary>{};
    for (final summary in summaries) {
      // summary.target.id = id della news
      map[summary.target.id] = summary;
    }

    _reactionSummaries = map;
  }

  /// Toggle 🔥 per una news.
  ///
  /// Richiede userId NON vuoto (solo utenti registrati).
  Future<void> toggleFireForNews({
    required String userId,
    required NewsItem newsItem,
  }) async {
    if (userId.isEmpty) {
      // v1: la UI dovrebbe intercettare e mandare al login, qui non facciamo nulla.
      return;
    }

    final target = _targetForNews(newsItem);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    _reactionSummaries[_newsId(newsItem)] = summary;
    notifyListeners();
  }

  /// Toggle ❄ per una news.
  ///
  /// Richiede userId NON vuoto (solo utenti registrati).
  Future<void> toggleIceForNews({
    required String userId,
    required NewsItem newsItem,
  }) async {
    if (userId.isEmpty) {
      // v1: la UI dovrebbe intercettare e mandare al login, qui non facciamo nulla.
      return;
    }

    final target = _targetForNews(newsItem);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    _reactionSummaries[_newsId(newsItem)] = summary;
    notifyListeners();
  }

  /// Permette di resettare lo stato di errore (es. dopo un retry).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
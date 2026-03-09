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

import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api.dart';

import 'package:sociale_vote/features/news/domain/news_topic.dart';
import 'package:sociale_vote/features/news/domain/news_language.dart';

/// Modalità di ordinamento per il feed news.
///
/// - [latest]  → usa l'ordine restituito da GetNewsFeed (tipicamente per data)
/// - [hottest] → per "calore" (engagement / reazioni)
enum NewsSortMode {
  latest,
  hottest,
}

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

  /// Tipologia errore “machine-friendly” (per localizzazione in UI).
  NewsApiErrorKind? _errorKind;

  /// News caricate finora (aggregato delle pagine).
  final List<NewsItem> _news = [];

  /// Reaction summary per newsId.
  final Map<String, ReactionSummary> _reactionSummaries =
      <String, ReactionSummary>{};

  /// Paging reale (Fase 4.3)
  static const int _pageSize = 10;
  int _currentOffset = 0;
  bool _hasMoreFromSource = true;

  /// Ultimo userId usato per caricare i ReactionSummary.
  String? _lastKnownUserId;

  /// Modalità di ordinamento corrente per il feed.
  NewsSortMode _sortMode = NewsSortMode.latest;

  /// Topic selezionato (enterprise): filtra lato use case/repository/api.
  NewsTopic _selectedTopic = NewsTopic.all;

  /// Lingua selezionata per le news (enterprise language filter).
  NewsLanguage _selectedLanguage = NewsLanguage.auto;

  // ===== GETTER STATO PUBBLICO =====

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  NewsApiErrorKind? get errorKind => _errorKind;

  List<NewsItem> get news => List<NewsItem>.unmodifiable(_news);

  bool get hasMoreFromSource => _hasMoreFromSource;

  NewsSortMode get sortMode => _sortMode;

  NewsTopic get selectedTopic => _selectedTopic;

  /// Lingua corrente esposta alla UI.
  NewsLanguage get selectedLanguage => _selectedLanguage;

  // ===== TOPIC =====

  Future<void> setTopic(NewsTopic topic, {String? userId}) async {
    if (_selectedTopic == topic) return;

    _selectedTopic = topic;

    _errorMessage = null;
    _errorKind = null;
    notifyListeners();

    await loadNews(userId: userId ?? _lastKnownUserId);
  }

  // ===== LANGUAGE =====

  /// Imposta la lingua delle news e ricarica dalla prima pagina.
  Future<void> setLanguage(NewsLanguage language, {String? userId}) async {
    if (_selectedLanguage == language) return;

    _selectedLanguage = language;

    _errorMessage = null;
    _errorKind = null;
    notifyListeners();

    await loadNews(userId: userId ?? _lastKnownUserId);
  }

  // ===== ORDINAMENTO =====

  void setSortMode(NewsSortMode mode) {
    if (_sortMode == mode) return;
    _sortMode = mode;
    _sortNews();
    notifyListeners();
  }

  // ===== REACTION SUMMARY =====

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
    return newsItem.id.value;
  }

  TargetRef _targetForNews(NewsItem newsItem) {
    return TargetRef.news(_newsId(newsItem));
  }

  /// Mapping esplicito e “safe” della lingua verso i codici attesi dalla API (GNews).
  /// Evita che un apiValue errato (es. "fa-IR" o "NewsLanguage.fa") faccia ricadere su AUTO.
  String? _languageApiValue(NewsLanguage language) {
    switch (language) {
      case NewsLanguage.auto:
        return null;
      case NewsLanguage.it:
        return 'it';
      case NewsLanguage.en:
        return 'en';
      case NewsLanguage.es:
        return 'es';
      case NewsLanguage.fr:
        return 'fr';
      case NewsLanguage.de:
        return 'de';
      case NewsLanguage.ar:
        return 'ar';
      case NewsLanguage.fa:
        return 'fa';
    }
  }

  // ===== CARICAMENTO FEED =====

  Future<void> loadNews({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    _errorKind = null;
    notifyListeners();

    _news.clear();
    _reactionSummaries.clear();
    _currentOffset = 0;
    _hasMoreFromSource = true;
    _lastKnownUserId = userId ?? _lastKnownUserId;

    try {
      await _loadNextPage();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error loading news: $e');
        debugPrint('$stackTrace');
      }

      _news.clear();
      _reactionSummaries.clear();
      _currentOffset = 0;
      _hasMoreFromSource = false;

      _applyError(e, fallbackMessage: 'Unable to load news at the moment.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNews() async {
    if (_isLoading) return;
    if (!_hasMoreFromSource) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _loadNextPage();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error loading more news: $e');
        debugPrint('$stackTrace');
      }

      _hasMoreFromSource = false;

      _applyError(e, fallbackMessage: 'Unable to load more news.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadNextPage() async {
    final geoScope = AppDI.instance.geoScopeController.scope;

    String? countryCode;
    String? cityId;

    switch (geoScope.level) {
      case GeoScopeLevel.world:
        break;
      case GeoScopeLevel.country:
        countryCode = geoScope.countryCode;
        break;
      case GeoScopeLevel.city:
        countryCode = geoScope.countryCode;
        cityId = geoScope.cityId;
        break;
    }

    final result = await _getNewsFeed(
      countryCode: countryCode,
      cityId: cityId,
      topic: _selectedTopic.apiValue,
      language: _languageApiValue(_selectedLanguage),
      limit: _pageSize,
      offset: _currentOffset,
    );

    if (result.length < _pageSize) {
      _hasMoreFromSource = false;
    }

    _currentOffset += result.length;
    _news.addAll(result);

    await _loadReactionSummariesForNews(result, userId: _lastKnownUserId);

    _sortNews();
  }

  Future<void> _loadReactionSummariesForNews(
    List<NewsItem> items, {
    String? userId,
  }) async {
    if (items.isEmpty) return;

    final targets = items.map(_targetForNews).toList();

    final summaries = await _getReactionSummary(
      targets,
      userId: userId,
    );

    for (final summary in summaries) {
      _reactionSummaries[summary.target.id] = summary;
    }
  }

  double _heatForNews(NewsItem item) {
    final summary = summaryForNews(item);
    if (summary == null) return 0;
    return (summary.likeCount - summary.dislikeCount).toDouble();
  }

  void _sortNews() {
    if (_news.isEmpty) return;

    switch (_sortMode) {
      case NewsSortMode.latest:
        break;
      case NewsSortMode.hottest:
        _news.sort((a, b) => _heatForNews(b).compareTo(_heatForNews(a)));
        break;
    }
  }

  Future<void> toggleFireForNews({
    required String userId,
    required NewsItem newsItem,
  }) async {
    if (userId.isEmpty) return;

    final target = _targetForNews(newsItem);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    _reactionSummaries[_newsId(newsItem)] = summary;

    if (_sortMode == NewsSortMode.hottest) {
      _sortNews();
    }

    notifyListeners();
  }

  Future<void> toggleIceForNews({
    required String userId,
    required NewsItem newsItem,
  }) async {
    if (userId.isEmpty) return;

    final target = _targetForNews(newsItem);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    _reactionSummaries[_newsId(newsItem)] = summary;

    if (_sortMode == NewsSortMode.hottest) {
      _sortNews();
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _errorKind = null;
    notifyListeners();
  }

  void _applyError(Object error, {required String fallbackMessage}) {
    if (error is NewsApiException) {
      _errorKind ??= error.kind;
      _errorMessage ??= error.message;
      return;
    }

    _errorMessage ??= fallbackMessage;
  }
}
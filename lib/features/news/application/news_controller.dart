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

import 'package:sociale_vote/features/news/domain/news_language.dart';
import 'package:sociale_vote/features/news/domain/news_topic.dart';

/// Modalità di ordinamento per il feed news.
///
/// - [latest]  → usa l'ordine restituito da GetNewsFeed (tipicamente per data)
/// - [hottest] → per importanza / engagement / rilevanza
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

  /// Comment count per newsId.
  final Map<String, int> _commentCounts = <String, int>{};

  /// Paging reale (Fase 4.3)
  static const int _pageSize = 10;
  int _currentOffset = 0;
  bool _hasMoreFromSource = true;

  /// Ultimo userId usato per caricare i ReactionSummary.
  String? _lastKnownUserId;

  /// Modalità di ordinamento corrente per il feed.
  NewsSortMode _sortMode = NewsSortMode.hottest;

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

  // ===== REACTION SUMMARY / COMMENTS =====

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

  int commentCountForNews(NewsItem newsItem) {
    return _commentCounts[_newsId(newsItem)] ?? 0;
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
    _commentCounts.clear();
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
      _commentCounts.clear();
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
    await _loadCommentCountsForNews(result);

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

  Future<void> _loadCommentCountsForNews(List<NewsItem> items) async {
    if (items.isEmpty) return;

    for (final item in items) {
      final count =
          await AppDI.instance.getCommentCountForTarget(_targetForNews(item));
      _commentCounts[_newsId(item)] = count;
    }
  }

  Future<void> refreshCommentCountForNews(NewsItem newsItem) async {
    try {
      final count = await AppDI.instance.getCommentCountForTarget(
        _targetForNews(newsItem),
      );
      _commentCounts[_newsId(newsItem)] = count;

      if (_sortMode == NewsSortMode.hottest) {
        _sortNews();
      }

      notifyListeners();
    } catch (_) {
      // refresh locale silenzioso
    }
  }

  double _heatForNews(NewsItem item) {
    final summary = summaryForNews(item);
    if (summary == null) return 0;
    return (summary.likeCount - summary.dislikeCount).toDouble();
  }

  int _fireCountForNews(NewsItem item) {
    return summaryForNews(item)?.likeCount ?? 0;
  }

  int _iceCountForNews(NewsItem item) {
    return summaryForNews(item)?.dislikeCount ?? 0;
  }

  String _titleForNews(NewsItem item) {
    final value = _readStringField(item, const [
      'title',
      'headline',
      'name',
      'subject',
    ]);
    return value.toLowerCase();
  }

  String _descriptionForNews(NewsItem item) {
    final value = _readStringField(item, const [
      'description',
      'content',
      'summary',
      'body',
      'excerpt',
      'text',
    ]);
    return value.toLowerCase();
  }

  String _sourceForNews(NewsItem item) {
    final value = _readStringField(item, const [
      'sourceName',
      'source',
      'publisher',
      'author',
    ]);
    return value.toLowerCase();
  }

  DateTime? _publishedAtForNews(NewsItem item) {
    final dynamicValue = _readDynamicField(item, const [
      'publishedAt',
      'createdAt',
      'date',
      'updatedAt',
    ]);

    if (dynamicValue == null) {
      return null;
    }

    if (dynamicValue is DateTime) {
      return dynamicValue;
    }

    return DateTime.tryParse(dynamicValue.toString());
  }

  String _readStringField(NewsItem item, List<String> fieldNames) {
    final dynamic value = _readDynamicField(item, fieldNames);
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  dynamic _readDynamicField(NewsItem item, List<String> fieldNames) {
    final dynamic entity = item;

    for (final field in fieldNames) {
      try {
        switch (field) {
          case 'title':
            return entity.title;
          case 'headline':
            return entity.headline;
          case 'name':
            return entity.name;
          case 'subject':
            return entity.subject;
          case 'description':
            return entity.description;
          case 'content':
            return entity.content;
          case 'summary':
            return entity.summary;
          case 'body':
            return entity.body;
          case 'excerpt':
            return entity.excerpt;
          case 'text':
            return entity.text;
          case 'sourceName':
            return entity.sourceName;
          case 'source':
            return entity.source;
          case 'publisher':
            return entity.publisher;
          case 'author':
            return entity.author;
          case 'publishedAt':
            return entity.publishedAt;
          case 'createdAt':
            return entity.createdAt;
          case 'date':
            return entity.date;
          case 'updatedAt':
            return entity.updatedAt;
        }
      } catch (_) {
        // continua
      }
    }

    return null;
  }

  double _breakingScoreForNews(NewsItem item) {
    final text = '${_titleForNews(item)} ${_descriptionForNews(item)}';

    const strongKeywords = <String>[
      'breaking',
      'live',
      'urgent',
      'emergency',
      'attack',
      'war',
      'earthquake',
      'explosion',
      'government',
      'minister',
      'president',
      'election',
      'vote',
      'parliament',
      'protest',
      'court',
      'police',
      'crisis',
      'alert',
      'flood',
      'wildfire',
      'storm',
      'blackout',
      'strike',
    ];

    double score = 0;

    for (final keyword in strongKeywords) {
      if (text.contains(keyword)) {
        score += 100;
      }
    }

    return score;
  }

  double _sourceWeightForNews(NewsItem item) {
    final source = _sourceForNews(item);

    if (source.isEmpty) {
      return 0;
    }

    const topTier = <String>[
      'reuters',
      'associated press',
      'ap',
      'bbc',
      'ansa',
      'agence france-presse',
      'afp',
      'financial times',
      'the economist',
      'bloomberg',
    ];

    const solidTier = <String>[
      'cnn',
      'sky news',
      'the guardian',
      'new york times',
      'washington post',
      'euronews',
      'il sole 24 ore',
      'la repubblica',
      'corriere',
    ];

    for (final name in topTier) {
      if (source.contains(name)) {
        return 10;
      }
    }

    for (final name in solidTier) {
      if (source.contains(name)) {
        return 6;
      }
    }

    return 1;
  }

  double _geoRelevanceForNews(NewsItem item) {
    final scope = AppDI.instance.geoScopeController.scope;
    final text =
        '${_titleForNews(item)} ${_descriptionForNews(item)} ${_sourceForNews(item)}';

    switch (scope.level) {
      case GeoScopeLevel.world:
        return 0;
      case GeoScopeLevel.country:
        final countryCode = scope.countryCode?.toLowerCase();
        if (countryCode == 'it') {
          if (text.contains('italy') ||
              text.contains('italia') ||
              text.contains('rome') ||
              text.contains('roma')) {
            return 40;
          }
        }
        return 0;
      case GeoScopeLevel.city:
        final cityId = scope.cityId?.toLowerCase();
        final countryCode = scope.countryCode?.toLowerCase();

        if (cityId != null && cityId.isNotEmpty) {
          final normalizedCity = cityId.replaceAll('_', ' ').toLowerCase();
          if (text.contains(normalizedCity)) {
            return 60;
          }
        }

        if (countryCode == 'it' &&
            (text.contains('italy') || text.contains('italia'))) {
          return 20;
        }

        return 0;
    }
  }

  double _recencyScoreForNews(NewsItem item) {
    final publishedAt = _publishedAtForNews(item);
    if (publishedAt == null) {
      return 0;
    }

    final ageHours = DateTime.now().difference(publishedAt).inHours;

    if (ageHours <= 1) return 12;
    if (ageHours <= 3) return 10;
    if (ageHours <= 6) return 8;
    if (ageHours <= 12) return 6;
    if (ageHours <= 24) return 4;
    if (ageHours <= 48) return 2;
    return 0;
  }

  double _importanceScoreForNews(NewsItem item) {
    final fire = _fireCountForNews(item).toDouble();
    final comment = commentCountForNews(item).toDouble();
    final ice = _iceCountForNews(item).toDouble();

    return _breakingScoreForNews(item) +
        _geoRelevanceForNews(item) +
        (fire * 5) +
        (comment * 3) +
        _sourceWeightForNews(item) +
        _recencyScoreForNews(item) -
        (ice * 4);
  }

  void _sortNews() {
    if (_news.isEmpty) return;

    switch (_sortMode) {
      case NewsSortMode.latest:
        break;
      case NewsSortMode.hottest:
        _news.sort((a, b) {
          final scoreCompare =
              _importanceScoreForNews(b).compareTo(_importanceScoreForNews(a));
          if (scoreCompare != 0) {
            return scoreCompare;
          }

          return _heatForNews(b).compareTo(_heatForNews(a));
        });
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
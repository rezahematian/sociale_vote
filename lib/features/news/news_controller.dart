import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'news_item.dart';
import 'news_service.dart';

class NewsController extends ChangeNotifier {
  final NewsService _newsService;

  NewsController(this._newsService) {
    _loadSavedVotes();
  }

  final List<NewsItem> _items = [];
  final Map<String, HeatVote> _userVotes = {};

  static const String _storageKey = 'news_user_votes';

  List<NewsItem> get items => List.unmodifiable(_items);

  // =========================================================
  // LOAD NEWS
  // =========================================================

  Future<void> loadNews({
    required String languageCode,
    required String countryCode,
    required NewsScope scope,
    String? locationId,
  }) async {
    final fetched = await _newsService.fetchNews(
      languageCode: languageCode,
      countryCode: countryCode,
      scope: scope,
      locationId: locationId,
    );

    _items
      ..clear()
      ..addAll(
        fetched.map(
          (n) => n.copyWith(
            userVote: _userVotes[n.id] ?? HeatVote.none,
          ),
        ),
      );

    _sortByHeat();
    notifyListeners();
  }

  Future<void> loadGlobalNews({
    required String languageCode,
    required String countryCode,
  }) {
    return loadNews(
      languageCode: languageCode,
      countryCode: countryCode,
      scope: NewsScope.global,
    );
  }

  Future<void> loadCountryNews({
    required String languageCode,
    required String countryCode,
  }) {
    return loadNews(
      languageCode: languageCode,
      countryCode: countryCode,
      scope: NewsScope.country,
    );
  }

  Future<void> loadCityNews({
    required String languageCode,
    required String countryCode,
    required String cityId,
  }) {
    return loadNews(
      languageCode: languageCode,
      countryCode: countryCode,
      scope: NewsScope.city,
      locationId: cityId,
    );
  }

  // =========================================================
  // 🔥 / ❄️ PUBLIC API
  // =========================================================

  void toggleHot(NewsItem news) => _setVote(news.id, HeatVote.hot);
  void toggleCold(NewsItem news) => _setVote(news.id, HeatVote.cold);
  void resetVote(NewsItem news) => _setVote(news.id, HeatVote.none);

  // =========================================================
  // CORE LOGIC – GLOBAL HEAT (3 STATI REALI)
  // =========================================================

  void _setVote(String newsId, HeatVote tappedVote) {
    final index = _items.indexWhere((n) => n.id == newsId);
    if (index == -1) return;

    final currentItem = _items[index];
    final previousVote = _userVotes[newsId] ?? HeatVote.none;

    // 🔁 Toggle reale a 3 stati
    HeatVote newVote;
    if (previousVote == tappedVote) {
      newVote = HeatVote.none;
    } else {
      newVote = tappedVote;
    }

    int hot = currentItem.hotCount;
    int cold = currentItem.coldCount;

    // Rimuove voto precedente
    if (previousVote == HeatVote.hot && hot > 0) {
      hot--;
    }
    if (previousVote == HeatVote.cold && cold > 0) {
      cold--;
    }

    // Applica nuovo voto
    if (newVote == HeatVote.hot) {
      hot++;
    }
    if (newVote == HeatVote.cold) {
      cold++;
    }

    // Aggiorna mappa voti
    if (newVote == HeatVote.none) {
      _userVotes.remove(newsId);
    } else {
      _userVotes[newsId] = newVote;
    }

    _items[index] = currentItem.copyWith(
      hotCount: hot,
      coldCount: cold,
      userVote: newVote,
    );

    _saveVotes();
    _sortByHeat();
    notifyListeners();
  }

  void _sortByHeat() {
    _items.sort((a, b) {
      final scoreA = a.hotCount - a.coldCount;
      final scoreB = b.hotCount - b.coldCount;

      final scoreCompare = scoreB.compareTo(scoreA);
      if (scoreCompare != 0) return scoreCompare;

      // tie-break: più recente sopra
      return b.publishedAt.compareTo(a.publishedAt);
    });
  }

  // =========================================================
  // 💾 PERSISTENCE
  // =========================================================

  Future<void> _loadSavedVotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];

    for (final entry in raw) {
      final parts = entry.split('|');
      if (parts.length != 2) continue;

      final newsId = parts[0];
      final vote = HeatVote.values.firstWhere(
        (v) => v.name == parts[1],
        orElse: () => HeatVote.none,
      );

      if (vote != HeatVote.none) {
        _userVotes[newsId] = vote;
      }
    }
  }

  Future<void> _saveVotes() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _userVotes.entries
        .map((e) => '${e.key}|${e.value.name}')
        .toList();

    await prefs.setStringList(_storageKey, data);
  }
}

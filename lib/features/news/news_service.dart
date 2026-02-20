import 'dart:convert';
import 'package:http/http.dart' as http;

import 'news_item.dart';

class NewsService {
  static const String _apiKey = '14b527a326ee4ea0891173e331dded9e';
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<NewsItem>> fetchNews({
    required String languageCode,
    required String countryCode,
    NewsScope? scope,
    String? locationId,
  }) async {
    try {
      Uri uri;

      switch (scope) {
        // ================= GLOBAL =================
        case NewsScope.global:
          uri = Uri.parse(
            '$_baseUrl/top-headlines'
            '?country=us'
            '&category=general'
            '&pageSize=20'
            '&apiKey=$_apiKey',
          );
          break;

        // ================= COUNTRY =================
        case NewsScope.country:
          uri = Uri.parse(
            '$_baseUrl/top-headlines'
            '?country=$countryCode'
            '&category=general'
            '&pageSize=20'
            '&apiKey=$_apiKey',
          );
          break;

        // ================= CITY =================
        case NewsScope.city:
          final query = locationId != null && locationId.isNotEmpty
              ? _prettyLocation(locationId)
              : 'city';

          uri = Uri.parse(
            '$_baseUrl/everything'
            '?q="$query"'
            '&sortBy=publishedAt'
            '&pageSize=20'
            '&apiKey=$_apiKey',
          );
          break;

        default:
          uri = Uri.parse(
            '$_baseUrl/top-headlines'
            '?country=us'
            '&pageSize=20'
            '&apiKey=$_apiKey',
          );
      }

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final List articles = data['articles'] as List? ?? [];

      final news = articles.map((article) {
        final description = article['description'] ?? '';
        final content = article['content'] ?? '';

        return NewsItem(
          id: article['url'] ?? DateTime.now().toIso8601String(),
          title: article['title'] ?? 'Titolo non disponibile',
          summary: description,
          fullContent: content.isNotEmpty ? content : description,
          sourceUrl: article['url'],
          languageCode: languageCode,
          countryCode: countryCode,
          publishedAt:
              DateTime.tryParse(article['publishedAt'] ?? '') ??
                  DateTime.now(),
          scope: scope ?? NewsScope.global,
          locationId: locationId ?? 'world',
          imageUrl: article['urlToImage'],
          hotCount: 0,
          coldCount: 0,
        );
      }).toList();

      news.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return news;
    } catch (e) {
      return [];
    }
  }

  String _prettyLocation(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1)}',
        )
        .join(' ');
  }
}

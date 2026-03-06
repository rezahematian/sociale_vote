import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final List<NewsItem> _mockNews = [
    NewsItem(
      id: const EntityId('n1'),
      title: 'Global Climate Agreement Updated',
      content: 'World leaders have agreed on new climate targets...',
      summary: 'New global climate targets agreed.',
      authorId: 'admin',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      isBreaking: true,
    ),
    NewsItem(
      id: const EntityId('n2'),
      title: 'Italy Approves New Budget Reform',
      content: 'The Italian parliament has approved a new budget reform...',
      summary: 'New economic reform approved in Italy.',
      authorId: 'it_editor',
      countryCode: 'IT',
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NewsItem(
      id: const EntityId('n3'),
      title: 'Torino Launches Smart Mobility Plan',
      content: 'The city of Torino has launched a new smart mobility initiative...',
      summary: 'New mobility initiative in Torino.',
      authorId: 'torino_editor',
      countryCode: 'IT',
      cityId: 'TORINO',
      publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  @override
  Future<List<NewsItem>> getNewsFeed({
    String? countryCode,
    String? cityId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filtered = _mockNews.where((news) {
      if (countryCode == null && cityId == null) {
        return news.countryCode == null && news.cityId == null;
      }

      if (countryCode != null && cityId == null) {
        return news.countryCode == countryCode && news.cityId == null;
      }

      if (countryCode != null && cityId != null) {
        return news.countryCode == countryCode &&
            news.cityId == cityId;
      }

      return false;
    }).toList();

    filtered.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return filtered;
  }

  @override
  Future<NewsItem> getNewsDetail(EntityId id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _mockNews.firstWhere(
      (news) => news.id == id,
      orElse: () => throw Exception('News not found'),
    );
  }
}
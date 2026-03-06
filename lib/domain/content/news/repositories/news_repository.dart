import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';

abstract class NewsRepository {
  Future<List<NewsItem>> getNewsFeed({
    String? countryCode,
    String? cityId,
  });

  Future<NewsItem> getNewsDetail(EntityId id);
}
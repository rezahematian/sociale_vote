import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';

class GetNewsFeed {
  final NewsRepository _repository;

  const GetNewsFeed(this._repository);

  Future<List<NewsItem>> call({
    String? countryCode,
    String? cityId,
  }) {
    return _repository.getNewsFeed(
      countryCode: countryCode,
      cityId: cityId,
    );
  }
}
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';

class GetNewsDetail {
  final NewsRepository _repository;

  const GetNewsDetail(this._repository);

  Future<NewsItem> call(EntityId id) {
    return _repository.getNewsDetail(id);
  }
}
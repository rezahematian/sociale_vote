import 'dart:convert';
import '../../core/repository/base_repository.dart';
import '../../core/api/api_endpoints.dart';
import '../../domain/news/news_dto.dart';

class NewsRepository extends BaseRepository {
  NewsRepository(super.client);

  Future<List<NewsDTO>> fetchNews({
    required String language,
    required String country,
  }) async {
    final res = await client.get(
      '${ApiEndpoints.news}?lang=$language&country=$country',
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load news');
    }

    final data = jsonDecode(res.body) as List;
    return data.map((e) => NewsDTO.fromJson(e)).toList();
  }
}

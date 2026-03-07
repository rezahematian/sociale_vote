import 'dart:convert';
import '../../core/repository/base_repository.dart';
import '../../core/api/api_endpoints.dart';
import '../../domain/video/video_dto.dart';

class VideoRepository extends BaseRepository {
  VideoRepository(super.client);

  Future<List<VideoDTO>> fetchVideos() async {
    final res = await client.get(ApiEndpoints.videos);

    if (res.statusCode != 200) {
      throw Exception('Failed to load videos');
    }

    final data = jsonDecode(res.body) as List;
    return data.map((e) => VideoDTO.fromJson(e)).toList();
  }
}

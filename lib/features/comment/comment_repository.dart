import 'dart:convert';
import '../../core/repository/base_repository.dart';
import '../../core/api/api_endpoints.dart';
import '../../domain/comment/comment_dto.dart';

class CommentRepository extends BaseRepository {
  CommentRepository(super.client);

  Future<List<CommentDTO>> fetchForPoll(String pollId) async {
    final res =
        await client.get('${ApiEndpoints.comments}?poll_id=$pollId');

    if (res.statusCode != 200) {
      throw Exception('Failed to load comments');
    }

    final data = jsonDecode(res.body) as List;
    return data.map((e) => CommentDTO.fromJson(e)).toList();
  }
}

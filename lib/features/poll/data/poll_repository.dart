import '../../core/network/api_response.dart';
import '../../domain/poll/poll_detail_dto.dart';

abstract class PollRepository {
  Future<ApiResponse<List<PollDetailDto>>> getActivePolls();

  Future<ApiResponse<PollDetailDto>> getPollById(
    String pollId,
  );
}

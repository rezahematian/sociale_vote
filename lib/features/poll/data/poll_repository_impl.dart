import '../../core/network/api_response.dart';
import '../../domain/poll/poll_detail_dto.dart';
import '../../domain/poll/poll_option_dto.dart';
import 'poll_repository.dart';

class PollRepositoryImpl implements PollRepository {

  @override
  Future<ApiResponse<List<PollDetailDto>>> getActivePolls() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return ApiResponse.success([
      _mockPoll('1', locationId: 'rome'),
      _mockPoll('2', locationId: 'new_york'),
      _mockPoll('3', locationId: 'tokyo'),
    ]);
  }

  @override
  Future<ApiResponse<PollDetailDto>> getPollById(
    String pollId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return ApiResponse.success(
      _mockPoll(pollId, locationId: 'rome'),
    );
  }

  PollDetailDto _mockPoll(
    String id, {
    required String locationId,
  }) {
    final options = [
      PollOptionDto(
        id: '1',
        label: 'Sì',
        votes: 3,
      ),
      PollOptionDto(
        id: '2',
        label: 'No',
        votes: 1,
      ),
    ];

    return PollDetailDto(
      id: id,
      locationId: locationId,
      title: 'Sondaggio $id',
      description: 'Descrizione del sondaggio $id',
      createdAt: DateTime.now(),
      expiresAt: null,
      options: options,
      totalVotes: options.fold(
        0,
        (sum, o) => sum + o.votes,
      ),
    );
  }
}

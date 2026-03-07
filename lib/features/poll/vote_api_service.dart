import '../../core/api/api_endpoints.dart';
import '../../core/api/api_response.dart';

import 'package:sociale_vote/domain/poll/vote_request.dart';
import 'package:sociale_vote/domain/poll/vote_entity.dart';

class VoteApiService {
  // Placeholder for REST / GraphQL backend
  VoteApiService();

  Future<ApiResponse<VoteEntity>> sendVote(
    VoteRequest request,
  ) async {
    // TODO: implement real HTTP call
    await Future.delayed(const Duration(milliseconds: 200));

    return ApiResponse.error(
      'Remote voting endpoint not configured',
    );
  }
}

import '../../core/network/api_response.dart';

import '../../domain/poll/poll_detail_dto.dart';
import '../../domain/poll/poll_entity.dart';
import '../../domain/poll/value_objects/poll_configuration.dart';
import '../../domain/poll/poll_type.dart';

import 'poll_repository.dart';

class PollService {
  // =========================
  // DEPENDENCIES
  // =========================
  final PollRepository pollRepository;

  PollService(this.pollRepository);

  // =========================
  // PUBLIC API (DOMAIN)
  // =========================

  Future<List<PollEntity>> getActivePolls() async {
    final ApiResponse<List<PollDetailDto>> response =
        await pollRepository.getActivePolls();

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ??
            'Errore caricamento sondaggi',
      );
    }

    return response.data!
        .map(_mapToEntity)
        .toList();
  }

  Future<PollEntity> getPollById(String pollId) async {
    final ApiResponse<PollDetailDto> response =
        await pollRepository.getPollById(pollId);

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ??
            'Errore caricamento sondaggio',
      );
    }

    return _mapToEntity(response.data!);
  }

  // =========================
  // MAPPING (ENTERPRISE SAFE)
  // =========================

  PollEntity _mapToEntity(PollDetailDto dto) {
    final configuration = PollConfiguration(
      endDate: dto.expiresAt,
      isActive: !dto.isArchived,
      allowMultipleSelection: dto.allowMultipleSelection,
      maxSelections: dto.maxSelections,
    );

    return PollEntity(
      id: dto.id,
      locationId: dto.locationId,
      title: dto.title,
      description: dto.description,
      createdAt: dto.createdAt,
      type: _mapPollType(dto.type),
      configuration: configuration,
      options: dto.options,
      totalVotes: dto.totalVotes,
      isClosed: dto.isClosed,

      // 🔥 Heat mapping
      heatHotCount: dto.heatHotCount ?? 0,
      heatColdCount: dto.heatColdCount ?? 0,

      // utente
      userSelectedOptionIds: dto.userSelectedOptionIds,
      userHeatVote: _mapUserHeat(dto.userHeatVote),
    );
  }

  // =========================
  // PRIVATE HELPERS
  // =========================

  PollType _mapPollType(String type) {
    switch (type) {
      case 'single':
        return PollType.single;
      case 'multiple':
        return PollType.multiple;
      default:
        return PollType.single;
    }
  }

  HeatVote? _mapUserHeat(String? heat) {
    if (heat == null) return null;
    if (heat == 'hot') return HeatVote.hot;
    if (heat == 'cold') return HeatVote.cold;
    return null;
  }
}

import 'package:sociale_vote/core/network/api_response.dart';

import 'package:sociale_vote/domain/poll/poll_detail_dto.dart';
import 'package:sociale_vote/domain/poll/poll_option_dto.dart';

import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';

import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';

import 'data/poll_repository.dart';

class PollService {
  // =========================
  // DEPENDENCIES
  // =========================
  final PollRepository pollRepository;

  PollService(this.pollRepository);

  // =========================
  // PUBLIC API (DOMAIN)
  // =========================

  Future<List<Poll>> getActivePolls() async {
    final ApiResponse<List<PollDetailDto>> response =
        await pollRepository.getActivePolls();

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ?? 'Errore caricamento sondaggi',
      );
    }

    return response.data!.map(_mapToDomain).toList(growable: false);
  }

  Future<Poll> getPollById(String pollId) async {
    final ApiResponse<PollDetailDto> response =
        await pollRepository.getPollById(pollId);

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ?? 'Errore caricamento sondaggio',
      );
    }

    return _mapToDomain(response.data!);
  }

  // =========================
  // MAPPING -> DOMAIN (SINGLE SOURCE OF TRUTH)
  // =========================

  Poll _mapToDomain(PollDetailDto dto) {
    // DTO attuale NON espone type/status/config dal backend.
    // Mapping deterministico (non bridge):
    // - type: singleChoice
    // - status: open
    final PollType type = PollType.singleChoice;
    final PollStatus status = PollStatus.open;

    final List<PollOption> options =
        dto.options.map(_mapOptionToDomain).toList(growable: false);

    // Config minimale coerente col domain pulito.
    // Quando backend espone min/max e allowVoteChange, aggiorniamo qui.
    final PollConfiguration configuration = PollConfiguration(
      minSelections: 1,
      maxSelections: 1,
      allowVoteChange: false,
    );

    return Poll(
      id: PollId(dto.id),
      title: dto.title,
      description: dto.description,
      type: type,
      status: status,
      options: options,
      configuration: configuration,
      startAt: null,
      endAt: dto.expiresAt,
      countryCode: null,
      cityId: dto.locationId,
      createdByUserId: null,
    );
  }

  PollOption _mapOptionToDomain(PollOptionDto dto) {
    return PollOption(
      id: dto.id,
      label: dto.label,
    );
  }
}
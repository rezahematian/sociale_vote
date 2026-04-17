import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';

import '../models/poll_dto.dart';
import '../models/poll_option_dto.dart';

class PollMapper {
  static Poll fromDto(PollDto dto) {
    return Poll(
      id: PollId(dto.id),
      title: dto.title,
      description: dto.description,
      type: PollType.values.firstWhere((e) => e.name == dto.type),
      status: PollStatus.values.firstWhere((e) => e.name == dto.status),
      options: dto.options
          .map(
            (o) => PollOption(
              id: o.id,
              label: o.label,
            ),
          )
          .toList(),
      configuration: PollConfiguration(
        minSelections: dto.minSelections,
        maxSelections: dto.maxSelections,
        participationRules: ParticipationRules(
          scope: ParticipationScope.values.firstWhere(
            (e) => e.name == dto.participationScope,
          ),
          countryCode: dto.participationCountryCode,
        ),
      ),
      countryCode: dto.countryCode,
      cityId: dto.cityId,
      createdByUserId: dto.createdByUserId,
      publishedAsActorType: dto.publishedAsActorType == null
          ? null
          : ActorTypeX.fromStorageKey(dto.publishedAsActorType),
      publishedAsInstitutionLevel: dto.publishedAsInstitutionLevel == null
          ? null
          : InstitutionLevelX.fromStorageKey(
              dto.publishedAsInstitutionLevel,
            ),
      publishedAsDisplayName: _normalizeNullable(dto.publishedAsDisplayName),
    );
  }

  static PollDto toDto(Poll poll) {
    return PollDto(
      id: poll.id.value,
      title: poll.title,
      description: poll.description,
      type: poll.type.name,
      status: poll.status.name,
      options: poll.options
          .map(
            (o) => PollOptionDto(
              id: o.id,
              label: o.label,
              votes: 0,
            ),
          )
          .toList(),
      minSelections: poll.configuration.minSelections,
      maxSelections: poll.configuration.maxSelections,
      participationScope: poll.configuration.participationRules.scope.name,
      participationCountryCode:
          poll.configuration.participationRules.countryCode,
      countryCode: poll.countryCode,
      cityId: poll.cityId,
      createdByUserId: poll.createdByUserId,
      publishedAsActorType: poll.publishedAsActorType?.storageKey,
      publishedAsInstitutionLevel:
          poll.publishedAsInstitutionLevel?.storageKey,
      publishedAsDisplayName: _normalizeNullable(poll.publishedAsDisplayName),
    );
  }

  static String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
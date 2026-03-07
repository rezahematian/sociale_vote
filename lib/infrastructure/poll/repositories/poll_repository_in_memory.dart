import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';

class PollRepositoryInMemory implements PollRepository {
  final List<Poll> _polls = [
    Poll(
      id: const PollId('1'),
      title: 'Global Climate Agreement',
      description: 'Should countries adopt stricter climate policies?',
      type: PollType.yesNo,
      status: PollStatus.open,
      options: const [
        PollOption(id: 'yes', label: 'Yes'),
        PollOption(id: 'no', label: 'No'),
      ],
      configuration: const PollConfiguration(
        minSelections: 1,
        maxSelections: 1,
        participationRules: ParticipationRules(
          scope: ParticipationScope.everyone,
        ),
      ),
    ),
    Poll(
      id: const PollId('2'),
      title: 'City Transport Reform',
      description: 'Which transport improvement should be prioritised?',
      type: PollType.singleChoice,
      status: PollStatus.open,
      options: const [
        PollOption(id: 'metro', label: 'Expand metro'),
        PollOption(id: 'bus', label: 'Improve buses'),
        PollOption(id: 'bike', label: 'More bike lanes'),
      ],
      configuration: const PollConfiguration(
        minSelections: 1,
        maxSelections: 1,
        participationRules: ParticipationRules(
          scope: ParticipationScope.geoScopeOnly,
          countryCode: 'IT',
        ),
      ),
      countryCode: 'IT',
      cityId: 'TORINO',
    ),
  ];

  @override
  Future<List<Poll>> getPolls({
    String? countryCode,
    String? cityId,
    int? limit,
    int? offset,
  }) async {
    List<Poll> filtered = _polls.where((poll) {
      final matchesCountry =
          countryCode == null || poll.countryCode == countryCode;
      final matchesCity =
          cityId == null || poll.cityId == cityId;
      return matchesCountry && matchesCity;
    }).toList();

    if (limit == null) return filtered;

    final start = (offset ?? 0).clamp(0, filtered.length);
    final end = (start + limit).clamp(0, filtered.length);

    return filtered.sublist(start, end);
  }

  @override
  Future<Poll?> getPollDetail(PollId pollId) async {
    try {
      return _polls.firstWhere((p) => p.id == pollId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Poll> createPoll(Poll poll) async {
    _polls.add(poll);
    return poll;
  }
}
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';

class PollRepositoryImpl implements PollRepository {
  /// Mock in-memory di tutti i poll disponibili.
  ///
  /// In un contesto reale questo verrebbe popolato da una sorgente esterna
  /// (API, database, ecc.). Qui funge da "database" in memoria, che può
  /// essere arricchito da [createPoll].
  final List<Poll> _polls = <Poll>[
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
      ),
      // Nessun country/city -> poll globale
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
      ),
      countryCode: 'IT',
      cityId: 'TORINO',
    ),
    Poll(
      id: const PollId('3'),
      title: 'Tech Policy Priorities',
      description: 'Select the areas that should receive funding.',
      type: PollType.multipleChoice,
      status: PollStatus.open,
      options: const [
        PollOption(id: 'ai', label: 'AI Research'),
        PollOption(id: 'cyber', label: 'Cybersecurity'),
        PollOption(id: 'edu', label: 'Digital Education'),
      ],
      configuration: const PollConfiguration(
        minSelections: 1,
        maxSelections: 3,
      ),
      // Anche questo, per ora, è globale.
    ),
  ];

  @override
  Future<List<Poll>> getPolls({
    String? countryCode,
    String? cityId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Se nessun filtro è specificato -> ritorniamo tutti i poll.
    if (countryCode == null && cityId == null) {
      return List<Poll>.unmodifiable(_polls);
    }

    // Altrimenti applichiamo il filtro.
    final filtered = _polls.where((poll) {
      final matchesCountry =
          countryCode == null || poll.countryCode == countryCode;
      final matchesCity = cityId == null || poll.cityId == cityId;
      return matchesCountry && matchesCity;
    }).toList();

    return filtered;
  }

  @override
  Future<Poll?> getPollDetail(PollId pollId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    for (final poll in _polls) {
      if (poll.id == pollId) {
        return poll;
      }
    }

    return null;
  }

  @override
  Future<Poll> createPoll(Poll poll) async {
    // Simuliamo una piccola latenza di rete.
    await Future.delayed(const Duration(milliseconds: 200));

    // In un backend reale qui si potrebbe:
    // - generare un nuovo PollId
    // - salvare su DB
    // - restituire il Poll aggiornato.
    //
    // Per ora assumiamo che chi chiama fornisca un Poll con un PollId valido
    // e lo aggiungiamo semplicemente al "database" in memoria.
    _polls.add(poll);

    return poll;
  }
}
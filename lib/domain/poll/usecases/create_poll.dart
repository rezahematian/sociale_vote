import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';

import '../entities/poll.dart';
import '../repositories/poll_repository.dart';

/// Use case applicativo per creare una nuova votazione.
///
/// Qui teniamo le regole business minime di creazione che non devono
/// restare solo nella UI/controller.
class CreatePoll {
  final PollRepository repository;

  CreatePoll(this.repository);

  /// Crea una nuova votazione.
  ///
  /// Regole applicate qui:
  /// - utente creatore obbligatorio
  /// - massimo 1 poll creato al giorno per utente
  /// - validazione coerenza identity rappresentativa snapshot
  ///
  /// Restituisce il poll effettivamente creato/persistito.
  Future<Poll> call(Poll poll) async {
    final createdByUserId = poll.createdByUserId?.trim();
    if (createdByUserId == null || createdByUserId.isEmpty) {
      throw Exception('User is required to create a poll.');
    }

    _validateRepresentativePublishingSnapshot(poll);

    final now = DateTime.now();
    final startOfLocalDay = DateTime(now.year, now.month, now.day);

    final hasCreatedToday = await repository.hasUserCreatedPollSince(
      userId: createdByUserId,
      since: startOfLocalDay.toUtc(),
    );

    if (hasCreatedToday) {
      throw Exception('daily poll limit reached');
    }

    return repository.createPoll(poll);
  }

  void _validateRepresentativePublishingSnapshot(Poll poll) {
    final publishedAsActorType = poll.publishedAsActorType;
    final publishedAsDisplayName = poll.representativeDisplayName;
    final publishedAsInstitutionLevel = poll.publishedAsInstitutionLevel;

    if (publishedAsActorType == null) {
      if (publishedAsDisplayName != null || publishedAsInstitutionLevel != null) {
        throw Exception(
          'Representative poll snapshot is inconsistent.',
        );
      }
      return;
    }

    if (publishedAsDisplayName == null) {
      throw Exception(
        'Representative poll requires publishedAsDisplayName.',
      );
    }

    switch (publishedAsActorType) {
      case ActorType.publicOfficial:
        if (publishedAsInstitutionLevel != null) {
          throw Exception(
            'Public official poll cannot have institution level.',
          );
        }
        break;

      case ActorType.institution:
        if (publishedAsInstitutionLevel == null) {
          throw Exception(
            'Institution poll requires institution level.',
          );
        }
        break;

      case ActorType.citizen:
        throw Exception(
          'Representative poll cannot be published as citizen.',
        );
    }
  }
}
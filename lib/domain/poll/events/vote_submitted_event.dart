import '../entities/vote_entity.dart';
import 'domain_event.dart';

class VoteSubmittedEvent extends DomainEvent {
  final VoteEntity vote;

  VoteSubmittedEvent(this.vote);
}

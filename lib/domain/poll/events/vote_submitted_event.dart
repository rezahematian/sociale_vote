import '../entities/vote.dart';
import 'domain_event.dart';

class VoteSubmittedEvent extends DomainEvent {
  final Vote vote;

  VoteSubmittedEvent(this.vote);
}
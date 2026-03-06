import '../entities/poll.dart';
import 'domain_event.dart';

class PollClosedEvent extends DomainEvent {
  final Poll poll;

  PollClosedEvent(this.poll);
}
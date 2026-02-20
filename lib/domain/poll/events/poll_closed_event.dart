import '../entities/poll_entity.dart';
import 'domain_event.dart';

class PollClosedEvent extends DomainEvent {
  final PollEntity poll;

  PollClosedEvent(this.poll);
}

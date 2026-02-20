import '../../domain/poll/poll_entity.dart';

class PollViewModel {
  final PollEntity poll;

  PollViewModel(this.poll);

  String get title => poll.title;
  String get description => poll.description;
  bool get isOpen => poll.isOpen;
}

import 'package:sociale_vote/domain/poll/entities/poll.dart';

class PollViewModel {
  final Poll poll;

  PollViewModel(this.poll);

  String get title => poll.title;
  String get description => poll.description ?? '';
  bool get isOpen => poll.isOpen;
}
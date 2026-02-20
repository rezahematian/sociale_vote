abstract class PollException implements Exception {}

class PollClosedException extends PollException {}

class VoteAlreadyCastException extends PollException {}

class UnauthorizedVoteException extends PollException {}

class InvalidVoteException extends PollException {
  final String reason;
  InvalidVoteException(this.reason);
}

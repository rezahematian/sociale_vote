import 'package:sociale_vote/domain/poll/entities/poll.dart';

/// Stato del dettaglio di un singolo poll.
///
/// È un semplice "sealed-like" con 4 varianti:
/// - initial: nessun dato caricato
/// - loading: sta caricando dal repository
/// - loaded: poll caricato correttamente
/// - error: errore nel caricamento
abstract class PollDetailState {
  const PollDetailState();
}

class PollDetailInitial extends PollDetailState {
  const PollDetailInitial();
}

class PollDetailLoading extends PollDetailState {
  const PollDetailLoading();
}

class PollDetailLoaded extends PollDetailState {
  final Poll poll;

  const PollDetailLoaded(this.poll);
}

class PollDetailError extends PollDetailState {
  final String message;

  const PollDetailError(this.message);
}
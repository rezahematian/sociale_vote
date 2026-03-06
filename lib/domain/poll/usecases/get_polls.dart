import '../entities/poll.dart';
import '../repositories/poll_repository.dart';

/// Use case per ottenere la lista di poll.
///
/// v1:
/// - filtra per [countryCode] / [cityId].
///
/// v2 (Fase 4.3 – paginazione):
/// - espone anche [limit] e [offset] per supportare la paginazione lato dominio.
/// - al momento i parametri possono essere ignorati dall'implementazione
///   del [PollRepository] finché non viene aggiornata la firma del repository.
class GetPolls {
  final PollRepository repository;

  GetPolls(this.repository);

  Future<List<Poll>> call({
    String? countryCode,
    String? cityId,
    int? limit,
    int? offset,
  }) {
    // NOTE:
    // Per ora deleghiamo a PollRepository nella forma esistente.
    // Quando aggiornerai PollRepository.getPolls per supportare limit/offset,
    // potrai semplicemente passare anche questi parametri.
    return repository.getPolls(
      countryCode: countryCode,
      cityId: cityId,
      // limit: limit,
      // offset: offset,
    );
  }
}
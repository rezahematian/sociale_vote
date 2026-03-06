import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';

/// Use case per ottenere il feed social.
///
/// Incapsula l'accesso al [PostRepository] e definisce
/// l'API "ufficiale" lato dominio per leggere la lista di post.
///
/// v1: ritorna semplicemente una [List<Post>] senza wrapper Result.
/// In futuro potremo introdurre un Result/Failure globale.
class GetFeed {
  final PostRepository _repository;

  const GetFeed(this._repository);

  /// Restituisce il feed di post per lo scope richiesto.
  ///
  /// [countryCode] e [cityId] seguono la stessa semantica usata nel repository:
  /// - entrambi null  -> feed globale (world)
  /// - solo country   -> feed nazionale
  /// - country + city -> feed città
  ///
  /// [limit] e [offset] servono per la paginazione futura.
  Future<List<Post>> call({
    String? countryCode,
    String? cityId,
    int limit = 20,
    int offset = 0,
  }) {
    return _repository.getFeed(
      countryCode: countryCode,
      cityId: cityId,
      limit: limit,
      offset: offset,
    );
  }
}
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';

/// Use case per ottenere il dettaglio di un post del social feed.
///
/// V1: semplice delega al repository.
/// In futuro potrà:
/// - arricchire il modello con dati autore reali
/// - aggiungere caching
/// - gestire fallback o logging
class GetPostDetail {
  final PostRepository _postRepository;

  const GetPostDetail(this._postRepository);

  /// Carica il dettaglio del post con [postId].
  ///
  /// Ritorna `null` se il post non esiste.
  Future<Post?> call(String postId) {
    return _postRepository.getPostById(postId);
  }
}
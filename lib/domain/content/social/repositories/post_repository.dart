import 'package:sociale_vote/domain/content/social/entities/post.dart';

/// Repository astratto per la gestione dei post del social feed.
///
/// Questo è il contratto lato dominio.
/// Le implementazioni concrete vivono in `infrastructure/social/repositories`.
abstract class PostRepository {
  /// Restituisce il feed di post per l'area richiesta.
  ///
  /// - [countryCode] e [cityId] seguono la stessa logica usata per Poll/News:
  ///   - se entrambi null → feed globale (world)
  ///   - se solo [countryCode] valorizzato → feed nazionale
  ///   - se anche [cityId] valorizzato → feed città
  ///
  /// [limit] e [offset] servono per la paginazione futura.
  /// Per v1 puoi anche ignorarli nella implementazione mock,
  /// ma il contratto è già pronto.
  Future<List<Post>> getFeed({
    String? countryCode,
    String? cityId,
    int limit = 20,
    int offset = 0,
  });

  /// Restituisce il dettaglio di un singolo post.
  ///
  /// Ritorna `null` se il post non esiste.
  Future<Post?> getPostById(String postId);

  /// Crea un nuovo post nel feed.
  ///
  /// In v1 lavoriamo in-memory:
  /// - genera l'id nella usecase o nella implementazione
  /// - ritorna il post creato con id valorizzato.
  Future<Post> createPost(Post post);

  /// Aggiorna un post esistente.
  ///
  /// In questa prima versione di edit supportiamo solo i campi testuali
  /// principali, per evitare di riaprire scope/localizzazione.
  Future<Post> updatePost({
    required String postId,
    required String title,
    required String content,
  });

  /// (Opzionale ma utile da subito) Elimina un post esistente.
  ///
  /// In v1 mock può semplicemente rimuoverlo dalla lista in memoria.
  Future<void> deletePost(String postId);
}
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/favorite.dart';

/// Contratto astratto per la gestione dei preferiti (⭐).
///
/// Implementazioni concrete:
/// - in-memory (v1)
/// - HTTP verso backend reale (v2)
abstract class FavoriteRepository {
  /// Ritorna `true` se l'utente ha già messo il target tra i preferiti.
  Future<bool> isFavorite({
    required String userId,
    required TargetRef target,
  });

  /// Aggiunge un target tra i preferiti dell'utente.
  Future<void> addFavorite(Favorite favorite);

  /// Rimuove un target dai preferiti dell'utente.
  Future<void> removeFavorite({
    required String userId,
    required TargetRef target,
  });

  /// Ritorna la lista dei target preferiti dell'utente.
  ///
  /// v1: nessun filtro; in v2 puoi aggiungere:
  /// - tipo di target (solo poll / news / post)
  /// - scope geo, ecc.
  Future<List<Favorite>> getFavoritesForUser(String userId);
}
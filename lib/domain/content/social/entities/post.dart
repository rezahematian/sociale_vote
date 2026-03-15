import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';

/// Entity di dominio per un post del social feed.
///
/// Obiettivo v1:
/// - rappresentare un post "civico" pubblicato da un utente
/// - collegarlo a un ambito geografico (world / country / city)
/// - avere i dati minimi per mostrarlo in un feed e in dettaglio
///
/// In futuro potremo:
/// - collegare a UserId reale
/// - aggiungere like, share, allegati, ecc.
class Post {
  /// Identificatore univoco del post.
  ///
  /// Usiamo l'EntityId generico per non introdurre subito un PostId dedicato.
  final EntityId id;

  /// Nome visuale dell'autore del post.
  ///
  /// v1: semplice stringa.
  /// In futuro potrà essere derivata da UserProfile.
  final String authorName;

  /// Titolo breve del post, mostrato nel feed.
  final String title;

  /// Contenuto testuale principale del post.
  final String content;

  /// Timestamp di creazione del post (UTC o locale coerente con il resto dell'app).
  final DateTime createdAt;

  /// Numero commenti associati al post.
  final int commentCount;

  /// Codice paese associato al post (es. 'IT').
  ///
  /// - null  => post globale (world)
  /// - non null, cityId null => post nazionale
  /// - non null, cityId non null => post di città
  final String? countryCode;

  /// Identificatore città associato al post (es. 'TORINO').
  final String? cityId;

  /// Località completa del contenuto.
  final ContentLocation? contentLocation;

  /// Utente che ha creato il post.
  /// Per i post esistenti può essere null.
  final String? createdByUserId;

  /// Costruttore principale.
  const Post({
    required this.id,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.commentCount = 0,
    this.countryCode,
    this.cityId,
    this.contentLocation,
    this.createdByUserId,
  });

  /// True se il post è globale (world).
  bool get isGlobal => countryCode == null && cityId == null;

  /// True se il post è a livello di paese.
  bool get isCountryLevel => countryCode != null && cityId == null;

  /// True se il post è a livello di città.
  bool get isCityLevel => countryCode != null && cityId != null;

  /// Verifica se il post appartiene allo scope richiesto.
  ///
  /// Questa logica è coerente con Poll/News:
  /// - scope world: countryCode e cityId null
  /// - scope country: stesso countryCode, cityId null
  /// - scope city: stesso countryCode e stesso cityId
  bool matchesScope({
    String? countryCode,
    String? cityId,
  }) {
    if (countryCode == null && cityId == null) {
      return isGlobal;
    }

    if (countryCode != null && cityId == null) {
      return this.countryCode == countryCode && this.cityId == null;
    }

    if (countryCode != null && cityId != null) {
      return this.countryCode == countryCode && this.cityId == cityId;
    }

    return false;
  }

  /// Crea una copia immutabile con override parziali.
  Post copyWith({
    EntityId? id,
    String? authorName,
    String? title,
    String? content,
    DateTime? createdAt,
    int? commentCount,
    String? countryCode,
    String? cityId,
    ContentLocation? contentLocation,
    String? createdByUserId,
  }) {
    return Post(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      commentCount: commentCount ?? this.commentCount,
      countryCode: countryCode ?? this.countryCode,
      cityId: cityId ?? this.cityId,
      contentLocation: contentLocation ?? this.contentLocation,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }
}

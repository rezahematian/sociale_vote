/// Riferimento generico ad un contenuto “target” dell’engagement.
/// 
/// Viene usato da:
/// - engagement (reactions / heat)
/// - favorites (follow / preferiti)
/// - discussion (commenti)
/// - search / trending
///
/// L’obiettivo è avere UN SOLO modo tipizzato per riferirsi a:
/// - poll
/// - news
/// - post (social)
/// - video
/// - city / country
/// - topic
/// - user
///
/// Questo file NON dipende da Flutter, solo da dart:core.
/// Può essere usato liberamente in tutto il dominio.
enum TargetType {
  poll,
  news,
  post,
  video,
  city,
  country,
  topic,
  user,
}

/// Value object che identifica univocamente un “bersaglio” di engagement
/// tramite coppia (type, id).
///
/// Esempi:
/// - TargetRef.poll('123')
/// - TargetRef.news('article-42')
/// - TargetRef.city('TORINO')
class TargetRef {
  final TargetType type;
  final String id;

  const TargetRef({
    required this.type,
    required this.id,
  });

  /// Helper factory per creare riferimenti a poll.
  const TargetRef.poll(String pollId)
      : type = TargetType.poll,
        id = pollId;

  /// Helper factory per creare riferimenti a news.
  const TargetRef.news(String newsId)
      : type = TargetType.news,
        id = newsId;

  /// Helper factory per creare riferimenti a post social.
  const TargetRef.post(String postId)
      : type = TargetType.post,
        id = postId;

  /// Helper factory per creare riferimenti a video.
  const TargetRef.video(String videoId)
      : type = TargetType.video,
        id = videoId;

  /// Helper factory per riferimenti a città.
  const TargetRef.city(String cityId)
      : type = TargetType.city,
        id = cityId;

  /// Helper factory per riferimenti a country (es. IT, FR, US).
  const TargetRef.country(String countryCode)
      : type = TargetType.country,
        id = countryCode;

  /// Helper factory per riferimenti a topic/argomento.
  const TargetRef.topic(String topicId)
      : type = TargetType.topic,
        id = topicId;

  /// Helper factory per riferimenti a user.
  const TargetRef.user(String userId)
      : type = TargetType.user,
        id = userId;

  /// Chiave stringa comoda per mappe/cache:
  /// es. "poll:123", "news:article-42".
  String get key => '${type.name}:$id';

  /// Copia con override selettivo (pattern immutable).
  TargetRef copyWith({
    TargetType? type,
    String? id,
  }) {
    return TargetRef(
      type: type ?? this.type,
      id: id ?? this.id,
    );
  }

  /// Conversione in JSON base (utile per DTO o persistenza semplice).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.name,
      'id': id,
    };
  }

  /// Ricostruzione da JSON.
  ///
  /// Se il tipo non è riconosciuto, lancia un ArgumentError:
  /// è preferibile fallire esplicitamente a questo livello.
  factory TargetRef.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final id = json['id'] as String?;

    if (typeStr == null || id == null) {
      throw ArgumentError('Invalid TargetRef JSON: $json');
    }

    final type = TargetType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () {
        throw ArgumentError('Unknown TargetType "$typeStr" in TargetRef JSON');
      },
    );

    return TargetRef(
      type: type,
      id: id,
    );
  }

  @override
  String toString() => 'TargetRef(type: $type, id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TargetRef &&
        other.type == type &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}
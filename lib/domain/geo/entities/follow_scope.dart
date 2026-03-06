import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

/// Entità di dominio che rappresenta il "follow" di uno scope geografico.
///
/// - [userId]: utente che segue lo scope (String, coerente con SessionRepository)
/// - [scope]: GeoScope seguito (World / Country / City)
/// - [followedAt]: timestamp di quando è stato fatto il follow
///
/// Nota: a livello di identità logica, la coppia (userId, scope)
/// è unica. [followedAt] è meta-informazione utile per ranking / UI.
class FollowScope {
  final String userId;
  final GeoScope scope;
  final DateTime followedAt;

  const FollowScope({
    required this.userId,
    required this.scope,
    required this.followedAt,
  });

  FollowScope copyWith({
    String? userId,
    GeoScope? scope,
    DateTime? followedAt,
  }) {
    return FollowScope(
      userId: userId ?? this.userId,
      scope: scope ?? this.scope,
      followedAt: followedAt ?? this.followedAt,
    );
  }

  /// Due FollowScope sono considerati uguali se
  /// rappresentano lo stesso utente che segue lo stesso scope.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FollowScope &&
        other.userId == userId &&
        other.scope == scope;
  }

  @override
  int get hashCode => Object.hash(userId, scope);

  @override
  String toString() {
    return 'FollowScope(userId: $userId, scope: $scope, followedAt: $followedAt)';
  }
}
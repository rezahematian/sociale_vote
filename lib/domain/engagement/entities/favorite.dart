import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

/// Marca un contenuto (poll, news, post, ecc.) come "preferito"
/// da parte di un certo utente.
class Favorite {
  final String userId;
  final TargetRef target;
  final DateTime createdAt;

  const Favorite({
    required this.userId,
    required this.target,
    required this.createdAt,
  });
}
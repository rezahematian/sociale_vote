import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/favorite.dart';
import 'package:sociale_vote/domain/engagement/repositories/favorite_repository.dart';

class FavoriteRepositorySupabase implements FavoriteRepository {
  static const String _table = 'favorites';

  @override
  Future<bool> isFavorite({
    required String userId,
    required TargetRef target,
  }) async {
    final rows = await AppSupabase.client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('target_type', _targetType(target))
        .eq('target_id', target.id)
        .limit(1);

    return rows.isNotEmpty;
  }

  @override
  Future<void> addFavorite(Favorite favorite) async {
    await AppSupabase.client.from(_table).upsert(
      {
        'user_id': favorite.userId,
        'target_type': _targetType(favorite.target),
        'target_id': favorite.target.id,
        'created_at': favorite.createdAt.toUtc().toIso8601String(),
      },
      onConflict: 'user_id,target_type,target_id',
    );
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required TargetRef target,
  }) async {
    await AppSupabase.client
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .eq('target_type', _targetType(target))
        .eq('target_id', target.id);
  }

  @override
  Future<List<Favorite>> getFavoritesForUser(String userId) async {
    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows
        .whereType<Map<String, dynamic>>()
        .map(_mapFavorite)
        .toList(growable: false);
  }

  Favorite _mapFavorite(Map<String, dynamic> row) {
    return Favorite(
      userId: (row['user_id'] as String?) ?? '',
      target: _targetFromRow(row),
      createdAt: _parseDateTime(row['created_at']),
    );
  }

  TargetRef _targetFromRow(Map<String, dynamic> row) {
    final type = (row['target_type'] as String?) ?? '';
    final id = (row['target_id'] as String?) ?? '';

    switch (type) {
      case 'poll':
        return TargetRef.poll(id);
      case 'post':
        return TargetRef.post(id);
      case 'news':
        return TargetRef.news(id);
      case 'video':
        return TargetRef.video(id);
      default:
        throw Exception('Tipo target favorite non supportato: $type');
    }
  }

  String _targetType(TargetRef target) {
    switch (target.type) {
      case TargetType.poll:
        return 'poll';
      case TargetType.post:
        return 'post';
      case TargetType.news:
        return 'news';
      case TargetType.video:
        return 'video';
      default:
        throw Exception(
          'Target type non supportato per favorites: ${target.type}',
        );
    }
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }
}
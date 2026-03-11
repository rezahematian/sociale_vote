import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';

/// Implementazione Supabase del [PostRepository].
///
/// V2:
/// - legge i post reali dalla tabella `public.posts`
/// - legge il dettaglio di un post reale
/// - crea un post reale su Supabase
/// - elimina un post reale
///
/// Nota:
/// per mantenere compatibilità con il dominio attuale,
/// il filtraggio scope viene fatto in Dart dopo il fetch.
/// In una fase successiva potremo ottimizzare la query lato database.
class PostRepositoryImpl implements PostRepository {
  static const String _postsTable = 'posts';
  static const String _usersTable = 'users';

  @override
  Future<List<Post>> getFeed({
    String? countryCode,
    String? cityId,
    int limit = 20,
    int offset = 0,
  }) async {
    final rows = await AppSupabase.client
        .from(_postsTable)
        .select()
        .order('created_at', ascending: false);

    final mapped = await _mapPosts(rows);

    final scoped = mapped
        .where(
          (post) => post.matchesScope(
            countryCode: countryCode,
            cityId: cityId,
          ),
        )
        .toList();

    if (scoped.isEmpty) {
      return const [];
    }

    final int start = offset.clamp(0, scoped.length);
    final int end = (start + limit).clamp(0, scoped.length);

    if (start >= end) {
      return const [];
    }

    return List<Post>.unmodifiable(scoped.sublist(start, end));
  }

  @override
  Future<Post?> getPostById(String postId) async {
    final rows = await AppSupabase.client
        .from(_postsTable)
        .select()
        .eq('id', postId)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final mapped = await _mapPosts(rows);
    if (mapped.isEmpty) {
      return null;
    }

    return mapped.first;
  }

  @override
  Future<Post> createPost(Post post) async {
    final currentUser = AppSupabase.currentUser;
    if (currentUser == null) {
      throw Exception('Utente non autenticato.');
    }

    await _ensureCurrentUserRow();

    final insertedRows = await AppSupabase.client
        .from(_postsTable)
        .insert({
          'author_id': currentUser.id,
          'title': post.title,
          'content': post.content,
          'country_code': post.countryCode,
          'city_id': post.cityId,
        })
        .select()
        .limit(1);

    if (insertedRows.isEmpty) {
      throw Exception('Creazione post fallita.');
    }

    final mapped = await _mapPosts(insertedRows);
    if (mapped.isEmpty) {
      throw Exception('Creazione post fallita.');
    }

    return mapped.first;
  }

  @override
  Future<void> deletePost(String postId) async {
    await AppSupabase.client
        .from(_postsTable)
        .delete()
        .eq('id', postId);
  }

  Future<List<Post>> _mapPosts(List<dynamic> rows) async {
    if (rows.isEmpty) {
      return const [];
    }

    final normalizedRows = rows
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    if (normalizedRows.isEmpty) {
      return const [];
    }

    final authorIds = normalizedRows
        .map((row) => row['author_id'])
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);

    final authorsById = await _loadAuthorsById(authorIds);

    return normalizedRows.map((row) {
      final authorId = row['author_id'] as String?;
      final createdAtRaw = row['created_at'];

      return Post(
        id: EntityId(row['id'] as String),
        authorName: authorsById[authorId] ?? 'Unknown user',
        title: (row['title'] as String?) ?? '',
        content: (row['content'] as String?) ?? '',
        createdAt: _parseDateTime(createdAtRaw),
        commentCount: 0,
        countryCode: row['country_code'] as String?,
        cityId: row['city_id'] as String?,
      );
    }).toList(growable: false);
  }

  Future<Map<String, String>> _loadAuthorsById(List<String> authorIds) async {
    if (authorIds.isEmpty) {
      return const {};
    }

    final rows = await AppSupabase.client
        .from(_usersTable)
        .select('id, display_name, email')
        .inFilter('id', authorIds);

    final result = <String, String>{};

    for (final row in rows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }

      final id = row['id'] as String?;
      if (id == null || id.trim().isEmpty) {
        continue;
      }

      final displayName = row['display_name'] as String?;
      final email = row['email'] as String?;

      result[id] = (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : (email != null && email.trim().isNotEmpty)
              ? email.trim()
              : 'Unknown user';
    }

    return result;
  }

  Future<void> _ensureCurrentUserRow() async {
    final currentUser = AppSupabase.currentUser;
    if (currentUser == null) {
      return;
    }

    final metadata = currentUser.userMetadata ?? const <String, dynamic>{};

    final displayName = _readDisplayName(metadata);
    final email = currentUser.email;

    await AppSupabase.client.from(_usersTable).upsert(
      {
        'id': currentUser.id,
        'email': email,
        'display_name': displayName,
      },
      onConflict: 'id',
    );
  }

  String? _readDisplayName(Map<String, dynamic> metadata) {
    final value = metadata['display_name'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }
}
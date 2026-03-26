import 'package:flutter/foundation.dart';
import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';

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
    final requestedCountry = _prepareDbFilterValue(countryCode);
    final requestedCity = _prepareDbFilterValue(cityId);

    dynamic query = AppSupabase.client.from(_postsTable).select();

    if (requestedCountry != null) {
      query = query.eq('country_code', requestedCountry);
    }

    if (requestedCity != null) {
      query = query.eq('city_id', requestedCity);
    }

    query = query.order('created_at', ascending: false);

    final safeOffset = offset < 0 ? 0 : offset;

    if (limit <= 0) {
      return const [];
    }

    query = query.range(safeOffset, safeOffset + limit - 1);

    final rows = await query as List<dynamic>;
    return _mapPosts(rows);
  }

  String? _prepareDbFilterValue(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
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
        .insert(
          _buildInsertPayload(
            post: post,
            authorId: currentUser.id,
          ),
        )
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

  Map<String, dynamic> _buildInsertPayload({
    required Post post,
    required String authorId,
  }) {
    final payload = <String, dynamic>{
      'author_id': authorId,
      'title': post.title,
      'content': post.content,
      'country_code': post.countryCode ?? post.contentLocation?.countryCode,
      'city_id': post.cityId ?? post.contentLocation?.cityId,
      'content_location': post.contentLocation?.toJson(),
    };

    if (kDebugMode) {
      debugPrint('Post insert payload: $payload');
    }

    return payload;
  }

  @override
  Future<void> deletePost(String postId) async {
    await AppSupabase.client.from(_postsTable).delete().eq('id', postId);
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
      final rowCountryCode = row['country_code'] as String?;
      final rowCityId = row['city_id'] as String?;
      final contentLocation = _mapContentLocation(
        row,
        rowCountryCode,
        rowCityId,
      );

      final effectiveCountryCode =
          rowCountryCode ?? contentLocation?.countryCode;
      final effectiveCityId = rowCityId ?? contentLocation?.cityId;

      return Post(
        id: EntityId(row['id'] as String),
        authorName: authorsById[authorId] ?? 'Unknown user',
        title: (row['title'] as String?) ?? '',
        content: (row['content'] as String?) ?? '',
        createdAt: _parseDateTime(createdAtRaw),
        commentCount: 0,
        countryCode: effectiveCountryCode,
        cityId: effectiveCityId,
        contentLocation: contentLocation,
        createdByUserId: authorId,
      );
    }).toList(growable: false);
  }

  ContentLocation? _mapContentLocation(
    Map<String, dynamic> row,
    String? countryCode,
    String? cityId,
  ) {
    final raw = row['content_location'];

    if (raw is Map<String, dynamic>) {
      return ContentLocation.fromJson(raw);
    }

    if (raw is Map) {
      return ContentLocation.fromJson(
        raw.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }

    final centerLat = _toDouble(row['center_lat']);
    final centerLng = _toDouble(row['center_lng']);
    final latitude = _toDouble(row['latitude']);
    final longitude = _toDouble(row['longitude']);

    final fallback = ContentLocation(
      source: ContentLocationSource.geoScopeFallback,
      countryCode: countryCode,
      cityId: cityId,
      centerLat: centerLat,
      centerLng: centerLng,
      latitude: latitude,
      longitude: longitude,
    );

    return fallback.isEmpty ? null : fallback;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
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
    if (value is DateTime) {
      return value.toLocal();
    }
    return DateTime.now();
  }
}
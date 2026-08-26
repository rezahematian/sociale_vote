import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/content/news/entities/world_brief.dart';
import 'package:sociale_vote/domain/content/news/repositories/world_brief_repository.dart';

class WorldBriefRepositorySupabase implements WorldBriefRepository {
  static const String _table = 'social_vote_world_briefs';

  SupabaseClient get _client => AppSupabase.client;

  static const String _columns =
      'id, status, language_code, title, what_happened, why_it_matters, '
      'what_is_uncertain, social_vote_view, source_urls, country_code, city_id, location_label, '
      'latitude, longitude, map_visible, featured, breaking, priority, '
      'published_at, expires_at, created_at, updated_at';

  @override
  Future<List<WorldBrief>> listPublished({
    String? languageCode,
    String? countryCode,
    String? cityId,
    int limit = 50,
  }) async {
    try {
      final requestedLanguage = _language(languageCode);
      dynamic query =
          _client.from(_table).select(_columns).eq('status', 'published');
      if (requestedLanguage != null) {
        query = query.eq('language_code', requestedLanguage);
      }
      final rows = await query
          .order('featured', ascending: false)
          .order('priority', ascending: false)
          .order('published_at', ascending: false)
          .limit(limit.clamp(1, 100).toInt());

      final requestedCountry = _country(countryCode);
      final requestedCity = _text(cityId)?.toLowerCase();

      return rows.map(_fromRow).where((brief) {
        if (requestedLanguage != null &&
            brief.languageCode != requestedLanguage) {
          return false;
        }
        return _matchesScope(
          brief,
          countryCode: requestedCountry,
          cityId: requestedCity,
        );
      }).toList(growable: false);
    } on PostgrestException catch (error) {
      if (error.code == '42P01' || error.code == 'PGRST205') {
        return const <WorldBrief>[];
      }
      rethrow;
    }
  }

  @override
  Future<WorldBrief?> getPublishedById(String id) async {
    final normalized = _text(id);
    if (normalized == null) return null;

    try {
      final row = await _client
          .from(_table)
          .select(_columns)
          .eq('id', normalized)
          .eq('status', 'published')
          .maybeSingle();
      return row == null ? null : _fromRow(row);
    } on PostgrestException catch (error) {
      if (error.code == '42P01' || error.code == 'PGRST205') {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<WorldBrief>> listForAdmin({
    WorldBriefStatus? status,
    int limit = 100,
  }) async {
    dynamic query = _client.from(_table).select(_columns);
    if (status != null) {
      query = query.eq('status', status.storageKey);
    }
    final rows = await query
        .order('updated_at', ascending: false)
        .limit(limit.clamp(1, 200).toInt());
    return (rows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_fromRow)
        .toList(growable: false);
  }

  @override
  Future<WorldBrief> saveDraft(WorldBriefDraft draft) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw StateError('Authenticated admin required.');
    }

    final payload = <String, dynamic>{
      if (_text(draft.id) != null) 'id': _text(draft.id),
      'status': 'draft',
      'language_code': _language(draft.languageCode) ?? 'en',
      'title': draft.title.trim(),
      'what_happened': draft.whatHappened.trim(),
      'why_it_matters': draft.whyItMatters.trim(),
      'what_is_uncertain': _text(draft.whatIsUncertain),
      'social_vote_view': _text(draft.socialVoteView),
      'source_urls': draft.sourceUrls
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      'country_code': _country(draft.countryCode),
      'city_id': _text(draft.cityId),
      'location_label': _text(draft.locationLabel),
      'latitude': draft.latitude,
      'longitude': draft.longitude,
      'map_visible': draft.mapVisible,
      'featured': draft.featured,
      'breaking': draft.breaking,
      'priority': draft.priority.clamp(0, 100).toInt(),
      'expires_at': draft.expiresAt?.toUtc().toIso8601String(),
      'created_by': currentUserId,
      'updated_by': currentUserId,
    };

    final data = await _client.rpc(
      'admin_world_brief_save',
      params: <String, dynamic>{'p_payload': payload},
    );
    return _fromRow(_rpcRow(data));
  }

  @override
  Future<WorldBrief> publish(String id) async {
    return _setStatus(id, WorldBriefStatus.published);
  }

  @override
  Future<WorldBrief> withdraw(String id) async {
    return _setStatus(id, WorldBriefStatus.withdrawn);
  }

  @override
  Future<void> deleteDraft(String id) async {
    final normalized = _text(id);
    if (normalized == null) return;
    await _client.rpc(
      'admin_world_brief_delete_draft',
      params: <String, dynamic>{'p_id': normalized},
    );
  }

  Future<WorldBrief> _setStatus(
    String id,
    WorldBriefStatus status,
  ) async {
    final normalized = _text(id);
    final currentUserId = _client.auth.currentUser?.id;
    if (normalized == null || currentUserId == null) {
      throw StateError('Authenticated admin and brief id required.');
    }

    final data = await _client.rpc(
      'admin_world_brief_set_status',
      params: <String, dynamic>{
        'p_id': normalized,
        'p_status': status.storageKey,
      },
    );
    return _fromRow(_rpcRow(data));
  }

  Map<String, dynamic> _rpcRow(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw StateError('Invalid World Brief backend response.');
  }

  bool _matchesScope(
    WorldBrief brief, {
    required String? countryCode,
    required String? cityId,
  }) {
    final briefCountry = _country(brief.countryCode);
    final briefCity = _text(brief.cityId)?.toLowerCase();

    if (cityId != null) {
      if (briefCountry != null &&
          countryCode != null &&
          briefCountry != countryCode) {
        return false;
      }
      return briefCity == null || briefCity == cityId;
    }
    if (countryCode != null) {
      return briefCountry == null || briefCountry == countryCode;
    }
    return true;
  }

  WorldBrief _fromRow(Map<String, dynamic> row) {
    final sourceUrls = row['source_urls'];
    return WorldBrief(
      id: _text(row['id']) ?? '',
      status: WorldBriefStatusX.fromStorageKey(_text(row['status'])),
      languageCode: _language(row['language_code']?.toString()) ?? 'en',
      title: _text(row['title']) ?? '',
      whatHappened: _text(row['what_happened']) ?? '',
      whyItMatters: _text(row['why_it_matters']) ?? '',
      whatIsUncertain: _text(row['what_is_uncertain']),
      socialVoteView: _text(row['social_vote_view']),
      sourceUrls: sourceUrls is List
          ? sourceUrls
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList(growable: false)
          : const <String>[],
      countryCode: _country(row['country_code']?.toString()),
      cityId: _text(row['city_id']),
      locationLabel: _text(row['location_label']),
      latitude: _double(row['latitude']),
      longitude: _double(row['longitude']),
      mapVisible: row['map_visible'] == true,
      featured: row['featured'] == true,
      breaking: row['breaking'] == true,
      priority: _integer(row['priority']).clamp(0, 100).toInt(),
      publishedAt: _date(row['published_at']),
      expiresAt: _date(row['expires_at']),
      createdAt:
          _date(row['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          _date(row['updated_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String? _text(dynamic value) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? _language(String? value) {
    final normalized = _text(value)?.toLowerCase().replaceAll('_', '-');
    return normalized?.split('-').first;
  }

  String? _country(String? value) => _text(value)?.toUpperCase();

  int _integer(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  DateTime? _date(dynamic value) {
    if (value is DateTime) return value.toLocal();
    final raw = _text(value);
    return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  }
}

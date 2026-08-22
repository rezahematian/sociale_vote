import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/domain/organization/entities/organization_models.dart';
import 'package:sociale_vote/domain/organization/repositories/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  static const String _mediaBucket = 'organization-media';

  SupabaseClient get _client => AppSupabase.client;

  @override
  Future<OrganizationContext?> getMyOrganization() async {
    final raw = await _client.rpc('organization_get_mine');
    if (raw == null) return null;
    final json = _map(raw);
    if (json.isEmpty || json['organization'] == null) return null;
    return OrganizationContext.fromJson(json);
  }

  @override
  Future<OrganizationContext> bootstrapFromVerifiedProfile() async {
    final raw = await _client.rpc('organization_bootstrap_from_verified_profile');
    return OrganizationContext.fromJson(_requiredMap(raw));
  }

  @override
  Future<OrganizationProfile?> getPublicOrganizationByOperator(
    String userId,
  ) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return null;

    final raw = await _client.rpc(
      'organization_public_get_by_operator',
      params: <String, dynamic>{'p_user_id': normalized},
    );
    if (raw == null) return null;
    final json = _map(raw);
    if (json.isEmpty) return null;
    return OrganizationProfile.fromJson(json);
  }

  @override
  Future<OrganizationContext> updateOrganizationProfile({
    required OrganizationEntityType entityType,
    required String legalName,
    required String publicName,
    String? countryCode,
    String? city,
    String? websiteUrl,
    String? description,
  }) async {
    final raw = await _client.rpc(
      'organization_update_profile',
      params: <String, dynamic>{
        'p_entity_type': entityType.storageKey,
        'p_legal_name': legalName.trim(),
        'p_public_name': publicName.trim(),
        'p_country_code': _nullable(countryCode)?.toUpperCase(),
        'p_city': _nullable(city),
        'p_website_url': _nullable(websiteUrl),
        'p_description': _nullable(description),
      },
    );
    return OrganizationContext.fromJson(_requiredMap(raw));
  }

  @override
  Future<String> uploadOrganizationMedia({
    required String organizationId,
    required Uint8List bytes,
    required String fileName,
    required bool isCover,
  }) async {
    final normalizedOrg = organizationId.trim();
    if (normalizedOrg.isEmpty || bytes.isEmpty) {
      throw ArgumentError('Invalid organization media upload.');
    }

    final extension = _safeImageExtension(fileName);
    final kind = isCover ? 'cover' : 'logo';
    final path = '$normalizedOrg/$kind.$extension';

    await _client.storage.from(_mediaBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            cacheControl: '3600',
            contentType: _contentType(extension),
          ),
        );

    final publicUrl = _client.storage.from(_mediaBucket).getPublicUrl(path);
    final raw = await _client.rpc(
      'organization_set_media_url',
      params: <String, dynamic>{
        'p_organization_id': normalizedOrg,
        'p_kind': kind,
        'p_url': publicUrl,
      },
    );

    final context = OrganizationContext.fromJson(_requiredMap(raw));
    final resolved = isCover
        ? context.organization.coverUrl
        : context.organization.logoUrl;
    if (resolved == null || resolved.isEmpty) {
      throw StateError('Organization media URL was not persisted.');
    }
    return resolved;
  }

  @override
  Future<List<LiveSessionSummary>> listSessions() async {
    final raw = await _client.rpc('sessions_list_mine');
    final list = raw is List ? raw : const <dynamic>[];
    return list
        .map((item) => LiveSessionSummary.fromJson(_map(item)))
        .toList(growable: false);
  }

  @override
  Future<String> createSession({
    required String title,
    required LiveSessionAccessMode accessMode,
    required LiveSessionResultsVisibility resultsVisibility,
    required String rawRetention,
    required int expectedParticipants,
  }) async {
    final raw = await _client.rpc(
      'session_create',
      params: <String, dynamic>{
        'p_title': title.trim(),
        'p_access_mode': accessMode.storageKey,
        'p_results_visibility': resultsVisibility.storageKey,
        'p_raw_retention': rawRetention,
        'p_expected_participants': expectedParticipants,
      },
    );
    final id = raw?.toString().trim() ?? '';
    if (id.isEmpty) throw StateError('Session creation returned no id.');
    return id;
  }

  @override
  Future<LiveSessionDetail> getOrganizerSession(String sessionId) async {
    final raw = await _client.rpc(
      'session_organizer_get',
      params: <String, dynamic>{'p_session_id': sessionId.trim()},
    );
    return LiveSessionDetail.fromJson(_requiredMap(raw));
  }

  @override
  Future<String> addQuestion({
    required String sessionId,
    required String title,
    required LiveQuestionType type,
    required List<String> options,
    required int minSelections,
    required int maxSelections,
  }) async {
    final raw = await _client.rpc(
      'session_add_question',
      params: <String, dynamic>{
        'p_session_id': sessionId.trim(),
        'p_title': title.trim(),
        'p_question_type': type.storageKey,
        'p_options': options.map((value) => value.trim()).toList(),
        'p_min_selections': minSelections,
        'p_max_selections': maxSelections,
      },
    );
    final id = raw?.toString().trim() ?? '';
    if (id.isEmpty) throw StateError('Question creation returned no id.');
    return id;
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    await _client.rpc(
      'session_delete_question',
      params: <String, dynamic>{'p_question_id': questionId.trim()},
    );
  }

  @override
  Future<List<String>> generateTokens({
    required String sessionId,
    required int count,
  }) async {
    final raw = await _client.rpc(
      'session_generate_tokens',
      params: <String, dynamic>{
        'p_session_id': sessionId.trim(),
        'p_count': count,
      },
    );
    final list = raw is List ? raw : const <dynamic>[];
    return list
        .map((row) => _map(row)['token']?.toString().trim() ?? '')
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> openSession(String sessionId) async {
    await _client.rpc(
      'session_open',
      params: <String, dynamic>{'p_session_id': sessionId.trim()},
    );
  }

  @override
  Future<void> openQuestion(String questionId) async {
    await _client.rpc(
      'session_question_open',
      params: <String, dynamic>{'p_question_id': questionId.trim()},
    );
  }

  @override
  Future<void> closeQuestion(String questionId) async {
    await _client.rpc(
      'session_question_close',
      params: <String, dynamic>{'p_question_id': questionId.trim()},
    );
  }

  @override
  Future<String> closeSession(String sessionId) async {
    final raw = await _client.rpc(
      'session_close',
      params: <String, dynamic>{'p_session_id': sessionId.trim()},
    );
    final reportId = raw?.toString().trim() ?? '';
    if (reportId.isEmpty) throw StateError('Session close returned no report id.');
    return reportId;
  }

  @override
  Future<ParticipantJoinResult> joinPublicSession({
    required String joinCode,
    String? token,
  }) async {
    final raw = await _client.rpc(
      'session_public_join',
      params: <String, dynamic>{
        'p_join_code': joinCode.trim().toUpperCase(),
        'p_token': _nullable(token),
      },
    );
    return ParticipantJoinResult.fromJson(_requiredMap(raw));
  }

  @override
  Future<LiveSessionDetail> getPublicSessionState({
    required String joinCode,
    String? participantSecret,
  }) async {
    final raw = await _client.rpc(
      'session_public_state',
      params: <String, dynamic>{
        'p_join_code': joinCode.trim().toUpperCase(),
        'p_participant_secret': _nullable(participantSecret),
      },
    );
    return LiveSessionDetail.fromJson(_requiredMap(raw));
  }

  @override
  Future<String> submitPublicVote({
    required String joinCode,
    required String participantSecret,
    required String questionId,
    required List<String> optionIds,
  }) async {
    final raw = await _client.rpc(
      'session_public_vote',
      params: <String, dynamic>{
        'p_join_code': joinCode.trim().toUpperCase(),
        'p_participant_secret': participantSecret.trim(),
        'p_question_id': questionId.trim(),
        'p_option_ids': optionIds,
      },
    );
    final json = _requiredMap(raw);
    final receipt = json['receipt']?.toString().trim() ?? '';
    if (receipt.isEmpty) throw StateError('Vote receipt missing.');
    return receipt;
  }

  @override
  Future<LiveQuestion?> getPublicResults({
    required String joinCode,
    required String participantSecret,
    required String questionId,
  }) async {
    final raw = await _client.rpc(
      'session_public_results',
      params: <String, dynamic>{
        'p_join_code': joinCode.trim().toUpperCase(),
        'p_participant_secret': participantSecret.trim(),
        'p_question_id': questionId.trim(),
      },
    );
    if (raw == null) return null;
    final json = _map(raw);
    if (json.isEmpty || json['visible'] == false) return null;
    return LiveQuestion.fromJson(json);
  }

  @override
  Future<VerifiedSessionReport> getVerifiedReport(String reportId) async {
    final raw = await _client.rpc(
      'session_verified_report',
      params: <String, dynamic>{'p_report_id': reportId.trim()},
    );
    return VerifiedSessionReport.fromJson(_requiredMap(raw));
  }

  Map<String, dynamic> _requiredMap(dynamic raw) {
    final result = _map(raw);
    if (result.isEmpty) throw StateError('Unexpected empty backend response.');
    return result;
  }

  Map<String, dynamic> _map(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is List && raw.length == 1 && raw.first is Map) {
      return Map<String, dynamic>.from(raw.first as Map);
    }
    return <String, dynamic>{};
  }

  String? _nullable(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String _safeImageExtension(String fileName) {
    final lower = fileName.toLowerCase().trim();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    return 'jpg';
  }

  String _contentType(String extension) => switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
}

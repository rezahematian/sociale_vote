import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';

class VerificationRequestRepositoryImpl
    implements VerificationRequestRepository {
  static const String _table = 'verification_requests';

  @override
  Future<VerificationRequest?> getById(String requestId) async {
    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('id', requestId)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapRequest(row);
  }

  @override
  Future<VerificationRequest?> getPendingRequestForUser(String userId) async {
    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('status', VerificationRequestStatus.pending.storageKey)
        .order('submitted_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapRequest(row);
  }

  @override
  Future<List<VerificationRequest>> getRequestsForUser(String userId) async {
    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('submitted_at', ascending: false);

    return rows
        .cast<Map<String, dynamic>>()
        .map(_mapRequest)
        .toList(growable: false);
  }

  @override
  Future<List<VerificationRequest>> getPendingRequests({
    int limit = 50,
    int offset = 0,
  }) async {
    if (limit <= 0) {
      return const <VerificationRequest>[];
    }

    final safeOffset = offset < 0 ? 0 : offset;
    final end = safeOffset + limit - 1;

    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('status', VerificationRequestStatus.pending.storageKey)
        .order('submitted_at', ascending: false)
        .range(safeOffset, end);

    return rows
        .cast<Map<String, dynamic>>()
        .map(_mapRequest)
        .toList(growable: false);
  }

  @override
  Future<VerificationRequest> createRequest({
    required String userId,
    required VerificationRequestType requestType,
    required ActorType targetActorType,
    required VerificationLevel targetVerificationLevel,
    InstitutionLevel? targetInstitutionLevel,
    String? officialTitle,
    String? institutionName,
  }) async {
    final existingPending = await getPendingRequestForUser(userId);
    if (existingPending != null) {
      throw Exception('Esiste già una richiesta di verifica in corso.');
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'request_type': requestType.storageKey,
      'target_actor_type': targetActorType.storageKey,
      'target_verification_level': targetVerificationLevel.storageKey,
      'target_institution_level': targetInstitutionLevel?.storageKey,
      'official_title': _normalizeNullable(officialTitle),
      'institution_name': _normalizeNullable(institutionName),
      'status': VerificationRequestStatus.pending.storageKey,
    };

    final rows = await AppSupabase.client
        .from(_table)
        .insert(payload)
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Creazione richiesta verifica fallita.');
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapRequest(row);
  }

  @override
  Future<VerificationRequest> reviewRequest({
    required String requestId,
    required VerificationRequestStatus status,
    required String reviewedBy,
    String? reviewNote,
  }) async {
    if (status == VerificationRequestStatus.pending ||
        status == VerificationRequestStatus.cancelled) {
      throw Exception('Stato review non valido.');
    }

    final updates = <String, dynamic>{
      'status': status.storageKey,
      'reviewed_by': reviewedBy,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      'review_note': _normalizeNullable(reviewNote),
    };

    final rows = await AppSupabase.client
        .from(_table)
        .update(updates)
        .eq('id', requestId)
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Review richiesta verifica fallita.');
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapRequest(row);
  }

  @override
  Future<VerificationRequest> cancelRequest({
    required String requestId,
  }) async {
    final updates = <String, dynamic>{
      'status': VerificationRequestStatus.cancelled.storageKey,
      'reviewed_by': null,
      'reviewed_at': null,
    };

    final rows = await AppSupabase.client
        .from(_table)
        .update(updates)
        .eq('id', requestId)
        .eq('status', VerificationRequestStatus.pending.storageKey)
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Annullamento richiesta verifica fallito.');
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapRequest(row);
  }

  VerificationRequest _mapRequest(Map<String, dynamic> row) {
    return VerificationRequest(
      id: (row['id'] as String?) ?? '',
      userId: (row['user_id'] as String?) ?? '',
      requestType: VerificationRequestTypeX.fromStorageKey(
        row['request_type'] as String?,
      ),
      targetActorType: ActorTypeX.fromStorageKey(
        row['target_actor_type'] as String?,
      ),
      targetVerificationLevel: VerificationLevelX.fromStorageKey(
        row['target_verification_level'] as String?,
      ),
      targetInstitutionLevel: _readInstitutionLevel(
        row['target_institution_level'],
      ),
      officialTitle: row['official_title'] as String?,
      institutionName: row['institution_name'] as String?,
      status: VerificationRequestStatusX.fromStorageKey(
        row['status'] as String?,
      ),
      submittedAt: _parseDateTime(row['submitted_at']),
      reviewedAt: _parseNullableDateTime(row['reviewed_at']),
      reviewedBy: row['reviewed_by'] as String?,
      reviewNote: row['review_note'] as String?,
      createdAt: _parseDateTime(row['created_at']),
      updatedAt: _parseDateTime(row['updated_at']),
    );
  }

  InstitutionLevel? _readInstitutionLevel(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return InstitutionLevelX.fromStorageKey(value);
  }

  String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  DateTime? _parseNullableDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    return null;
  }

  DateTime _parseDateTime(dynamic value) {
    return _parseNullableDateTime(value) ?? DateTime.now();
  }
}
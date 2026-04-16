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
    final normalizedRequestId = requestId.trim();
    if (normalizedRequestId.isEmpty) {
      throw ArgumentError('Request id non valido.');
    }

    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('id', normalizedRequestId)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapRequest(row);
  }

  @override
  Future<VerificationRequest?> getPendingRequestForUser(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError('User id non valido.');
    }

    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('user_id', normalizedUserId)
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
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError('User id non valido.');
    }

    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('user_id', normalizedUserId)
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
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError('User id non valido.');
    }

    final existingPending = await getPendingRequestForUser(normalizedUserId);
    if (existingPending != null) {
      throw Exception('Esiste già una richiesta di verifica in corso.');
    }

    final payload = <String, dynamic>{
      'user_id': normalizedUserId,
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
    final normalizedRequestId = requestId.trim();
    final normalizedReviewedBy = reviewedBy.trim();
    final normalizedReviewNote = _normalizeNullable(reviewNote);

    if (normalizedRequestId.isEmpty) {
      throw ArgumentError('Request id non valido.');
    }

    if (normalizedReviewedBy.isEmpty) {
      throw ArgumentError('Reviewed by non valido.');
    }

    if (status == VerificationRequestStatus.pending ||
        status == VerificationRequestStatus.cancelled) {
      throw ArgumentError('Stato review non valido.');
    }

    final updates = <String, dynamic>{
      'status': status.storageKey,
      'reviewed_by': normalizedReviewedBy,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      'review_note': normalizedReviewNote,
    };

    final rows = await AppSupabase.client
        .from(_table)
        .update(updates)
        .eq('id', normalizedRequestId)
        .eq('status', VerificationRequestStatus.pending.storageKey)
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
    final normalizedRequestId = requestId.trim();
    if (normalizedRequestId.isEmpty) {
      throw ArgumentError('Request id non valido.');
    }

    final updates = <String, dynamic>{
      'status': VerificationRequestStatus.cancelled.storageKey,
      'reviewed_by': null,
      'reviewed_at': null,
      'review_note': null,
    };

    final rows = await AppSupabase.client
        .from(_table)
        .update(updates)
        .eq('id', normalizedRequestId)
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
      id: _readRequiredString(row, 'id'),
      userId: _readRequiredString(row, 'user_id'),
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
      officialTitle: _normalizeNullable(row['official_title'] as String?),
      institutionName: _normalizeNullable(row['institution_name'] as String?),
      status: VerificationRequestStatusX.fromStorageKey(
        row['status'] as String?,
      ),
      submittedAt: _parseRequiredDateTime(row['submitted_at'], 'submitted_at'),
      reviewedAt: _parseNullableDateTime(row['reviewed_at']),
      reviewedBy: _normalizeNullable(row['reviewed_by'] as String?),
      reviewNote: _normalizeNullable(row['review_note'] as String?),
      createdAt: _parseRequiredDateTime(row['created_at'], 'created_at'),
      updatedAt: _parseRequiredDateTime(row['updated_at'], 'updated_at'),
    );
  }

  String _readRequiredString(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw StateError('Campo obbligatorio mancante o non valido: $key');
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

  DateTime _parseRequiredDateTime(dynamic value, String fieldName) {
    final parsed = _parseNullableDateTime(value);
    if (parsed == null) {
      throw StateError('Campo datetime obbligatorio non valido: $fieldName');
    }
    return parsed;
  }
}
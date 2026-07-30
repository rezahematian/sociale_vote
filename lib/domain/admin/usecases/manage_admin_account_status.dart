import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class SuspendAdminAccount {
  final AdminRepository _repository;

  const SuspendAdminAccount(this._repository);

  Future<void> call({
    required String operationId,
    required String targetUserId,
    required DateTime suspendedUntil,
    required String reason,
  }) {
    final normalizedSuspendedUntil = suspendedUntil.toUtc();

    if (!normalizedSuspendedUntil.isAfter(DateTime.now().toUtc())) {
      throw ArgumentError.value(
        suspendedUntil,
        'suspendedUntil',
      );
    }

    return _repository.suspendAccount(
      operationId: _AdminAccountActionInput.normalizeUuid(
        operationId,
        name: 'operationId',
      ),
      targetUserId: _AdminAccountActionInput.normalizeUuid(
        targetUserId,
        name: 'targetUserId',
      ),
      suspendedUntil: normalizedSuspendedUntil,
      reason: _AdminAccountActionInput.normalizeReason(reason),
    );
  }
}

class ReactivateAdminAccount {
  final AdminRepository _repository;

  const ReactivateAdminAccount(this._repository);

  Future<void> call({
    required String operationId,
    required String targetUserId,
    required String reason,
  }) {
    return _repository.reactivateAccount(
      operationId: _AdminAccountActionInput.normalizeUuid(
        operationId,
        name: 'operationId',
      ),
      targetUserId: _AdminAccountActionInput.normalizeUuid(
        targetUserId,
        name: 'targetUserId',
      ),
      reason: _AdminAccountActionInput.normalizeReason(reason),
    );
  }
}

class _AdminAccountActionInput {
  static const int maximumReasonLength = 1000;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static String normalizeUuid(
    String value, {
    required String name,
  }) {
    final normalized = value.trim().toLowerCase();

    if (!_uuidPattern.hasMatch(normalized)) {
      throw ArgumentError.value(
        value,
        name,
      );
    }

    return normalized;
  }

  static String normalizeReason(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty || normalized.length > maximumReasonLength) {
      throw ArgumentError.value(
        value,
        'reason',
      );
    }

    return normalized;
  }
}

import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class DeleteAdminAccount {
  static const int maximumReasonLength = 1000;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  final AdminRepository _repository;

  const DeleteAdminAccount(this._repository);

  Future<void> call({
    required String operationId,
    required String targetUserId,
    required String reason,
    required String confirmation,
    required String accountIdentifier,
  }) {
    final normalizedOperationId = _normalizeUuid(
      operationId,
      name: 'operationId',
    );
    final normalizedTargetUserId = _normalizeUuid(
      targetUserId,
      name: 'targetUserId',
    );
    final normalizedReason = reason.trim();
    final normalizedAccountIdentifier = accountIdentifier.trim().toLowerCase();

    if (normalizedReason.isEmpty ||
        normalizedReason.length > maximumReasonLength) {
      throw ArgumentError.value(
        reason,
        'reason',
      );
    }

    if (confirmation != 'DELETE') {
      throw ArgumentError.value(
        confirmation,
        'confirmation',
      );
    }

    if (normalizedAccountIdentifier != normalizedTargetUserId) {
      throw ArgumentError.value(
        accountIdentifier,
        'accountIdentifier',
      );
    }

    return _repository.deleteAccount(
      operationId: normalizedOperationId,
      targetUserId: normalizedTargetUserId,
      reason: normalizedReason,
      confirmation: confirmation,
      accountIdentifier: normalizedAccountIdentifier,
    );
  }

  static String _normalizeUuid(
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
}

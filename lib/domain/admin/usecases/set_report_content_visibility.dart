import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class SetReportContentVisibility {
  static const int minimumReasonLength = 3;
  static const int maximumReasonLength = 2000;

  final AdminRepository _repository;

  const SetReportContentVisibility(this._repository);

  Future<void> call({
    required String reportId,
    required bool isHidden,
    required String reason,
  }) {
    final normalizedReportId = reportId.trim();
    final normalizedReason = reason.trim();

    if (normalizedReportId.isEmpty) {
      throw ArgumentError.value(
        reportId,
        'reportId',
        'Report ID is required.',
      );
    }

    if (normalizedReason.length < minimumReasonLength ||
        normalizedReason.length > maximumReasonLength) {
      throw ArgumentError.value(
        reason,
        'reason',
        'Reason must contain between $minimumReasonLength and '
            '$maximumReasonLength characters.',
      );
    }

    return _repository.setReportContentVisibility(
      reportId: normalizedReportId,
      isHidden: isHidden,
      reason: normalizedReason,
    );
  }
}

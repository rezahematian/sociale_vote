import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class RecordAdminReportDecision {
  static const int minimumReviewNoteLength = 3;
  static const int maximumReviewNoteLength = 2000;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  final AdminRepository _repository;

  const RecordAdminReportDecision(this._repository);

  Future<void> call({
    required String reportId,
    required AdminReportDecision decision,
    required String reviewNote,
  }) {
    if (decision == AdminReportDecision.unknown) {
      throw ArgumentError.value(
        decision,
        'decision',
      );
    }

    final normalizedReviewNote = reviewNote.trim();

    if (normalizedReviewNote.length < minimumReviewNoteLength ||
        normalizedReviewNote.length > maximumReviewNoteLength) {
      throw ArgumentError.value(
        reviewNote,
        'reviewNote',
      );
    }

    return _repository.recordReportDecision(
      reportId: _normalizeUuid(
        reportId,
        name: 'reportId',
      ),
      decision: decision,
      reviewNote: normalizedReviewNote,
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

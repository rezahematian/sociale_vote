import 'package:sociale_vote/domain/moderation/entities/report.dart';

enum SubmitReportResult {
  submitted,
  alreadyReported,
}

abstract class ModerationRepository {
  Future<SubmitReportResult> submitReport(Report report);
}
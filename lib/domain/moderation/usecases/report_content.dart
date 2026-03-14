import 'package:sociale_vote/domain/moderation/entities/report.dart';
import 'package:sociale_vote/domain/moderation/repositories/moderation_repository.dart';

class ReportContent {
  final ModerationRepository repository;

  const ReportContent(this.repository);

  Future<SubmitReportResult> call(Report report) {
    return repository.submitReport(report);
  }
}
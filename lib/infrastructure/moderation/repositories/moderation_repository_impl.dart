import 'package:sociale_vote/domain/moderation/entities/report.dart';
import 'package:sociale_vote/domain/moderation/repositories/moderation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModerationRepositoryImpl implements ModerationRepository {
  final SupabaseClient supabase;

  const ModerationRepositoryImpl(this.supabase);

  @override
  Future<SubmitReportResult> submitReport(Report report) async {
    final targetType = report.target.type.name;
    final targetId = report.target.id;
    final userId = report.userId;
    final reason = report.reason.trim();

    if (reason.isEmpty) {
      throw Exception('Reason cannot be empty');
    }

    final existing = await supabase
        .from('reports')
        .select('id')
        .eq('target_type', targetType)
        .eq('target_id', targetId)
        .eq('user_id', userId)
        .limit(1);

    if (existing.isNotEmpty) {
      return SubmitReportResult.alreadyReported;
    }

    try {
      await supabase.from('reports').insert({
        if (report.id != null) 'id': report.id,
        'target_type': targetType,
        'target_id': targetId,
        'user_id': userId,
        'reason': reason,
        'created_at': report.createdAt.toUtc().toIso8601String(),
      });

      return SubmitReportResult.submitted;
    } on PostgrestException catch (e) {
      final message = e.message.toLowerCase();
      final details = (e.details?.toString() ?? '').toLowerCase();

      final isDuplicate = message.contains('duplicate key') ||
          message.contains('unique constraint') ||
          details.contains('duplicate key') ||
          details.contains('unique constraint');

      if (isDuplicate) {
        return SubmitReportResult.alreadyReported;
      }

      rethrow;
    }
  }
}

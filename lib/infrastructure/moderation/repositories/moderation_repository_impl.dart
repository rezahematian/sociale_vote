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

  @override
  Future<bool> isUserBlocked({
    required String blockerUserId,
    required String blockedUserId,
  }) async {
    final blockerId = blockerUserId.trim();
    final blockedId = blockedUserId.trim();

    if (blockerId.isEmpty || blockedId.isEmpty || blockerId == blockedId) {
      return false;
    }

    final rows = await supabase
        .from('blocked_users')
        .select('blocked_user_id')
        .eq('blocker_user_id', blockerId)
        .eq('blocked_user_id', blockedId)
        .limit(1);

    return rows.isNotEmpty;
  }

  @override
  Future<void> blockUser({
    required String blockerUserId,
    required String blockedUserId,
  }) async {
    final blockerId = blockerUserId.trim();
    final blockedId = blockedUserId.trim();

    if (blockerId.isEmpty || blockedId.isEmpty) {
      throw ArgumentError('User ids cannot be empty.');
    }

    if (blockerId == blockedId) {
      throw ArgumentError('A user cannot block themselves.');
    }

    try {
      await supabase.from('blocked_users').insert({
        'blocker_user_id': blockerId,
        'blocked_user_id': blockedId,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> unblockUser({
    required String blockerUserId,
    required String blockedUserId,
  }) async {
    final blockerId = blockerUserId.trim();
    final blockedId = blockedUserId.trim();

    if (blockerId.isEmpty || blockedId.isEmpty || blockerId == blockedId) {
      return;
    }

    await supabase
        .from('blocked_users')
        .delete()
        .eq('blocker_user_id', blockerId)
        .eq('blocked_user_id', blockedId);
  }
}

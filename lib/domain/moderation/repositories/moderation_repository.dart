import 'package:sociale_vote/domain/moderation/entities/report.dart';

enum SubmitReportResult {
  submitted,
  alreadyReported,
}

abstract class ModerationRepository {
  Future<SubmitReportResult> submitReport(Report report);

  /// Verifica se l'utente autenticato ha bloccato [blockedUserId].
  Future<bool> isUserBlocked({
    required String blockerUserId,
    required String blockedUserId,
  });

  /// Blocca un altro utente.
  Future<void> blockUser({
    required String blockerUserId,
    required String blockedUserId,
  });

  /// Rimuove il blocco verso un altro utente.
  Future<void> unblockUser({
    required String blockerUserId,
    required String blockedUserId,
  });
}

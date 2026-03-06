import 'dart:convert';

import 'vote_audit_log.dart';
import 'package:sociale_vote/domain/poll/entities/vote.dart';

class VoteAuditService {
  static const String _unknownUserId = 'unknown';

  final List<VoteAuditLog> _logs = [];

  Future<void> logVote(Vote vote) async {
    final voteId = _buildClientVoteId(vote);

    final String optionId;
    if (vote.optionIds.isEmpty) {
      optionId = '';
    } else if (vote.optionIds.length == 1) {
      optionId = vote.optionIds.first;
    } else {
      optionId = 'multi';
    }

    final log = VoteAuditLog(
      voteId: voteId,
      pollId: vote.pollId.value,
      userId: _unknownUserId,
      optionId: optionId,
      timestamp: vote.createdAt,
      source: 'client',
    );

    _logs.add(log);

    // In futuro:
    // - invio a backend
    // - firma crittografica
    // - write-once storage
    // - userId reale (quando Vote includerà un identificatore o quando lo passiamo come parametro)
  }

  List<VoteAuditLog> get logs => List.unmodifiable(_logs);

  String _buildClientVoteId(Vote vote) {
    // Deterministico: stesso input -> stesso ID.
    // Nota: usando createdAt come parte dell'input, l'ID è stabile per quell'istanza di voto.
    // Usiamo un digest corto per evitare ID troppo lunghi.
    final payload = jsonEncode({
      'pollId': vote.pollId.value,
      'createdAt': vote.createdAt.toUtc().toIso8601String(),
      'optionIds': vote.optionIds,
    });

    final bytes = utf8.encode(payload);
    final digest = base64Url.encode(bytes);

    // Limitiamo la lunghezza mantenendo stabilità.
    final short = digest.length > 32 ? digest.substring(0, 32) : digest;

    return '${vote.pollId.value}::$short';
  }
}
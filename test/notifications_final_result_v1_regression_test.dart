import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vote submit path does not create poll_result per individual vote', () {
    final source = File(
      'lib/domain/poll/usecases/submit_vote_and_notify.dart',
    ).readAsStringSync();

    expect(source, contains('await _submitVote('));
    expect(source, isNot(contains('_createPollResultNotification')));
    expect(source, isNot(contains('createNotification(')));
  });

  test('final-result notification copy exists in all 11 locales', () {
    const expected = <String, List<String>>{
      'ar': ['النتيجة النهائية لـ Vote', 'النتيجة النهائية متاحة في {target}'],
      'de': [
        'Endergebnis der Vote',
        'Das Endergebnis ist in {target} verfügbar'
      ],
      'en': ['Final Vote result', 'The final result is available in {target}'],
      'es': [
        'Resultado final de Vote',
        'El resultado final está disponible en {target}'
      ],
      'fa': ['نتیجه نهایی Vote', 'نتیجه نهایی در {target} در دسترس است'],
      'fr': [
        'Résultat final du Vote',
        'Le résultat final est disponible dans {target}'
      ],
      'it': [
        'Risultato finale Vote',
        'Il risultato finale è disponibile in {target}'
      ],
      'pt': [
        'Resultado final da Vote',
        'O resultado final está disponível em {target}'
      ],
      'ro': [
        'Rezultatul final al Vote',
        'Rezultatul final este disponibil în {target}'
      ],
      'ru': [
        'Итоговый результат Vote',
        'Итоговый результат доступен в {target}'
      ],
      'zh': ['Vote 最终结果', '{target} 中已提供最终结果'],
    };

    for (final entry in expected.entries) {
      final raw = jsonDecode(
        File('lib/l10n/app_${entry.key}.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(raw['notificationsPollResultTitle'], entry.value[0]);
      expect(raw['notificationsPollResultSubtitle'], entry.value[1]);
    }
  });

  test('backend migration blocks per-vote writes and schedules final result',
      () {
    final sql = File(
      'supabase/migration/20260921090000_notifications_final_result_v1.sql',
    ).readAsStringSync();

    expect(sql, contains("'comment_reply'::text"));
    expect(sql, contains("'mention'::text"));
    expect(sql, contains('emit_due_poll_result_notifications_v1'));
    expect(sql, contains('poll-final-result-notifications-v1'));
    expect(sql, contains('notifications_poll_result_final_unique_v1'));
    expect(sql, contains("where type = 'poll_result';"));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/domain/poll/services/create_poll_timing_rules.dart';
import 'package:sociale_vote/features/poll/presentation/create_poll_form_messages.dart';

void main() {
  const languages = [
    'en',
    'it',
    'de',
    'fa',
    'es',
    'pt',
    'fr',
    'ar',
    'ro',
    'ru',
    'zh'
  ];
  const keys = [
    'intro',
    'stepQuestion',
    'stepAnswers',
    'stepParticipation',
    'stepPublication',
    'reviewButton',
    'reviewTitle',
    'reviewHint',
    'reviewCancel',
    'reviewConfirm',
    'reviewPublisher',
    'reviewPersonal',
    'reviewLocation',
    'reviewAnonymity',
    'reviewEnabled',
  ];

  test('V2 review and four-step guidance are truly localized in 11 languages',
      () {
    for (final language in languages) {
      for (final key in keys) {
        expect(CreatePollFormMessages.hasTranslation(language, key), isTrue,
            reason: '$language/$key should not silently fall back to English');
        expect(CreatePollFormMessages.of(language, key).trim(), isNotEmpty);
      }
    }
  });

  test('V2 keeps 31 inclusive calendar days unchanged', () {
    final start = DateTime(2026, 10, 13);
    expect(CreatePollTimingRules.lastAllowedEndDate(start),
        DateTime(2026, 11, 12));
    expect(
        CreatePollTimingRules.inclusiveDays(start, DateTime(2026, 11, 12)), 31);
    expect(CreatePollTimingRules.isOverLimit(start, DateTime(2026, 11, 12)),
        isFalse);
    expect(CreatePollTimingRules.isOverLimit(start, DateTime(2026, 11, 13)),
        isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/domain/poll/services/create_poll_timing_rules.dart';
import 'package:sociale_vote/features/poll/presentation/create_poll_form_messages.dart';

void main() {
  test('31 calendar days inclusive are allowed; day 32 is rejected', () {
    final start = DateTime(2026, 10, 1, 17, 45);
    expect(
        CreatePollTimingRules.inclusiveDays(start, DateTime(2026, 10, 31)), 31);
    expect(CreatePollTimingRules.isOverLimit(start, DateTime(2026, 10, 31)),
        isFalse);
    expect(CreatePollTimingRules.isOverLimit(start, DateTime(2026, 11, 1)),
        isTrue);
    expect(CreatePollTimingRules.lastAllowedEndDate(start),
        DateTime(2026, 10, 31));
  });

  test('short months and daylight savings do not change calendar count', () {
    expect(
        CreatePollTimingRules.inclusiveDays(
            DateTime(2027, 2, 1), DateTime(2027, 2, 28)),
        28);
    expect(
        CreatePollTimingRules.inclusiveDays(
            DateTime(2026, 10, 12), DateTime(2026, 11, 11)),
        31);
    expect(
        CreatePollTimingRules.isOverLimit(
            DateTime(2026, 10, 12), DateTime(2026, 11, 12)),
        isTrue);
  });

  test('required guidance is present in all 11 supported languages', () {
    for (final language in [
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
    ]) {
      for (final key in [
        'status',
        'ready',
        'max31',
        'startMissing',
        'endMissing',
        'titleMissing',
        'optionsMissing',
        'invalid',
        'tooLong',
        'selectionInvalid',
        'countryMissing',
        'firstStart',
        'wholeDays',
        'endRange'
      ]) {
        final message = CreatePollFormMessages.of(language, key);
        expect(message, isNotEmpty, reason: '$language/$key');
        expect(message, isNot(key), reason: '$language/$key');
      }
      expect(CreatePollFormMessages.of(language, 'duration', days: 31),
          contains('31'));
    }
  });
}

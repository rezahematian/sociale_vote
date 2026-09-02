import 'package:flutter/widgets.dart';

const String antiAbuseRateLimitCode = 'anti_abuse_rate_limit';

bool isAntiAbuseRateLimitError(Object error) {
  final raw = error.toString().toLowerCase();
  return raw.contains('54000') ||
      raw.contains('rate_limit=') ||
      raw.contains('too many actions') ||
      raw.contains('action limit reached') ||
      raw.contains('too many participant joins');
}

String antiAbuseRateLimitMessage(BuildContext context) {
  return antiAbuseRateLimitMessageForLanguageCode(
    Localizations.localeOf(context).languageCode,
  );
}

String antiAbuseRateLimitMessageForLanguageCode(String languageCode) {
  switch (languageCode.toLowerCase()) {
    case 'it':
      return 'Hai effettuato troppe azioni in poco tempo. Attendi un po’ e riprova.';
    case 'de':
      return 'Du hast in kurzer Zeit zu viele Aktionen ausgeführt. Bitte warte kurz und versuche es erneut.';
    case 'fa':
      return 'در مدت کوتاهی اقدامات زیادی انجام داده‌اید. کمی صبر کنید و دوباره تلاش کنید.';
    default:
      return 'You’ve made too many actions in a short time. Please wait a little and try again.';
  }
}

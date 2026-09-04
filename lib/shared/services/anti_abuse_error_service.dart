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
    case 'es':
      return 'Has realizado demasiadas acciones en poco tiempo. Espera un momento y vuelve a intentarlo.';
    case 'pt':
      return 'Você realizou ações demais em pouco tempo. Aguarde um pouco e tente novamente.';
    case 'fr':
      return 'Vous avez effectué trop d’actions en peu de temps. Attendez un moment puis réessayez.';
    case 'ar':
      return 'لقد أجريت عددًا كبيرًا من الإجراءات خلال وقت قصير. انتظر قليلًا ثم حاول مرة أخرى.';
    case 'ro':
      return 'Ai efectuat prea multe acțiuni într-un timp scurt. Așteaptă puțin și încearcă din nou.';
    case 'ru':
      return 'Вы выполнили слишком много действий за короткое время. Немного подождите и попробуйте снова.';
    case 'zh':
      return '你在短时间内执行了过多操作。请稍等片刻后重试。';
    default:
      return 'You’ve made too many actions in a short time. Please wait a little and try again.';
  }
}

/// Process-local mirror of the language explicitly selected inside Social Vote.
///
/// `null` means System. News AUTO uses this value first and only reads the
/// platform locale when the app itself is in System mode.
class AppLanguageState {
  AppLanguageState._();

  static String? selectedLanguageCode;
}

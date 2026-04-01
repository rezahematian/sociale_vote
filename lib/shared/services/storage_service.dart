import 'package:sociale_vote/core/storage/key_value_storage.dart';

/// Servizio centrale per accesso semplice allo storage locale.
///
/// Obiettivo:
/// - evitare chiamate sparse dirette allo storage
/// - avere un punto unico per chiavi comuni e helper futuri
class StorageService {
  static const String contentLanguagePreferenceKey =
      'content_language_preference';
  static const String rememberMeKey = 'remember_me';

  final KeyValueStorage _storage;

  const StorageService(this._storage);

  Future<void> writeString(String key, String value) {
    return _storage.writeString(key, value);
  }

  Future<String?> readString(String key) {
    return _storage.readString(key);
  }

  Future<void> writeBool(String key, bool value) {
    return _storage.writeBool(key, value);
  }

  Future<bool?> readBool(String key) {
    return _storage.readBool(key);
  }

  Future<void> writeInt(String key, int value) {
    return _storage.writeInt(key, value);
  }

  Future<int?> readInt(String key) {
    return _storage.readInt(key);
  }

  Future<void> writeContentLanguagePreference(String value) {
    return writeString(contentLanguagePreferenceKey, value);
  }

  Future<String?> readContentLanguagePreference() {
    return readString(contentLanguagePreferenceKey);
  }

  Future<void> clearContentLanguagePreference() {
    return remove(contentLanguagePreferenceKey);
  }

  Future<void> writeRememberMe(bool value) {
    return writeBool(rememberMeKey, value);
  }

  Future<bool> readRememberMe() async {
    return await readBool(rememberMeKey) ?? false;
  }

  Future<void> clearRememberMe() {
    return remove(rememberMeKey);
  }

  Future<void> remove(String key) {
    return _storage.remove(key);
  }

  Future<void> clearAll() {
    return _storage.clear();
  }
}
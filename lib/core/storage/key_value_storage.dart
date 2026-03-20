import 'package:shared_preferences/shared_preferences.dart';

/// Contratto minimo per accesso key-value locale.
///
/// Serve per evitare dipendenze sparse dirette da SharedPreferences
/// nei layer più alti dell'app.
abstract class KeyValueStorage {
  Future<void> writeString(String key, String value);
  Future<String?> readString(String key);

  Future<void> writeBool(String key, bool value);
  Future<bool?> readBool(String key);

  Future<void> writeInt(String key, int value);
  Future<int?> readInt(String key);

  Future<void> remove(String key);
  Future<void> clear();
}

/// Implementazione locale basata su SharedPreferences.
class SharedPreferencesKeyValueStorage implements KeyValueStorage {
  const SharedPreferencesKeyValueStorage();

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  @override
  Future<void> writeString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  @override
  Future<String?> readString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  @override
  Future<bool?> readBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }

  @override
  Future<void> writeInt(String key, int value) async {
    final prefs = await _prefs;
    await prefs.setInt(key, value);
  }

  @override
  Future<int?> readInt(String key) async {
    final prefs = await _prefs;
    return prefs.getInt(key);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
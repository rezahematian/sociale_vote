import 'package:supabase_flutter/supabase_flutter.dart';

/// Accesso centralizzato al client Supabase dell'app.
///
/// Nota:
/// Supabase deve essere inizializzato in `main.dart` prima di usare questo file.
class AppSupabase {
  AppSupabase._();

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static Session? get currentSession => auth.currentSession;

  static User? get currentUser => auth.currentUser;
}
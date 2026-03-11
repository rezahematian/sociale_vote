import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';

/// API auth minima basata su Supabase Auth.
///
/// Responsabilità:
/// - login email/password
/// - register email/password
/// - lettura sessione corrente
/// - logout
///
/// Nota importante:
/// se in Supabase hai la conferma email attiva, `register()` potrebbe
/// non restituire subito una sessione valida. In quel caso questo file
/// lancia un errore esplicito, così in questa fase MVP il comportamento
/// resta chiaro e prevedibile.
class AuthApi {
  const AuthApi();

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await AppSupabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final session = response.session;
    final user = response.user;

    if (session == null || user == null) {
      throw Exception('Login fallito: sessione non disponibile.');
    }

    return _mapToAuthSession(
      session: session,
      user: user,
    );
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await AppSupabase.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{
        'display_name': displayName,
      },
    );

    final session = response.session;
    final user = response.user;

    if (user == null) {
      throw Exception('Registrazione fallita: utente non creato.');
    }

    if (session == null) {
      throw Exception(
        'Registrazione completata ma sessione non disponibile. '
        'Controlla se la conferma email è attiva in Supabase.',
      );
    }

    return _mapToAuthSession(
      session: session,
      user: user,
    );
  }

  Future<AuthSession?> getCurrentSession() async {
    final session = AppSupabase.currentSession;
    final user = AppSupabase.currentUser;

    if (session == null || user == null) {
      return null;
    }

    return _mapToAuthSession(
      session: session,
      user: user,
    );
  }

  Future<void> logout() async {
    await AppSupabase.auth.signOut();
  }

  AuthSession _mapToAuthSession({
    required Session session,
    required User user,
  }) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};

    return AuthSession(
      userId: user.id,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      email: user.email,
      displayName: _readDisplayName(metadata),
    );
  }

  String? _readDisplayName(Map<String, dynamic> metadata) {
    final value = metadata['display_name'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }
}
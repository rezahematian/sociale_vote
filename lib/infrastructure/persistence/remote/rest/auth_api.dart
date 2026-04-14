import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';

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

    await _upsertUserProfile(user);

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

    await _upsertUserProfile(user);

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

    await _upsertUserProfile(user);

    return _mapToAuthSession(
      session: session,
      user: user,
    );
  }

  Future<void> sendPasswordResetEmail({
    required String email,
    required String redirectTo,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedRedirectTo = redirectTo.trim();

    if (normalizedEmail.isEmpty) {
      throw ArgumentError('Email reset non valida.');
    }

    if (normalizedRedirectTo.isEmpty) {
      throw ArgumentError('Redirect reset password mancante.');
    }

    final redirectUri = Uri.tryParse(normalizedRedirectTo);
    if (redirectUri == null || !redirectUri.hasScheme) {
      throw ArgumentError('Redirect reset password non valido.');
    }

    await AppSupabase.auth.resetPasswordForEmail(
      normalizedEmail,
      redirectTo: normalizedRedirectTo,
    );
  }

  Future<void> updatePassword({
    required String newPassword,
  }) async {
    await AppSupabase.auth.updateUser(
      UserAttributes(
        password: newPassword,
      ),
    );
  }

  Future<void> logout() async {
    await AppSupabase.auth.signOut();
  }

  Future<void> _upsertUserProfile(User user) async {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final displayName = _readDisplayName(metadata);
    final role = _readRole(metadata);

    await Supabase.instance.client.from('users').upsert(
      <String, dynamic>{
        'id': user.id,
        'email': user.email,
        'display_name': displayName,
        'role': role.storageKey,
      },
      onConflict: 'id',
    );
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
      role: _readRole(metadata),
    );
  }

  String? _readDisplayName(Map<String, dynamic> metadata) {
    final value = metadata['display_name'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  Role _readRole(Map<String, dynamic> metadata) {
    final raw = metadata['role'];
    if (raw is String && raw.trim().isNotEmpty) {
      return RoleX.fromStorageKey(raw);
    }
    return Role.user;
  }
}
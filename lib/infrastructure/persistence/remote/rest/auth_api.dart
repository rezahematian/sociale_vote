import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';

class EmailConfirmationRequiredException implements Exception {
  final String email;

  const EmailConfirmationRequiredException(this.email);

  @override
  String toString() {
    return 'Email confirmation required for $email.';
  }
}

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
    required String username,
    required String country,
    required String city,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedDisplayName = displayName.trim();
    final normalizedUsername = _normalizeUsername(username);
    final normalizedCountry = country.trim();
    final normalizedCity = city.trim();

    final response = await AppSupabase.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: <String, dynamic>{
        'display_name': normalizedDisplayName,
        'username': normalizedUsername,
        'country': normalizedCountry,
        'city': normalizedCity,
      },
    );

    final session = response.session;
    final user = response.user;

    if (user == null) {
      throw Exception('Registrazione fallita: utente non creato.');
    }

    if (session == null) {
      throw EmailConfirmationRequiredException(
        user.email ?? normalizedEmail,
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
    final userMetadata = user.userMetadata ?? const <String, dynamic>{};
    final appMetadata = user.appMetadata;
    final displayName = _readDisplayName(userMetadata);
    final username = _readUsername(userMetadata);
    final country = _readOptionalString(userMetadata, 'country');
    final city = _readOptionalString(userMetadata, 'city');
    final role = _readRole(appMetadata);

    await Supabase.instance.client.from('users').upsert(
      <String, dynamic>{
        'id': user.id,
        'email': user.email,
        'display_name': displayName,
        'role': role.storageKey,
      },
      onConflict: 'id',
    );

    final existingRows = await AppSupabase.client
        .from('user_profiles')
        .select('id, display_name, username, country, city')
        .eq('id', user.id)
        .limit(1);

    final now = DateTime.now().toUtc().toIso8601String();

    if (existingRows.isEmpty) {
      await AppSupabase.client.from('user_profiles').insert(
        <String, dynamic>{
          'id': user.id,
          'display_name': displayName,
          'username': username,
          'avatar_url': null,
          'bio': null,
          'country': country,
          'city': city,
          'actor_type': 'citizen',
          'verification_level': 'none',
          'institution_level': null,
          'verification_status': 'none',
          'verification_requested_at': null,
          'verified_at': null,
          'official_title': null,
          'institution_name': null,
          'account_type': 'citizen',
          'is_verified': false,
          'created_at': now,
          'updated_at': now,
        },
      );
      return;
    }

    final existing = existingRows.first;
    final updates = <String, dynamic>{};

    if (_isMissing(existing['display_name']) && displayName != null) {
      updates['display_name'] = displayName;
    }
    if (_isMissing(existing['username']) && username != null) {
      updates['username'] = username;
    }
    if (_isMissing(existing['country']) && country != null) {
      updates['country'] = country;
    }
    if (_isMissing(existing['city']) && city != null) {
      updates['city'] = city;
    }

    if (updates.isEmpty) {
      return;
    }

    updates['updated_at'] = now;

    await AppSupabase.client
        .from('user_profiles')
        .update(updates)
        .eq('id', user.id);
  }

  AuthSession _mapToAuthSession({
    required Session session,
    required User user,
  }) {
    final userMetadata = user.userMetadata ?? const <String, dynamic>{};
    final appMetadata = user.appMetadata;

    return AuthSession(
      userId: user.id,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      email: user.email,
      displayName: _readDisplayName(userMetadata),
      role: _readRole(appMetadata),
    );
  }

  String? _readDisplayName(Map<String, dynamic> metadata) {
    return _readOptionalString(metadata, 'display_name');
  }

  String? _readUsername(Map<String, dynamic> metadata) {
    final value = _readOptionalString(metadata, 'username');
    if (value == null) {
      return null;
    }
    return _normalizeUsername(value);
  }

  String? _readOptionalString(
    Map<String, dynamic> metadata,
    String key,
  ) {
    final value = metadata[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  String _normalizeUsername(String value) {
    var normalized = value.trim().toLowerCase();
    if (normalized.startsWith('@')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  bool _isMissing(dynamic value) {
    return value == null || value is String && value.trim().isEmpty;
  }

  Role _readRole(Map<String, dynamic> appMetadata) {
    final raw = appMetadata['role'];
    if (raw is String && raw.trim().isNotEmpty) {
      return RoleX.fromStorageKey(raw);
    }
    return Role.user;
  }
}

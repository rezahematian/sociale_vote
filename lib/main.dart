import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/firebase_options.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/auth_api.dart';
import 'package:sociale_vote/shared/services/storage_service.dart';

const _supabaseUrl = 'https://rbuzlrclwhxaigkgndrb.supabase.co';
const _supabasePersistSessionKey = 'sb-rbuzlrclwhxaigkgndrb-auth-token';

class _RememberMeLocalStorage extends LocalStorage {
  _RememberMeLocalStorage()
      : _delegate = SharedPreferencesLocalStorage(
          persistSessionKey: _supabasePersistSessionKey,
        );

  final SharedPreferencesLocalStorage _delegate;

  Future<bool> _shouldPersist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageService.rememberMeKey) ?? false;
  }

  @override
  Future<void> initialize() {
    return _delegate.initialize();
  }

  @override
  Future<String?> accessToken() async {
    if (!await _shouldPersist()) {
      await _delegate.removePersistedSession();
      return null;
    }

    return _delegate.accessToken();
  }

  @override
  Future<bool> hasAccessToken() async {
    if (!await _shouldPersist()) {
      await _delegate.removePersistedSession();
      return false;
    }

    return _delegate.hasAccessToken();
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    if (!await _shouldPersist()) {
      await _delegate.removePersistedSession();
      return;
    }

    await _delegate.persistSession(persistSessionString);
  }

  @override
  Future<void> removePersistedSession() {
    return _delegate.removePersistedSession();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capture the startup URL before Supabase processes and potentially
  // clears the authentication parameters from the browser address.
  final startupUri = Uri.base;
  final isPasswordRecoveryStartup = _hasPasswordRecoverySignal(startupUri);

  final shouldInitFirebase = kIsWeb || !Platform.isWindows;

  if (shouldInitFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Analytics remains disabled until Social Vote provides an explicit
    // consent flow. Firebase Core stays available for the configured targets.
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  }

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJidXpscmNsd2h4YWlna2duZHJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNDY3MzYsImV4cCI6MjA4ODgyMjczNn0.dHNA8s3NcqnluakSb-NFnb2jNgCcaVm3Ix24LbbIpHI',
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
      localStorage: _RememberMeLocalStorage(),
    ),
  );

  await _restoreStartupAuthSession(
    preserveRecoverySession: isPasswordRecoveryStartup,
  );

  runApp(
    ChangeNotifierProvider<GeoScopeController>.value(
      value: AppDI.instance.geoScopeController,
      child: const SocialeVoteApp(),
    ),
  );
}

bool _hasPasswordRecoverySignal(Uri uri) {
  final raw = uri.toString().toLowerCase();
  final fragment = uri.fragment.toLowerCase();

  if (raw.contains('type=recovery') || fragment.contains('type=recovery')) {
    return true;
  }

  return uri.queryParameters.containsKey('code');
}

Future<void> _restoreStartupAuthSession({
  required bool preserveRecoverySession,
}) async {
  final storageService = AppDI.instance.storageService;
  final sessionRepository = AppDI.instance.sessionRepository;
  const authApi = AuthApi();
  final rememberMe = await storageService.readRememberMe();

  // A password-recovery link creates a temporary authenticated session.
  // Do not destroy it only because Remember me is disabled.
  if (!rememberMe && !preserveRecoverySession) {
    try {
      await authApi.logout();
    } catch (_) {
      // The app must still start unauthenticated even if the remote sign-out
      // request cannot be completed. Supabase clears its local session during
      // sign-out, while the app session is cleared explicitly below.
    }

    await sessionRepository.clearSession();
    return;
  }

  try {
    final existingSession = await authApi.getCurrentSession();

    if (existingSession == null) {
      await sessionRepository.clearSession();
      return;
    }

    await sessionRepository.saveSession(existingSession);
  } catch (_) {
    // A stale, invalid or temporarily unavailable remembered session must
    // never block app startup.
    await sessionRepository.clearSession();
  }
}

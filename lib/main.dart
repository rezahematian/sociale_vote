import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/firebase_options.dart';
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

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Web keeps its existing Firebase-before-app bootstrap. On native,
  // Firebase is not needed for routing/auth startup and Analytics is already
  // disabled by AndroidManifest metadata, so do not hold the first Flutter
  // frame behind Firebase platform initialization.
  if (kIsWeb) {
    await _initializeFirebaseIfSupported();
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

  await _restoreStartupAuthSessionLocally();

  runApp(
    ChangeNotifierProvider<GeoScopeController>.value(
      value: AppDI.instance.geoScopeController,
      child: const SocialeVoteApp(),
    ),
  );

  if (!kIsWeb) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Keep Firebase away from the critical first-paint window. Android
      // Analytics collection is already disabled natively before Flutter.
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        unawaited(_initializeFirebaseIfSupported());
      });
    });
  }
}

Future<void> _initializeFirebaseIfSupported() async {
  final shouldInitFirebase = kIsWeb || !Platform.isWindows;
  if (!shouldInitFirebase) {
    return;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Analytics remains disabled until Social Vote provides an explicit
    // consent flow. Android also enforces this from native startup metadata.
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  } catch (_) {
    // Firebase/Analytics is non-critical for Social Vote startup.
  }
}

/// Restores only the app's in-memory session before the first Flutter frame.
///
/// Important: startup must not wait for Supabase network calls. The custom
/// LocalStorage above already decides whether a persisted Supabase session is
/// allowed to survive when Remember me is disabled. Backend/profile sync and
/// active-session validation remain handled by the existing auth flow/guards
/// after the UI is available.
Future<void> _restoreStartupAuthSessionLocally() async {
  final storageService = AppDI.instance.storageService;
  final sessionRepository = AppDI.instance.sessionRepository;
  final rememberMe = await storageService.readRememberMe();

  if (!rememberMe) {
    await sessionRepository.clearSession();
    return;
  }

  final supabaseSession = Supabase.instance.client.auth.currentSession;
  if (supabaseSession == null) {
    await sessionRepository.clearSession();
    return;
  }

  final user = supabaseSession.user;
  final userMetadata = user.userMetadata ?? const <String, dynamic>{};
  final appMetadata = user.appMetadata;

  final rawDisplayName = userMetadata['display_name'];
  final displayName =
      rawDisplayName is String && rawDisplayName.trim().isNotEmpty
          ? rawDisplayName.trim()
          : null;

  final rawRole = appMetadata['role'];

  await sessionRepository.saveSession(
    AuthSession(
      userId: user.id,
      accessToken: supabaseSession.accessToken,
      refreshToken: supabaseSession.refreshToken,
      email: user.email,
      displayName: displayName,
      role: RoleX.fromStorageKey(rawRole is String ? rawRole : null),
    ),
  );
}

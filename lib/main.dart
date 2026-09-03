import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
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
import 'package:sociale_vote/shared/services/current_location_uri.dart';
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
    // Capture the QR URL before PathUrlStrategy can normalize browser state.
    // The participant page consumes this initial URI once to recover an
    // Access Pass carried in the URL fragment.
    captureCurrentLocationUriForBootstrap();
    usePathUrlStrategy();

    // Preserve the approved Web bootstrap. The native startup path below is
    // intentionally isolated so the Web URL/deep-link behaviour cannot
    // regress while Android startup is optimized.
    await _initializeFirebaseIfSupported();
    await _initializeSupabase();
    await _restoreStartupAuthSessionLocally();
    runApp(_buildSocialeVoteApp());
    return;
  }

  // Render a Flutter frame immediately on native. Supabase/session recovery
  // continues behind a lightweight app-owned startup surface instead of
  // extending the Android launch screen for several seconds.
  runApp(const _NativeStartupBootstrap());
}

Future<void> _initializeSupabase() async {
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJidXpscmNsd2h4YWlna2duZHJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNDY3MzYsImV4cCI6MjA4ODgyMjczNn0.dHNA8s3NcqnluakSb-NFnb2jNgCcaVm3Ix24LbbIpHI',
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
      localStorage: _RememberMeLocalStorage(),
    ),
  );
}

Widget _buildSocialeVoteApp() {
  return ChangeNotifierProvider<GeoScopeController>.value(
    value: AppDI.instance.geoScopeController,
    child: const SocialeVoteApp(),
  );
}

class _NativeStartupBootstrap extends StatefulWidget {
  const _NativeStartupBootstrap();

  @override
  State<_NativeStartupBootstrap> createState() =>
      _NativeStartupBootstrapState();
}

class _NativeStartupBootstrapState extends State<_NativeStartupBootstrap> {
  bool _supabaseInitialized = false;
  bool _isInitializing = false;
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    if (_isInitializing || _isReady) {
      return;
    }

    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      if (!_supabaseInitialized) {
        await _initializeSupabase();
        _supabaseInitialized = true;
      }

      await _restoreStartupAuthSessionLocally();

      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _isReady = true;
      });

      _scheduleNonCriticalNativeStartup();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Native startup initialization failed: $error');
        debugPrint('$stackTrace');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _hasError = true;
      });
    }
  }

  void _scheduleNonCriticalNativeStartup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        unawaited(_initializeFirebaseIfSupported());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return _buildSocialeVoteApp();
    }

    final startupLanguageCode =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    final startupErrorText = switch (startupLanguageCode) {
      'it' => 'Impossibile avviare Social Vote.',
      'de' => 'Social Vote konnte nicht gestartet werden.',
      'fa' => 'راه‌اندازی Social Vote ممکن نشد.',
      'es' => 'No se pudo iniciar Social Vote.',
      'pt' => 'Não foi possível iniciar o Social Vote.',
      'fr' => 'Impossible de démarrer Social Vote.',
      'ar' => 'تعذر تشغيل Social Vote.',
      'ro' => 'Social Vote nu a putut fi pornit.',
      _ => 'Unable to start Social Vote.',
    };
    final startupRetryText = switch (startupLanguageCode) {
      'it' => 'Riprova',
      'de' => 'Erneut versuchen',
      'fa' => 'تلاش دوباره',
      'es' => 'Reintentar',
      'pt' => 'Tentar novamente',
      'fr' => 'Réessayer',
      'ar' => 'إعادة المحاولة',
      'ro' => 'Încearcă din nou',
      _ => 'Retry',
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.how_to_vote_rounded,
                    size: 64,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Social Vote',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_hasError) ...[
                    Text(
                      startupErrorText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _isInitializing ? null : _initialize,
                      child: Text(startupRetryText),
                    ),
                  ] else
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(strokeWidth: 2.6),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

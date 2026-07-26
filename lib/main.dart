import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/firebase_options.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/auth_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final shouldInitFirebase = kIsWeb || !Platform.isWindows;

  if (shouldInitFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await Supabase.initialize(
    url: 'https://rbuzlrclwhxaigkgndrb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJidXpscmNsd2h4YWlna2duZHJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNDY3MzYsImV4cCI6MjA4ODgyMjczNn0.dHNA8s3NcqnluakSb-NFnb2jNgCcaVm3Ix24LbbIpHI',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  await _restoreStartupAuthSession();

  runApp(
    ChangeNotifierProvider<GeoScopeController>.value(
      value: AppDI.instance.geoScopeController,
      child: const SocialeVoteApp(),
    ),
  );
}

Future<void> _restoreStartupAuthSession() async {
  final storageService = AppDI.instance.storageService;
  final sessionRepository = AppDI.instance.sessionRepository;
  const authApi = AuthApi();
  final rememberMe = await storageService.readRememberMe();

  if (!rememberMe) {
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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Autenticazione biometrica esclusivamente locale.
///
/// Non crea sessioni, non sostituisce password/Supabase e non modifica
/// autorizzazioni server-side.
class BiometricUnlockService {
  BiometricUnlockService({
    LocalAuthentication? localAuthentication,
  }) : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  bool get isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  Future<bool> canUseBiometrics() async {
    if (!isSupportedPlatform) {
      return false;
    }

    try {
      final supported = await _localAuthentication.isDeviceSupported();
      if (!supported) {
        return false;
      }

      return await _localAuthentication.canCheckBiometrics;
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate({
    required String localizedReason,
  }) async {
    if (!isSupportedPlatform) {
      return false;
    }

    try {
      return await _localAuthentication.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> cancelAuthentication() async {
    if (!isSupportedPlatform) {
      return;
    }

    try {
      await _localAuthentication.stopAuthentication();
    } catch (_) {
      // Best effort only.
    }
  }
}

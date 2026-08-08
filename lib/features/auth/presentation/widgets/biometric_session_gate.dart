import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/biometric_unlock_service.dart';
import 'package:sociale_vote/shared/services/navigation_service.dart';

class BiometricSessionGate extends StatefulWidget {
  final Widget child;
  final bool skipLock;

  const BiometricSessionGate({
    super.key,
    required this.child,
    this.skipLock = false,
  });

  @override
  State<BiometricSessionGate> createState() => _BiometricSessionGateState();
}

class _BiometricSessionGateState extends State<BiometricSessionGate> {
  final BiometricUnlockService _biometricService = BiometricUnlockService();

  bool _loading = true;
  bool _locked = false;
  bool _authenticating = false;
  bool _attemptedAutomaticUnlock = false;
  bool _unlockFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLockState());
  }

  Future<void> _loadLockState() async {
    if (widget.skipLock) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _locked = false;
      });
      return;
    }

    final storage = AppDI.instance.storageService;

    try {
      final rememberMe = await storage.readRememberMe();
      final biometricEnabled = await storage.readBiometricUnlockEnabled();
      final hasRestoredSession = AppDI.instance.currentUserId != null;

      final shouldLock = rememberMe && biometricEnabled && hasRestoredSession;

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _locked = shouldLock;
      });

      if (shouldLock && !_attemptedAutomaticUnlock) {
        _attemptedAutomaticUnlock = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            unawaited(_authenticate());
          }
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      // A failure while reading a local preference must not block the app.
      setState(() {
        _loading = false;
        _locked = false;
      });
    }
  }

  Future<void> _authenticate() async {
    if (_authenticating || !_locked) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _authenticating = true;
      _unlockFailed = false;
    });

    final authenticated = await _biometricService.authenticate(
      localizedReason: l10n.biometricUnlockReason,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _authenticating = false;
      _locked = !authenticated;
      _unlockFailed = !authenticated;
    });
  }

  Future<void> _usePassword() async {
    if (_authenticating) {
      return;
    }

    setState(() {
      _authenticating = true;
    });

    await _biometricService.cancelAuthentication();

    try {
      await AppDI.instance.logoutCurrentUser();
    } catch (_) {
      // The local application session is cleared by logoutCurrentUser's
      // finally block even if the remote logout fails.
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _authenticating = false;
      _locked = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = NavigationService.navigatorKey.currentState;
      if (navigator == null) {
        return;
      }

      navigator.pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    unawaited(_biometricService.cancelAuthentication());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_locked) {
      return widget.child;
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint_rounded,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    l10n.biometricLockTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.biometricLockMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (_unlockFailed) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.biometricUnlockFailedMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _authenticating ? null : _authenticate,
                      icon: _authenticating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.fingerprint_rounded),
                      label: Text(l10n.biometricUnlockButton),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _authenticating ? null : _usePassword,
                      child: Text(
                        l10n.biometricUsePasswordButton,
                      ),
                    ),
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/auth/application/auth_controller.dart';
import 'package:sociale_vote/features/auth/presentation/pages/register_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isResettingPassword = false;
  bool _rememberMe = false;
  bool _lastActionWasPasswordReset = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final value = await AppDI.instance.storageService.readRememberMe();
    if (!mounted) {
      return;
    }

    setState(() {
      _rememberMe = value;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  String _buildPasswordResetRedirectTo() {
    if (kIsWeb) {
      return Uri.base.origin;
    }

    return 'socialevote://reset-password';
  }

  bool _validateInputs(AppLocalizations l10n) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    String? emailError;
    String? passwordError;

    if (email.isEmpty) {
      emailError = l10n.authEmailRequiredError;
    } else if (!_isValidEmail(email)) {
      emailError = l10n.authEmailInvalidError;
    }

    if (password.isEmpty) {
      passwordError = l10n.authPasswordRequiredError;
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return emailError == null && passwordError == null;
  }

  void _clearControllerError(BuildContext context) {
    final controller = context.read<AuthController>();
    if (controller.errorMessage != null) {
      controller.clearError();
    }
  }

  String _localizedControllerError(
    AppLocalizations l10n,
    String rawMessage,
  ) {
    final normalized = rawMessage.trim().toLowerCase();

    if (normalized.contains('invalid login credentials') ||
        normalized.contains('invalid credentials') ||
        normalized.contains('email or password not valid')) {
      return l10n.authInvalidCredentialsError;
    }

    if (normalized.contains('invalid email') ||
        normalized.contains('email_address_invalid') ||
        normalized.contains('email address') &&
            normalized.contains('invalid')) {
      return l10n.authEmailInvalidError;
    }

    if (normalized.contains('email not confirmed')) {
      return l10n.authEmailNotConfirmedError;
    }

    if (normalized.contains('too many') || normalized.contains('rate limit')) {
      return l10n.authTooManyAttemptsError;
    }

    if (normalized.contains('network') ||
        normalized.contains('socket') ||
        normalized.contains('timeout') ||
        normalized.contains('timed out') ||
        normalized.contains('failed host lookup') ||
        normalized.contains('failed to fetch')) {
      return l10n.authNetworkError;
    }

    if (_lastActionWasPasswordReset || normalized.contains('password reset')) {
      return l10n.authPasswordResetGenericError;
    }

    return l10n.authLoginGenericError;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isBusy = _isSubmitting || _isResettingPassword;
    final controllerError = controller.errorMessage;

    return AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authLoginHeadline,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            enabled: !isBusy,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [
              AutofillHints.username,
              AutofillHints.email,
            ],
            onTap: () => _clearControllerError(context),
            onChanged: (_) {
              _clearControllerError(context);
              if (_emailError != null) {
                setState(() {
                  _emailError = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: l10n.authEmailLabel,
              border: const OutlineInputBorder(),
              errorText: _emailError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            enabled: !isBusy,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onTap: () => _clearControllerError(context),
            onChanged: (_) {
              _clearControllerError(context);
              if (_passwordError != null) {
                setState(() {
                  _passwordError = null;
                });
              }
            },
            onSubmitted: (_) {
              if (!isBusy) {
                _submit(context);
              }
            },
            decoration: InputDecoration(
              labelText: l10n.authPasswordLabel,
              border: const OutlineInputBorder(),
              errorText: _passwordError,
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? l10n.authShowPasswordTooltip
                    : l10n.authHidePasswordTooltip,
                onPressed: isBusy
                    ? null
                    : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final rememberControl = InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: isBusy
                    ? null
                    : () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: isBusy
                            ? null
                            : (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                      ),
                      Flexible(
                        child: Text(l10n.authRememberMeLabel),
                      ),
                    ],
                  ),
                ),
              );

              final forgotPasswordControl = TextButton(
                onPressed: isBusy ? null : () => _forgotPassword(context),
                child: Text(l10n.authForgotPasswordAction),
              );

              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: rememberControl,
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: forgotPasswordControl,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: rememberControl),
                  forgotPasswordControl,
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          if (controllerError != null) ...[
            Text(
              _localizedControllerError(l10n, controllerError),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isBusy ? null : () => _submit(context),
              child: isBusy
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(l10n.authLoginButton),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isBusy
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
            child: Text(
              '${l10n.authRegisterPrompt} ${l10n.authRegisterAction}',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _forgotPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    var email = _emailController.text.trim();
    String? dialogEmailError;

    final selectedEmail = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.authForgotPasswordDialogTitle),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.authForgotPasswordDialogBody),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: email,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (value) {
                        email = value;
                        if (dialogEmailError != null) {
                          setDialogState(() {
                            dialogEmailError = null;
                          });
                        }
                      },
                      onFieldSubmitted: (_) {
                        final normalizedEmail = email.trim();
                        if (normalizedEmail.isEmpty) {
                          setDialogState(() {
                            dialogEmailError =
                                l10n.authForgotPasswordEmailRequiredError;
                          });
                          return;
                        }
                        if (!_isValidEmail(normalizedEmail)) {
                          setDialogState(() {
                            dialogEmailError = l10n.authEmailInvalidError;
                          });
                          return;
                        }
                        Navigator.of(dialogContext).pop(normalizedEmail);
                      },
                      decoration: InputDecoration(
                        labelText: l10n.authEmailLabel,
                        border: const OutlineInputBorder(),
                        errorText: dialogEmailError,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.commonCancelButton),
                ),
                FilledButton(
                  onPressed: () {
                    final normalizedEmail = email.trim();
                    if (normalizedEmail.isEmpty) {
                      setDialogState(() {
                        dialogEmailError =
                            l10n.authForgotPasswordEmailRequiredError;
                      });
                      return;
                    }
                    if (!_isValidEmail(normalizedEmail)) {
                      setDialogState(() {
                        dialogEmailError = l10n.authEmailInvalidError;
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(normalizedEmail);
                  },
                  child: Text(l10n.authForgotPasswordSendButton),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted || selectedEmail == null) {
      return;
    }

    _emailController.text = selectedEmail;
    _clearControllerError(context);

    setState(() {
      _lastActionWasPasswordReset = true;
      _emailError = null;
      _isResettingPassword = true;
    });

    final controller = context.read<AuthController>();

    try {
      final success = await controller.forgotPassword(
        email: selectedEmail,
        redirectTo: _buildPasswordResetRedirectTo(),
      );

      if (!context.mounted) {
        return;
      }

      if (!success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _passwordFocusNode.requestFocus();
          }
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authPasswordResetEmailSent),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResettingPassword = false;
        });
      }
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (_isSubmitting) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    if (!_validateInputs(l10n)) {
      return;
    }

    final controller = context.read<AuthController>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    _clearControllerError(context);

    setState(() {
      _isSubmitting = true;
      _lastActionWasPasswordReset = false;
    });

    try {
      await controller.login(
        email: email,
        password: password,
      );

      if (!controller.isAuthenticated || !context.mounted) {
        return;
      }

      await AppDI.instance.storageService.writeRememberMe(_rememberMe);

      if (!context.mounted) {
        return;
      }

      TextInput.finishAutofillContext();
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

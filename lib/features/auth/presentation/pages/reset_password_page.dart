import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/auth/application/auth_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppDI.instance.createAuthController(),
      child: const _ResetPasswordView(),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView();

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs(AppLocalizations l10n) {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    String? newPasswordError;
    String? confirmPasswordError;

    if (newPassword.isEmpty) {
      newPasswordError = l10n.authPasswordRequiredError;
    } else if (newPassword.length < 8) {
      newPasswordError = l10n.authPasswordTooShortError;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError = l10n.authConfirmPasswordRequiredError;
    } else if (newPassword != confirmPassword) {
      confirmPasswordError = l10n.authPasswordsDoNotMatchError;
    }

    setState(() {
      _newPasswordError = newPasswordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return newPasswordError == null && confirmPasswordError == null;
  }

  void _clearControllerError(BuildContext context) {
    final controller = context.read<AuthController>();

    if (controller.errorMessage != null) {
      controller.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final isNarrow = mediaQuery.size.width < 600;
    final isBusy = _isSubmitting || controller.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authResetPasswordPageTitle),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = isNarrow ? 20.0 : 32.0;
              final verticalPadding = isNarrow ? 24.0 : 40.0;
              final availableHeight =
                  constraints.maxHeight - bottomInset - (verticalPadding * 2);

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding + bottomInset,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: availableHeight > 0 ? availableHeight : 0,
                  ),
                  child: Align(
                    alignment:
                        isNarrow ? Alignment.topCenter : Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: AutofillGroup(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.authResetPasswordHeadline,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _newPasswordController,
                              enabled: !isBusy,
                              obscureText: _obscureNewPassword,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.newPassword,
                              ],
                              onChanged: (_) {
                                _clearControllerError(context);

                                if (_newPasswordError != null ||
                                    _confirmPasswordError != null) {
                                  setState(() {
                                    _newPasswordError = null;
                                    _confirmPasswordError = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: l10n.authNewPasswordLabel,
                                border: const OutlineInputBorder(),
                                errorText: _newPasswordError,
                                suffixIcon: IconButton(
                                  tooltip: _obscureNewPassword
                                      ? l10n.authShowPasswordTooltip
                                      : l10n.authHidePasswordTooltip,
                                  onPressed: isBusy
                                      ? null
                                      : () {
                                          setState(() {
                                            _obscureNewPassword =
                                                !_obscureNewPassword;
                                          });
                                        },
                                  icon: Icon(
                                    _obscureNewPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _confirmPasswordController,
                              enabled: !isBusy,
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [
                                AutofillHints.newPassword,
                              ],
                              onChanged: (_) {
                                _clearControllerError(context);

                                if (_confirmPasswordError != null) {
                                  setState(() {
                                    _confirmPasswordError = null;
                                  });
                                }
                              },
                              onSubmitted: (_) {
                                if (!isBusy) {
                                  _submit(context);
                                }
                              },
                              decoration: InputDecoration(
                                labelText: l10n.authConfirmNewPasswordLabel,
                                border: const OutlineInputBorder(),
                                errorText: _confirmPasswordError,
                                suffixIcon: IconButton(
                                  tooltip: _obscureConfirmPassword
                                      ? l10n.authShowPasswordTooltip
                                      : l10n.authHidePasswordTooltip,
                                  onPressed: isBusy
                                      ? null
                                      : () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (controller.errorMessage != null) ...[
                              Text(
                                l10n.authPasswordUpdateGenericError,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    isBusy ? null : () => _submit(context),
                                child: isBusy
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      )
                                    : Text(l10n.authUpdatePasswordButton),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
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
    final newPassword = _newPasswordController.text.trim();

    _clearControllerError(context);

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await controller.updatePassword(
        newPassword: newPassword,
      );

      if (!context.mounted || !success) {
        return;
      }

      TextInput.finishAutofillContext();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authPasswordUpdated),
        ),
      );

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

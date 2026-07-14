import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/features/auth/application/auth_controller.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _acceptedLegal = false;

  String? _displayNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _legalError;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  bool _validateInputs() {
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _passwordConfirmController.text.trim();

    String? displayNameError;
    String? emailError;
    String? passwordError;
    String? confirmPasswordError;
    String? legalError;

    if (displayName.isEmpty) {
      displayNameError = 'Enter your display name';
    } else if (displayName.length < 2) {
      displayNameError = 'Display name is too short';
    }

    if (email.isEmpty) {
      emailError = 'Enter your email';
    } else if (!_isValidEmail(email)) {
      emailError = 'Enter a valid email';
    }

    if (password.isEmpty) {
      passwordError = 'Enter your password';
    } else if (password.length < 8) {
      passwordError = 'Password must be at least 8 characters';
    }

    if (confirm.isEmpty) {
      confirmPasswordError = 'Confirm your password';
    } else if (password != confirm) {
      confirmPasswordError = 'Passwords do not match';
    }

    if (!_acceptedLegal) {
      legalError = 'You must accept Terms and Privacy Policy';
    }

    setState(() {
      _displayNameError = displayNameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
      _legalError = legalError;
    });

    return displayNameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        legalError == null;
  }

  String? _buildFriendlyRegisterError(String? rawError) {
    if (rawError == null) {
      return null;
    }

    final normalized = rawError.toLowerCase();

    if (normalized.contains('user already registered') ||
        normalized.contains('already been registered') ||
        normalized.contains('already exists')) {
      return 'This email is already registered.';
    }

    if (normalized.contains('invalid email')) {
      return 'Enter a valid email address.';
    }

    if (normalized.contains('password')) {
      return 'Check your password and try again.';
    }

    if (normalized.contains('network') ||
        normalized.contains('socket') ||
        normalized.contains('timeout') ||
        normalized.contains('failed host lookup')) {
      return 'Network error. Check your connection and try again.';
    }

    return 'Registration failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final theme = Theme.of(context);
    final isBusy = _isSubmitting || controller.status == AuthStatus.loading;
    final friendlyError = _buildFriendlyRegisterError(controller.errorMessage);

    if (controller.requiresEmailConfirmation) {
      return _buildEmailConfirmationView(
        context,
        controller: controller,
        email:
            controller.pendingEmailConfirmation ?? _emailController.text.trim(),
      );
    }

    return AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create an account',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _displayNameController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            onChanged: (_) {
              if (_displayNameError != null) {
                setState(() {
                  _displayNameError = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: 'Display name',
              border: const OutlineInputBorder(),
              errorText: _displayNameError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            onChanged: (_) {
              if (_emailError != null) {
                setState(() {
                  _emailError = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: 'Email',
              border: const OutlineInputBorder(),
              errorText: _emailError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (_) {
              if (_passwordError != null || _confirmPasswordError != null) {
                setState(() {
                  _passwordError = null;
                  _confirmPasswordError = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              errorText: _passwordError,
              suffixIcon: IconButton(
                onPressed: () {
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
          const SizedBox(height: 16),
          TextField(
            controller: _passwordConfirmController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (_) {
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
              labelText: 'Confirm password',
              border: const OutlineInputBorder(),
              errorText: _confirmPasswordError,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
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
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _acceptedLegal,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: isBusy
                ? null
                : (value) {
                    setState(() {
                      _acceptedLegal = value ?? false;
                      _legalError = null;
                    });
                  },
            title: const Text(
              'I accept the Terms and Privacy Policy',
            ),
          ),
          if (_legalError != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _legalError!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (friendlyError != null) ...[
            Text(
              friendlyError,
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
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Register'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isBusy ? null : () => Navigator.of(context).pop(),
            child: const Text('Already have an account? Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailConfirmationView(
    BuildContext context, {
    required AuthController controller,
    required String email,
  }) {
    final theme = Theme.of(context);
    final normalizedEmail = email.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a confirmation link to:',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        if (normalizedEmail.isNotEmpty) ...[
          const SizedBox(height: 8),
          SelectableText(
            normalizedEmail,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Open the link in that message to verify your address. '
          'After confirmation, return to the app and sign in.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              controller.clearEmailConfirmationState();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.login),
            label: const Text('Back to login'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            _emailController.clear();
            _passwordController.clear();
            _passwordConfirmController.clear();
            controller.clearEmailConfirmationState();
          },
          child: const Text('Use another email address'),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (_isSubmitting) {
      return;
    }

    if (!_validateInputs()) {
      return;
    }

    final controller = context.read<AuthController>();
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await controller.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (!context.mounted) {
        return;
      }

      if (controller.isAuthenticated) {
        TextInput.finishAutofillContext();
        Navigator.of(context).pop();
        return;
      }

      if (controller.requiresEmailConfirmation) {
        TextInput.finishAutofillContext();
        FocusScope.of(context).unfocus();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

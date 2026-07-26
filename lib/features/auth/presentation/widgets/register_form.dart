import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';
import 'package:sociale_vote/features/auth/application/auth_controller.dart';
import 'package:sociale_vote/features/auth/presentation/pages/legal_document_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/country_selector_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  String? _selectedCountryCode;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _acceptedLegal = false;
  bool _openedTerms = false;
  bool _openedPrivacy = false;

  String? _displayNameError;
  String? _usernameError;
  String? _emailError;
  String? _countryError;
  String? _cityError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _legalError;

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  String _normalizeUsername(String value) {
    var normalized = value.trim().toLowerCase();

    if (normalized.startsWith('@')) {
      normalized = normalized.substring(1);
    }

    return normalized;
  }

  bool _isValidUsername(String value) {
    return RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(value);
  }

  void _clearControllerError(BuildContext context) {
    final controller = context.read<AuthController>();
    if (controller.errorMessage != null) {
      controller.clearError();
    }
  }

  bool _validateInputs(AppLocalizations l10n) {
    final displayName = _displayNameController.text.trim();
    final username = _normalizeUsername(_usernameController.text);
    final email = _emailController.text.trim();
    final city = _cityController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _passwordConfirmController.text.trim();
    final countryCode = _selectedCountryCode?.trim();

    String? displayNameError;
    String? usernameError;
    String? emailError;
    String? countryError;
    String? cityError;
    String? passwordError;
    String? confirmPasswordError;
    String? legalError;

    if (displayName.isEmpty) {
      displayNameError = l10n.authDisplayNameRequiredError;
    } else if (displayName.length < 2) {
      displayNameError = l10n.authDisplayNameTooShortError;
    }

    if (username.isEmpty) {
      usernameError = l10n.authUsernameRequiredError;
    } else if (!_isValidUsername(username)) {
      usernameError = l10n.authUsernameInvalidError;
    }

    if (email.isEmpty) {
      emailError = l10n.authEmailRequiredError;
    } else if (!_isValidEmail(email)) {
      emailError = l10n.authEmailInvalidError;
    }

    if (countryCode == null || countryCode.isEmpty) {
      countryError = l10n.authCountryRequiredError;
    }

    if (city.isEmpty) {
      cityError = l10n.authCityRequiredError;
    }

    if (password.isEmpty) {
      passwordError = l10n.authPasswordRequiredError;
    } else if (password.length < 8) {
      passwordError = l10n.authPasswordTooShortError;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError = l10n.authConfirmPasswordRequiredError;
    } else if (password != confirmPassword) {
      confirmPasswordError = l10n.authPasswordsDoNotMatchError;
    }

    if (!_openedTerms || !_openedPrivacy || !_acceptedLegal) {
      legalError = l10n.authLegalConsentRequiredError;
    }

    setState(() {
      _displayNameError = displayNameError;
      _usernameError = usernameError;
      _emailError = emailError;
      _countryError = countryError;
      _cityError = cityError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
      _legalError = legalError;
    });

    return displayNameError == null &&
        usernameError == null &&
        emailError == null &&
        countryError == null &&
        cityError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        legalError == null;
  }

  String? _buildFriendlyRegisterError(
    AppLocalizations l10n,
    String? rawError,
  ) {
    if (rawError == null) {
      return null;
    }

    final normalized = rawError.trim().toLowerCase();

    if (normalized.contains('user already registered') ||
        normalized.contains('already been registered') ||
        normalized.contains('email already') ||
        normalized.contains('already exists') && normalized.contains('email')) {
      return l10n.authEmailAlreadyRegisteredError;
    }

    if (normalized.contains('invalid email') ||
        normalized.contains('email_address_invalid')) {
      return l10n.authEmailInvalidError;
    }

    if (normalized.contains('username') &&
        (normalized.contains('duplicate') ||
            normalized.contains('already') ||
            normalized.contains('unique'))) {
      return l10n.authUsernameInvalidError;
    }

    if (normalized.contains('rate limit') || normalized.contains('too many')) {
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

    return l10n.authRegisterGenericError;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isBusy = _isSubmitting || controller.status == AuthStatus.loading;
    final friendlyError = _buildFriendlyRegisterError(
      l10n,
      controller.errorMessage,
    );

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
            l10n.authRegisterHeadline,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _displayNameController,
            enabled: !isBusy,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            onChanged: (_) {
              _clearControllerError(context);
              if (_displayNameError != null) {
                setState(() {
                  _displayNameError = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: l10n.authDisplayNameLabel,
              border: const OutlineInputBorder(),
              errorText: _displayNameError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            enabled: !isBusy,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9_@]'),
              ),
              LengthLimitingTextInputFormatter(21),
            ],
            onChanged: (_) {
              _clearControllerError(context);
              if (_usernameError != null) {
                setState(() {
                  _usernameError = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: l10n.authUsernameLabel,
              prefixText: '@',
              border: const OutlineInputBorder(),
              errorText: _usernameError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            enabled: !isBusy,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [
              AutofillHints.username,
              AutofillHints.email,
            ],
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
          IgnorePointer(
            ignoring: isBusy,
            child: Opacity(
              opacity: isBusy ? 0.6 : 1,
              child: CountrySelectorField(
                selectedCountryCode: _selectedCountryCode,
                required: true,
                label: l10n.authCountryOfResidenceLabel,
                onCountrySelected: (countryCode) {
                  _clearControllerError(context);

                  setState(() {
                    final normalized = countryCode.trim().toUpperCase();

                    if (_selectedCountryCode != normalized) {
                      _cityController.clear();
                    }

                    _selectedCountryCode = normalized;
                    _countryError = null;
                    _cityError = null;
                  });
                },
              ),
            ),
          ),
          if (_countryError != null) ...[
            const SizedBox(height: 6),
            Text(
              _countryError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _cityController,
            enabled: !isBusy,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.addressCity],
            onChanged: (_) {
              _clearControllerError(context);
              if (_cityError != null) {
                setState(() {
                  _cityError = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: l10n.authCityOfResidenceLabel,
              hintText: l10n.homeScopeCityExampleHint,
              border: const OutlineInputBorder(),
              errorText: _cityError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            enabled: !isBusy,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (_) {
              _clearControllerError(context);
              if (_passwordError != null || _confirmPasswordError != null) {
                setState(() {
                  _passwordError = null;
                  _confirmPasswordError = null;
                });
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
          const SizedBox(height: 16),
          TextField(
            controller: _passwordConfirmController,
            enabled: !isBusy,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
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
              labelText: l10n.authConfirmPasswordLabel,
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
          _buildLegalConsent(
            context,
            isBusy: isBusy,
          ),
          if (_legalError != null) ...[
            const SizedBox(height: 6),
            Text(
              _legalError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
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
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(l10n.authRegisterButton),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isBusy ? null : () => Navigator.of(context).pop(),
            child: Text(
              '${l10n.authLoginPrompt} ${l10n.authLoginAction}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalConsent(
    BuildContext context, {
    required bool isBusy,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canAccept = _openedTerms && _openedPrivacy && !isBusy;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: _legalError == null
              ? theme.dividerColor
              : theme.colorScheme.error,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: isBusy
                      ? null
                      : () => _openLegalDocument(
                            context,
                            type: LegalDocumentType.terms,
                          ),
                  icon: Icon(
                    _openedTerms
                        ? Icons.check_circle_outline
                        : Icons.description_outlined,
                  ),
                  label: Text(l10n.authTermsOfServiceAction),
                ),
                TextButton.icon(
                  onPressed: isBusy
                      ? null
                      : () => _openLegalDocument(
                            context,
                            type: LegalDocumentType.privacy,
                          ),
                  icon: Icon(
                    _openedPrivacy
                        ? Icons.check_circle_outline
                        : Icons.privacy_tip_outlined,
                  ),
                  label: Text(l10n.authPrivacyPolicyAction),
                ),
              ],
            ),
            CheckboxListTile(
              value: _acceptedLegal,
              enabled: canAccept,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                '${l10n.authLegalConsentPrefix} '
                '${l10n.authTermsOfServiceAction} / '
                '${l10n.authPrivacyPolicyAction}.',
              ),
              onChanged: canAccept
                  ? (value) {
                      setState(() {
                        _acceptedLegal = value ?? false;
                        _legalError = null;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLegalDocument(
    BuildContext context, {
    required LegalDocumentType type,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LegalDocumentPage(type: type),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      if (type == LegalDocumentType.terms) {
        _openedTerms = true;
      } else {
        _openedPrivacy = true;
      }

      if (_openedTerms && _openedPrivacy && _acceptedLegal) {
        _legalError = null;
      }
    });
  }

  Widget _buildEmailConfirmationView(
    BuildContext context, {
    required AuthController controller,
    required String email,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
          l10n.authEmailConfirmationTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.authEmailConfirmationIntro,
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
          l10n.authEmailConfirmationInstructions,
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
            label: Text(l10n.authBackToLoginButton),
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
          child: Text(l10n.authUseAnotherEmailButton),
        ),
      ],
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
    final displayName = _displayNameController.text.trim();
    final username = _normalizeUsername(_usernameController.text);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final countryCode = _selectedCountryCode!.trim().toUpperCase();
    final cityInput = _cityController.text.trim();

    _clearControllerError(context);

    setState(() {
      _isSubmitting = true;
      _cityError = null;
    });

    ContentLocation? resolvedLocation;

    try {
      resolvedLocation =
          await AppDI.instance.geocodingRepository.geocodeContentLocation(
        ContentLocation(
          source: ContentLocationSource.manual,
          countryCode: countryCode,
          cityName: cityInput,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _cityError = l10n.homeScopeCityVerificationError;
          _isSubmitting = false;
        });
      }
      return;
    }

    if (!context.mounted) {
      return;
    }

    if (resolvedLocation == null) {
      setState(() {
        _cityError = l10n.homeScopeCityNotFoundError;
        _isSubmitting = false;
      });
      return;
    }

    final resolvedCountry =
        (resolvedLocation.countryCode ?? countryCode).trim().toUpperCase();
    final resolvedCity = (resolvedLocation.cityName ?? cityInput).trim();

    if (resolvedCountry.isEmpty || resolvedCity.isEmpty) {
      setState(() {
        _cityError = l10n.homeScopeCityNotFoundError;
        _isSubmitting = false;
      });
      return;
    }

    try {
      await controller.register(
        email: email,
        password: password,
        displayName: displayName,
        username: username,
        country: resolvedCountry,
        city: resolvedCity,
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

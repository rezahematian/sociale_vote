import 'package:flutter/material.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/auth_api.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

// Client-side validation improves UX. Supabase Auth remains authoritative.
enum ChangeEmailInputStatus { valid, invalid, unchanged }

ChangeEmailInputStatus validateAccountEmailChange(
  String currentEmail,
  String proposedEmail,
) {
  final normalized = proposedEmail.trim();
  final format = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (normalized.length > 254 || !format.hasMatch(normalized)) {
    return ChangeEmailInputStatus.invalid;
  }
  if (normalized.toLowerCase() == currentEmail.trim().toLowerCase()) {
    return ChangeEmailInputStatus.unchanged;
  }
  return ChangeEmailInputStatus.valid;
}

class ChangeEmailPage extends StatefulWidget {
  final String currentEmail;

  const ChangeEmailPage({super.key, required this.currentEmail});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController _newEmail = TextEditingController();
  bool _busy = false;
  bool _requested = false;
  String? _error;

  @override
  void dispose() {
    _newEmail.dispose();
    super.dispose();
  }

  Future<void> _requestChange() async {
    if (_busy || _requested) return;
    final l10n = AppLocalizations.of(context)!;
    final result = validateAccountEmailChange(
      widget.currentEmail,
      _newEmail.text,
    );
    if (result != ChangeEmailInputStatus.valid) {
      setState(() {
        _error = result == ChangeEmailInputStatus.unchanged
            ? l10n.profileChangeEmailUnchanged
            : l10n.profileChangeEmailInvalid;
      });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await const AuthApi().requestEmailChange(newEmail: _newEmail.text);
      if (!mounted) return;
      setState(() => _requested = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.profileChangeEmailRequestFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileChangeEmailAction)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(l10n.profileChangeEmailCurrent,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  SelectableText(widget.currentEmail),
                  const SizedBox(height: 20),
                  if (_requested) ...[
                    const Icon(Icons.mark_email_read_outlined, size: 42),
                    const SizedBox(height: 12),
                    Text(l10n.profileChangeEmailRequested,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.profileChangeEmailClose),
                    ),
                  ] else ...[
                    TextField(
                      controller: _newEmail,
                      enabled: !_busy,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      onSubmitted: (_) => _requestChange(),
                      decoration: InputDecoration(
                        labelText: l10n.profileChangeEmailNew,
                        hintText: 'name@example.com',
                        errorText: _error,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(l10n.profileChangeEmailSecurityNote),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _busy ? null : _requestChange,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.profileChangeEmailSubmit),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

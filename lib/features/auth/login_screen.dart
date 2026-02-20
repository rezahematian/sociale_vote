import 'package:flutter/material.dart';

import '../../core/session_manager.dart';
import '../../domain/user/user_identity.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // =========================
    // LOGIN FITTIZIO (STEP 7)
    // =========================
    await Future.delayed(const Duration(seconds: 1));

    // Creazione identità utente coerente col dominio
    final user = UserIdentity(
      userId: 'user_demo_001',
      username: _emailController.text.trim(),
      isVerified: true,
      countryCode: 'IT',
    );

    // Avvio sessione
    final sessionManager = SessionManager();
    sessionManager.startSession(user);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accedi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _onLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Accedi'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // TODO: navigare a registrazione
              },
              child: const Text('Non hai un account? Registrati'),
            ),
          ],
        ),
      ),
    );
  }
}

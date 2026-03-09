import 'package:flutter/material.dart';

import 'package:sociale_vote/shared/ui/ui.dart';

/// Servizio centralizzato per mostrare dialog e messaggi.
///
/// Obiettivo:
/// - evitare showDialog sparsi nell'app
/// - UI coerente
/// - riuso semplice
class DialogService {
  const DialogService();

  /// Dialog informativo semplice.
  Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            AppButton.primary(
              label: buttonLabel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Dialog di conferma.
  ///
  /// Ritorna:
  /// true → confermato
  /// false → annullato
  Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Conferma',
    String cancelLabel = 'Annulla',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            AppButton.text(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            AppButton.primary(
              label: confirmLabel,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// Snackbar informativa.
  void showSnackBar(
    BuildContext context, {
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
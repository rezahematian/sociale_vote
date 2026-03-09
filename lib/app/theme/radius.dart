import 'package:flutter/widgets.dart';

/// Sistema centrale dei radius di Sociale_Vote.
///
/// Regole:
/// - Card radius = 16
/// - Button radius = 12
/// - Input radius = 12
/// - Sheet radius = 20
/// - Pill / chip = 999 (full pill)
///
/// Obiettivo:
/// - Niente `BorderRadius.circular(x)` sparsi
/// - Un solo posto dove cambiare i corner in futuro
class AppRadius {
  AppRadius._();

  // =========================================================
  // VALORI GREZZI
  // =========================================================

  /// Radius molto piccolo (icone container, mini badge).
  static const double small = 8.0;

  /// Radius per button (primary/secondary/outlined).
  static const double button = 12.0;

  /// Radius per campi di input.
  static const double input = 12.0;

  /// Radius per card standard.
  static const double card = 16.0;

  /// Radius card più grandi (hero container / panels).
  static const double cardLarge = 20.0;

  /// Radius per sheet / modali.
  static const double sheet = 20.0;

  /// Radius per dialog.
  static const double dialog = 18.0;

  /// Radius "pill" (chip, badge).
  static const double pill = 999.0;

  // =========================================================
  // BORDER RADIUS COMODI
  // =========================================================

  /// BorderRadius piccolo.
  static const BorderRadius smallRadius =
      BorderRadius.all(Radius.circular(small));

  /// BorderRadius per button.
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(button));

  /// BorderRadius per input.
  static const BorderRadius inputRadius =
      BorderRadius.all(Radius.circular(input));

  /// BorderRadius per card.
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(card));

  /// BorderRadius card grandi.
  static const BorderRadius cardLargeRadius =
      BorderRadius.all(Radius.circular(cardLarge));

  /// BorderRadius per dialog.
  static const BorderRadius dialogRadius =
      BorderRadius.all(Radius.circular(dialog));

  /// BorderRadius per bottom sheet.
  static const BorderRadius sheetRadius =
      BorderRadius.vertical(top: Radius.circular(sheet));

  /// BorderRadius pill.
  static const BorderRadius pillRadius =
      BorderRadius.all(Radius.circular(pill));
}
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

  /// Radius per card (contenitori principali).
  static const double card = 16.0;

  /// Radius per button (primary/secondary/outlined).
  static const double button = 12.0;

  /// Radius per campi di input.
  static const double input = 12.0;

  /// Radius per sheet / modali top-rounded.
  static const double sheet = 20.0;

  /// Radius "pill" (chip, badge, label arrotondate).
  static const double pill = 999.0;

  // =========================================================
  // BORDER RADIUS COMODI
  // =========================================================

  /// BorderRadius per card standard.
  static BorderRadius get cardRadius =>
      BorderRadius.circular(card);

  /// BorderRadius per button standard.
  static BorderRadius get buttonRadius =>
      BorderRadius.circular(button);

  /// BorderRadius per input standard.
  static BorderRadius get inputRadius =>
      BorderRadius.circular(input);

  /// BorderRadius per bottom sheet / dialog top-rounded.
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );

  /// BorderRadius per pill / chip full-rounded.
  static BorderRadius get pillRadius =>
      BorderRadius.circular(pill);
}
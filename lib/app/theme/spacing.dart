import 'package:flutter/widgets.dart';

/// Sistema di spacing centrale di Sociale_Vote.
///
/// Regole:
/// - Grid base 4/8px (4 come sotto-unità, 8 come step principale)
/// - Padding card = 16
/// - Spaziatura sezione = 24
/// - Niente numeri magici sparsi: usare sempre [AppSpacing].
class AppSpacing {
  AppSpacing._();

  // =========================================================
  // UNITÀ BASE
  // =========================================================

  /// Unità base di spacing (grid fine): 4px.
  static const double unitXS = 4.0;

  /// Unità base principale (grid): 8px.
  static const double unitS = 8.0;

  /// Unità media: 12px (usata raramente).
  static const double unitM = 12.0;

  /// Unità grande: 16px (padding card, contenitori principali).
  static const double unitL = 16.0;

  /// Unità extra: 24px (spaziatura tra sezioni).
  static const double unitXL = 24.0;

  /// Unità enorme: 32px (hero / separatori forti).
  static const double unitXXL = 32.0;

  // Alias più semantici (opzionali, ma leggibili):

  static const double cardPadding = unitL; // 16
  static const double sectionSpacing = unitXL; // 24
  static const double pagePadding = unitL; // 16

  // =========================================================
  // EDGEINSETS COMUNI
  // =========================================================

  /// Padding standard per una pagina (left/right/top/bottom).
  static const EdgeInsets page = EdgeInsets.all(pagePadding);

  /// Padding orizzontale pagina (es. ListView padding).
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: pagePadding);

  /// Padding verticale pagina (per blocchi in colonna).
  static const EdgeInsets pageVertical =
      EdgeInsets.symmetric(vertical: unitS);

  /// Padding standard per card.
  static const EdgeInsets card = EdgeInsets.all(cardPadding);

  /// Padding verticale per card (quando l’orizzontale è gestito dal layout).
  static const EdgeInsets cardVertical =
      EdgeInsets.symmetric(vertical: unitS);

  /// Spaziatura standard tra sezioni (solo top).
  static const EdgeInsets sectionTop =
      EdgeInsets.only(top: sectionSpacing);

  /// Spaziatura tra elementi di lista (es. tra card).
  static const EdgeInsets listItemSpacing =
      EdgeInsets.only(top: unitS);
}
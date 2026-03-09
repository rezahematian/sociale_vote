import 'package:flutter/widgets.dart';

/// Sistema di spacing centrale di Sociale_Vote.
///
/// Regole:
/// - Grid base 4/8px
/// - Padding card = 16
/// - Spaziatura sezione = 24
/// - Niente numeri magici sparsi: usare sempre [AppSpacing].
class AppSpacing {
  AppSpacing._();

  // =========================================================
  // SCALE BASE
  // =========================================================

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 12.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  // =========================================================
  // COMPATIBILITÀ RETRO
  // =========================================================
  // Manteniamo i vecchi nomi usati già nel progetto
  // per non rompere i file esistenti.

  static const double unitXS = xxs;   // 4
  static const double unitS = xs;     // 8
  static const double unitM = s;      // 12
  static const double unitL = m;      // 16
  static const double unitXL = l;     // 24
  static const double unitXXL = xl;   // 32

  // =========================================================
  // ALIAS SEMANTICI
  // =========================================================

  /// Padding principale delle pagine.
  static const double pagePadding = m;

  /// Padding interno delle card.
  static const double cardPadding = m;

  /// Spaziatura tra sezioni principali.
  static const double sectionSpacing = l;

  /// Spaziatura tra blocchi importanti.
  static const double blockSpacing = xl;

  // =========================================================
  // EDGE INSETS PREDEFINITI
  // =========================================================

  /// Padding pagina completo.
  static const EdgeInsets page = EdgeInsets.all(pagePadding);

  /// Padding orizzontale pagina.
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: pagePadding);

  /// Padding verticale pagina.
  static const EdgeInsets pageVertical =
      EdgeInsets.symmetric(vertical: xs);

  /// Padding standard per card.
  static const EdgeInsets card = EdgeInsets.all(cardPadding);

  /// Padding verticale card.
  static const EdgeInsets cardVertical =
      EdgeInsets.symmetric(vertical: xs);

  /// Padding interno contenitori grandi.
  static const EdgeInsets block = EdgeInsets.all(m);

  /// Spazio sopra una sezione.
  static const EdgeInsets sectionTop =
      EdgeInsets.only(top: sectionSpacing);

  /// Spazio tra elementi di lista.
  static const EdgeInsets listItemSpacing =
      EdgeInsets.only(top: xs);

  // =========================================================
  // GAPS RAPIDI
  // =========================================================

  static const SizedBox gapXS = SizedBox(height: xs);
  static const SizedBox gapS = SizedBox(height: s);
  static const SizedBox gapM = SizedBox(height: m);
  static const SizedBox gapL = SizedBox(height: l);
  static const SizedBox gapXL = SizedBox(height: xl);
}
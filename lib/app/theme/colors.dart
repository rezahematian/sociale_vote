import 'package:flutter/material.dart';

/// Color system centrale di Sociale_Vote.
///
/// Tutti i colori dell'app devono passare da qui.
/// Niente colori hardcoded sparsi nei widget.
///
/// Filosofia:
/// - Base neutra chiara
/// - Primary blu moderno per azioni
/// - Colori di stato per engagement (heat/cool/success/warning)
/// - Testo in scala di grigi (no nero pieno)
class AppColors {
  AppColors._();

  // =========================================================
  // BASE / BACKGROUND
  // =========================================================

  /// Sfondo principale dell'app (dietro le card).
  static const Color background = Color(0xFFF7F8FC);

  /// Variante alternativa di background per layering leggero.
  static const Color backgroundAlt = Color(0xFFF1F5F9);

  /// Superficie principale (card, fogli, pannelli).
  static const Color surface = Color(0xFFFFFFFF);

  /// Variante di surface leggermente distinta.
  static const Color surfaceAlt = Color(0xFFFDFEFF);

  /// Surface variant per contenitori secondari, placeholder, box informativi.
  static const Color surfaceVariant = Color(0xFFF8FAFC);

  // =========================================================
  // BORDI / DIVIDER
  // =========================================================

  /// Bordo soft per card e contenitori.
  static const Color borderSoft = Color(0xFFE2E4EA);

  /// Divider leggero tra elementi di lista / sezioni.
  static const Color divider = Color(0xFFECEFF4);

  // =========================================================
  // PRIMARY / BRAND
  // =========================================================

  /// Colore primary: blu moderno per azioni principali.
  ///
  /// Usato per:
  /// - Primary button
  /// - Icone attive importanti
  /// - Link / "View all"
  /// - Focus state di input
  static const Color primary = Color(0xFF2563EB);

  /// Variante più scura di primary (pressed state, hover).
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// Variante più chiara di primary.
  static const Color primaryLight = Color(0xFF60A5FA);

  /// Soft background per pill, badge, highlight di primary.
  static const Color primarySoftBackground = Color(0xFFEFF6FF);

  /// Testo/icona sopra primarySoftBackground.
  static const Color primarySoftForeground = primary;

  // =========================================================
  // ENGAGEMENT / STATE
  // =========================================================

  /// Heat / positivo forte (es. contenuti molto caldi).
  static const Color heat = Color(0xFFEF4444);

  /// Variante soft per badge / background heat.
  static const Color heatSoftBackground = Color(0xFFFFEEEE);

  /// Colore freddo / neutro (es. cool, downvote, elementi "ice").
  static const Color cool = Color(0xFF0EA5E9);

  /// Variante soft per badge / background cool.
  static const Color coolSoftBackground = Color(0xFFE0F7FF);

  /// Success (azioni riuscite, stato ok).
  static const Color success = Color(0xFF10B981);

  /// Soft background per success.
  static const Color successSoftBackground = Color(0xFFDCFCE7);

  /// Warning (attenzioni, stati non critici).
  static const Color warning = Color(0xFFF59E0B);

  /// Soft background per warning.
  static const Color warningSoftBackground = Color(0xFFFFF7E5);

  /// Error (errori formali, validazione, ecc.).
  static const Color error = Color(0xFFDC2626);

  /// Soft background per error.
  static const Color errorSoftBackground = Color(0xFFFEE2E2);

  // =========================================================
  // TEXT
  // =========================================================

  /// Testo principale (titoli, body importante).
  static const Color textPrimary = Color(0xFF111827);

  /// Testo secondario (descrizioni, meta info).
  static const Color textSecondary = Color(0xFF4B5563);

  /// Testo attenuato (caption, label leggere).
  static const Color textMuted = Color(0xFF9CA3AF);

  /// Testo su superfici scure / primary.
  static const Color textInverted = Color(0xFFFFFFFF);

  // =========================================================
  // ICON / DISABLED
  // =========================================================

  /// Icone di default (stato neutro).
  static const Color icon = Color(0xFF6B7280);

  /// Icone disabilitate / elementi disattivati.
  static const Color iconDisabled = Color(0xFFCBD5E1);

  /// Colore generico per elementi disabled.
  static const Color disabled = Color(0xFFD1D5DB);

  // =========================================================
  // FEEDBACK VISUAL / EFFECTS
  // =========================================================

  /// Ombra standard molto leggera per card e overlay.
  static const Color shadow = Color(0x14000000);

  /// Base per skeleton loading.
  static const Color skeletonBase = Color(0xFFE5E7EB);

  /// Highlight per skeleton loading.
  static const Color skeletonHighlight = Color(0xFFF3F4F6);

  // =========================================================
  // OVERLAY / SCRIM
  // =========================================================

  /// Scrim per dialog, bottom sheet, overlay.
  static const Color scrim = Color(0x99000000);

  // =========================================================
  // HELPER: MATERIAL COLOR PRIMARY SWATCH
  // =========================================================

  /// Swatch Material per compatibilità con vecchie API.
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF2563EB,
    <int, Color>{
      50: Color(0xFFEFF6FF),
      100: Color(0xFFDBEAFE),
      200: Color(0xFFBFDBFE),
      300: Color(0xFF93C5FD),
      400: Color(0xFF60A5FA),
      500: Color(0xFF3B82F6),
      600: Color(0xFF2563EB),
      700: Color(0xFF1D4ED8),
      800: Color(0xFF1E40AF),
      900: Color(0xFF1E3A8A),
    },
  );
}
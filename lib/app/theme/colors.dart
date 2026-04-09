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
  static const Color background = Color(0xFFF5F7FB);

  /// Variante alternativa di background per layering leggero.
  static const Color backgroundAlt = Color(0xFFEEF3F9);

  /// Superficie principale (card, fogli, pannelli).
  static const Color surface = Color(0xFFFFFFFF);

  /// Variante di surface leggermente distinta.
  static const Color surfaceAlt = Color(0xFFFCFDFE);

  /// Surface variant per contenitori secondari, placeholder, box informativi.
  static const Color surfaceVariant = Color(0xFFF6F8FC);

  // =========================================================
  // DARK / BACKGROUND
  // =========================================================

  /// Sfondo principale dark dell'app.
  static const Color backgroundDark = Color(0xFF0B1220);

  /// Variante alternativa dark per layering leggero.
  static const Color backgroundAltDark = Color(0xFF0F1728);

  /// Superficie principale dark (card, fogli, pannelli).
  static const Color surfaceDark = Color(0xFF121A26);

  /// Variante dark di surface leggermente distinta.
  static const Color surfaceAltDark = Color(0xFF172131);

  /// Surface variant dark per contenitori secondari, placeholder, box informativi.
  static const Color surfaceVariantDark = Color(0xFF1D2938);

  // =========================================================
  // BORDI / DIVIDER
  // =========================================================

  /// Bordo soft per card e contenitori.
  static const Color borderSoft = Color(0xFFDCE3EC);

  /// Divider leggero tra elementi di lista / sezioni.
  static const Color divider = Color(0xFFE8EDF3);

  // =========================================================
  // DARK / BORDI / DIVIDER
  // =========================================================

  /// Bordo soft dark per card e contenitori.
  static const Color borderSoftDark = Color(0xFF2D3A4D);

  /// Divider dark tra elementi di lista / sezioni.
  static const Color dividerDark = Color(0xFF223044);

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

  /// Soft background primary per dark surfaces.
  static const Color primarySoftBackgroundDark = Color(0xFF1A2B52);

  /// Testo/icona sopra primarySoftBackgroundDark.
  static const Color primarySoftForegroundDark = Color(0xFFD8E6FF);

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
  // DARK / ENGAGEMENT / STATE
  // =========================================================

  /// Variante soft dark per badge / background heat.
  static const Color heatSoftBackgroundDark = Color(0xFF412022);

  /// Variante soft dark per badge / background cool.
  static const Color coolSoftBackgroundDark = Color(0xFF102D42);

  /// Soft background dark per success.
  static const Color successSoftBackgroundDark = Color(0xFF123125);

  /// Soft background dark per warning.
  static const Color warningSoftBackgroundDark = Color(0xFF402817);

  /// Soft background dark per error.
  static const Color errorSoftBackgroundDark = Color(0xFF3E1A1D);

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
  // DARK / TEXT
  // =========================================================

  /// Testo principale dark (titoli, body importante).
  static const Color textPrimaryDark = Color(0xFFF3F7FD);

  /// Testo secondario dark (descrizioni, meta info).
  static const Color textSecondaryDark = Color(0xFFBEC9D8);

  /// Testo attenuato dark (caption, label leggere).
  static const Color textMutedDark = Color(0xFF8FA1B7);

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
  // DARK / ICON / DISABLED
  // =========================================================

  /// Icone di default dark (stato neutro).
  static const Color iconDark = Color(0xFFC8D3E1);

  /// Icone disabilitate dark / elementi disattivati.
  static const Color iconDisabledDark = Color(0xFF475569);

  /// Colore generico dark per elementi disabled.
  static const Color disabledDark = Color(0xFF334155);

  // =========================================================
  // FEEDBACK VISUAL / EFFECTS
  // =========================================================

  /// Ombra standard molto leggera per card e overlay.
  static const Color shadow = Color(0x140F172A);

  /// Base per skeleton loading.
  static const Color skeletonBase = Color(0xFFE5E7EB);

  /// Highlight per skeleton loading.
  static const Color skeletonHighlight = Color(0xFFF3F4F6);

  // =========================================================
  // DARK / FEEDBACK VISUAL / EFFECTS
  // =========================================================

  /// Ombra dark per card e overlay.
  static const Color shadowDark = Color(0x66000000);

  /// Base dark per skeleton loading.
  static const Color skeletonBaseDark = Color(0xFF1E293B);

  /// Highlight dark per skeleton loading.
  static const Color skeletonHighlightDark = Color(0xFF334155);

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
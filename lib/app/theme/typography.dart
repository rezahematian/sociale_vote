import 'package:flutter/material.dart';

import 'colors.dart';

/// Typography system centrale di Sociale_Vote.
///
/// Obiettivi:
/// - Scala tipografica coerente per tutta l'app
/// - Max 3 pesi: 400 (regular), 500 (medium), 600 (semibold)
/// - Niente font size sotto 12
/// - Nessun TextStyle hardcoded sparso nei widget: usare [AppTypography].
class AppTypography {
  AppTypography._();

  /// TextTheme principale da agganciare a ThemeData.
  static const TextTheme textTheme = TextTheme(
    // Hero / grandi titoli
    displayLarge: _heroTitle,

    // Page / app bar titles
    headlineLarge: _h1,
    headlineMedium: _h2,
    headlineSmall: _h3,

    // Sezioni / card titles
    titleLarge: _sectionTitle,
    titleMedium: _cardTitle,
    titleSmall: _sectionSubtitle,

    // Body
    bodyLarge: _bodyLarge,
    bodyMedium: _body,
    bodySmall: _meta,

    // Buttons / labels / caption
    labelLarge: _buttonLabel,
    labelMedium: _meta,
    labelSmall: _caption,
  );

  // =========================================================
  // STILI BASE (privati)
  // =========================================================

  /// Hero title — grandi titoli introduttivi.
  static const TextStyle _heroTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  /// H1 — Page title / titoli pagina.
  static const TextStyle _h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// H2 — Titoli sezione principali.
  static const TextStyle _h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// H3 — Header minori o sottosezioni.
  static const TextStyle _h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Section title — titoli sezione.
  static const TextStyle _sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Card title — titoli di card / item (Poll, News, Post).
  static const TextStyle _cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  /// Section subtitle — descrizione sotto il titolo.
  static const TextStyle _sectionSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Body large — testo leggermente più importante.
  static const TextStyle _bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  /// Body — testo principale.
  static const TextStyle _body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  /// Meta — testo secondario (timestamp, scope, meta info).
  static const TextStyle _meta = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  /// Button label — testo bottoni.
  static const TextStyle _buttonLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Caption — testo piccolo (badge, helper, hint).
  static const TextStyle _caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textMuted,
  );
}
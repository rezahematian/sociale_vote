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
    // Page / App bar titles
    headlineMedium: _h1,
    headlineSmall: _h2,

    // Sezioni / card titles
    titleLarge: _cardTitle,
    titleMedium: _sectionTitle,
    titleSmall: _sectionSubtitle,

    // Body
    bodyLarge: _body,
    bodyMedium: _body,
    bodySmall: _meta,

    // Caption / badge
    labelMedium: _meta,
    labelSmall: _caption,
  );

  // =========================================================
  // STILI BASE (privati)
  // =========================================================

  /// H1 — Page title / grandi titoli.
  static const TextStyle _h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// H2 — Sezioni principali, header importanti.
  static const TextStyle _h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Card title — Titoli di card / item (Poll, News, Post).
  static const TextStyle _cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Section title — Titoli secondari / header sezione.
  static const TextStyle _sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Section subtitle — eventuale descrizione sotto il titolo.
  static const TextStyle _sectionSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Body — testo principale (paragrafi, contenuto card).
  static const TextStyle _body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Meta — testo secondario (timestamp, scope, meta info).
  static const TextStyle _meta = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Caption — testo molto piccolo (badge, helper, hint).
  static const TextStyle _caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
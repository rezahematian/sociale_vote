import 'package:flutter/material.dart';

import 'colors.dart';
import 'radius.dart';
import 'typography.dart';

/// Theme centrale di Sociale_Vote.
///
/// Obiettivi:
/// - Usare SOLO i colori definiti in [AppColors]
/// - Nessun colore hardcoded nel ThemeData
/// - Base pulita per i prossimi step (typography, component system)
class AppTheme {
  AppTheme._();

  /// Theme principale (light) dell'app.
  static final ThemeData lightTheme = _buildLightTheme();

  /// Alias comodo, in caso il codice esistente usi `AppTheme.theme`.
  static ThemeData get theme => lightTheme;

  static ThemeData _buildLightTheme() {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textInverted,
      secondary: AppColors.cool,
      onSecondary: AppColors.textInverted,
      error: AppColors.error,
      onError: AppColors.textInverted,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    );

    return ThemeData(
      // =========================================================
      // BASE COLORI
      // =========================================================
      colorScheme: colorScheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.divider,
      disabledColor: AppColors.iconDisabled,
      hintColor: AppColors.textMuted,
      iconTheme: const IconThemeData(
        color: AppColors.icon,
      ),

      // =========================================================
      // APP BAR
      // =========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // =========================================================
      // CARD
      // =========================================================
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: const BorderSide(
            color: AppColors.borderSoft,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // =========================================================
      // BUTTON
      // =========================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.primary.withValues(alpha: 0.4);
            }
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.all<Color>(
            AppColors.textInverted,
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryDark.withValues(alpha: 0.12);
            }
            return null;
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
          ),
          minimumSize: WidgetStateProperty.all<Size>(
            const Size(64, 44),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primarySoftBackground;
            }
            return null;
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
          ),
          minimumSize: WidgetStateProperty.all<Size>(
            const Size(48, 36),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
          side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(
              color: AppColors.primary,
              width: 1,
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primarySoftBackground;
            }
            return null;
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
          ),
          minimumSize: WidgetStateProperty.all<Size>(
            const Size(48, 36),
          ),
        ),
      ),

      // =========================================================
      // INPUT
      // =========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.borderSoft,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.borderSoft,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.2,
          ),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        helperStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
        ),
      ),

      // =========================================================
      // LIST TILE / BOTTOM SHEET / SNACKBAR
      // =========================================================
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.icon,
        textColor: AppColors.textPrimary,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shadowColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sheetRadius,
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: TextStyle(
          color: AppColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // =========================================================
      // TEXT THEME — usa il sistema tipografico centrale
      // =========================================================
      textTheme: AppTypography.textTheme,
    );
  }
}
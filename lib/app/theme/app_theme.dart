import 'package:flutter/material.dart';

import 'colors.dart';
import 'radius.dart';
import 'spacing.dart';
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

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.divider,
      disabledColor: AppColors.disabled,
      hintColor: AppColors.textMuted,
      shadowColor: AppColors.shadow,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textTheme: AppTypography.textTheme,
      primaryTextTheme: AppTypography.textTheme,
      iconTheme: const IconThemeData(
        color: AppColors.icon,
      ),
    );

    return base.copyWith(
      // =========================================================
      // APP BAR
      // =========================================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.textTheme.headlineMedium,
        iconTheme: const IconThemeData(
          color: AppColors.icon,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.icon,
        ),
      ),

      // =========================================================
      // CARD
      // =========================================================
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: const BorderSide(
            color: AppColors.borderSoft,
            width: 1,
          ),
        ),
      ),

      // =========================================================
      // DIVIDER
      // =========================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // =========================================================
      // BUTTONS
      // =========================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all<TextStyle?>(
            AppTypography.textTheme.labelLarge,
          ),
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
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.xs,
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all<TextStyle?>(
            AppTypography.textTheme.labelLarge,
          ),
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
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.xs,
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all<TextStyle?>(
            AppTypography.textTheme.labelLarge,
          ),
          foregroundColor: WidgetStateProperty.all<Color>(
            AppColors.primary,
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
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.xxs,
            ),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all<TextStyle?>(
            AppTypography.textTheme.labelLarge,
          ),
          foregroundColor: WidgetStateProperty.all<Color>(
            AppColors.primary,
          ),
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
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.xxs,
            ),
          ),
        ),
      ),

      // =========================================================
      // INPUT
      // =========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
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
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textMuted,
        ),
        helperStyle: AppTypography.textTheme.labelSmall,
        errorStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.error,
        ),
      ),

      // =========================================================
      // CHIP
      // =========================================================
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        disabledColor: AppColors.disabled,
        selectedColor: AppColors.primarySoftBackground,
        secondarySelectedColor: AppColors.primarySoftBackground,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        labelStyle: AppTypography.textTheme.labelMedium!.copyWith(
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: AppTypography.textTheme.labelMedium!.copyWith(
          color: AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pillRadius,
          side: const BorderSide(
            color: AppColors.borderSoft,
            width: 1,
          ),
        ),
        side: const BorderSide(
          color: AppColors.borderSoft,
          width: 1,
        ),
      ),

      // =========================================================
      // LIST TILE / FAB / DIALOG / BOTTOM SHEET / SNACKBAR
      // =========================================================
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.icon,
        textColor: AppColors.textPrimary,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverted,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialogRadius,
        ),
        titleTextStyle: AppTypography.textTheme.headlineSmall,
        contentTextStyle: AppTypography.textTheme.bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sheetRadius,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: AppTypography.textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
      ),
    );
  }
}
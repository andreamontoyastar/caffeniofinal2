import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_border_radius.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Caffenio — ThemeData completo
///
/// Uso:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// )
/// ```
abstract final class AppTheme {
  // ── Color Schemes ─────────────────────────────────────────────────────────

  static ColorScheme get _lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        // Primary
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        // Secondary
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        // Tertiary
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        // Error
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onPrimaryContainer,
        // Surface / Background
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
        inverseSurface: AppColors.onBackground,
        onInverseSurface: AppColors.surface,
        inversePrimary: AppColors.primaryLight,
      );

  static ColorScheme get _darkColorScheme => ColorScheme(
        brightness: Brightness.dark,
        // Primary
        primary: AppColors.dark.primary,
        onPrimary: AppColors.dark.onPrimary,
        primaryContainer: AppColors.dark.primaryContainer,
        onPrimaryContainer: AppColors.dark.onPrimaryContainer,
        // Secondary
        secondary: AppColors.dark.secondary,
        onSecondary: AppColors.dark.onSecondary,
        secondaryContainer: AppColors.dark.secondaryContainer,
        onSecondaryContainer: AppColors.dark.onSecondaryContainer,
        // Tertiary
        tertiary: AppColors.dark.tertiary,
        onTertiary: AppColors.dark.onTertiary,
        tertiaryContainer: AppColors.dark.tertiaryContainer,
        onTertiaryContainer: AppColors.dark.onTertiaryContainer,
        // Error
        error: AppColors.dark.error,
        onError: AppColors.dark.onError,
        errorContainer: AppColors.dark.errorContainer,
        onErrorContainer: AppColors.dark.onPrimaryContainer,
        // Surface / Background
        surface: AppColors.dark.surface,
        onSurface: AppColors.dark.onSurface,
        surfaceContainerHighest: AppColors.dark.surfaceVariant,
        onSurfaceVariant: AppColors.dark.onSurfaceVariant,
        outline: AppColors.dark.outline,
        outlineVariant: AppColors.dark.outlineVariant,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
        inverseSurface: AppColors.dark.onSurface,
        onInverseSurface: AppColors.dark.surface,
        inversePrimary: AppColors.primary,
      );

  // ── Light Theme ───────────────────────────────────────────────────────────

  static ThemeData get light => _buildTheme(
        colorScheme: _lightColorScheme,
        isDark: false,
      );

  // ── Dark Theme ────────────────────────────────────────────────────────────

  static ThemeData get dark => _buildTheme(
        colorScheme: _darkColorScheme,
        isDark: true,
      );

  // ── Builder interno ───────────────────────────────────────────────────────

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final textTheme = AppTypography.buildTextTheme(isDark: isDark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.dark.background : AppColors.background,
      splashFactory: InkSparkle.splashFactory,

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor:
            isDark ? AppColors.dark.surface : AppColors.surface,
        foregroundColor:
            isDark ? AppColors.dark.onSurface : AppColors.onSurface,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: isDark ? AppColors.dark.onSurface : AppColors.onSurface,
          fontSize: 20,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.dark.onSurface : AppColors.onSurface,
          size: AppSpacing.iconSize,
        ),
      ),

      // ── NavigationBar ──────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: AppSpacing.bottomNavHeight,
        backgroundColor:
            isDark ? AppColors.dark.surface : AppColors.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? colorScheme.primary : AppColors.primary,
          foregroundColor:
              isDark ? colorScheme.onPrimary : AppColors.onPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
          textStyle: AppTypography.button,
          padding: AppSpacing.buttonPadding,
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 4;
            if (states.contains(WidgetState.hovered)) return 2;
            return 0;
          }),
        ),
      ),

      // ── FilledButton ───────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor:
              isDark ? colorScheme.primary : AppColors.primary,
          foregroundColor:
              isDark ? colorScheme.onPrimary : AppColors.onPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTypography.button,
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorderRadius.mdAll,
          ),
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.dark.surface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.card,
        ),
        margin: EdgeInsets.zero,
      ),

      // ── InputDecoration ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.dark.surfaceVariant
            : AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(
            color: isDark ? AppColors.dark.outline : AppColors.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(
            color: isDark ? AppColors.dark.outline : AppColors.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: isDark
              ? AppColors.dark.onSurfaceVariant
              : AppColors.onSurfaceVariant,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: isDark
              ? AppColors.dark.onSurfaceVariant
              : AppColors.onSurfaceVariant,
        ),
        floatingLabelStyle: AppTypography.bodySmall.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.error,
        ),
      ),

      // ── Chip ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.dark.surfaceVariant
            : AppColors.surfaceVariant,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: AppTypography.chip,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.chip,
        ),
        padding: AppSpacing.chipPadding,
      ),

      // ── BottomSheet ────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDark ? AppColors.dark.surface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.bottomSheet,
        ),
        showDragHandle: true,
        dragHandleColor: isDark
            ? AppColors.dark.outlineVariant
            : AppColors.outlineVariant,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor:
            isDark ? AppColors.dark.surface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.dialog,
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: isDark ? AppColors.dark.onSurface : AppColors.onSurface,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.dark.onSurface : AppColors.onSurface,
        ),
      ),

      // ── FloatingActionButton ───────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.lgAll,
        ),
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dark.outlineVariant : AppColors.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? AppColors.dark.onSurface : AppColors.onSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.dark.surface : AppColors.surface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdAll,
        ),
      ),

      // ── Switch ─────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),

      // ── ProgressIndicator ──────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),

      // ── TabBar ─────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: isDark
            ? AppColors.dark.onSurfaceVariant
            : AppColors.onSurfaceVariant,
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        dividerColor: Colors.transparent,
      ),

      // ── ListTile ───────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: AppTypography.titleSmall,
        subtitleTextStyle: AppTypography.bodySmall,
        iconColor: isDark
            ? AppColors.dark.onSurfaceVariant
            : AppColors.onSurfaceVariant,
      ),

      // ── Icon ───────────────────────────────────────────────────────────
      iconTheme: IconThemeData(
        size: AppSpacing.iconSize,
        color: isDark ? AppColors.dark.onSurface : AppColors.onSurface,
      ),
    );
  }
}

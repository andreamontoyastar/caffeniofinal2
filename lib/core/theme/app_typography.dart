import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Caffenio — Sistema tipográfico
///
/// Playfair Display → display, headings grandes
/// Nunito           → body, labels, botones, UI
///
/// Uso: `AppTypography.displayLarge`, `Theme.of(context).textTheme`
abstract final class AppTypography {
  // ── Playfair Display (títulos y display) ──────────────────────────────────

  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.12,
        color: AppColors.onBackground,
      );

  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.16,
        color: AppColors.onBackground,
      );

  static TextStyle get displaySmall => GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.22,
        color: AppColors.onBackground,
      );

  static TextStyle get headlineLarge => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.25,
        color: AppColors.onBackground,
      );

  static TextStyle get headlineMedium => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.29,
        color: AppColors.onBackground,
      );

  static TextStyle get headlineSmall => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: AppColors.onBackground,
      );

  // ── Nunito (UI, body, labels) ─────────────────────────────────────────────

  static TextStyle get titleLarge => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.27,
        color: AppColors.onBackground,
      );

  static TextStyle get titleMedium => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.50,
        color: AppColors.onBackground,
      );

  static TextStyle get titleSmall => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.onBackground,
      );

  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: AppColors.onBackground,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: AppColors.onBackground,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelLarge => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.onBackground,
      );

  static TextStyle get labelMedium => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
        color: AppColors.onBackground,
      );

  static TextStyle get labelSmall => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: AppColors.onSurfaceVariant,
      );

  // ── Estilos especiales Caffenio ───────────────────────────────────────────

  /// Precio de producto
  static TextStyle get price => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0,
      );

  /// Precio grande (hero de producto)
  static TextStyle get priceLarge => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0,
      );

  /// Puntos de lealtad
  static TextStyle get loyaltyPoints => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.gold,
        letterSpacing: -0.5,
      );

  /// Etiqueta de categoría / chip
  static TextStyle get chip => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  /// Texto de botón
  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        height: 1.4,
      );

  /// Texto de botón pequeño
  static TextStyle get buttonSmall => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        height: 1.4,
      );

  // ── TextTheme completo ────────────────────────────────────────────────────

  /// Construye el TextTheme de Material 3 completo.
  static TextTheme buildTextTheme({bool isDark = false}) {
    final Color textColor =
        isDark ? AppColors.dark.onBackground : AppColors.onBackground;
    final Color mutedColor =
        isDark ? AppColors.dark.onSurfaceVariant : AppColors.onSurfaceVariant;

    return TextTheme(
      displayLarge: displayLarge.copyWith(color: textColor),
      displayMedium: displayMedium.copyWith(color: textColor),
      displaySmall: displaySmall.copyWith(color: textColor),
      headlineLarge: headlineLarge.copyWith(color: textColor),
      headlineMedium: headlineMedium.copyWith(color: textColor),
      headlineSmall: headlineSmall.copyWith(color: textColor),
      titleLarge: titleLarge.copyWith(color: textColor),
      titleMedium: titleMedium.copyWith(color: textColor),
      titleSmall: titleSmall.copyWith(color: textColor),
      bodyLarge: bodyLarge.copyWith(color: textColor),
      bodyMedium: bodyMedium.copyWith(color: textColor),
      bodySmall: bodySmall.copyWith(color: mutedColor),
      labelLarge: labelLarge.copyWith(color: textColor),
      labelMedium: labelMedium.copyWith(color: textColor),
      labelSmall: labelSmall.copyWith(color: mutedColor),
    );
  }
}

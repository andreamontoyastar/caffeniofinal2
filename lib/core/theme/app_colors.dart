import 'package:flutter/material.dart';

/// Caffenio — Sistema de colores
///
/// Paleta completa con soporte para modo claro y oscuro.
/// Uso: `AppColors.primary`, `AppColors.dark.surface`, etc.
abstract final class AppColors {
  // ── Primarios (Rojo Caffenio) ─────────────────────────────────────────────
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryLight = Color(0xFFEF5350);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryContainer = Color(0xFFEF9A9A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF410002);

  // ── Secundarios (Café) ────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF5D4037);
  static const Color secondaryLight = Color(0xFF8D6E63);
  static const Color secondaryDark = Color(0xFF3E2723);
  static const Color secondaryContainer = Color(0xFFBCAAA4);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1B0000);

  // ── Terciarios (Dorado cálido) ────────────────────────────────────────────
  static const Color tertiary = Color(0xFFE65100);
  static const Color tertiaryLight = Color(0xFFFF7043);
  static const Color tertiaryContainer = Color(0xFFFFCC80);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF3E1000);

  // ── Neutros (modo claro) ──────────────────────────────────────────────────
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFF0EDED);
  static const Color outline = Color(0xFF7A7A7A);
  static const Color outlineVariant = Color(0xFFB0B0B0);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onSurfaceVariant = Color(0xFF1A1A1A);

  // ── Semánticos ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF43A047);
  static const Color successContainer = Color(0xFFA5D6A7);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFF57F17);
  static const Color warningContainer = Color(0xFFFFE082);
  static const Color onWarning = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorContainer = Color(0xFFEF9A9A);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color info = Color(0xFF0277BD);
  static const Color infoContainer = Color(0xFF81D4FA);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ── Especiales ────────────────────────────────────────────────────────────
  static const Color gold = Color(0xFFFFB300);
  static const Color goldLight = Color(0xFFFFCA28);
  static const Color scrim = Color(0xFF000000);
  static const Color shadow = Color(0xFF000000);

  // ── Transparencias comunes ────────────────────────────────────────────────
  static const Color overlay04 = Color(0x0A000000);
  static const Color overlay08 = Color(0x14000000);
  static const Color overlay12 = Color(0x1F000000);
  static const Color overlay16 = Color(0x29000000);

  // ─────────────────────────────────────────────────────────────────────────
  // MODO OSCURO
  // ─────────────────────────────────────────────────────────────────────────

  /// Colores específicos para tema oscuro
  static const _DarkColors dark = _DarkColors();
}

final class _DarkColors {
  const _DarkColors();

  // ── Primarios dark (contraste legible) ────────────────────────────────────
  Color get primary => const Color(0xFFEF5350);
  Color get primaryLight => const Color(0xFFFFAB91);
  Color get primaryDark => const Color(0xFFE53935);
  Color get primaryContainer => const Color(0xFF5C1A1A);
  Color get onPrimary => const Color(0xFFFFFFFF);
  Color get onPrimaryContainer => const Color(0xFFFFDAD6);

  // ── Secundarios dark ──────────────────────────────────────────────────────
  Color get secondary => const Color(0xFF8D6E63);
  Color get secondaryContainer => const Color(0xFF4E342E);
  Color get onSecondary => const Color(0xFFFFFFFF);
  Color get onSecondaryContainer => const Color(0xFFEFEBE9);

  // ── Terciarios dark ───────────────────────────────────────────────────────
  Color get tertiary => const Color(0xFFFF8A65);
  Color get tertiaryContainer => const Color(0xFF6D3B00);
  Color get onTertiary => const Color(0xFFFFFFFF);
  Color get onTertiaryContainer => const Color(0xFFFFE0B2);

  // ── Neutros dark ──────────────────────────────────────────────────────────
  Color get background => const Color(0xFF121212);
  Color get surface => const Color(0xFF1E1E1E);
  Color get surfaceVariant => const Color(0xFF2C2C2C);
  Color get surfaceContainer => const Color(0xFF252525);
  Color get outline => const Color(0xFFE5E5EA);
  Color get outlineVariant => const Color(0xFF8E8E93);
  Color get onBackground => const Color(0xFFFFFFFF);
  Color get onSurface => const Color(0xFFFFFFFF);
  Color get onSurfaceVariant => const Color(0xFFFFFFFF);

  // ── Semánticos dark ───────────────────────────────────────────────────────
  Color get success => const Color(0xFF81C784);
  Color get successContainer => const Color(0xFF1B5E20);
  Color get onSuccess => const Color(0xFF003909);

  Color get warning => const Color(0xFFFFD54F);
  Color get warningContainer => const Color(0xFF7A4F00);
  Color get onWarning => const Color(0xFF402D00);

  Color get error => const Color(0xFFFFB4AB);
  Color get errorContainer => const Color(0xFF93000A);
  Color get onError => const Color(0xFF690005);
}

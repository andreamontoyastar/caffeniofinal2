import 'package:flutter/material.dart';

/// Caffenio — Sistema de espaciado
///
/// Escala de 8 puntos con tokens semánticos.
/// Uso: `AppSpacing.md`, `Gap(AppSpacing.lg)`, `SizedBox(height: AppSpacing.xl)`
abstract final class AppSpacing {
  // ── Escala base ───────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ── Tokens semánticos ─────────────────────────────────────────────────────
  static const double screenPadding = md;
  static const double cardPadding = md;
  static const double sectionGap = lg;
  static const double itemGap = sm;
  static const double iconGap = xs;
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 72.0;
  static const double chipHeight = 36.0;
  static const double avatarSize = 48.0;
  static const double avatarSizeLg = 80.0;
  static const double iconSize = 24.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeLg = 32.0;

  // ── EdgeInsets predefinidos ───────────────────────────────────────────────
  static const EdgeInsets pagePadding = EdgeInsets.all(screenPadding);
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets chipPadding =
      EdgeInsets.symmetric(horizontal: sm, vertical: xs);
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: sm);
}

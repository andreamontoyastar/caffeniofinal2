import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Caffenio — Sistema de sombras
///
/// Sombras sutiles y elegantes con color rojo/neutro.
/// Uso: `AppShadows.md`, `BoxDecoration(boxShadow: AppShadows.card)`
abstract final class AppShadows {
  // ── Sombras neutras ───────────────────────────────────────────────────────

  /// Sombra pequeña — para chips, badges, inputs
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // 5% opacidad
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x14000000), // 8% opacidad
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Sombra media — para cards, botones elevados
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacidad
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% opacidad
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Sombra grande — para modales, bottom sheets, elementos flotantes
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x26000000), // 15% opacidad
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x14000000), // 8% opacidad
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Sombra extra grande — para FABs, drawers
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x33000000), // 20% opacidad
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% opacidad
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ── Sombras con color primario (rojo) ─────────────────────────────────────

  /// Sombra roja sutil — para botones primarios, elementos destacados
  static final List<BoxShadow> primarySm = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.20),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  /// Sombra roja media — hover y pressed states
  static final List<BoxShadow> primaryMd = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.15),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Sombra roja fuerte — para elementos en foco (FAB, CTA principal)
  static final List<BoxShadow> primaryLg = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.40),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.20),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ── Tokens semánticos ─────────────────────────────────────────────────────
  static const List<BoxShadow> card = md;
  static const List<BoxShadow> dialog = lg;
  static const List<BoxShadow> bottomSheet = lg;
  static const List<BoxShadow> input = sm;
}

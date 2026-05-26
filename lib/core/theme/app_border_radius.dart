import 'package:flutter/material.dart';

/// Caffenio — Sistema de bordes redondeados
///
/// Uso: `AppBorderRadius.lg`, `BorderRadius.circular(AppBorderRadius.md)`
abstract final class AppBorderRadius {
  // ── Valores escalares ─────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 100.0;

  // ── BorderRadius objects ──────────────────────────────────────────────────
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  // ── Bordes asimétricos (útiles para cards/sheets) ─────────────────────────
  static const BorderRadius topLg = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
  static const BorderRadius topXl = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
  static const BorderRadius bottomLg = BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );
  static const BorderRadius bottomXl = BorderRadius.only(
    bottomLeft: Radius.circular(xl),
    bottomRight: Radius.circular(xl),
  );

  // ── Tokens semánticos ─────────────────────────────────────────────────────
  static const BorderRadius card = lgAll;
  static const BorderRadius button = fullAll;
  static const BorderRadius chip = fullAll;
  static const BorderRadius input = mdAll;
  static const BorderRadius dialog = xlAll;
  static const BorderRadius bottomSheet = topXl;
  static const BorderRadius image = lgAll;
  static const BorderRadius badge = fullAll;
  static const BorderRadius tooltip = smAll;
}

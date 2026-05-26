/// Caffenio — Rutas de assets locales
///
/// Centraliza todos los paths de assets para evitar magic strings.
/// Uso: `AssetConstants.logoFull`, `Image.asset(AssetConstants.splashLogo)`
abstract final class AssetConstants {
  // ── Base paths ────────────────────────────────────────────────────────────
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';

  // ── Imágenes ─────────────────────────────────────────────────────────────
  static const String logoFull = '$_images/logo_full.png';
  static const String logoMark = '$_images/logo_mark.png';
  static const String logoWhite = '$_images/logo_white.png';
  static const String splashLogo = '$_images/splash_logo.png';
  static const String appIcon = '$_images/app_icon.png';
  static const String appIconFg = '$_images/app_icon_fg.png';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.png';

  // ── Ilustraciones / estados vacíos ────────────────────────────────────────
  static const String emptyCart = '$_images/empty_cart.png';
  static const String emptyOrders = '$_images/empty_orders.png';
  static const String emptySearch = '$_images/empty_search.png';
  static const String emptyNotifications = '$_images/empty_notifications.png';
  static const String errorGeneral = '$_images/error_general.png';
  static const String errorNetwork = '$_images/error_network.png';
  static const String successCheckout = '$_images/success_checkout.png';
  static const String loyaltyBanner = '$_images/loyalty_banner.png';

  // ── Iconos SVG ────────────────────────────────────────────────────────────
  static const String iconCoffee = '$_icons/icon_coffee.svg';
  static const String iconEspresso = '$_icons/icon_espresso.svg';
  static const String iconTea = '$_icons/icon_tea.svg';
  static const String iconFood = '$_icons/icon_food.svg';
  static const String iconGoogle = '$_icons/icon_google.svg';
  static const String iconApple = '$_icons/icon_apple.svg';
  static const String iconStar = '$_icons/icon_star.svg';
  static const String iconLoyalty = '$_icons/icon_loyalty.svg';
  static const String iconBarista = '$_icons/icon_barista.svg';

  // ── Animaciones Lottie ────────────────────────────────────────────────────
  static const String animLoading = '$_animations/loading_coffee.json';
  static const String animSuccess = '$_animations/success.json';
  static const String animError = '$_animations/error.json';
  static const String animEmpty = '$_animations/empty.json';
  static const String animOrderPreparing = '$_animations/order_preparing.json';
  static const String animOrderReady = '$_animations/order_ready.json';
  static const String animLoyalty = '$_animations/loyalty_points.json';
  static const String animSplash = '$_animations/splash.json';
}

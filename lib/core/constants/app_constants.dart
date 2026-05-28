/// Caffenio — Constantes generales de la aplicación
abstract final class AppConstants {
  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'Caffenio';
  static const String appTagline = 'Tu café, a tu manera';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String packageName = 'com.caffenio.app';

  // ── Roles de usuario ──────────────────────────────────────────────────────
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';

  // ── Paginación ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int searchPageSize = 15;
  static const int ordersPageSize = 10;

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration httpTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);
  static const Duration sessionTimeout = Duration(days: 30);

  // ── Carrito ───────────────────────────────────────────────────────────────
  static const int maxCartItems = 20;
  static const int maxItemQuantity = 10;
  static const double minOrderAmount = 50.0; // MXN

  // ── Lealtad ───────────────────────────────────────────────────────────────
  static const double pointsPerPeso = 1.0; // 1 punto por cada $1 MXN
  static const double pesoPerPoint = 0.10; // $0.10 MXN por punto al canjear
  static const int minRedeemablePoints = 100;
  static const int welcomeBonusPoints = 0;

  // ── Personalización de productos ─────────────────────────────────────────
  static const List<String> productSizes = ['Chico', 'Mediano', 'Grande', 'Extra'];
  static const List<String> milkOptions = [
    'Entera',
    'Descremada',
    'Deslactosada',
    'Almendra',
    'Avena',
    'Soya',
    'Coco',
  ];

  // ── Estados de pedido ─────────────────────────────────────────────────────
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReady = 'ready';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  // ── Storage ───────────────────────────────────────────────────────────────
  static const String hiveBoxUser = 'caffenio_user';
  static const String hiveBoxSettings = 'caffenio_settings';
  static const String hiveBoxCart = 'caffenio_cart';
  static const String prefKeyTheme = 'pref_theme_mode';
  static const String prefKeyOnboarded = 'pref_onboarded';
  static const String prefKeyLanguage = 'pref_language';
  static const String secureKeyAuthToken = 'secure_auth_token';

  // ── Remote Config defaults ────────────────────────────────────────────────
  static const String rcKeyMaintenanceMode = 'maintenance_mode';
  static const String rcKeyForceUpdate = 'force_update';
  static const String rcKeyMinVersion = 'min_app_version';
  static const String rcKeyFeaturedBanners = 'featured_banners';
  static const String rcKeyLoyaltyEnabled = 'loyalty_enabled';
  static const String rcKeyPointsMultiplier = 'points_multiplier';

  // ── Imágenes / placeholders ───────────────────────────────────────────────
  static const String placeholderProductUrl =
      'https://placehold.co/400x300/D32F2F/FFFFFF?text=Caffenio';
  static const String placeholderAvatarUrl =
      'https://placehold.co/200x200/5D4037/FFFFFF?text=?';

  // ── FCM Topics ────────────────────────────────────────────────────────────
  static const String fcmTopicPromo = 'promotions';
  static const String fcmTopicOrders = 'orders';
  static const String fcmTopicAll = 'all_users';

  // ── Analytics events ──────────────────────────────────────────────────────
  static const String analyticsLogin = 'login';
  static const String analyticsSignup = 'sign_up';
  static const String analyticsAddToCart = 'add_to_cart';
  static const String analyticsRemoveFromCart = 'remove_from_cart';
  static const String analyticsBeginCheckout = 'begin_checkout';
  static const String analyticsPurchase = 'purchase';
  static const String analyticsViewItem = 'view_item';
  static const String analyticsSearch = 'search';
  static const String analyticsRedeemPoints = 'redeem_points';
}

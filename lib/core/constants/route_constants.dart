abstract final class RouteConstants {
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  static const String home = '/home';
  static const String catalog = '/home/catalog';
  static const String cart = '/cart';
  static const String orders = '/home/orders';
  static const String profile = '/home/profile';

  static const String productDetail = '/catalog/product/:productId';
  static const String productDetailName = 'productDetail';
  static const String categoryProducts = '/catalog/category/:categoryId';
  static const String search = '/catalog/search';

  static const String checkout = '/cart/checkout';
  static const String orderConfirmation = '/cart/confirmation';

  static const String orderDetail = '/orders/:orderId';
  static const String orderDetailName = 'orderDetail';
  static const String orderTracking = '/orders/:orderId/tracking';

  static const String loyalty = '/home/loyalty';
  static const String loyaltyRewards = '/loyalty/rewards';
  static const String loyaltyHistory = '/loyalty/history';

  static const String profileEdit = '/profile/edit';
  static const String profileAddresses = '/profile/addresses';
  static const String profilePayments = '/profile/payments';
  static const String profileNotifications = '/profile/notifications';

  static const String settings = '/settings';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsAbout = '/settings/about';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminProductCreate = '/admin/products/create';
  static const String adminProductEdit = '/admin/products/:productId/edit';
  static const String adminCategories = '/admin/categories';
  static const String adminCategoriesCreate = '/admin/categories/create';
  static const String adminCategoriesEdit = '/admin/categories/:categoryId/edit';
  static const String adminSucursales = '/admin/sucursales';
  static const String adminSucursalesCreate = '/admin/sucursales/create';
  static const String adminSucursalesEdit = '/admin/sucursales/:sucursalId/edit';
  static const String adminOrders = '/admin/orders';
  static const String adminUsers = '/admin/users';
  static const String adminUserDetail = '/admin/users/:userId';
  static const String adminBranches = '/admin/branches';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminPromotions = '/admin/promotions';
  static const String adminSuppliers = '/admin/suppliers';
  static const String adminPurchaseOrders = '/admin/purchase-orders';

  static const String baristaQueue = '/barista/orders';
  static const String baristaOrderDetail = '/barista/orders/:orderId';

  static const String notifications = '/notifications';
  static const String maintenance = '/maintenance';
  static const String forceUpdate = '/force-update';
  static const String error = '/error';
}

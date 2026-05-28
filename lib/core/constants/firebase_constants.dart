/// Caffenio — Nombres de colecciones y documentos de Firestore
///
/// Centraliza todos los paths de Firestore para evitar magic strings.
/// Uso: `FirebaseConstants.usersCollection`
abstract final class FirebaseConstants {
  // ── Colecciones raíz ──────────────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String loyaltyCollection = 'loyaltyCards';
  /// Colección legada (migración automática a [loyaltyCollection]).
  static const String loyaltyLegacyCollection = 'loyalty';
  static const String branchesCollection = 'branches';
  static const String promotionsCollection = 'promotions';
  static const String notificationsCollection = 'notifications';
  static const String reviewsCollection = 'reviews';
  static const String bannersCollection = 'banners';
  static const String configCollection = 'config';
  static const String inventoryCollection = 'inventory';
  static const String employeesCollection = 'employees';
  static const String suppliersCollection = 'suppliers';
  static const String recipesCollection = 'recipes';
  static const String purchaseOrdersCollection = 'purchaseOrders';
  static const String purchaseOrderDetailsCollection = 'purchaseOrderDetails';
  static const String loyaltyCardsCollection = loyaltyCollection;
  static const String sucursalesCollection = branchesCollection;

  // ── Subcolecciones ────────────────────────────────────────────────────────
  static const String orderItemsSubcollection = 'items';
  static const String loyaltyTransactionsSubcollection = 'transactions';
  static const String userNotificationsSubcollection = 'notifications';
  static const String userAddressesSubcollection = 'addresses';

  // ── Campos comunes (evitar magic strings en queries) ──────────────────────
  static const String fieldId = 'id';
  static const String fieldUid = 'uid';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldDeletedAt = 'deletedAt';
  static const String fieldIsActive = 'isActive';
  static const String fieldIsDeleted = 'isDeleted';

  // ── Campos de usuario ─────────────────────────────────────────────────────
  static const String fieldUserEmail = 'email';
  static const String fieldUserDisplayName = 'displayName';
  static const String fieldUserPhotoUrl = 'photoUrl';
  static const String fieldUserRole = 'role';
  static const String fieldUserPhone = 'phone';
  static const String fieldUserFcmToken = 'fcmToken';
  static const String fieldUserBranchId = 'branchId';
  static const String fieldUserAddress = 'address';

  // ── Campos de producto ────────────────────────────────────────────────────
  static const String fieldProductName = 'name';
  static const String fieldProductDescription = 'description';
  static const String fieldProductPrice = 'price';
  static const String fieldProductCategory = 'categoryId';
  static const String fieldProductImageUrl = 'imageUrl';
  static const String fieldProductIsAvailable = 'isAvailable';
  static const String fieldProductIsFeatured = 'isFeatured';
  static const String fieldProductSortOrder = 'sortOrder';
  static const String fieldProductTags = 'tags';
  static const String fieldProductNutrition = 'nutrition';
  static const String fieldProductCustomizations = 'customizations';

  // ── Campos de pedido ──────────────────────────────────────────────────────
  static const String fieldOrderUserId = 'userId';
  static const String fieldOrderBranchId = 'branchId';
  static const String fieldOrderStatus = 'status';
  static const String fieldOrderTotal = 'total';
  static const String fieldOrderSubtotal = 'subtotal';
  static const String fieldOrderPointsEarned = 'pointsEarned';
  static const String fieldOrderPointsRedeemed = 'pointsRedeemed';
  static const String fieldOrderNotes = 'notes';
  static const String fieldOrderPickupTime = 'pickupTime';
  static const String fieldOrderEstimatedTime = 'estimatedReadyTime';
  static const String fieldOrderPaymentMethod = 'paymentMethod';
  static const String fieldOrderBaristaId = 'baristaId';

  // ── Campos de lealtad ─────────────────────────────────────────────────────
  static const String fieldLoyaltyPoints = 'points';
  static const String fieldLoyaltyTotalEarned = 'totalEarned';
  static const String fieldLoyaltyTotalRedeemed = 'totalRedeemed';
  static const String fieldLoyaltyLevel = 'level';
  static const String fieldTransactionType = 'type';
  static const String fieldTransactionAmount = 'amount';
  static const String fieldTransactionOrderId = 'orderId';

  // ── Documentos de configuración ───────────────────────────────────────────
  static const String configDocApp = 'app_config';
  static const String configDocLoyalty = 'loyalty_config';
  static const String configDocPayments = 'payments_config';

  // ── Storage paths ─────────────────────────────────────────────────────────
  static const String storageProductImages = 'products/images';
  static const String storageUserAvatars = 'users/avatars';
  static const String storageBannerImages = 'banners';
  static const String storageCategoryImages = 'categories/images';

  // ── Índices compuestos frecuentes (documentados para Cloud Console) ────────
  /// orders: userId ASC, createdAt DESC
  /// orders: branchId ASC, status ASC, createdAt DESC
  /// products: categoryId ASC, sortOrder ASC, isAvailable DESC
  /// products: isFeatured DESC, sortOrder ASC
}

import 'package:caffenio/features/admin/data/datasources/employee_remote_datasource.dart';
import 'package:caffenio/features/admin/data/datasources/inventory_remote_datasource.dart';
import 'package:caffenio/features/admin/data/datasources/promotion_remote_datasource.dart';
import 'package:caffenio/features/admin/data/datasources/purchase_order_remote_datasource.dart';
import 'package:caffenio/features/admin/data/datasources/recipe_remote_datasource.dart';
import 'package:caffenio/features/admin/data/datasources/sucursal_remote_datasource.dart';
import 'package:caffenio/features/admin/data/datasources/supplier_remote_datasource.dart';
import 'package:caffenio/features/admin/data/repositories/employee_repository_impl.dart';
import 'package:caffenio/features/admin/data/repositories/inventory_repository_impl.dart';
import 'package:caffenio/features/admin/data/repositories/promotion_repository_impl.dart';
import 'package:caffenio/features/admin/data/repositories/purchase_order_repository_impl.dart';
import 'package:caffenio/features/admin/data/repositories/recipe_repository_impl.dart';
import 'package:caffenio/features/admin/data/repositories/sucursal_repository_impl.dart';
import 'package:caffenio/features/admin/data/repositories/supplier_repository_impl.dart';
import 'package:caffenio/features/admin/domain/repositories/employee_repository.dart';
import 'package:caffenio/features/admin/domain/repositories/inventory_repository.dart';
import 'package:caffenio/features/admin/domain/repositories/promotion_repository.dart';
import 'package:caffenio/features/admin/domain/repositories/purchase_order_repository.dart';
import 'package:caffenio/features/admin/domain/repositories/recipe_repository.dart';
import 'package:caffenio/features/admin/domain/repositories/sucursal_repository.dart';
import 'package:caffenio/features/admin/domain/repositories/supplier_repository.dart';
import 'package:caffenio/features/admin/domain/services/stock_automation_service.dart';
import 'package:caffenio/features/admin/domain/usecases/employee_usecases.dart';
import 'package:caffenio/features/admin/domain/usecases/inventory_usecases.dart';
import 'package:caffenio/features/admin/domain/usecases/promotion_usecases.dart';
import 'package:caffenio/features/admin/domain/usecases/purchase_order_usecases.dart';
import 'package:caffenio/features/admin/domain/usecases/recipe_usecases.dart';
import 'package:caffenio/features/admin/domain/usecases/sucursal_usecases.dart';
import 'package:caffenio/features/admin/domain/usecases/supplier_usecases.dart';
import 'package:caffenio/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:caffenio/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:caffenio/features/auth/domain/repositories/auth_repository.dart';
import 'package:caffenio/features/catalog/data/datasources/product_remote_datasource.dart';
import 'package:caffenio/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:caffenio/features/catalog/domain/repositories/product_repository.dart';
import 'package:caffenio/features/loyalty/data/datasources/loyalty_remote_datasource.dart';
import 'package:caffenio/features/loyalty/data/repositories/loyalty_repository_impl.dart';
import 'package:caffenio/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:caffenio/features/loyalty/domain/usecases/get_loyalty_card.dart';
import 'package:caffenio/features/loyalty/domain/usecases/update_loyalty_points.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:caffenio/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:caffenio/features/orders/data/repositories/order_repository_impl.dart';
import 'package:caffenio/features/orders/domain/repositories/order_repository.dart';
import 'package:caffenio/features/orders/domain/usecases/get_customer_orders.dart';
import 'package:caffenio/features/orders/domain/usecases/place_order.dart';
import 'package:caffenio/features/orders/domain/usecases/watch_all_orders.dart';
import 'package:caffenio/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instancia global del service locator.
final GetIt sl = GetIt.instance;

/// Registra todas las dependencias de la aplicación.
///
/// Llamar una sola vez en [main] antes de [runApp].
Future<void> setupServiceLocator() async {
  // ── External / Platform ───────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: DefaultFirebaseOptions.googleWebClientId,
    ),
  );

  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // ── Auth Feature ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
      googleSignIn: sl<GoogleSignIn>(),
      notificationsDataSource: sl<NotificationsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl<ProductRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: sl<OrderRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<PlaceOrder>(
    () => PlaceOrder(repository: sl<OrderRepository>()),
  );

  sl.registerLazySingleton<GetCustomerOrders>(
    () => GetCustomerOrders(repository: sl<OrderRepository>()),
  );

  sl.registerLazySingleton<WatchAllOrders>(
    () => WatchAllOrders(repository: sl<OrderRepository>()),
  );

  sl.registerLazySingleton<LoyaltyRemoteDataSource>(
    () => LoyaltyRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<LoyaltyRepository>(
    () => LoyaltyRepositoryImpl(
      remoteDataSource: sl<LoyaltyRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetLoyaltyCard>(
    () => GetLoyaltyCard(repository: sl<LoyaltyRepository>()),
  );

  sl.registerLazySingleton<UpdateLoyaltyPoints>(
    () => UpdateLoyaltyPoints(repository: sl<LoyaltyRepository>()),
  );

  // ── Admin Features: Sucursales ────────────────────────────────────────────
  sl.registerLazySingleton<SucursalRemoteDataSource>(
    () => SucursalRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<SucursalRepository>(
    () => SucursalRepositoryImpl(
      remoteDataSource: sl<SucursalRemoteDataSource>(),
    ),
  );

  // ── Admin Features: Promociones ───────────────────────────────────────────
  sl.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<PromotionRepository>(
    () => PromotionRepositoryImpl(
      remoteDataSource: sl<PromotionRemoteDataSource>(),
    ),
  );

  // ── Admin Features: Inventario ───────────────────────────────────────────
  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(
      remoteDataSource: sl<InventoryRemoteDataSource>(),
    ),
  );

  // ── Admin Features: Empleados ────────────────────────────────────────────
  sl.registerLazySingleton<EmployeeRemoteDataSource>(
    () => EmployeeRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(
      remoteDataSource: sl<EmployeeRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<SupplierRemoteDataSource>(
    () => SupplierRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepositoryImpl(
      remoteDataSource: sl<SupplierRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<PurchaseOrderRemoteDataSource>(
    () => PurchaseOrderRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<PurchaseOrderRepository>(
    () => PurchaseOrderRepositoryImpl(
      remoteDataSource: sl<PurchaseOrderRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<RecipeRemoteDataSource>(
    () => RecipeRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(
      remoteDataSource: sl<RecipeRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<StockAutomationService>(
    () => StockAutomationService(
      getInventoryBySucursalAndIngredient:
          sl<GetInventoryBySucursalAndIngredient>(),
      decrementInventoryStock: sl<DecrementInventoryStock>(),
      getRecipesByProductId: sl<GetRecipesByProductId>(),
      watchAllSuppliers: sl<WatchAllSuppliers>(),
      createPurchaseOrder: sl<CreatePurchaseOrder>(),
    ),
  );

  // ── Admin Use Cases: Sucursales ───────────────────────────────────────────
  sl.registerLazySingleton<WatchAllSucursales>(
    () => WatchAllSucursales(repository: sl<SucursalRepository>()),
  );
  sl.registerLazySingleton<GetSucursalById>(
    () => GetSucursalById(repository: sl<SucursalRepository>()),
  );
  sl.registerLazySingleton<CreateSucursal>(
    () => CreateSucursal(repository: sl<SucursalRepository>()),
  );
  sl.registerLazySingleton<UpdateSucursal>(
    () => UpdateSucursal(repository: sl<SucursalRepository>()),
  );
  sl.registerLazySingleton<DeleteSucursal>(
    () => DeleteSucursal(repository: sl<SucursalRepository>()),
  );

  // ── Admin Use Cases: Promociones ─────────────────────────────────────────
  sl.registerLazySingleton<WatchAllPromotions>(
    () => WatchAllPromotions(repository: sl<PromotionRepository>()),
  );
  sl.registerLazySingleton<GetPromotionById>(
    () => GetPromotionById(repository: sl<PromotionRepository>()),
  );
  sl.registerLazySingleton<CreatePromotion>(
    () => CreatePromotion(repository: sl<PromotionRepository>()),
  );
  sl.registerLazySingleton<UpdatePromotion>(
    () => UpdatePromotion(repository: sl<PromotionRepository>()),
  );
  sl.registerLazySingleton<DeletePromotion>(
    () => DeletePromotion(repository: sl<PromotionRepository>()),
  );

  // ── Admin Use Cases: Inventario ───────────────────────────────────────────
  sl.registerLazySingleton<WatchInventoryBySucursal>(
    () => WatchInventoryBySucursal(repository: sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<GetInventoryById>(
    () => GetInventoryById(repository: sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<GetInventoryBySucursalAndIngredient>(
    () => GetInventoryBySucursalAndIngredient(
        repository: sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<CreateInventoryItem>(
    () => CreateInventoryItem(repository: sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<UpdateInventoryItem>(
    () => UpdateInventoryItem(repository: sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<DeleteInventoryItem>(
    () => DeleteInventoryItem(repository: sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<DecrementInventoryStock>(
    () => DecrementInventoryStock(repository: sl<InventoryRepository>()),
  );

  sl.registerLazySingleton<WatchAllSuppliers>(
    () => WatchAllSuppliers(repository: sl<SupplierRepository>()),
  );
  sl.registerLazySingleton<GetSupplierById>(
    () => GetSupplierById(repository: sl<SupplierRepository>()),
  );
  sl.registerLazySingleton<CreateSupplier>(
    () => CreateSupplier(repository: sl<SupplierRepository>()),
  );
  sl.registerLazySingleton<UpdateSupplier>(
    () => UpdateSupplier(repository: sl<SupplierRepository>()),
  );
  sl.registerLazySingleton<DeleteSupplier>(
    () => DeleteSupplier(repository: sl<SupplierRepository>()),
  );

  sl.registerLazySingleton<WatchAllPurchaseOrders>(
    () => WatchAllPurchaseOrders(repository: sl<PurchaseOrderRepository>()),
  );
  sl.registerLazySingleton<GetPurchaseOrderById>(
    () => GetPurchaseOrderById(repository: sl<PurchaseOrderRepository>()),
  );
  sl.registerLazySingleton<CreatePurchaseOrder>(
    () => CreatePurchaseOrder(repository: sl<PurchaseOrderRepository>()),
  );
  sl.registerLazySingleton<UpdatePurchaseOrder>(
    () => UpdatePurchaseOrder(repository: sl<PurchaseOrderRepository>()),
  );
  sl.registerLazySingleton<DeletePurchaseOrder>(
    () => DeletePurchaseOrder(repository: sl<PurchaseOrderRepository>()),
  );

  sl.registerLazySingleton<GetRecipesByProductId>(
    () => GetRecipesByProductId(repository: sl<RecipeRepository>()),
  );

  // ── Admin Use Cases: Empleados ───────────────────────────────────────────
  sl.registerLazySingleton<WatchAllEmployees>(
    () => WatchAllEmployees(repository: sl<EmployeeRepository>()),
  );
  sl.registerLazySingleton<WatchEmployeesBySucursal>(
    () => WatchEmployeesBySucursal(repository: sl<EmployeeRepository>()),
  );
  sl.registerLazySingleton<GetEmployeeByUid>(
    () => GetEmployeeByUid(repository: sl<EmployeeRepository>()),
  );
  sl.registerLazySingleton<CreateEmployee>(
    () => CreateEmployee(repository: sl<EmployeeRepository>()),
  );
  sl.registerLazySingleton<UpdateEmployeeRole>(
    () => UpdateEmployeeRole(repository: sl<EmployeeRepository>()),
  );
  sl.registerLazySingleton<UpdateEmployeeSucursal>(
    () => UpdateEmployeeSucursal(repository: sl<EmployeeRepository>()),
  );
  sl.registerLazySingleton<DeleteEmployee>(
    () => DeleteEmployee(repository: sl<EmployeeRepository>()),
  );
  sl.registerLazySingleton<DeactivateEmployee>(
    () => DeactivateEmployee(repository: sl<EmployeeRepository>()),
  );
}

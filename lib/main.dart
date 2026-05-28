import 'dart:async';
import 'package:caffenio/core/services/notification_local_service.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/core/theme/app_theme.dart';
import 'package:caffenio/features/auth/domain/repositories/auth_repository.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/cart/presentation/providers/cart_provider.dart';
import 'package:caffenio/features/catalog/domain/repositories/product_repository.dart';
import 'package:caffenio/features/catalog/presentation/providers/product_provider.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:caffenio/features/orders/presentation/providers/order_provider.dart';
import 'package:caffenio/features/seed/seed_data.dart';
import 'package:caffenio/features/settings/presentation/providers/settings_provider.dart';
import 'package:caffenio/firebase_options.dart';
import 'package:caffenio/navigation/app_router.dart';
import 'package:caffenio/shared/models/app_notification_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar notificaciones locales
  try {
    await NotificationLocalService.instance.initialize();
  } catch (_) {}

  // Inicializar Firebase (manejo de inicialización duplicada del lado nativo)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase ya fue inicializado por el lado nativo de Android; ignorar.
  }

  // Inicializar localizador de servicios (DI)
  await setupServiceLocator();

  // Insertar datos de ejemplo en Firestore (solo la primera vez)
  await SeedData.seedIfNeeded();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(
            sharedPreferences: sl<SharedPreferences>(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authRepository: sl<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(
            repository: sl<ProductRepository>(),
          ),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;
  StreamSubscription<List<AppNotificationModel>>? _notificationSubscription;
  Set<String>? _knownNotificationIds;
  String? _lastUserUid;

  @override
  void initState() {
    super.initState();
    // Inicializar el router central inyectando el AuthProvider para reactividad
    _appRouter = AppRouter(authProvider: context.read<AuthProvider>());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final uid = authProvider.currentUser?.uid;
    if (uid != _lastUserUid) {
      _lastUserUid = uid;
      _notificationSubscription?.cancel();
      _knownNotificationIds = null;
      if (uid != null) {
        _notificationSubscription = sl<NotificationsRemoteDataSource>()
            .watchForUser(uid)
            .listen((notifications) {
          final ids = notifications.map((n) => n.id).toSet();
          if (_knownNotificationIds == null) {
            // Primer cargado: solo registrar las ya existentes para no repetir
            _knownNotificationIds = ids;
          } else {
            // Buscar nuevas notificaciones que no estaban registradas
            for (final item in notifications) {
              if (!_knownNotificationIds!.contains(item.id)) {
                _knownNotificationIds!.add(item.id);
                if (!item.read) {
                  NotificationLocalService.instance.showNotification(
                    title: item.title,
                    body: item.body,
                    id: item.id.hashCode,
                  );
                }
              }
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp.router(
      title: 'Caffenio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settingsProvider.themeMode,
      routerConfig: _appRouter.router,
    );
  }
}

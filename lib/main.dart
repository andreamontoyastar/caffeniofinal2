import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/core/theme/app_theme.dart';
import 'package:caffenio/features/auth/domain/repositories/auth_repository.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/cart/presentation/providers/cart_provider.dart';
import 'package:caffenio/features/catalog/domain/repositories/product_repository.dart';
import 'package:caffenio/features/catalog/presentation/providers/product_provider.dart';
import 'package:caffenio/features/orders/presentation/providers/order_provider.dart';
import 'package:caffenio/features/settings/presentation/providers/settings_provider.dart';
import 'package:caffenio/firebase_options.dart';
import 'package:caffenio/navigation/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar localizador de servicios (DI)
  await setupServiceLocator();

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

  @override
  void initState() {
    super.initState();
    // Inicializar el router central inyectando el AuthProvider para reactividad
    _appRouter = AppRouter(authProvider: context.read<AuthProvider>());
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

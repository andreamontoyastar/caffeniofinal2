import 'package:caffenio/core/constants/route_constants.dart';
import 'package:caffenio/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/admin_product_form_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/purchase_orders_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/suppliers_screen.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:caffenio/features/auth/presentation/screens/login_screen.dart';
import 'package:caffenio/features/auth/presentation/screens/register_screen.dart';
import 'package:caffenio/features/auth/presentation/screens/splash_screen.dart';
import 'package:caffenio/features/cart/presentation/screens/cart_screen.dart';
import 'package:caffenio/features/cart/presentation/screens/checkout_screen.dart';
import 'package:caffenio/features/catalog/presentation/providers/product_provider.dart';
import 'package:caffenio/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:caffenio/features/catalog/presentation/screens/product_detail_screen.dart';
import 'package:caffenio/features/loyalty/presentation/screens/loyalty_screen.dart';
import 'package:caffenio/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:caffenio/features/orders/presentation/screens/order_confirmation_screen.dart';
import 'package:caffenio/features/orders/presentation/screens/user_orders_screen.dart';
import 'package:caffenio/features/profile/presentation/screens/profile_screen.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:caffenio/shared/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Scaffold Principal con el BottomNavigationBar reactivo
class MainShellScaffold extends StatelessWidget {
  final Widget child;
  const MainShellScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location.startsWith('/cart')) currentIndex = 1;
    if (location.startsWith('/home/orders')) currentIndex = 2;
    if (location.startsWith('/home/loyalty')) currentIndex = 3;
    if (location.startsWith('/home/profile')) currentIndex = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home/catalog');
              break;
            case 1:
              if (!location.startsWith('/cart')) {
                context.push('/cart');
              }
              break;
            case 2:
              context.go('/home/orders');
              break;
            case 3:
              context.go('/home/loyalty');
              break;
            case 4:
              context.go('/home/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.coffee), label: 'Menú'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_membership), label: 'Lealtad'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// App Router setup

class AppRouter {
  final AuthProvider authProvider;
  AppRouter({required this.authProvider});

  GoRouter get router => GoRouter(
        initialLocation: '/splash',
        refreshListenable: authProvider,
        redirect: (context, state) {
          final authStatus = authProvider.authStatus;
          final userRole = authProvider.currentUser?.role;

          final isGoingToSplash = state.matchedLocation == '/splash';
          final isGoingToAuth = state.matchedLocation.startsWith('/auth');

          if (authStatus == AuthStatus.initial ||
              authStatus == AuthStatus.loading) {
            return isGoingToSplash ? null : '/splash';
          }

          if (authStatus == AuthStatus.unauthenticated ||
              (authStatus == AuthStatus.error &&
                  authProvider.currentUser == null)) {
            return isGoingToAuth ? null : '/auth/login';
          }

          // Evita "No route found" para la raíz y ruta home redirigiendo a la pantalla inicial correspondiente
          if (state.matchedLocation == '/' ||
              state.matchedLocation == '/home') {
            if (userRole == 'admin') return '/admin/dashboard';
            return '/home/catalog';
          }

          if (authStatus == AuthStatus.authenticated &&
              (isGoingToSplash || isGoingToAuth)) {
            if (userRole == 'admin') return '/admin/dashboard';
            return '/home/catalog';
          }

          if (state.matchedLocation.startsWith('/admin') && userRole != 'admin') {
            return '/home/catalog';
          }

          return null;
        },
        routes: [
          GoRoute(
              path: '/splash',
              builder: (context, state) => const SplashScreen()),
          GoRoute(
              path: '/auth/login',
              builder: (context, state) => const LoginScreen()),
          GoRoute(
              path: '/auth/register',
              builder: (context, state) => const RegisterScreen()),
          GoRoute(
              path: '/auth/forgot-password',
              builder: (context, state) => const ForgotPasswordScreen()),
          GoRoute(
              path: RouteConstants.notifications,
              builder: (context, state) => const NotificationsScreen()),

          // ZONA CLIENTES CON BOTTOM NAV INTEGRADO
          ShellRoute(
            builder: (context, state, child) => MainShellScaffold(child: child),
            routes: [
              GoRoute(
                path: '/home/catalog',
                builder: (context, state) => const CatalogScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final product = state.extra as ProductModel;
                      return ProductDetailScreen(product: product);
                    },
                  ),
                ],
              ),
              GoRoute(
                  path: '/home/orders',
                  builder: (context, state) => const UserOrdersScreen()),
              GoRoute(
                  path: '/home/loyalty',
                  builder: (context, state) => const LoyaltyScreen()),
              GoRoute(
                  path: '/home/profile',
                  builder: (context, state) => const ProfileScreen()),
            ],
          ),

          // FLUJO DE COMPRA INDEPENDIENTE FUERA DEL SHELL
          GoRoute(
              path: '/cart', builder: (context, state) => const CartScreen()),
          GoRoute(
              path: '/cart/checkout',
              builder: (context, state) => const CheckoutScreen()),
          GoRoute(
            path: '/cart/confirmation',
            builder: (context, state) {
              final order = state.extra as OrderModel;
              return OrderConfirmationScreen(order: order);
            },
          ),

          // CONTROLES DE EMPLEADOS VIA RUTA DIRECTA
          GoRoute(
              path: RouteConstants.adminDashboard,
              builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(
            path: RouteConstants.adminProducts,
            builder: (context, state) => const AdminProductsScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminProductCreate,
            builder: (context, state) => const AdminProductFormScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminProductEdit,
            builder: (context, state) {
              final productId = state.pathParameters['productId'] ?? '';
              final provider = context.read<ProductProvider>();

              ProductModel? product;
              try {
                product = provider.products.firstWhere(
                    (ProductModel product) => product.id == productId);
              } catch (_) {
                product = null;
              }

              if (product == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Producto no encontrado')),
                  body: const Center(
                    child: Text('No se encontró el producto para editar.'),
                  ),
                );
              }

              return AdminProductFormScreen(product: product);
            },
          ),
          GoRoute(
            path: RouteConstants.adminSuppliers,
            builder: (context, state) => const SuppliersScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminPurchaseOrders,
            builder: (context, state) => const PurchaseOrdersScreen(),
          ),
        ],
      );
}

import 'package:caffenio/core/constants/route_constants.dart';
import 'package:caffenio/features/admin/presentation/screens/admin_categories_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/admin_category_form_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/admin_product_form_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/admin_products_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/purchase_orders_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/sucursales_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/suppliers_screen.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:caffenio/features/auth/presentation/screens/login_screen.dart';
import 'package:caffenio/features/auth/presentation/screens/register_screen.dart';
import 'package:caffenio/features/auth/presentation/screens/splash_screen.dart';
import 'package:caffenio/features/barista/presentation/screens/barista_orders_screen.dart';
import 'package:caffenio/features/cart/presentation/screens/cart_screen.dart';
import 'package:caffenio/features/cart/presentation/screens/checkout_screen.dart';
import 'package:caffenio/features/catalog/presentation/screens/catalog_screen.dart';
import 'package:caffenio/features/catalog/presentation/screens/product_detail_screen.dart';
import 'package:caffenio/features/loyalty/presentation/screens/loyalty_screen.dart';
import 'package:caffenio/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:caffenio/features/orders/presentation/screens/order_confirmation_screen.dart';
import 'package:caffenio/features/orders/presentation/screens/user_orders_screen.dart';
import 'package:caffenio/features/profile/presentation/screens/profile_screen.dart';
import 'package:caffenio/shared/models/category_model.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:caffenio/shared/models/product_model.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/screens/admin_sucursal_form_screen.dart';

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
              context.go(RouteConstants.catalog);
              break;
            case 1:
              if (!location.startsWith(RouteConstants.cart)) {
                context.push(RouteConstants.cart);
              }
              break;
            case 2:
              context.go(RouteConstants.orders);
              break;
            case 3:
              context.go(RouteConstants.loyalty);
              break;
            case 4:
              context.go(RouteConstants.profile);
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

class AppRouter {
  final AuthProvider authProvider;
  AppRouter({required this.authProvider});

  GoRouter get router => GoRouter(
        initialLocation: RouteConstants.splash,
        refreshListenable: authProvider,
        redirect: (context, state) {
          final authStatus = authProvider.authStatus;
          final userRole = authProvider.currentUser?.role;

          final isGoingToSplash = state.matchedLocation == RouteConstants.splash;
          final isGoingToAuth = state.matchedLocation.startsWith('/auth');

          if (authStatus == AuthStatus.initial ||
              authStatus == AuthStatus.loading) {
            return isGoingToSplash ? null : RouteConstants.splash;
          }

          if (authStatus == AuthStatus.unauthenticated ||
              (authStatus == AuthStatus.error &&
                  authProvider.currentUser == null)) {
            return isGoingToAuth ? null : RouteConstants.login;
          }

          if (state.matchedLocation == '/' ||
              state.matchedLocation == RouteConstants.home) {
            if (userRole == 'barista') return RouteConstants.baristaQueue;
            if (userRole == 'admin') return RouteConstants.adminDashboard;
            return RouteConstants.catalog;
          }

          if (authStatus == AuthStatus.authenticated &&
              (isGoingToSplash || isGoingToAuth)) {
            if (userRole == 'barista') return RouteConstants.baristaQueue;
            if (userRole == 'admin') return RouteConstants.adminDashboard;
            return RouteConstants.catalog;
          }

          if (state.matchedLocation.startsWith('/admin') && userRole != 'admin') {
            return RouteConstants.catalog;
          }
          if (state.matchedLocation.startsWith('/barista') &&
              userRole != 'barista' &&
              userRole != 'admin') {
            return RouteConstants.catalog;
          }

          return null;
        },
        routes: [
          GoRoute(
              path: RouteConstants.splash,
              builder: (context, state) => const SplashScreen()),
          GoRoute(
              path: RouteConstants.login,
              builder: (context, state) => const LoginScreen()),
          GoRoute(
              path: RouteConstants.register,
              builder: (context, state) => const RegisterScreen()),
          GoRoute(
              path: RouteConstants.forgotPassword,
              builder: (context, state) => const ForgotPasswordScreen()),
          GoRoute(
              path: RouteConstants.notifications,
              builder: (context, state) => const NotificationsScreen()),
          ShellRoute(
            builder: (context, state, child) => MainShellScaffold(child: child),
            routes: [
              GoRoute(
                path: RouteConstants.catalog,
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final product = state.extra as ProductModel;
                      return ProductDetailScreen(product: product);
                    },
                  ),
                ],
                builder: (context, state) => const CatalogScreen(),
              ),
              GoRoute(
                  path: RouteConstants.orders,
                  builder: (context, state) => const UserOrdersScreen()),
              GoRoute(
                  path: RouteConstants.loyalty,
                  builder: (context, state) => const LoyaltyScreen()),
              GoRoute(
                  path: RouteConstants.profile,
                  builder: (context, state) => const ProfileScreen()),
            ],
          ),
          GoRoute(
              path: RouteConstants.cart,
              builder: (context, state) => const CartScreen()),
          GoRoute(
              path: RouteConstants.checkout,
              builder: (context, state) => const CheckoutScreen()),
          GoRoute(
            path: RouteConstants.orderConfirmation,
            builder: (context, state) {
              final order = state.extra as OrderModel;
              return OrderConfirmationScreen(order: order);
            },
          ),
          GoRoute(
              path: RouteConstants.baristaQueue,
              builder: (context, state) => const BaristaOrdersScreen()),
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
              final productId = state.pathParameters['productId']!;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: const Center(child: Text('Producto no encontrado.')),
                    );
                  }
                  final product = ProductModel.fromFirestore(snapshot.data as DocumentSnapshot<Map<String, dynamic>>);
                  return AdminProductFormScreen(product: product);
                },
              );
            },
          ),
          GoRoute(
            path: RouteConstants.adminCategories,
            builder: (context, state) => const AdminCategoriesScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminCategoriesCreate,
            builder: (context, state) => const AdminCategoryFormScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminCategoriesEdit,
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId']!;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('categories').doc(categoryId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: const Center(child: Text('Categoría no encontrada.')),
                    );
                  }
                  final category = CategoryModel.fromFirestore(snapshot.data as DocumentSnapshot<Map<String, dynamic>>);
                  return AdminCategoryFormScreen(category: category);
                },
              );
            },
          ),
          GoRoute(
            path: RouteConstants.adminSucursales,
            builder: (context, state) => const SucursalesScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminSucursalesCreate,
            builder: (context, state) => const AdminSucursalFormScreen(),
          ),
           GoRoute(
            path: RouteConstants.adminSucursalesEdit,
            builder: (context, state) {
              final sucursalId = state.pathParameters['sucursalId']!;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('sucursales').doc(sucursalId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Error')),
                      body: const Center(child: Text('Sucursal no encontrada.')),
                    );
                  }
                  final sucursal = SucursalModel.fromFirestore(snapshot.data as DocumentSnapshot<Map<String, dynamic>>);
                  return AdminSucursalFormScreen(sucursal: sucursal);
                },
              );
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

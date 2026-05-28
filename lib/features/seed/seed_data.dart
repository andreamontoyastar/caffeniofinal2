import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeedData {
  static const _seedFlagKey = 'hasSeeded_v4';

  /// Inserts example data into Firestore only the first time the app runs.
  static Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seedFlagKey) ?? false;
    if (alreadySeeded) return;

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // ----- 1. Clear legacy products that might cause parsing issues -----
    try {
      final oldProducts = await firestore.collection('products').get();
      for (final doc in oldProducts.docs) {
        batch.delete(doc.reference);
      }
    } catch (_) {}

    // ----- 2. Seed Premium Products (Structured as ProductModel) -----
    const githubImageBaseUrl =
        'https://raw.githubusercontent.com/montoya06470/Imagenes-para-flutter-6to-I-fecha-11-feb-2026/refs/heads/main';

    final products = [
      {
        'id': '1',
        'name': 'Café Americano',
        'description': 'Café negro clásico elaborado con granos seleccionados de la casa, suave y aromático.',
        'price': 35.0,
        'categoryId': 'bebidas-calientes',
        'preparationTimeMinutes': 4,
        'imageUrl': '$githubImageBaseUrl/americano.png',
        'sizes': [
          {'name': 'Chico', 'priceExtra': 0.0},
          {'name': 'Mediano', 'priceExtra': 5.0},
          {'name': 'Grande', 'priceExtra': 10.0},
        ],
        'milkTypes': <Map<String, dynamic>>[],
        'extras': [
          {'name': 'Shot Extra de Espresso', 'priceExtra': 12.0},
          {'name': 'Endulzante Splenda', 'priceExtra': 0.0},
        ],
      },
      {
        'id': '2',
        'name': 'Capuchino Clásico',
        'description': 'Equilibrio perfecto de espresso robusto, leche vaporizada y abundante espuma cremosa.',
        'price': 45.0,
        'categoryId': 'bebidas-calientes',
        'preparationTimeMinutes': 6,
        'imageUrl': '$githubImageBaseUrl/capuchino.png',
        'sizes': [
          {'name': 'Chico', 'priceExtra': 0.0},
          {'name': 'Mediano', 'priceExtra': 6.0},
          {'name': 'Grande', 'priceExtra': 12.0},
        ],
        'milkTypes': [
          {'name': 'Leche Regular', 'priceExtra': 0.0},
          {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
          {'name': 'Leche de Almendra', 'priceExtra': 8.0},
          {'name': 'Leche de Soya', 'priceExtra': 8.0},
        ],
        'extras': [
          {'name': 'Shot Extra de Espresso', 'priceExtra': 12.0},
          {'name': 'Canela en Polvo', 'priceExtra': 0.0},
          {'name': 'Jarabe de Vainilla', 'priceExtra': 7.0},
        ],
      },
      {
        'id': '3',
        'name': 'Latte Frío Caramel',
        'description': 'Bebida helada de café con leche cremosa y un toque dulce de jarabe de caramelo premium.',
        'price': 49.0,
        'categoryId': 'bebidas-frias',
        'preparationTimeMinutes': 7,
        'imageUrl': '$githubImageBaseUrl/cafe1.png',
        'sizes': [
          {'name': 'Chico', 'priceExtra': 0.0},
          {'name': 'Mediano', 'priceExtra': 6.0},
          {'name': 'Grande', 'priceExtra': 12.0},
        ],
        'milkTypes': [
          {'name': 'Leche Regular', 'priceExtra': 0.0},
          {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
          {'name': 'Leche de Almendra', 'priceExtra': 8.0},
        ],
        'extras': [
          {'name': 'Salsa de Caramelo Extra', 'priceExtra': 8.0},
          {'name': 'Shot Extra de Espresso', 'priceExtra': 12.0},
        ],
      },
      {
        'id': '4',
        'name': 'Café Moka',
        'description': 'Una deliciosa combinación de rico chocolate amargo, café espresso y leche vaporizada.',
        'price': 48.0,
        'categoryId': 'bebidas-calientes',
        'preparationTimeMinutes': 6,
        'imageUrl': '$githubImageBaseUrl/cafe2.png',
        'sizes': [
          {'name': 'Chico', 'priceExtra': 0.0},
          {'name': 'Mediano', 'priceExtra': 8.0},
          {'name': 'Grande', 'priceExtra': 15.0},
        ],
        'milkTypes': [
          {'name': 'Leche Regular', 'priceExtra': 0.0},
          {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
          {'name': 'Leche de Almendra', 'priceExtra': 8.0},
        ],
        'extras': [
          {'name': 'Crema Batida', 'priceExtra': 8.0},
          {'name': 'Chispas de Chocolate', 'priceExtra': 5.0},
          {'name': 'Shot Extra de Espresso', 'priceExtra': 12.0},
        ],
      },
      {
        'id': '5',
        'name': 'K\'Freeze Caramelo',
        'description': 'Nuestra bebida congelada con base cremosa y listones de caramelo premium.',
        'price': 55.0,
        'categoryId': 'bebidas-frias',
        'preparationTimeMinutes': 8,
        'imageUrl': '$githubImageBaseUrl/cafe3.png',
        'sizes': [
          {'name': 'Mediano', 'priceExtra': 0.0},
          {'name': 'Grande', 'priceExtra': 14.0},
        ],
        'milkTypes': [
          {'name': 'Leche Entera', 'priceExtra': 0.0},
          {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
        ],
        'extras': [
          {'name': 'Crema Batida', 'priceExtra': 10.0},
          {'name': 'Chispas de Chocolate', 'priceExtra': 7.0},
        ],
      },
      {
        'id': '6',
        'name': 'K\'Freeze Moka Intenso',
        'description': 'Fusión helada de café espresso y jarabe de chocolate semi-amargo.',
        'price': 58.0,
        'categoryId': 'bebidas-frias',
        'preparationTimeMinutes': 9,
        'imageUrl': '$githubImageBaseUrl/cafe4.png',
        'sizes': [
          {'name': 'Mediano', 'priceExtra': 0.0},
          {'name': 'Grande', 'priceExtra': 14.0},
        ],
        'milkTypes': [
          {'name': 'Leche Entera', 'priceExtra': 0.0},
          {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
        ],
        'extras': [
          {'name': 'Extra Jarabe de Chocolate', 'priceExtra': 8.0},
          {'name': 'Crema Batida', 'priceExtra': 10.0},
        ],
      },
    ];

    for (final prod in products) {
      final id = prod['id'] as String;
      batch.set(firestore.collection('products').doc(id), prod);
    }

    // ----- 3. Seed Branches (Sucursales) -----
    final branches = [
      {
        'id': 'centro',
        'name': 'Caffenio Centro',
        'address': 'Av. Juárez 123',
        'city': 'Hermosillo',
        'phone': '6621002030',
        'schedule': '07:00 - 22:00',
        'lat': 29.072967,
        'lng': -110.955919,
        'isActive': true,
        'employees': <String>[],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'id': 'morelos',
        'name': 'Caffenio Morelos',
        'address': 'Blvd. Morelos 456',
        'city': 'Hermosillo',
        'phone': '6621004050',
        'schedule': '07:00 - 23:00',
        'lat': 29.123456,
        'lng': -110.987654,
        'isActive': true,
        'employees': <String>[],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'id': 'colosio',
        'name': 'Caffenio Colosio',
        'address': 'Blvd. Colosio 789',
        'city': 'Hermosillo',
        'phone': '6621006070',
        'schedule': '06:00 - 22:00',
        'lat': 29.087654,
        'lng': -111.012345,
        'isActive': true,
        'employees': <String>[],
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    ];

    for (final branch in branches) {
      final id = branch['id'] as String;
      batch.set(firestore.collection('branches').doc(id), branch);
    }

    // ----- 4. Seed Recipes (Recetas para decremento de Stock) -----
    final recipes = [
      // Café Americano (id: 1)
      {'id': 'r1_1', 'productId': '1', 'ingredientId': 'cafe_granos', 'quantity': 0.015},
      {'id': 'r1_2', 'productId': '1', 'ingredientId': 'vaso', 'quantity': 1.0},
      // Capuchino (id: 2)
      {'id': 'r2_1', 'productId': '2', 'ingredientId': 'cafe_granos', 'quantity': 0.015},
      {'id': 'r2_2', 'productId': '2', 'ingredientId': 'leche_regular', 'quantity': 0.25},
      {'id': 'r2_3', 'productId': '2', 'ingredientId': 'vaso', 'quantity': 1.0},
      // Latte Frío (id: 3)
      {'id': 'r3_1', 'productId': '3', 'ingredientId': 'cafe_granos', 'quantity': 0.015},
      {'id': 'r3_2', 'productId': '3', 'ingredientId': 'leche_regular', 'quantity': 0.25},
      {'id': 'r3_3', 'productId': '3', 'ingredientId': 'jarabe_caramelo', 'quantity': 0.03},
      {'id': 'r3_4', 'productId': '3', 'ingredientId': 'vaso', 'quantity': 1.0},
      // Café Moka (id: 4)
      {'id': 'r4_1', 'productId': '4', 'ingredientId': 'cafe_granos', 'quantity': 0.015},
      {'id': 'r4_2', 'productId': '4', 'ingredientId': 'leche_regular', 'quantity': 0.25},
      {'id': 'r4_3', 'productId': '4', 'ingredientId': 'chocolate', 'quantity': 0.02},
      {'id': 'r4_4', 'productId': '4', 'ingredientId': 'vaso', 'quantity': 1.0},
      // K'Freeze Caramelo (id: 5)
      {'id': 'r5_1', 'productId': '5', 'ingredientId': 'cafe_granos', 'quantity': 0.01},
      {'id': 'r5_2', 'productId': '5', 'ingredientId': 'leche_regular', 'quantity': 0.3},
      {'id': 'r5_3', 'productId': '5', 'ingredientId': 'jarabe_caramelo', 'quantity': 0.05},
      {'id': 'r5_4', 'productId': '5', 'ingredientId': 'vaso', 'quantity': 1.0},
      // K'Freeze Moka (id: 6)
      {'id': 'r6_1', 'productId': '6', 'ingredientId': 'cafe_granos', 'quantity': 0.01},
      {'id': 'r6_2', 'productId': '6', 'ingredientId': 'leche_regular', 'quantity': 0.3},
      {'id': 'r6_3', 'productId': '6', 'ingredientId': 'chocolate', 'quantity': 0.05},
      {'id': 'r6_4', 'productId': '6', 'ingredientId': 'vaso', 'quantity': 1.0},
    ];

    for (final recipe in recipes) {
      final id = recipe['id'] as String;
      batch.set(firestore.collection('recipes').doc(id), recipe);
    }

    // ----- 5. Seed Inventory stock for each branch -----
    final List<Map<String, dynamic>> inventoryItems = [];
    final branchIds = ['centro', 'morelos', 'colosio'];
    final ingredients = [
      {'id': 'cafe_granos', 'unit': 'kg', 'current': 50.0, 'min': 10.0},
      {'id': 'leche_regular', 'unit': 'L', 'current': 100.0, 'min': 20.0},
      {'id': 'jarabe_caramelo', 'unit': 'L', 'current': 20.0, 'min': 5.0},
      {'id': 'chocolate', 'unit': 'kg', 'current': 30.0, 'min': 6.0},
      {'id': 'vaso', 'unit': 'piezas', 'current': 500.0, 'min': 100.0},
    ];

    for (final branchId in branchIds) {
      for (final ing in ingredients) {
        inventoryItems.add({
          'id': '${branchId}_${ing['id']}',
          'sucursalId': branchId,
          'ingredientId': ing['id'] as String,
          'currentStock': ing['current'] as double,
          'minStock': ing['min'] as double,
          'unit': ing['unit'] as String,
          'lastUpdated': Timestamp.now(),
        });
      }
    }

    for (final item in inventoryItems) {
      final id = item['id'] as String;
      batch.set(firestore.collection('inventory').doc(id), item);
    }

    // ----- 6. Seed Suppliers -----
    final suppliers = [
      {
        'id': 'sup_cafe',
        'name': 'Café de Altura S.A.',
        'contactName': 'Carlos Ruiz',
        'phone': '5552003040',
        'email': 'contacto@cafealtura.com',
        'address': 'Guatepec, Veracruz',
        'city': 'Xalapa',
        'isActive': true,
        'leadTimeDays': 5,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'id': 'sup_leche',
        'name': 'Lácteos del Norte',
        'contactName': 'Patricia Sosa',
        'phone': '8181020304',
        'email': 'ventas@lacteosnorte.com',
        'address': 'Torreón, Coahuila',
        'city': 'Torreón',
        'isActive': true,
        'leadTimeDays': 2,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    ];

    for (final supplier in suppliers) {
      final id = supplier['id'] as String;
      batch.set(firestore.collection('suppliers').doc(id), supplier);
    }

    // ----- 7. Seed Promotions -----
    final promotions = [
      {
        'id': 'promo_1',
        'title': '2x1 en Capuchino Chico',
        'description': 'Disfruta de nuestra promoción de martes y jueves en Capuchino Chico.',
        'discountPercentage': 50.0,
        'couponCode': 'CAPU2X1',
        'startDate': Timestamp.now(),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'isActive': true,
      },
      {
        'id': 'promo_2',
        'title': '15% de Descuento en K\'Freeze',
        'description': 'Refréscate con un 15% de descuento en cualquier especialidad de K\'Freeze.',
        'discountPercentage': 15.0,
        'couponCode': 'FREEZE15',
        'startDate': Timestamp.now(),
        'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
        'isActive': true,
      },
    ];

    for (final promo in promotions) {
      final id = promo['id'] as String;
      batch.set(firestore.collection('promotions').doc(id), promo);
    }

    // ----- 8. Seed Base Employees/Users -----
    final demoUsers = [
      {
        'uid': 'demo_admin_uid',
        'email': 'admin@caffenio.com',
        'displayName': 'Administrador General',
        'role': 'admin',
        'status': 'active',
        'phone': '5551234567',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'uid': 'demo_customer_uid',
        'email': 'cliente@caffenio.com',
        'displayName': 'Ana Martínez',
        'role': 'customer',
        'status': 'active',
        'phone': '5557654321',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      }
    ];

    for (final usr in demoUsers) {
      final uid = usr['uid'] as String;
      batch.set(firestore.collection('users').doc(uid), usr);
    }

    await batch.commit();

    // Mark as seeded
    await prefs.setBool(_seedFlagKey, true);
  }
}

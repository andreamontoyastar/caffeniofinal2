import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeedData {
  static const _seedFlagKey = 'hasSeededWithImages';

  /// Inserts example data into Firestore only the first time the app runs.
  static Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seedFlagKey) ?? false;
    if (alreadySeeded) return;

    final firestore = FirebaseFirestore.instance;

    // Helper to update existing products or add new ones
    Future<void> addOrUpdateProduct(Map<String, dynamic> data) async {
      final name = data['name'] as String;
      final query = await firestore
          .collection('products')
          .where('name', isEqualTo: name)
          .get();

      if (query.docs.isNotEmpty) {
        for (final doc in query.docs) {
          await doc.reference.update(data);
        }
      } else {
        await firestore.collection('products').add(data);
      }
    }

    // Helper to update or add employees
    Future<void> addOrUpdateEmployee(Map<String, dynamic> data) async {
      final name = data['name'] as String;
      final query = await firestore
          .collection('employees')
          .where('name', isEqualTo: name)
          .get();

      if (query.docs.isNotEmpty) {
        for (final doc in query.docs) {
          await doc.reference.update(data);
        }
      } else {
        await firestore.collection('employees').add(data);
      }
    }

    // ----- Products -----
    await addOrUpdateProduct({
      'name': 'Café Espresso',
      'description': 'Espresso concentrado con un aroma intenso y una capa densa de crema.',
      'price': 2.5,
      'stock': 3,
      'categoryId': 'bebidas-calientes',
      'preparationTimeMinutes': 3,
      'imageUrl': 'https://images.unsplash.com/photo-151097252790b-af4f42d91015?auto=format&fit=crop&w=600&q=80',
      'sizes': [
        {'name': 'Chico', 'priceExtra': 0.0},
        {'name': 'Mediano', 'priceExtra': 5.0}
      ],
      'milkTypes': <Map<String, dynamic>>[],
      'extras': [
        {'name': 'Shot Extra', 'priceExtra': 12.0}
      ]
    });

    await addOrUpdateProduct({
      'name': 'Latte',
      'description': 'Espresso suave con leche vaporizada y una ligera capa de espuma.',
      'price': 3.5,
      'stock': 12,
      'categoryId': 'bebidas-calientes',
      'preparationTimeMinutes': 5,
      'imageUrl': 'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&w=600&q=80',
      'sizes': [
        {'name': 'Chico', 'priceExtra': 0.0},
        {'name': 'Mediano', 'priceExtra': 6.0},
        {'name': 'Grande', 'priceExtra': 10.0}
      ],
      'milkTypes': [
        {'name': 'Leche Regular', 'priceExtra': 0.0},
        {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
        {'name': 'Leche de Almendra', 'priceExtra': 8.0}
      ],
      'extras': [
        {'name': 'Jarabe de Vainilla', 'priceExtra': 7.0}
      ]
    });

    await addOrUpdateProduct({
      'name': 'Cappuccino',
      'description': 'Una deliciosa combinación de espresso, leche vaporizada y abundante espuma de leche.',
      'price': 3.0,
      'stock': 2,
      'categoryId': 'bebidas-calientes',
      'preparationTimeMinutes': 5,
      'imageUrl': 'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=600&q=80',
      'sizes': [
        {'name': 'Chico', 'priceExtra': 0.0},
        {'name': 'Mediano', 'priceExtra': 6.0},
        {'name': 'Grande', 'priceExtra': 10.0}
      ],
      'milkTypes': [
        {'name': 'Leche Regular', 'priceExtra': 0.0},
        {'name': 'Leche Deslactosada', 'priceExtra': 5.0}
      ],
      'extras': [
        {'name': 'Canela en Polvo', 'priceExtra': 0.0}
      ]
    });

    await addOrUpdateProduct({
      'name': 'Muffin de chocolate',
      'description': 'Esponjoso muffin de chocolate con chispas de chocolate fundidas en su interior.',
      'price': 1.8,
      'stock': 20,
      'categoryId': 'reposteria',
      'preparationTimeMinutes': 2,
      'imageUrl': 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?auto=format&fit=crop&w=600&q=80',
      'sizes': <Map<String, dynamic>>[],
      'milkTypes': <Map<String, dynamic>>[],
      'extras': <Map<String, dynamic>>[]
    });

    await addOrUpdateProduct({
      'name': 'Bagel',
      'description': 'Bagel tradicional tostado, crujiente por fuera y suave por dentro.',
      'price': 1.2,
      'stock': 15,
      'categoryId': 'reposteria',
      'preparationTimeMinutes': 3,
      'imageUrl': 'https://images.unsplash.com/photo-1585478259715-876acc5be8eb?auto=format&fit=crop&w=600&q=80',
      'sizes': <Map<String, dynamic>>[],
      'milkTypes': <Map<String, dynamic>>[],
      'extras': <Map<String, dynamic>>[]
    });

    // ----- Employees -----
    await addOrUpdateEmployee({
      'name': 'Ana Martínez',
      'role': 'Barista',
    });
    await addOrUpdateEmployee({
      'name': 'Luis Gómez',
      'role': 'Cajero',
    });
    await addOrUpdateEmployee({
      'name': 'María Torres',
      'role': 'Gerente',
    });

    // ----- Sales (orders) -----
    final salesQuery = await firestore.collection('sales').limit(1).get();
    if (salesQuery.docs.isEmpty) {
      await firestore.collection('sales').add({
        'productId': 'espresso',
        'quantity': 2,
        'total': 5.0,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await firestore.collection('sales').add({
        'productId': 'latte',
        'quantity': 1,
        'total': 3.5,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Mark as seeded
    await prefs.setBool(_seedFlagKey, true);
  }
}

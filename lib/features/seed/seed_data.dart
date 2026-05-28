import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeedData {
  static const _seedFlagKey = 'hasSeeded';

  /// Inserts example data into Firestore only the first time the app runs.
  static Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seedFlagKey) ?? false;
    if (alreadySeeded) return;

    final firestore = FirebaseFirestore.instance;
    // ----- Products -----
    await firestore.collection('products').add({
      'name': 'Café Espresso',
      'price': 2.5,
      'stock': 3, // low inventory
    });
    await firestore.collection('products').add({
      'name': 'Latte',
      'price': 3.5,
      'stock': 12,
    });
    await firestore.collection('products').add({
      'name': 'Cappuccino',
      'price': 3.0,
      'stock': 2, // low inventory
    });
    await firestore.collection('products').add({
      'name': 'Muffin de chocolate',
      'price': 1.8,
      'stock': 20,
    });
    await firestore.collection('products').add({
      'name': 'Bagel',
      'price': 1.2,
      'stock': 15,
    });

    // ----- Employees -----
    await firestore.collection('employees').add({
      'name': 'Ana Martínez',
      'role': 'Barista',
    });
    await firestore.collection('employees').add({
      'name': 'Luis Gómez',
      'role': 'Cajero',
    });
    await firestore.collection('employees').add({
      'name': 'María Torres',
      'role': 'Gerente',
    });

    // ----- Sales (orders) -----
    await firestore.collection('sales').add({
      'productId': 'espresso', // placeholder, you could query the id after creation
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

    // Mark as seeded
    await prefs.setBool(_seedFlagKey, true);
  }
}

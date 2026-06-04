import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Script extendido para poblar Firebase Firestore con el menú oficial de Caffenio,
// incluyendo rutas de imágenes reales desde el repositorio de GitHub.

class FirestoreSeeder {
  static Future<void> uploadMenuData() async {
    final firestore = FirebaseFirestore.instance;

    debugPrint(
        '🚀 Iniciando la carga masiva del menú extendido de Caffenio en Firestore...');

    // Base de la URL para las imágenes en GitHub verificadas.
    const String baseUrl =
        'https://raw.githubusercontent.com/montoya06470/Imagenes-para-flutter-6to-I-fecha-11-feb-2026/refs/heads/main';

    // 1. DEFINICIÓN DE CATEGORÍAS (Estructura base)
    final Map<String, Map<String, dynamic>> categories = {
      'cat_cafes_calientes': {'name': 'Cafés Calientes', 'order': 0},
      'cat_frappes': {'name': 'Frappés & K\'Freeze', 'order': 1},
      'cat_bebidas_frias': {'name': 'Bebidas Frías & Tés', 'order': 2},
      'cat_reposteria': {'name': 'Panadería & Repostería', 'order': 3},
    };

    for (var entry in categories.entries) {
      await firestore.collection('categories').doc(entry.key).set({
        'name': entry.value['name'],
        'isActive': true,
        'order': entry.value['order'],
      });
      debugPrint('✅ Categoría verificada/creada: ${entry.value['name']}');
    }

    // 2. DEFINICIÓN DE PRODUCTOS EXPANDIDOS (Alineados con tus assets)
    final List<Map<String, dynamic>> products = [
      // --- CAFÉS CALIENTES ---
      {
        'id': 'prod_americano',
        'categoria_id': 'cat_cafes_calientes',
        'nombre': 'Café Americano Intenso',
        'descripcion':
            'Café de grano selecto Caffenio, tostado oscuro con notas sutiles de chocolate puro.',
        'precio': 38.0,
        'imageUrl': '$baseUrl/americano.png',
        'disponible': true,
        'isFeatured': true,
        'sizes': <Map<String, dynamic>>[
          {'name': 'Chico', 'priceExtra': 0.0},
          {'name': 'Mediano', 'priceExtra': 7.0},
          {'name': 'Grande', 'priceExtra': 12.0},
        ],
        'milkTypes': <Map<String, dynamic>>[],
        'extras': <Map<String, dynamic>>[
          {'name': 'Shot de Espresso Extra', 'priceExtra': 15.0},
        ],
      },
      {
        'id': 'prod_capuccino',
        'categoria_id': 'cat_cafes_calientes',
        'nombre': 'Capuccino Clásico',
        'descripcion':
            'Espresso perfecto balanceado con leche vaporizada cremosa y una fina capa de espuma de la casa.',
        'precio': 48.0,
        'imageUrl': '$baseUrl/capuchino.png',
        'disponible': true,
        'isFeatured': true,
        'sizes': <Map<String, dynamic>>[
          {'name': 'Chico', 'priceExtra': 0.0},
          {'name': 'Mediano', 'priceExtra': 9.0},
          {'name': 'Grande', 'priceExtra': 15.0},
        ],
        'milkTypes': <Map<String, dynamic>>[
          {'name': 'Leche Entera', 'priceExtra': 0.0},
          {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
          {'name': 'Leche de Almendra', 'priceExtra': 12.0},
        ],
        'extras': <Map<String, dynamic>>[
          {'name': 'Shot de Espresso Extra', 'priceExtra': 15.0},
          {'name': 'Jarabe de Vainilla', 'priceExtra': 8.0},
          {'name': 'Jarabe de Caramelo', 'priceExtra': 8.0},
        ],
      },
      {
        'id': 'prod_latte_vainilla',
        'categoria_id': 'cat_cafes_calientes',
        'nombre': 'Café Latte Vainilla',
        'descripcion':
            'Café espresso suave combinado con leche caliente texturizada y un toque dulce de jarabe de vainilla francesa.',
        'precio': 52.0,
        'imageUrl': '$baseUrl/cafe1.png',
        'disponible': true,
        'isFeatured': false,
        'sizes': <Map<String, dynamic>>[
          {'name': 'Chico', 'priceExtra': 0.0},
          {'name': 'Mediano', 'priceExtra': 8.0},
          {'name': 'Grande', 'priceExtra': 14.0},
        ],
        'milkTypes': <Map<String, dynamic>>[
          {'name': 'Leche Entera', 'priceExtra': 0.0},
          {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
        ],
        'extras': <Map<String, dynamic>>[
          {'name': 'Canela en Polvo', 'priceExtra': 0.0},
          {'name': 'Crema Batida', 'priceExtra': 10.0},
        ],
      },

      // --- FRAPPÉS & K'FREEZE ---
      {
        'id': 'prod_kfreeze',
        'categoria_id': 'cat_frappes',
        'nombre': 'K\'Freeze Caramelo',
        'descripcion':
            'Nuestra emblemática bebida congelada licuada con base cremosa de café y listones de caramelo premium.',
        'precio': 55.0,
        'imageUrl': '$baseUrl/cafe2.png',
        'disponible': true,
        'isFeatured': true,
        'sizes': <Map<String, dynamic>>[
          {'name': 'Mediano', 'priceExtra': 0.0},
          {'name': 'Grande', 'priceExtra': 14.0},
        ],
        'milkTypes': <Map<String, dynamic>>[
          {'name': 'Leche Entera', 'priceExtra': 0.0},
          {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
        ],
        'extras': <Map<String, dynamic>>[
          {'name': 'Crema Batida', 'priceExtra': 10.0},
          {'name': 'Chispas de Chocolate', 'priceExtra': 7.0},
        ],
      },
      {
        'id': 'prod_kfreeze_moka',
        'categoria_id': 'cat_frappes',
        'nombre': 'K\'Freeze Moka Intenso',
        'descripcion':
            'Fusión helada de café espresso y jarabe de chocolate semi-amargo, licuado a la perfección con hielo y base láctea.',
        'precio': 58.0,
        'imageUrl': '$baseUrl/cafe3.png',
        'disponible': true,
        'isFeatured': false,
        'sizes': <Map<String, dynamic>>[
          {'name': 'Mediano', 'priceExtra': 0.0},
          {'name': 'Grande', 'priceExtra': 14.0},
        ],
        'milkTypes': <Map<String, dynamic>>[
          {'name': 'Leche Entera', 'priceExtra': 0.0},
          {'name': 'Leche Deslactosada', 'priceExtra': 5.0},
        ],
        'extras': <Map<String, dynamic>>[
          {'name': 'Extra Jarabe de Chocolate', 'priceExtra': 8.0},
          {'name': 'Crema Batida', 'priceExtra': 10.0},
        ],
      }
    ];

    // 3. PROCESO DE INYECCIÓN ATÓMICA EN FIRESTORE
    for (var prod in products) {
      final String docId = prod['id'] as String;
      // Clonamos el mapa eliminando la llave 'id' para que no se duplique dentro del documento
      final Map<String, dynamic> data = Map<String, dynamic>.from(prod)
        ..remove('id');

      await firestore.collection('products').doc(docId).set(data);
      debugPrint('☕ Producto cargado/actualizado con éxito: ${prod['nombre']}');
    }

    debugPrint(
        '🎉 ¡Todo el menú extendido e institucional de Caffenio ha sido sincronizado exitosamente con Firestore!');
  }
}

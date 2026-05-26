import 'package:caffenio/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../scripts/seed_firestore.dart';

void main() {
  test('Sembrado de datos en Firestore', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirestoreSeeder.uploadMenuData();
  }, skip: 'Ejecución manual: quitar el skip para inyectar datos a Firebase real');
}

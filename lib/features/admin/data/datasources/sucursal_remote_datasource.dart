import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SucursalRemoteDataSource {
  Stream<List<SucursalModel>> watchAllSucursales();
  Future<SucursalModel?> getSucursalById(String id);
  Future<void> createSucursal(SucursalModel sucursal);
  Future<void> updateSucursal(SucursalModel sucursal);
  Future<void> deleteSucursal(String id);
}

class SucursalRemoteDataSourceImpl implements SucursalRemoteDataSource {
  final FirebaseFirestore _firestore;

  SucursalRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  late final CollectionReference<Map<String, dynamic>> _sucursalesRef =
      _firestore.collection(FirebaseConstants.sucursalesCollection);

  @override
  Stream<List<SucursalModel>> watchAllSucursales() {
    return _sucursalesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SucursalModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<SucursalModel?> getSucursalById(String id) async {
    final doc = await _sucursalesRef.doc(id).get();
    if (!doc.exists) return null;
    return SucursalModel.fromFirestore(doc);
  }

  @override
  Future<void> createSucursal(SucursalModel sucursal) async {
    await _sucursalesRef.doc(sucursal.id).set(sucursal.toMap());
  }

  @override
  Future<void> updateSucursal(SucursalModel sucursal) async {
    await _sucursalesRef.doc(sucursal.id).update({
      ...sucursal.toMap(),
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> deleteSucursal(String id) async {
    await _sucursalesRef.doc(id).delete();
  }
}

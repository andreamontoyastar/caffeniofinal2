import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/supplier_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SupplierRemoteDataSource {
  Stream<List<SupplierModel>> watchAllSuppliers();
  Future<SupplierModel?> getSupplierById(String id);
  Future<void> createSupplier(SupplierModel supplier);
  Future<void> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final FirebaseFirestore _firestore;

  SupplierRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  late final CollectionReference<Map<String, dynamic>> _suppliersRef =
      _firestore.collection(FirebaseConstants.suppliersCollection);

  @override
  Stream<List<SupplierModel>> watchAllSuppliers() {
    return _suppliersRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SupplierModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<SupplierModel?> getSupplierById(String id) async {
    final doc = await _suppliersRef.doc(id).get();
    if (!doc.exists) return null;
    return SupplierModel.fromFirestore(doc);
  }

  @override
  Future<void> createSupplier(SupplierModel supplier) async {
    await _suppliersRef.doc(supplier.id).set(supplier.toMap());
  }

  @override
  Future<void> updateSupplier(SupplierModel supplier) async {
    await _suppliersRef.doc(supplier.id).update(supplier.toMap());
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _suppliersRef.doc(id).delete();
  }
}

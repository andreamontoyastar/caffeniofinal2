import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/employee_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class EmployeeRemoteDataSource {
  Stream<List<EmployeeModel>> watchAllEmployees();
  Stream<List<EmployeeModel>> watchBySucursal(String sucursalId);
  Future<EmployeeModel?> getEmployeeByUid(String uid);
  Future<void> createEmployee(EmployeeModel employee);
  Future<void> updateEmployeeRole(String uid, String newRole);
  Future<void> updateEmployeeSucursal(String uid, String sucursalId);
  Future<void> deleteEmployee(String uid);
  Future<void> deactivateEmployee(String uid);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final FirebaseFirestore _firestore;

  EmployeeRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  late final CollectionReference<Map<String, dynamic>> _usersRef =
      _firestore.collection(FirebaseConstants.usersCollection);

  @override
  Stream<List<EmployeeModel>> watchAllEmployees() {
    return _usersRef
        .orderBy('displayName')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EmployeeModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<EmployeeModel>> watchBySucursal(String sucursalId) {
    return _usersRef
        .where('sucursalId', isEqualTo: sucursalId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EmployeeModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<EmployeeModel?> getEmployeeByUid(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return EmployeeModel.fromFirestore(doc);
  }

  @override
  Future<void> createEmployee(EmployeeModel employee) async {
    await _usersRef.doc(employee.uid).set({
      ...employee.toMap(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateEmployeeRole(String uid, String newRole) async {
    await _usersRef.doc(uid).update({
      'role': newRole,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updateEmployeeSucursal(String uid, String sucursalId) async {
    await _usersRef.doc(uid).update({
      'sucursalId': sucursalId,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> deleteEmployee(String uid) async {
    await _usersRef.doc(uid).delete();
  }

  @override
  Future<void> deactivateEmployee(String uid) async {
    await _usersRef.doc(uid).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }
}

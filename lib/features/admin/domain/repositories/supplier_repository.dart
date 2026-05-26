import 'package:caffenio/shared/models/supplier_model.dart';

abstract class SupplierRepository {
  Stream<List<SupplierModel>> watchAllSuppliers();
  Future<SupplierModel?> getSupplierById(String id);
  Future<void> createSupplier(SupplierModel supplier);
  Future<void> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
}

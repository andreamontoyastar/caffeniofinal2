import 'package:caffenio/features/admin/data/datasources/supplier_remote_datasource.dart';
import 'package:caffenio/features/admin/domain/repositories/supplier_repository.dart';
import 'package:caffenio/shared/models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource remoteDataSource;

  SupplierRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<SupplierModel>> watchAllSuppliers() {
    return remoteDataSource.watchAllSuppliers();
  }

  @override
  Future<SupplierModel?> getSupplierById(String id) {
    return remoteDataSource.getSupplierById(id);
  }

  @override
  Future<void> createSupplier(SupplierModel supplier) {
    return remoteDataSource.createSupplier(supplier);
  }

  @override
  Future<void> updateSupplier(SupplierModel supplier) {
    return remoteDataSource.updateSupplier(supplier);
  }

  @override
  Future<void> deleteSupplier(String id) {
    return remoteDataSource.deleteSupplier(id);
  }
}

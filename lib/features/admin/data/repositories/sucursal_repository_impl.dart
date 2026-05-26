import 'package:caffenio/features/admin/data/datasources/sucursal_remote_datasource.dart';
import 'package:caffenio/features/admin/domain/repositories/sucursal_repository.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';

class SucursalRepositoryImpl implements SucursalRepository {
  final SucursalRemoteDataSource remoteDataSource;

  SucursalRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<SucursalModel>> watchAllSucursales() {
    return remoteDataSource.watchAllSucursales();
  }

  @override
  Future<SucursalModel?> getSucursalById(String id) {
    return remoteDataSource.getSucursalById(id);
  }

  @override
  Future<void> createSucursal(SucursalModel sucursal) {
    return remoteDataSource.createSucursal(sucursal);
  }

  @override
  Future<void> updateSucursal(SucursalModel sucursal) {
    return remoteDataSource.updateSucursal(sucursal);
  }

  @override
  Future<void> deleteSucursal(String id) {
    return remoteDataSource.deleteSucursal(id);
  }
}

import 'package:caffenio/shared/models/sucursal_model.dart';

abstract class SucursalRepository {
  Stream<List<SucursalModel>> watchAllSucursales();
  Future<SucursalModel?> getSucursalById(String id);
  Future<void> createSucursal(SucursalModel sucursal);
  Future<void> updateSucursal(SucursalModel sucursal);
  Future<void> deleteSucursal(String id);
}

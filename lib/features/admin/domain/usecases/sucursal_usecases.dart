import 'package:caffenio/features/admin/domain/repositories/sucursal_repository.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';

class WatchAllSucursales {
  final SucursalRepository repository;

  WatchAllSucursales({required this.repository});

  Stream<List<SucursalModel>> call() {
    return repository.watchAllSucursales();
  }
}

class GetSucursalById {
  final SucursalRepository repository;

  GetSucursalById({required this.repository});

  Future<SucursalModel?> call(String id) {
    return repository.getSucursalById(id);
  }
}

class CreateSucursal {
  final SucursalRepository repository;

  CreateSucursal({required this.repository});

  Future<void> call(SucursalModel sucursal) {
    return repository.createSucursal(sucursal);
  }
}

class UpdateSucursal {
  final SucursalRepository repository;

  UpdateSucursal({required this.repository});

  Future<void> call(SucursalModel sucursal) {
    return repository.updateSucursal(sucursal);
  }
}

class DeleteSucursal {
  final SucursalRepository repository;

  DeleteSucursal({required this.repository});

  Future<void> call(String id) {
    return repository.deleteSucursal(id);
  }
}

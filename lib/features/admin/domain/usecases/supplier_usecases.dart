import 'package:caffenio/features/admin/domain/repositories/supplier_repository.dart';
import 'package:caffenio/shared/models/supplier_model.dart';

class WatchAllSuppliers {
  final SupplierRepository repository;

  WatchAllSuppliers({required this.repository});

  Stream<List<SupplierModel>> call() {
    return repository.watchAllSuppliers();
  }
}

class GetSupplierById {
  final SupplierRepository repository;

  GetSupplierById({required this.repository});

  Future<SupplierModel?> call(String id) {
    return repository.getSupplierById(id);
  }
}

class CreateSupplier {
  final SupplierRepository repository;

  CreateSupplier({required this.repository});

  Future<void> call(SupplierModel supplier) {
    return repository.createSupplier(supplier);
  }
}

class UpdateSupplier {
  final SupplierRepository repository;

  UpdateSupplier({required this.repository});

  Future<void> call(SupplierModel supplier) {
    return repository.updateSupplier(supplier);
  }
}

class DeleteSupplier {
  final SupplierRepository repository;

  DeleteSupplier({required this.repository});

  Future<void> call(String id) {
    return repository.deleteSupplier(id);
  }
}

import 'package:caffenio/features/admin/domain/repositories/employee_repository.dart';
import 'package:caffenio/shared/models/employee_model.dart';

class WatchAllEmployees {
  final EmployeeRepository repository;

  WatchAllEmployees({required this.repository});

  Stream<List<EmployeeModel>> call() {
    return repository.watchAllEmployees();
  }
}

class WatchEmployeesBySucursal {
  final EmployeeRepository repository;

  WatchEmployeesBySucursal({required this.repository});

  Stream<List<EmployeeModel>> call(String sucursalId) {
    return repository.watchBySucursal(sucursalId);
  }
}

class GetEmployeeByUid {
  final EmployeeRepository repository;

  GetEmployeeByUid({required this.repository});

  Future<EmployeeModel?> call(String uid) {
    return repository.getEmployeeByUid(uid);
  }
}

class CreateEmployee {
  final EmployeeRepository repository;

  CreateEmployee({required this.repository});

  Future<void> call(EmployeeModel employee) {
    return repository.createEmployee(employee);
  }
}

class UpdateEmployeeRole {
  final EmployeeRepository repository;

  UpdateEmployeeRole({required this.repository});

  Future<void> call(String uid, String newRole) {
    return repository.updateEmployeeRole(uid, newRole);
  }
}

class UpdateEmployeeSucursal {
  final EmployeeRepository repository;

  UpdateEmployeeSucursal({required this.repository});

  Future<void> call(String uid, String sucursalId) {
    return repository.updateEmployeeSucursal(uid, sucursalId);
  }
}

class DeleteEmployee {
  final EmployeeRepository repository;

  DeleteEmployee({required this.repository});

  Future<void> call(String uid) {
    return repository.deleteEmployee(uid);
  }
}

class DeactivateEmployee {
  final EmployeeRepository repository;

  DeactivateEmployee({required this.repository});

  Future<void> call(String uid) {
    return repository.deactivateEmployee(uid);
  }
}

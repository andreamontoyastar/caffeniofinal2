import 'package:caffenio/features/admin/data/datasources/employee_remote_datasource.dart';
import 'package:caffenio/features/admin/domain/repositories/employee_repository.dart';
import 'package:caffenio/shared/models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<EmployeeModel>> watchAllEmployees() {
    return remoteDataSource.watchAllEmployees();
  }

  @override
  Stream<List<EmployeeModel>> watchBySucursal(String sucursalId) {
    return remoteDataSource.watchBySucursal(sucursalId);
  }

  @override
  Future<EmployeeModel?> getEmployeeByUid(String uid) {
    return remoteDataSource.getEmployeeByUid(uid);
  }

  @override
  Future<void> createEmployee(EmployeeModel employee) {
    return remoteDataSource.createEmployee(employee);
  }

  @override
  Future<void> updateEmployeeRole(String uid, String newRole) {
    return remoteDataSource.updateEmployeeRole(uid, newRole);
  }

  @override
  Future<void> updateEmployeeSucursal(String uid, String sucursalId) {
    return remoteDataSource.updateEmployeeSucursal(uid, sucursalId);
  }

  @override
  Future<void> deleteEmployee(String uid) {
    return remoteDataSource.deleteEmployee(uid);
  }

  @override
  Future<void> deactivateEmployee(String uid) {
    return remoteDataSource.deactivateEmployee(uid);
  }
}

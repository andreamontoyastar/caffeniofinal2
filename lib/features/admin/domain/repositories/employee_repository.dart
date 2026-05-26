import 'package:caffenio/shared/models/employee_model.dart';

abstract class EmployeeRepository {
  Stream<List<EmployeeModel>> watchAllEmployees();
  Stream<List<EmployeeModel>> watchBySucursal(String sucursalId);
  Future<EmployeeModel?> getEmployeeByUid(String uid);
  Future<void> createEmployee(EmployeeModel employee);
  Future<void> updateEmployeeRole(String uid, String newRole);
  Future<void> updateEmployeeSucursal(String uid, String sucursalId);
  Future<void> deleteEmployee(String uid);
  Future<void> deactivateEmployee(String uid);
}

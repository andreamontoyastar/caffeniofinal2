import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/repositories/employee_repository.dart';
import 'package:caffenio/shared/models/employee_model.dart';
import 'package:flutter/material.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late EmployeeRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = sl<EmployeeRepository>();
  }

  void _showRoleChangeDialog(EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cambiar rol de ${employee.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rol actual: ${employee.role}'),
            const SizedBox(height: 16),
            const Text('Selecciona nuevo rol:'),
          ],
        ),
        actions: [
          for (final role in ['customer', 'barista', 'admin'])
            ElevatedButton(
              onPressed: () async {
                try {
                  await _repository.updateEmployeeRole(employee.uid, role);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rol cambiado a $role')),
                    );
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text(role.toUpperCase()),
            ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desactivar empleado'),
        content: Text(
            '¿Desactivar a ${employee.name}? No podrá acceder al sistema.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _repository.deactivateEmployee(employee.uid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Empleado desactivado')),
                  );
                  Navigator.pop(ctx);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Empleados'),
      ),
      body: StreamBuilder<List<EmployeeModel>>(
        stream: _repository.watchAllEmployees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final employees = snapshot.data ?? [];

          if (employees.isEmpty) {
            return const Center(
              child: Text('No hay empleados registrados'),
            );
          }

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (ctx, i) {
              final employee = employees[i];
              final rolColor = employee.role == 'admin'
                  ? Colors.purple
                  : employee.role == 'barista'
                      ? Colors.orange
                      : Colors.blue;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(employee.name),
                  subtitle: Text(employee.email),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: rolColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      employee.role[0].toUpperCase(),
                      style: TextStyle(
                        color: rolColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        child: const Text('Cambiar rol'),
                        onTap: () => _showRoleChangeDialog(employee),
                      ),
                      PopupMenuItem(
                        child: const Text('Desactivar'),
                        onTap: () => _showDeactivateDialog(employee),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(employee.name),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${employee.email}'),
                            Text('Rol: ${employee.role}'),
                            if (employee.sucursalId != null)
                              Text('Sucursal: ${employee.sucursalId}'),
                            Text('Activo: ${employee.isActive}'),
                            if (employee.hireDate != null)
                              Text(
                                  'Contratado: ${employee.hireDate?.toLocal().toString().split('.')[0]}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

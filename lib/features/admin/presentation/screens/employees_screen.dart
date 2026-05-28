import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/features/admin/domain/repositories/employee_repository.dart';
import 'package:caffenio/shared/models/employee_model.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late EmployeeRepository _repository;
  List<SucursalModel> _sucursales = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _repository = sl<EmployeeRepository>();
    _loadSucursales();
  }

  Future<void> _loadSucursales() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirebaseConstants.sucursalesCollection)
        .get();
    if (mounted) {
      setState(() {
        _sucursales = snap.docs
            .map((d) => SucursalModel.fromFirestore(d))
            .where((s) => s.isActive)
            .toList();
      });
    }
  }

  String _sucursalName(String? id) {
    if (id == null) return '—';
    final s = _sucursales.where((s) => s.id == id).firstOrNull;
    return s?.name ?? id;
  }

  Color _roleColor(String role) => switch (role) {
        'admin' => Colors.purple,
        'customer' => Colors.blue,
        _ => Colors.teal,
      };

  IconData _roleIcon(String role) => switch (role) {
        'admin' => Icons.admin_panel_settings,
        'customer' => Icons.person,
        _ => Icons.badge,
      };

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showAddUserDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddUserDialog(
        sucursales: _sucursales,
        repository: _repository,
      ),
    );
  }

  void _showRoleDialog(EmployeeModel emp) {
    const roles = ['customer', 'admin'];
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Rol de ${emp.name}'),
        children: [
          for (final role in roles)
            RadioListTile<String>(
              value: role,
              groupValue: emp.role,
              title: Text(role[0].toUpperCase() + role.substring(1)),
              activeColor: AppColors.primary,
              onChanged: (v) async {
                Navigator.pop(ctx);
                if (v == null || v == emp.role) return;
                try {
                  await _repository.updateEmployeeRole(emp.uid, v);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rol actualizado a $v')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }

  void _showBranchDialog(EmployeeModel emp) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Sucursal de ${emp.name}'),
        children: [
          ListTile(
            leading: const Icon(Icons.cancel_outlined),
            title: const Text('Sin sucursal'),
            onTap: () async {
              Navigator.pop(ctx);
              try {
                await _repository.updateEmployeeSucursal(emp.uid, '');
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
          for (final s in _sucursales)
            RadioListTile<String>(
              value: s.id,
              groupValue: emp.sucursalId,
              title: Text(s.name),
              subtitle: Text(s.city),
              activeColor: AppColors.primary,
              onChanged: (v) async {
                Navigator.pop(ctx);
                if (v == null) return;
                try {
                  await _repository.updateEmployeeSucursal(emp.uid, v);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sucursal actualizada')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }

  void _confirmDeactivate(EmployeeModel emp) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desactivar usuario'),
        content: Text('¿Desactivar a ${emp.name}?\nNo podrá acceder al sistema.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _repository.deactivateEmployee(emp.uid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario desactivado')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(EmployeeModel emp) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar permanentemente a ${emp.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _repository.deleteEmployee(emp.uid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario eliminado')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Agregar usuario',
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Buscador ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),

          // ── Lista ──────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<EmployeeModel>>(
              stream: _repository.watchAllEmployees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var employees = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  employees = employees
                      .where((e) =>
                          e.name.toLowerCase().contains(_searchQuery) ||
                          e.email.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No hay usuarios registrados'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: employees.length,
                  itemBuilder: (ctx, i) {
                    final emp = employees[i];
                    final rColor = _roleColor(emp.role);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: rColor.withValues(alpha: 0.15),
                          child: Icon(_roleIcon(emp.role),
                              color: rColor, size: 20),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                emp.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (!emp.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Inactivo',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.red)),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emp.email,
                                style: const TextStyle(fontSize: 12)),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    emp.role[0].toUpperCase() +
                                        emp.role.substring(1),
                                    style: TextStyle(
                                        fontSize: 11, color: rColor),
                                  ),
                                  backgroundColor: rColor.withValues(alpha: 0.1),
                                  side: BorderSide.none,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 6),
                                if (emp.sucursalId != null &&
                                    emp.sucursalId!.isNotEmpty)
                                  Chip(
                                    avatar: const Icon(Icons.store, size: 12),
                                    label: Text(
                                      _sucursalName(emp.sucursalId),
                                      style:
                                          const TextStyle(fontSize: 11),
                                    ),
                                    side: BorderSide.none,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                            if (emp.hireDate != null)
                              Text(
                                'Desde: ${DateFormat('dd/MM/yyyy').format(emp.hireDate!)}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            switch (action) {
                              case 'role':
                                _showRoleDialog(emp);
                              case 'branch':
                                _showBranchDialog(emp);
                              case 'deactivate':
                                _confirmDeactivate(emp);
                              case 'delete':
                                _confirmDelete(emp);
                            }
                          },
                          itemBuilder: (ctx) => const [
                            PopupMenuItem(
                                value: 'role',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.manage_accounts),
                                  title: Text('Cambiar rol'),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                )),
                            PopupMenuItem(
                                value: 'branch',
                                child: ListTile(
                                  leading: Icon(Icons.store),
                                  title: Text('Asignar sucursal'),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                )),
                            PopupMenuItem(
                                value: 'deactivate',
                                child: ListTile(
                                  leading: Icon(Icons.block,
                                      color: Colors.orange),
                                  title: Text('Desactivar'),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                )),
                            PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  title: Text('Eliminar',
                                      style:
                                          TextStyle(color: Colors.red)),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar usuario'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog para agregar usuario
// ─────────────────────────────────────────────────────────────────────────────

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog({
    required this.sucursales,
    required this.repository,
  });

  final List<SucursalModel> sucursales;
  final EmployeeRepository repository;

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'customer';
  String? _sucursalId;
  DateTime? _hireDate;
  bool _obscurePassword = true;
  bool _isSaving = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickHireDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _hireDate = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      // Create Firebase Auth user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      await cred.user?.updateDisplayName(_nameCtrl.text.trim());

      final uid = cred.user!.uid;
      final employee = EmployeeModel(
        uid: uid,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        role: _role,
        sucursalId: (_sucursalId?.isNotEmpty ?? false) ? _sucursalId : null,
        hireDate: _hireDate ?? DateTime.now(),
        isActive: true,
      );

      await widget.repository.createEmployee(employee);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Usuario "${employee.name}" creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMsg = switch (e.code) {
          'email-already-in-use' => 'Este email ya está registrado.',
          'weak-password' => 'La contraseña es muy débil (mín. 6 caracteres).',
          'invalid-email' => 'El email no es válido.',
          _ => 'Error de autenticación: ${e.message}',
        };
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Error inesperado: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add_alt_1, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Nuevo usuario'),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre completo
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El nombre es requerido'
                    : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico *',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El correo es requerido';
                  }
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Contraseña
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'La contraseña es requerida';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Rol
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Rol *',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'customer', child: Text('Cliente')),
                  DropdownMenuItem(
                      value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'customer'),
              ),
              const SizedBox(height: 12),

              // Sucursal
              DropdownButtonFormField<String>(
                initialValue: _sucursalId,
                decoration: const InputDecoration(
                  labelText: 'Sucursal (opcional)',
                  prefixIcon: Icon(Icons.store_outlined),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String>(
                      child: Text('Sin sucursal')),
                  for (final s in widget.sucursales)
                    DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.name} — ${s.city}')),
                ],
                onChanged: (v) => setState(() => _sucursalId = v),
              ),
              const SizedBox(height: 12),

              // Fecha de contratación
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary),
                title: Text(
                  _hireDate != null
                      ? 'Contratado: ${DateFormat('dd/MM/yyyy').format(_hireDate!)}'
                      : 'Fecha de contratación (opcional)',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: _hireDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _hireDate = null),
                      )
                    : null,
                onTap: _pickHireDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),

              // Error
              if (_errorMsg != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save),
          label: const Text('Crear usuario'),
        ),
      ],
    );
  }
}

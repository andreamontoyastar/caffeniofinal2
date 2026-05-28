import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/repositories/supplier_repository.dart';
import 'package:caffenio/shared/models/supplier_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late SupplierRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = sl<SupplierRepository>();
  }

  void _showAddEditDialog({SupplierModel? supplier}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final contactCtrl =
        TextEditingController(text: supplier?.contactName ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');
    bool isActive = supplier?.isActive ?? true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.local_shipping, color: Colors.blue),
              const SizedBox(width: 8),
              Text(supplier == null ? 'Nuevo Proveedor' : 'Editar Proveedor'),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la empresa *',
                      prefixIcon: Icon(Icons.business_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'El nombre es requerido'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de contacto *',
                      prefixIcon: Icon(Icons.person_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'El contacto es requerido'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'El email es requerido';
                      }
                      if (!v.contains('@')) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Proveedor activo'),
                    subtitle: Text(isActive ? 'Habilitado' : 'Deshabilitado'),
                    value: isActive,
                    onChanged: (v) =>
                        setDialogState(() => isActive = v), // ← dialogo state
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;

                final name = nameCtrl.text.trim();
                final contactName = contactCtrl.text.trim();
                final email = emailCtrl.text.trim().toLowerCase();
                final phone = phoneCtrl.text.trim();
                final address = addressCtrl.text.trim();
                final now = DateTime.now();

                final newSupplier = (supplier ??
                        SupplierModel(
                          id: const Uuid().v4(),
                          name: '',
                          contactName: '',
                          email: '',
                          phone: '',
                          address: '',
                          isActive: true,
                          createdAt: now,
                          updatedAt: now,
                        ))
                    .copyWith(
                  name: name,
                  contactName: contactName,
                  email: email,
                  phone: phone,
                  address: address,
                  isActive: isActive,
                  updatedAt: now,
                );

                try {
                  if (supplier == null) {
                    await _repository.createSupplier(newSupplier);
                  } else {
                    await _repository.updateSupplier(newSupplier);
                  }
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(supplier == null
                            ? 'Proveedor creado'
                            : 'Proveedor actualizado'),
                        backgroundColor: Colors.green,
                      ),
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
              icon: const Icon(Icons.save),
              label: Text(supplier == null ? 'Crear' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Proveedores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo proveedor',
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<SupplierModel>>(
        stream: _repository.watchAllSuppliers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final suppliers = snapshot.data ?? [];
          if (suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No hay proveedores registrados'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar proveedor'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: suppliers.length,
            itemBuilder: (ctx, index) {
              final supplier = suppliers[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(Icons.business,
                        color: theme.colorScheme.secondary),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(supplier.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: supplier.isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          supplier.isActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 11,
                            color: supplier.isActive
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contacto: ${supplier.contactName}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(supplier.email,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (supplier.phone.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.phone_outlined, size: 12),
                            const SizedBox(width: 4),
                            Text(supplier.phone,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'edit') {
                        _showAddEditDialog(supplier: supplier);
                      } else if (action == 'delete') {
                        _repository.deleteSupplier(supplier.id).then((_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Proveedor eliminado')),
                            );
                          }
                        });
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading:
                              Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('Eliminar',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Proveedor'),
      ),
    );
  }
}

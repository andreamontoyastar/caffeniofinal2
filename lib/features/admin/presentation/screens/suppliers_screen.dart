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
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final contactCtrl =
        TextEditingController(text: supplier?.contactName ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');
    bool isActive = supplier?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(supplier == null ? 'Nuevo Proveedor' : 'Editar Proveedor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(label: Text('Nombre')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactCtrl,
                decoration:
                    const InputDecoration(label: Text('Nombre de contacto')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(label: Text('Email')),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(label: Text('Teléfono')),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(label: Text('Dirección')),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Proveedor activo'),
                value: isActive,
                onChanged: (value) => setState(() {
                  isActive = value;
                }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final contactName = contactCtrl.text.trim();
              final email = emailCtrl.text.trim();
              final phone = phoneCtrl.text.trim();
              final address = addressCtrl.text.trim();

              if (name.isEmpty || contactName.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Completa los campos requeridos')),
                );
                return;
              }

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
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proveedor creado')),
                    );
                  }
                } else {
                  await _repository.updateSupplier(newSupplier);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proveedor actualizado')),
                    );
                  }
                }
                if (mounted) Navigator.pop(ctx);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(supplier == null ? 'Crear' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Proveedores'),
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
            return const Center(
              child: Text('No hay proveedores. Agrega uno nuevo.'),
            );
          }

          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (ctx, index) {
              final supplier = suppliers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(supplier.name),
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        child: const Text('Editar'),
                        onTap: () => _showAddEditDialog(supplier: supplier),
                      ),
                      PopupMenuItem(
                        child: const Text('Eliminar'),
                        onTap: () async {
                          await _repository.deleteSupplier(supplier.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Proveedor eliminado')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  subtitleTextStyle: TextStyle(
                    color:
                        supplier.isActive ? Colors.black87 : Colors.redAccent,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contacto: ${supplier.contactName}'),
                      Text('Email: ${supplier.email}'),
                      Text('Tel: ${supplier.phone}'),
                      Text(
                          'Estado: ${supplier.isActive ? 'Activo' : 'Inactivo'}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

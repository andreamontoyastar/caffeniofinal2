import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/repositories/sucursal_repository.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({super.key});

  @override
  State<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends State<SucursalesScreen> {
  late SucursalRepository _repository;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = sl<SucursalRepository>();
  }

  void _showAddEditDialog({SucursalModel? sucursal}) {
    final nameCtrl = TextEditingController(text: sucursal?.name ?? '');
    final addressCtrl = TextEditingController(text: sucursal?.address ?? '');
    final cityCtrl = TextEditingController(text: sucursal?.city ?? '');
    final phoneCtrl = TextEditingController(text: sucursal?.phone ?? '');
    final scheduleCtrl = TextEditingController(text: sucursal?.schedule ?? '');
    final latCtrl =
        TextEditingController(text: (sucursal?.lat ?? 0.0).toString());
    final lngCtrl =
        TextEditingController(text: (sucursal?.lng ?? 0.0).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(sucursal == null ? 'Nueva Sucursal' : 'Editar Sucursal'),
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
                controller: addressCtrl,
                decoration: const InputDecoration(label: Text('Dirección')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(label: Text('Ciudad')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(label: Text('Teléfono')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: scheduleCtrl,
                decoration: const InputDecoration(
                    label: Text('Horario (ej: 08:00-21:00)')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: latCtrl,
                decoration: const InputDecoration(label: Text('Latitud')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lngCtrl,
                decoration: const InputDecoration(label: Text('Longitud')),
                keyboardType: TextInputType.number,
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
              final address = addressCtrl.text.trim();
              final city = cityCtrl.text.trim();
              final phone = phoneCtrl.text.trim();
              final schedule = scheduleCtrl.text.trim();

              if (name.isEmpty || address.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Completa todos los campos requeridos')),
                );
                return;
              }

              final lat = double.tryParse(latCtrl.text) ?? 0.0;
              final lng = double.tryParse(lngCtrl.text) ?? 0.0;
              final now = DateTime.now();

              final newSucursal = (sucursal ??
                      SucursalModel(
                        id: const Uuid().v4(),
                        name: '',
                        address: '',
                        city: '',
                        phone: '',
                        schedule: '',
                        lat: 0,
                        lng: 0,
                        isActive: true,
                        employees: const [],
                        createdAt: now,
                        updatedAt: now,
                      ))
                  .copyWith(
                name: name,
                address: address,
                city: city,
                phone: phone,
                schedule: schedule,
                lat: lat,
                lng: lng,
                updatedAt: now,
              );

              try {
                if (sucursal == null) {
                  await _repository.createSucursal(newSucursal);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sucursal creada')),
                    );
                  }
                } else {
                  await _repository.updateSucursal(newSucursal);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sucursal actualizada')),
                    );
                  }
                }
                if (mounted) Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(sucursal == null ? 'Crear' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Sucursales'),
      ),
      body: StreamBuilder<List<SucursalModel>>(
        stream: _repository.watchAllSucursales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sucursales = snapshot.data ?? [];

          if (sucursales.isEmpty) {
            return const Center(
              child: Text('No hay sucursales. Crea una nueva.'),
            );
          }

          return ListView.builder(
            itemCount: sucursales.length,
            itemBuilder: (ctx, i) {
              final sucursal = sucursales[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(sucursal.name),
                  subtitle: Text('${sucursal.address}, ${sucursal.city}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        child: const Text('Editar'),
                        onTap: () => _showAddEditDialog(sucursal: sucursal),
                      ),
                      PopupMenuItem(
                        child: const Text('Eliminar'),
                        onTap: () async {
                          await _repository.deleteSucursal(sucursal.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Sucursal eliminada')),
                            );
                          }
                        },
                      ),
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

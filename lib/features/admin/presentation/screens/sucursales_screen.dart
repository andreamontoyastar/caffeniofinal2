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

  @override
  void initState() {
    super.initState();
    _repository = sl<SucursalRepository>();
  }

  void _showAddEditDialog({SucursalModel? sucursal}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: sucursal?.name ?? '');
    final addressCtrl = TextEditingController(text: sucursal?.address ?? '');
    final cityCtrl = TextEditingController(text: sucursal?.city ?? '');
    final phoneCtrl = TextEditingController(text: sucursal?.phone ?? '');
    final scheduleCtrl =
        TextEditingController(text: sucursal?.schedule ?? '07:00 - 22:00');
    final latCtrl =
        TextEditingController(text: (sucursal?.lat ?? 0.0).toString());
    final lngCtrl =
        TextEditingController(text: (sucursal?.lng ?? 0.0).toString());
    bool isActive = sucursal?.isActive ?? true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.store, color: Colors.teal),
              const SizedBox(width: 8),
              Text(sucursal == null ? 'Nueva Sucursal' : 'Editar Sucursal'),
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
                      labelText: 'Nombre de la sucursal *',
                      prefixIcon: Icon(Icons.store_outlined),
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
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'La dirección es requerida'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cityCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad *',
                      prefixIcon: Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'La ciudad es requerida'
                        : null,
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
                    controller: scheduleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Horario',
                      hintText: 'Ej: 07:00 - 22:00',
                      prefixIcon: Icon(Icons.access_time_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: latCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Latitud',
                            prefixIcon: Icon(Icons.map_outlined),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: lngCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Longitud',
                            prefixIcon: Icon(Icons.map_outlined),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Sucursal activa'),
                    subtitle: Text(
                        isActive ? 'Visible para clientes' : 'No visible'),
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
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
                final address = addressCtrl.text.trim();
                final city = cityCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final schedule = scheduleCtrl.text.trim();
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
                  isActive: isActive,
                  updatedAt: now,
                );

                try {
                  if (sucursal == null) {
                    await _repository.createSucursal(newSucursal);
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sucursal creada'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    await _repository.updateSucursal(newSucursal);
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sucursal actualizada'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
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
              label: Text(sucursal == null ? 'Crear' : 'Actualizar'),
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
        title: const Text('Gestión de Sucursales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nueva sucursal',
            onPressed: () => _showAddEditDialog(),
          ),
        ],
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No hay sucursales registradas'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera sucursal'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sucursales.length,
            itemBuilder: (ctx, i) {
              final sucursal = sucursales[i];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    child: Icon(Icons.store,
                        color: theme.colorScheme.tertiary),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                          child: Text(sucursal.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                      if (!sucursal.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Inactiva',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.red)),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${sucursal.address}, ${sucursal.city}'),
                      Row(
                        children: [
                          if (sucursal.phone.isNotEmpty) ...[
                            const Icon(Icons.phone, size: 12),
                            const SizedBox(width: 4),
                            Text(sucursal.phone,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 12),
                          ],
                          if (sucursal.schedule.isNotEmpty) ...[
                            const Icon(Icons.access_time, size: 12),
                            const SizedBox(width: 4),
                            Text(sucursal.schedule,
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
                        _showAddEditDialog(sucursal: sucursal);
                      } else if (action == 'delete') {
                        showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Eliminar sucursal'),
                            content: Text(
                                '¿Eliminar "${sucursal.name}"? Esta acción no se puede deshacer.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await _repository
                                      .deleteSucursal(sucursal.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Sucursal eliminada')),
                                    );
                                  }
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
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
        label: const Text('Nueva Sucursal'),
      ),
    );
  }
}

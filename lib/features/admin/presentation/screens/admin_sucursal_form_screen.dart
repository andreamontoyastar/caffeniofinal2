import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminSucursalFormScreen extends StatefulWidget {
  final SucursalModel? sucursal;
  const AdminSucursalFormScreen({this.sucursal, super.key});

  @override
  State<AdminSucursalFormScreen> createState() => _AdminSucursalFormScreenState();
}

class _AdminSucursalFormScreenState extends State<AdminSucursalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  late final TextEditingController _scheduleController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sucursal?.name ?? '');
    _addressController = TextEditingController(text: widget.sucursal?.address ?? '');
    _cityController = TextEditingController(text: widget.sucursal?.city ?? '');
    _phoneController = TextEditingController(text: widget.sucursal?.phone ?? '');
    _scheduleController = TextEditingController(text: widget.sucursal?.schedule ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final sucursal = SucursalModel(
      id: widget.sucursal?.id ?? '', // ID will be set by firestore on create
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      phone: _phoneController.text.trim(),
      schedule: _scheduleController.text.trim(),
      lat: widget.sucursal?.lat ?? 0.0,
      lng: widget.sucursal?.lng ?? 0.0,
      isActive: widget.sucursal?.isActive ?? true,
      employees: widget.sucursal?.employees ?? [],
      createdAt: widget.sucursal?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      final collection = FirebaseFirestore.instance.collection(FirebaseConstants.sucursalesCollection);
      if (widget.sucursal == null) {
        await collection.add(sucursal.toMap());
      } else {
        await collection.doc(sucursal.id).update(sucursal.toMap());
      }
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showSnackBar(
        'Error al guardar la sucursal: $e',
        color: Theme.of(context).colorScheme.error,
      );
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sucursal != null;
    final title = isEditing ? 'Editar sucursal' : 'Agregar sucursal';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: theme.textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de la sucursal'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre de la sucursal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa la dirección';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa la ciudad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(labelText: 'Horario'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el horario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(
                        isEditing ? 'Actualizar sucursal' : 'Crear sucursal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

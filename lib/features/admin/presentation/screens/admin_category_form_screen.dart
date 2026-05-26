import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/shared/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminCategoryFormScreen extends StatefulWidget {
  final CategoryModel? category;
  const AdminCategoryFormScreen({this.category, super.key});

  @override
  State<AdminCategoryFormScreen> createState() => _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState extends State<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    final name = _nameController.text.trim();

    final category = CategoryModel(
      id: widget.category?.id ?? '',
      name: name,
      isActive: _isActive,
      order: widget.category?.order ?? 0, // No se edita aquí, se puede gestionar con otra interfaz
    );

    try {
      if (widget.category == null) {
        await FirebaseFirestore.instance.collection(FirebaseConstants.categoriesCollection).add(category.toMap());
      } else {
        await FirebaseFirestore.instance.collection(FirebaseConstants.categoriesCollection).doc(category.id).update(category.toMap());
      }
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showSnackBar(
        'Error al guardar la categoría: $e',
        color: Theme.of(context).colorScheme.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final title = isEditing ? 'Editar categoría' : 'Agregar categoría';
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
                    const InputDecoration(labelText: 'Nombre de la categoría'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre de la categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                title: const Text('Activa'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
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
                        isEditing ? 'Actualizar categoría' : 'Crear categoría'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

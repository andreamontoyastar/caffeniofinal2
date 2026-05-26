import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/features/catalog/presentation/providers/product_provider.dart';
import 'package:caffenio/shared/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  const AdminProductFormScreen({this.product, super.key});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _categoryController;
  late final TextEditingController _preparationTimeController;

  final _sizeNameControllers = <TextEditingController>[];
  final _sizePriceControllers = <TextEditingController>[];
  final _milkNameControllers = <TextEditingController>[];
  final _milkPriceControllers = <TextEditingController>[];
  final _extraNameControllers = <TextEditingController>[];
  final _extraPriceControllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(
      text: widget.product != null
          ? widget.product!.price.toStringAsFixed(2)
          : '',
    );
    _imageUrlController =
        TextEditingController(text: (widget.product?.imageUrl ?? ''));
    _categoryController = TextEditingController(
        text: (widget.product?.categoryId ?? ''));
    _preparationTimeController = TextEditingController(
      text: widget.product == null
          ? ''
          : widget.product!.preparationTimeMinutes.toString(),
    );

    if (widget.product != null) {
      final List<CustomizationOption> sizes = widget.product!.sizes;
      final List<CustomizationOption> milkTypes = widget.product!.milkTypes;
      final List<CustomizationOption> extras = widget.product!.extras;

      for (final CustomizationOption option in sizes) {
        _sizeNameControllers
            .add(TextEditingController(text: option.name));
        _sizePriceControllers.add(
          TextEditingController(text: option.priceExtra.toStringAsFixed(2)),
        );
      }
      for (final CustomizationOption option in milkTypes) {
        _milkNameControllers
            .add(TextEditingController(text: option.name));
        _milkPriceControllers.add(
          TextEditingController(text: option.priceExtra.toStringAsFixed(2)),
        );
      }
      for (final CustomizationOption option in extras) {
        _extraNameControllers
            .add(TextEditingController(text: option.name));
        _extraPriceControllers.add(
          TextEditingController(text: option.priceExtra.toStringAsFixed(2)),
        );
      }
    }

    if (_sizeNameControllers.isEmpty) {
      _sizeNameControllers.add(TextEditingController());
      _sizePriceControllers.add(TextEditingController(text: '0.00'));
    }
    if (_milkNameControllers.isEmpty) {
      _milkNameControllers.add(TextEditingController());
      _milkPriceControllers.add(TextEditingController(text: '0.00'));
    }
    if (_extraNameControllers.isEmpty) {
      _extraNameControllers.add(TextEditingController());
      _extraPriceControllers.add(TextEditingController(text: '0.00'));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _preparationTimeController.dispose();
    for (final controller in [
      ..._sizeNameControllers,
      ..._sizePriceControllers,
      ..._milkNameControllers,
      ..._milkPriceControllers,
      ..._extraNameControllers,
      ..._extraPriceControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSizeOption([CustomizationOption? option]) {
    _sizeNameControllers.add(TextEditingController(text: option?.name ?? ''));
    _sizePriceControllers.add(TextEditingController(
      text: option != null ? option.priceExtra.toStringAsFixed(2) : '0.00',
    ));
  }

  void _addMilkOption([CustomizationOption? option]) {
    _milkNameControllers.add(TextEditingController(text: option?.name ?? ''));
    _milkPriceControllers.add(TextEditingController(
      text: option != null ? option.priceExtra.toStringAsFixed(2) : '0.00',
    ));
  }

  void _addExtraOption([CustomizationOption? option]) {
    _extraNameControllers.add(TextEditingController(text: option?.name ?? ''));
    _extraPriceControllers.add(TextEditingController(
      text: option != null ? option.priceExtra.toStringAsFixed(2) : '0.00',
    ));
  }

  void _removeOption(
    List<TextEditingController> names,
    List<TextEditingController> prices,
    int index,
  ) {
    names[index].dispose();
    prices[index].dispose();
    names.removeAt(index);
    prices.removeAt(index);
  }

  List<CustomizationOption> _collectOptions(
    List<TextEditingController> nameControllers,
    List<TextEditingController> priceControllers,
  ) {
    final options = <CustomizationOption>[];
    for (var index = 0; index < nameControllers.length; index++) {
      final name = nameControllers[index].text.trim();
      final price = double.tryParse(
            priceControllers[index].text.trim().replaceAll(',', '.'),
          ) ??
          0.0;
      if (name.isNotEmpty) {
        options.add(CustomizationOption(name: name, priceExtra: price));
      }
    }
    return options;
  }

  Widget _buildCustomizationSection({
    required String title,
    required List<TextEditingController> nameControllers,
    required List<TextEditingController> priceControllers,
    required VoidCallback onAdd,
    required String addLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(nameControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: nameControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Opción #${index + 1}',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa un nombre para esta opción';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: priceControllers[index],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                      prefixText: '\u0024',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el cargo';
                      }
                      final parsed =
                          double.tryParse(value.replaceAll(',', '.'));
                      if (parsed == null) {
                        return 'Cargo no válido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: nameControllers.length > 1
                      ? () {
                          setState(() {
                            _removeOption(
                                nameControllers, priceControllers, index);
                          });
                        }
                      : null,
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            setState(onAdd);
          },
          icon: const Icon(Icons.add_circle_outline),
          label: Text(addLabel),
        ),
      ],
    );
  }

  void _showSnackBar(String message, {required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<ProductProvider>();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price =
        double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ?? 0;
    final categoryId = _categoryController.text.trim();
    final preparationTime =
        int.tryParse(_preparationTimeController.text.trim()) ?? 0;
    final imageUrl = _imageUrlController.text.trim();

    final sizes = _collectOptions(_sizeNameControllers, _sizePriceControllers);
    final milkTypes =
        _collectOptions(_milkNameControllers, _milkPriceControllers);
    final extras =
        _collectOptions(_extraNameControllers, _extraPriceControllers);

    if (categoryId.isEmpty) {
      _showSnackBar(
        'Ingresa la categoría del producto.',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (preparationTime <= 0) {
      _showSnackBar(
        'Ingresa un tiempo de preparación válido.',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (sizes.isEmpty) {
      _showSnackBar(
        'Agrega al menos una opción de tamaño.',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      preparationTimeMinutes: preparationTime,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      sizes: sizes,
      milkTypes: milkTypes,
      extras: extras,
    );

    if (widget.product == null) {
      await provider.addProduct(product);
    } else {
      await provider.updateProduct(product);
    }

    if (mounted && provider.errorMessage == null) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final isEditing = widget.product != null;
    final title = isEditing ? 'Editar producto' : 'Agregar producto';
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
                    const InputDecoration(labelText: 'Nombre del producto'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixText: ' 24',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el precio';
                  }
                  final parsed = double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null) {
                    return 'Precio no válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa la categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _preparationTimeController,
                keyboardType:
                    const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(
                  labelText: 'Tiempo de preparación (minutos)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el tiempo de preparación';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Tiempo no válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de imagen',
                  hintText:
                      'https://raw.githubusercontent.com/.../main/imagen.png',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildCustomizationSection(
                title: 'Tamaños',
                nameControllers: _sizeNameControllers,
                priceControllers: _sizePriceControllers,
                onAdd: () => _addSizeOption(),
                addLabel: 'Agregar tamaño',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildCustomizationSection(
                title: 'Leches',
                nameControllers: _milkNameControllers,
                priceControllers: _milkPriceControllers,
                onAdd: () => _addMilkOption(),
                addLabel: 'Agregar leche',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildCustomizationSection(
                title: 'Extras',
                nameControllers: _extraNameControllers,
                priceControllers: _extraPriceControllers,
                onAdd: () => _addExtraOption(),
                addLabel: 'Agregar extra',
              ),
              const SizedBox(height: AppSpacing.lg),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    provider.errorMessage!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              ElevatedButton(
                onPressed: provider.isActionLoading ? null : _submit,
                child: provider.isActionLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(
                        isEditing ? 'Actualizar producto' : 'Crear producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

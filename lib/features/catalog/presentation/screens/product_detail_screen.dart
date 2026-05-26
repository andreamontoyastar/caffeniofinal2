import 'package:caffenio/features/cart/presentation/providers/cart_provider.dart';
import 'package:caffenio/shared/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({required this.product, super.key});

  final ProductModel product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late CustomizationOption _selectedSize;
  CustomizationOption? _selectedMilk;
  final List<CustomizationOption> _selectedExtras = [];
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Inicializar con el tamaño base por defecto o el primero disponible
    final CustomizationOption defaultSize = widget.product.sizes.isNotEmpty
        ? widget.product.sizes.first
        : const CustomizationOption(name: 'Chico', priceExtra: 0.0);
    _selectedSize = defaultSize;

    if (widget.product.milkTypes.isNotEmpty) {
      _selectedMilk = widget.product.milkTypes.first;
    }
  }

  double _calculateCurrentTotal() {
    final double base = widget.product.price;
    double extra = _selectedSize.priceExtra;
    if (_selectedMilk != null) extra += _selectedMilk!.priceExtra;
    extra += _selectedExtras.fold(0.0, (sum, item) => sum + item.priceExtra);
    return (base + extra) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen/Icono con animación Hero
                  Hero(
                    tag: 'product_image_${widget.product.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: widget.product.imageUrl != null &&
                                widget.product.imageUrl!.isNotEmpty
                            ? Image.network(
                                widget.product.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  // Fall back to product.displayImageUrl (Unsplash) when the original fails
                                  return Image.network(
                                    widget.product.displayImageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error2, stackTrace2) {
                                      return Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        child: Center(
                                          child: Icon(Icons.coffee,
                                              size: 100,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            : Center(
                                child: Icon(Icons.coffee,
                                    size: 100,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Text(widget.product.name,
                      style: Theme.of(context).textTheme.displaySmall),
                  const Gap(8),
                  Text(widget.product.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  const Gap(24),

                  // 1. Selector de Tamaño
                  if (widget.product.sizes.isNotEmpty) ...[
                    const Text('Selecciona el tamaño:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      children: widget.product.sizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return ChoiceChip(
                          label: Text(
                              '${size.name} (+\$${size.priceExtra.toStringAsFixed(0)})'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedSize = size);
                          },
                        );
                      }).toList(),
                    ),
                    const Gap(20),
                  ],

                  // 2. Selector de Leche
                  if (widget.product.milkTypes.isNotEmpty) ...[
                    const Text('Tipo de leche:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Gap(4),
                    RadioGroup<CustomizationOption>(
                      groupValue: _selectedMilk,
                      onChanged: (CustomizationOption? val) =>
                          setState(() => _selectedMilk = val),
                      child: Column(
                        children: widget.product.milkTypes.map((milk) {
                          return RadioListTile<CustomizationOption>(
                            title: Text(
                                '${milk.name} (+\$${milk.priceExtra.toStringAsFixed(0)})'),
                            value: milk,
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    ),
                    const Gap(12),
                  ],

                  // 3. Selector de Extras
                  if (widget.product.extras.isNotEmpty) ...[
                    const Text('Extras sugeridos:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Gap(4),
                    Column(
                      children: widget.product.extras.map((extra) {
                        final isChecked = _selectedExtras.contains(extra);
                        return CheckboxListTile(
                          title: Text(
                              '${extra.name} (+\$${extra.priceExtra.toStringAsFixed(0)})'),
                          value: isChecked,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedExtras.add(extra);
                              } else {
                                _selectedExtras.remove(extra);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Barra Inferior de Compra/Acción
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Row(
              children: [
                // Contador de cantidad
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    Text('$_quantity',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
                const Gap(16),
                // Botón dinámico
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      cartProvider.addItem(
                        product: widget.product,
                        quantity: _quantity,
                        selectedSize: _selectedSize,
                        selectedMilk: _selectedMilk,
                        selectedExtras: _selectedExtras,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '¡${widget.product.name} agregado al carrito!')),
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Agregar · \$${_calculateCurrentTotal().toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

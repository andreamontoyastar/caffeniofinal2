import 'package:caffenio/core/constants/route_constants.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/features/catalog/presentation/providers/product_provider.dart';
import 'package:caffenio/shared/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Menú / Productos', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push(RouteConstants.adminProductCreate);
            },
            tooltip: 'Agregar producto',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage != null
                ? Center(
                    child: Text(
                      provider.errorMessage!,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : provider.products.isEmpty
                    ? const Center(
                        child: Text(
                            'No hay productos en el menú. Agrega uno nuevo.'),
                      )
                    : ListView.separated(
                        itemCount: provider.products.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          return _buildProductTile(context, product, provider);
                        },
                      ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.displayImageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(product.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Precio: \$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium,
              ),
              Text('Categoría: ${product.categoryId}',
                  style: theme.textTheme.bodySmall),
              Text(
                  'Tamaños: ${product.sizes.map((s) => s.name).join(', ')}',
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductProvider provider,
    ProductModel product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
            '¿Eliminar "${product.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteProduct(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${product.name}" eliminado.')),
        );
      }
    }
  }

  Widget _buildProductTile(
    BuildContext context,
    ProductModel product,
    ProductProvider provider,
  ) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            product.displayImageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image_outlined),
          ),
        ),
        title: Text(product.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _showProductDetails(context, product);
                break;
              case 'edit':
                context.push(
                  RouteConstants.adminProductEdit
                      .replaceFirst(':productId', product.id),
                );
                break;
              case 'delete':
                _confirmDelete(context, provider, product);
                break;
            }
          },
          itemBuilder: (ctx) => const [
            PopupMenuItem(value: 'view', child: Text('Ver detalle')),
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}

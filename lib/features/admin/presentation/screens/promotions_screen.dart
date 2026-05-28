import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/repositories/promotion_repository.dart';
import 'package:caffenio/shared/models/promotion_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  late PromotionRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = sl<PromotionRepository>();
  }

  void _showAddEditDialog({PromotionModel? promotion}) {
    final titleCtrl = TextEditingController(text: promotion?.title ?? '');
    final descCtrl = TextEditingController(text: promotion?.description ?? '');
    final valueCtrl =
        TextEditingController(text: (promotion?.value ?? 0).toString());
    final codeCtrl = TextEditingController(text: promotion?.code ?? '');
    String selectedType = promotion?.type ?? 'percentage';
    DateTime startDate = promotion?.startDate ?? DateTime.now();
    DateTime endDate =
        promotion?.endDate ?? DateTime.now().add(const Duration(days: 30));
    bool isActive = promotion?.isActive ?? true;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.amber),
              const SizedBox(width: 8),
              Text(promotion == null ? 'Nueva Promoción' : 'Editar Promoción'),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    prefixIcon: Icon(Icons.local_offer_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  items: const [
                    DropdownMenuItem(
                        value: 'percentage', child: Text('Porcentaje (%)')),
                    DropdownMenuItem(
                        value: 'fixed', child: Text('Descuento Fijo (\$)')),
                    DropdownMenuItem(value: '2x1', child: Text('2x1')),
                    DropdownMenuItem(
                        value: 'free_item', child: Text('Producto Gratis')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v ?? 'percentage'),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Promoción',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: valueCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    hintText: 'Ej: 15 para 15% o 20 para \$20',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Código de Cupón (opcional)',
                    prefixIcon: Icon(Icons.qr_code_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Promoción activa'),
                  subtitle:
                      Text(isActive ? 'Visible para clientes' : 'No visible'),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                // Fecha inicio
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Fecha inicio'),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(startDate)),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx2,
                          initialDate: startDate,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => startDate = picked);
                        }
                      },
                      child: const Text('Cambiar'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Fecha fin
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('Fecha fin'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(endDate)),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx2,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => endDate = picked);
                        }
                      },
                      child: const Text('Cambiar'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final desc = descCtrl.text.trim();
                final value = double.tryParse(valueCtrl.text) ?? 0;
                final code = codeCtrl.text.trim().isEmpty
                    ? null
                    : codeCtrl.text.trim().toUpperCase();

                if (title.isEmpty || desc.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('El título y la descripción son requeridos')),
                  );
                  return;
                }

                final newPromotion = (promotion ??
                        PromotionModel(
                          id: const Uuid().v4(),
                          title: '',
                          description: '',
                          type: 'percentage',
                          value: 0,
                          applicableProducts: const [],
                          startDate: DateTime.now(),
                          endDate: DateTime.now(),
                          isActive: true,
                          usageCount: 0,
                          createdAt: DateTime.now(),
                        ))
                    .copyWith(
                  title: title,
                  description: desc,
                  type: selectedType,
                  value: value,
                  code: code,
                  isActive: isActive,
                  startDate: startDate,
                  endDate: endDate,
                );

                try {
                  if (promotion == null) {
                    await _repository.createPromotion(newPromotion);
                  } else {
                    await _repository.updatePromotion(newPromotion);
                  }
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(promotion == null
                            ? 'Promoción creada'
                            : 'Promoción actualizada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: Text(promotion == null ? 'Crear' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
        'percentage' => 'Descuento %',
        'fixed' => 'Fijo \$',
        '2x1' => '2x1',
        'free_item' => 'Producto Gratis',
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Promociones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nueva promoción',
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<PromotionModel>>(
        stream: _repository.watchAllPromotions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final promotions = snapshot.data ?? [];

          if (promotions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No hay promociones activas'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera promoción'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: promotions.length,
            itemBuilder: (ctx, i) {
              final promo = promotions[i];
              final now = DateTime.now();
              final isExpired = promo.endDate.isBefore(now);
              final statusColor =
                  !promo.isActive || isExpired ? Colors.red : Colors.green;
              final statusText = isExpired
                  ? 'Expirada'
                  : promo.isActive
                      ? 'Activa'
                      : 'Inactiva';

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primaryContainer,
                    child: Icon(Icons.local_offer,
                        color: theme.colorScheme.primary),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                          child: Text(promo.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(statusText,
                            style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(promo.description,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      Row(
                        children: [
                          Chip(
                            label: Text(_typeLabel(promo.type),
                                style: const TextStyle(fontSize: 11)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 6),
                          Text('Valor: ${promo.value}',
                              style: const TextStyle(fontSize: 12)),
                          if (promo.code != null) ...[
                            const SizedBox(width: 6),
                            Text('Cód: ${promo.code}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                      Text(
                        'Vigencia: ${DateFormat('dd/MM/yy').format(promo.startDate)} - ${DateFormat('dd/MM/yy').format(promo.endDate)}',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'edit') {
                        _showAddEditDialog(promotion: promo);
                      } else if (action == 'delete') {
                        _repository.deletePromotion(promo.id).then((_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Promoción eliminada')),
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
        label: const Text('Nueva Promoción'),
      ),
    );
  }
}

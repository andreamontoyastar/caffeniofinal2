import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/repositories/promotion_repository.dart';
import 'package:caffenio/shared/models/promotion_model.dart';
import 'package:flutter/material.dart';
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
    final typeCtrl =
        TextEditingController(text: promotion?.type ?? 'percentage');
    final valueCtrl =
        TextEditingController(text: (promotion?.value ?? 0).toString());
    final codeCtrl = TextEditingController(text: promotion?.code ?? '');
    DateTime startDate = promotion?.startDate ?? DateTime.now();
    DateTime endDate =
        promotion?.endDate ?? DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(promotion == null ? 'Nueva Promoción' : 'Editar Promoción'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(label: Text('Título')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(label: Text('Descripción')),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: typeCtrl.text,
                items: ['percentage', 'fixed', '2x1', 'free_item']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => typeCtrl.text = v ?? 'percentage',
                decoration: const InputDecoration(label: Text('Tipo')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueCtrl,
                decoration: const InputDecoration(label: Text('Valor')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeCtrl,
                decoration:
                    const InputDecoration(label: Text('Código (opcional)')),
              ),
              const SizedBox(height: 12),
              Text(
                  'Fecha inicio: ${startDate.toLocal().toString().split('.')[0]}'),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    startDate = picked;
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Cambiar'),
              ),
              const SizedBox(height: 12),
              Text('Fecha fin: ${endDate.toLocal().toString().split('.')[0]}'),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: endDate,
                    firstDate: startDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    endDate = picked;
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Cambiar'),
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
              final title = titleCtrl.text.trim();
              final desc = descCtrl.text.trim();
              final type = typeCtrl.text.trim();
              final value = double.tryParse(valueCtrl.text) ?? 0;
              final code =
                  codeCtrl.text.trim().isEmpty ? null : codeCtrl.text.trim();

              if (title.isEmpty || desc.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa todos los campos')),
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
                type: type,
                value: value,
                code: code,
                startDate: startDate,
                endDate: endDate,
              );

              try {
                if (promotion == null) {
                  await _repository.createPromotion(newPromotion);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Promoción creada')),
                    );
                  }
                } else {
                  await _repository.updatePromotion(newPromotion);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Promoción actualizada')),
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
            child: Text(promotion == null ? 'Crear' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Promociones'),
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
            return const Center(
              child: Text('No hay promociones. Crea una nueva.'),
            );
          }

          return ListView.builder(
            itemCount: promotions.length,
            itemBuilder: (ctx, i) {
              final promo = promotions[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(promo.title),
                  subtitle: Text(
                      '${promo.type.toUpperCase()} - Valor: ${promo.value}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        child: const Text('Editar'),
                        onTap: () => _showAddEditDialog(promotion: promo),
                      ),
                      PopupMenuItem(
                        child: const Text('Eliminar'),
                        onTap: () async {
                          await _repository.deletePromotion(promo.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Promoción eliminada')),
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

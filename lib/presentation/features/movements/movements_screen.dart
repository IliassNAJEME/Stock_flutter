import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/product.dart';
import '../../../domain/models/stock_movement.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/async_value_builder.dart';

class MovementsScreen extends ConsumerWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movements = ref.watch(movementsProvider);

    return Scaffold(
      body: AsyncValueBuilder(
        value: movements,
        data: (items) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => const _MovementDialog(type: MovementType.entry),
                      ),
                      icon: const Icon(Icons.call_received),
                      label: const Text('Entree en stock'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => const _MovementDialog(type: MovementType.sale),
                      ),
                      icon: const Icon(Icons.point_of_sale),
                      label: const Text('Vente'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Aucun mouvement enregistre.'),
                  ),
                )
              else
                ...items.map(
                  (movement) => Card(
                    child: ListTile(
                      leading: Icon(
                        movement.type == MovementType.entry
                            ? Icons.south_west
                            : Icons.north_east,
                      ),
                      title: Text(movement.productName),
                      subtitle: Text(
                        '${movement.categoryName} • ${movement.quantity} unites',
                      ),
                      trailing: Text(
                        movement.type == MovementType.entry ? 'Entree' : 'Vente',
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MovementDialog extends ConsumerStatefulWidget {
  const _MovementDialog({required this.type});

  final MovementType type;

  @override
  ConsumerState<_MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends ConsumerState<_MovementDialog> {
  final _quantityController = TextEditingController(text: '1');
  String? _selectedProductId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final products = await ref.read(productsProvider.future);
    final selectedProduct = products.cast<Product?>().firstWhere(
          (product) => product?.id == _selectedProductId,
          orElse: () => null,
        );

    if (selectedProduct == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(inventoryControllerProvider).addMovement(
            product: selectedProduct,
            quantity: int.parse(_quantityController.text),
            type: widget.type,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);

    return AlertDialog(
      title: Text(widget.type == MovementType.entry ? 'Nouvelle entree' : 'Nouvelle vente'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            products.when(
              data: (items) {
                final hasSelectedProduct = items.any(
                  (product) => product.id == _selectedProductId,
                );
                if (!hasSelectedProduct && _selectedProductId != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _selectedProductId = null;
                    });
                  });
                }

                return DropdownButtonFormField<String>(
                  initialValue: hasSelectedProduct ? _selectedProductId : null,
                  decoration: const InputDecoration(labelText: 'Produit'),
                  items: items
                      .map(
                        (product) => DropdownMenuItem(
                          value: product.id,
                          child: Text('${product.name} (${product.stockQuantity})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProductId = value;
                    });
                  },
                );
              },
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantite'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: const Text('Valider'),
        ),
      ],
    );
  }
}

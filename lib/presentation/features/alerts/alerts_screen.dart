import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../widgets/async_value_builder.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStock = ref.watch(lowStockProductsProvider);

    return Scaffold(
      body: AsyncValueBuilder(
        value: lowStock,
        data: (products) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${products.length} produit(s) sous le seuil de reapprovisionnement',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: products.isEmpty
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final message = await ref
                                    .read(inventoryControllerProvider)
                                    .sendLowStockNotification();
                                messenger.showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              },
                        icon: const Icon(Icons.send),
                        label: const Text('Notifier'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (products.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Aucune alerte stock.'),
                  ),
                )
              else
                ...products.map(
                  (product) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber, color: Colors.orange),
                      title: Text(product.name),
                      subtitle: Text(product.categoryName),
                      trailing: Text(
                        '${product.stockQuantity}/${product.reorderThreshold}',
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

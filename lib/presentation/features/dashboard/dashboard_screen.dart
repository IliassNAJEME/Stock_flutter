import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_providers.dart';
import '../../widgets/async_value_builder.dart';
import '../../widgets/metric_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(selectedRangeProvider);
    final summary = ref.watch(dashboardSummaryProvider);
    final lowStock = ref.watch(lowStockProductsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Plage analysee'),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(range.start)} - '
                        '${DateFormat('dd/MM/yyyy').format(range.end)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: range,
                    );
                    if (picked != null) {
                      ref.read(selectedRangeProvider.notifier).update(picked);
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: const Text('Changer'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AsyncValueBuilder(
          value: summary,
          data: (data) {
            final currency = NumberFormat.currency(symbol: 'MAD ');
            return Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 720 ? 4 : 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    MetricCard(
                      label: 'Valeur du stock critique',
                      value: currency.format(data.totalStockValue),
                      icon: Icons.inventory_2,
                    ),
                    MetricCard(
                      label: 'Entrees sur la periode',
                      value: '${data.totalEntries}',
                      icon: Icons.call_received,
                    ),
                    MetricCard(
                      label: 'Ventes sur la periode',
                      value: '${data.totalSales}',
                      icon: Icons.point_of_sale,
                    ),
                    MetricCard(
                      label: 'Produits critiques',
                      value: '${lowStock.asData?.value.length ?? 0}',
                      icon: Icons.warning_amber,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Produits les plus vendus',
                  child: data.topSellingProducts.isEmpty
                      ? const Text('Aucune vente sur cette plage de dates.')
                      : Column(
                          children: data.topSellingProducts
                              .map(
                                (item) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item.productName),
                                  trailing: Text('${item.quantitySold} u'),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Ventes par categorie',
                  child: data.salesByCategory.isEmpty
                      ? const Text('Aucune categorie vendue sur cette periode.')
                      : Column(
                          children: data.salesByCategory
                              .map(
                                (item) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item.categoryName),
                                  trailing: Text(currency.format(item.amount)),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

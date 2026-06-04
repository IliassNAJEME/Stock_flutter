import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/category.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/async_value_builder.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      body: AsyncValueBuilder(
        value: products,
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aucun produit pour le moment.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = items[index];
              return Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.categoryName} • Stock ${product.stockQuantity} • '
                    'Seuil ${product.reorderThreshold}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${product.unitPrice.toStringAsFixed(2)} MAD'),
                      if (product.isBelowThreshold)
                        const Text(
                          'Critique',
                          style: TextStyle(color: Colors.red),
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
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const _AddProductDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Produit'),
      ),
    );
  }
}

class _AddProductDialog extends ConsumerStatefulWidget {
  const _AddProductDialog();

  @override
  ConsumerState<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<_AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _newCategoryController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _priceController = TextEditingController(text: '0');
  final _thresholdController = TextEditingController(text: '5');
  Category? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _newCategoryController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final controller = ref.read(inventoryControllerProvider);
      Category? category = _selectedCategory;

      if (category == null) {
        final name = _newCategoryController.text.trim();
        await controller.addCategory(name);
        final categories = await ref.read(categoriesProvider.future);
        category = categories.firstWhere((item) => item.name == name);
      }

      await controller.addProduct(
        name: _nameController.text.trim(),
        categoryId: category.id,
        categoryName: category.name,
        initialStock: int.parse(_stockController.text),
        unitPrice: double.parse(_priceController.text),
        reorderThreshold: int.parse(_thresholdController.text),
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
    final categories = ref.watch(categoriesProvider);

    return AlertDialog(
      title: const Text('Ajouter un produit'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom du produit'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Champ requis.' : null,
                ),
                const SizedBox(height: 12),
                categories.when(
                  data: (items) => DropdownButtonFormField<Category>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categorie'),
                    items: items
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const LinearProgressIndicator(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Nouvelle categorie si absente',
                  ),
                  validator: (value) {
                    if (_selectedCategory == null && (value == null || value.isEmpty)) {
                      return 'Selectionnez ou creez une categorie.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock initial'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Prix unitaire'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Seuil de reapprovisionnement',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/products/models/product.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  final _minStockController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final station = ref.read(selectedStationProvider);
    if (station == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(productRepositoryProvider);
      final newProduct = Product(
        id: '',
        tenantId: station.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        family: ProductFamily.produit,
        unit: _unitController.text.trim(),
        unitPrice: double.parse(_priceController.text),
        minStock: int.parse(_minStockController.text),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.createProduct(newProduct);
      ref.invalidate(productsStreamProvider(station.id));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit créé avec succès')),
      );

      _nameController.clear();
      _descController.clear();
      _unitController.clear();
      _priceController.clear();
      _minStockController.clear();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un Produit'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom du produit'),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unité (ex: Litre, bidon)'),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Prix unitaire (DT)'),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Prix invalide' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _minStockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Seuil stock minimum'),
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Seuil invalide' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : _createProduct,
              child: _isSaving
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = ref.watch(selectedStationProvider);

    if (selectedStation == null) {
      return const Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station sur le Dashboard.')),
      );
    }

    final productsStream = ref.watch(productsStreamProvider(selectedStation.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Produits - ${selectedStation.name}'),
      ),
      body: productsStream.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text('Aucun produit enregistré.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: Icon(Icons.inventory_2, color: Colors.white),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${product.description}\nSeuil min: ${product.minStock} ${product.unit}'),
                  trailing: Text(
                    '${product.unitPrice.toStringAsFixed(2)} DT',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCyan, fontSize: 16),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

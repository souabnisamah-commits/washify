import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/core/widgets/barcode_scan_button.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ProductFamily.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showProductDialog([Product? product]) {
    final station = ref.read(selectedStationProvider);
    if (station == null) return;

    final formKey = GlobalKey<FormState>();
    ProductFamily dialogType = product?.family ?? ProductFamily.values[_tabController.index];
    bool isSaving = false;

    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final unitController = TextEditingController(text: product?.unit ?? (dialogType == ProductFamily.revente ? 'Unité' : 'Bidon'));
    final purchasePriceController = TextEditingController(text: (product?.purchasePrice ?? 0).toString());
    final minStockController = TextEditingController(text: (product?.minStock ?? 5).toString());
    
    // New fields
    final capacityController = TextEditingController(text: (product?.capacityMl ?? 0).toString());
    final barcodeController = TextEditingController(text: product?.barcode ?? '');
    final retailPriceController = TextEditingController(text: (product?.unitPrice ?? 0).toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(product == null ? 'Nouveau Produit' : 'Modifier Produit'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Basic info
                        DropdownButtonFormField<ProductFamily>(
                          initialValue: dialogType,
                          decoration: InputDecoration(labelText: 'Famille de produit'.tr, prefixIcon: Icon(Icons.category)),
                          items: ProductFamily.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                          onChanged: product != null ? null : (val) {
                            if (val != null) {
                              setDialogState(() {
                                dialogType = val;
                                if (val == ProductFamily.revente) {
                                  unitController.text = 'Unité';
                                } else {
                                  unitController.text = 'Bidon';
                                }
                              });
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Nom du produit'.tr),
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: unitController,
                          decoration: InputDecoration(labelText: 'Unité (ex: Unité, Bidon, Litre)'.tr, prefixIcon: Icon(Icons.scale)),
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        SizedBox(height: 12),
                        // Type specific fields
                        if (dialogType == ProductFamily.revente) ...[
                          TextFormField(
                            controller: barcodeController,
                            decoration: InputDecoration(
                              labelText: 'Code-barres'.tr,
                              prefixIcon: Icon(Icons.qr_code),
                              suffixIcon: BarcodeScanIcon(
                                onScanned: (barcode) {
                                  barcodeController.text = barcode;
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: retailPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Prix de vente (DT)'.tr, prefixIcon: Icon(Icons.sell)),
                            validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ],
                        
                        if (dialogType != ProductFamily.revente) ...[
                          SizedBox(height: 16),
                          Text('Rendement (Suivi Stock)', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: capacityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Capacité totale (ml/g)'.tr, helperText: 'ex: 5000 pour 5L'),
                          ),
                        ],

                        SizedBox(height: 16),
                        Text('Gestion', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: purchasePriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Prix d\'.trachat (DT)'),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: minStockController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Seuil Alerte Stock'.tr),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Annuler'.tr),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => isSaving = true);

                    try {
                      final repo = ref.read(productRepositoryProvider);
                      final now = DateTime.now();

                      final newProduct = Product(
                        id: product?.id ?? '',
                        tenantId: station.id,
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                        family: dialogType,
                        unit: unitController.text.trim(),
                        unitPrice: double.tryParse(retailPriceController.text) ?? (product?.unitPrice ?? 0.0),
                        purchasePrice: double.tryParse(purchasePriceController.text) ?? 0.0,
                        minStock: int.tryParse(minStockController.text) ?? 0,
                        capacityMl: double.tryParse(capacityController.text) ?? 0.0,
                        barcode: barcodeController.text.trim(),
                        isActive: true,
                        createdAt: product?.createdAt ?? now,
                        updatedAt: now,
                      );

                      if (product == null) {
                        await repo.createProduct(newProduct);
                      } else {
                        await repo.updateProduct(newProduct);
                      }

                      ref.invalidate(productsStreamProvider(station.id));
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    } catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Erreur : $e'.tr)));
                      }
                    } finally {
                      if (dialogContext.mounted) setDialogState(() => isSaving = false);
                    }
                  },
                  child: isSaving ? const CircularProgressIndicator() : Text(product == null ? 'Créer' : 'Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le produit'.tr),
        content: Text('Voulez-vous vraiment supprimer "${product.name}" ?\nIl ne sera plus disponible pour les services et les ventes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repo = ref.read(productRepositoryProvider);
        await repo.deleteProduct(product.id);
        
        final selectedStation = ref.read(selectedStationProvider);
        if (selectedStation != null) {
          ref.invalidate(productsStreamProvider(selectedStation.id));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produit supprimé avec succès'.tr)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression : $e'.tr)),
          );
        }
      }
    }
  }

  Widget _buildProductList(List<Product> products, ProductFamily type) {
    final filtered = products.where((p) => p.family == type).toList();

    if (filtered.isEmpty) {
      return Center(child: Text('Aucun produit de type "${type.label}"', style: TextStyle(color: AppTheme.textHint)));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppTheme.primaryBlue, child: Icon(Icons.inventory_2, color: Colors.white)),
            title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == ProductFamily.revente) ...[
                  Text('Code: ${product.barcode.isEmpty ? "N/A" : product.barcode}'),
                  Text('Prix de vente: ${product.unitPrice} DT', style: TextStyle(color: AppTheme.successGreen)),
                ],
                if (type != ProductFamily.revente) ...[
                  Text('Capacité: ${product.capacityMl} ml/g'.tr),
                ],
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: AppTheme.accentCyan),
                  onPressed: () => _showProductDialog(product),
                  tooltip: 'Modifier'.tr,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppTheme.errorRed),
                  onPressed: () => _confirmDeleteProduct(product),
                  tooltip: 'Supprimer'.tr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = ref.watch(selectedStationProvider);

    if (selectedStation == null) {
      return Scaffold(body: Center(child: Text('Sélectionnez d\'abord une station.')));
    }

    final productsStream = ref.watch(productsStreamProvider(selectedStation.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Catalogue Produits'.tr),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: ProductFamily.values.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: productsStream.when(
        data: (products) => TabBarView(
          controller: _tabController,
          children: ProductFamily.values.map((t) => _buildProductList(products, t)).toList(),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: Icon(Icons.add),
        label: Text('Nouveau Produit'.tr),
      ),
    );
  }
}

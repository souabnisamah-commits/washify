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
                          decoration: InputDecoration(labelText: 'Famille de produit'.tr, prefixIcon: const Icon(Icons.category)),
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
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Nom du produit'.tr),
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: unitController,
                          decoration: InputDecoration(labelText: 'Unité (ex: Unité, Bidon, Litre)'.tr, prefixIcon: const Icon(Icons.scale)),
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        // Type specific fields
                        if (dialogType == ProductFamily.revente) ...[
                          TextFormField(
                            controller: barcodeController,
                            decoration: InputDecoration(
                              labelText: 'Code-barres'.tr,
                              prefixIcon: const Icon(Icons.qr_code),
                              suffixIcon: BarcodeScanButton(
                                onScanned: (barcode) {
                                  barcodeController.text = barcode;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: retailPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Prix de vente (DT)'.tr, prefixIcon: const Icon(Icons.sell)),
                            validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ],
                        
                        if (dialogType != ProductFamily.revente) ...[
                          const SizedBox(height: 16),
                          const Text('Rendement (Suivi Stock)', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: capacityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Capacité totale (ml/g)'.tr, helperText: 'ex: 5000 pour 5L'),
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Text('Gestion', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: purchasePriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Prix d\'achat (DT)'.tr),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: minStockController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Stock min d\'alerte'.tr),
                                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
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
                  onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
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
                        unitPrice: double.tryParse(retailPriceController.text) ?? 0,
                        minStock: int.tryParse(minStockController.text) ?? 5,
                        purchasePrice: double.tryParse(purchasePriceController.text) ?? 0,
                        capacityMl: double.tryParse(capacityController.text) ?? 0,
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
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    final selectedStation = ref.watch(selectedStationProvider);

    if (selectedStation == null) {
      return Scaffold(body: Center(child: Text('Sélectionnez d\'abord une station.'.tr)));
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
          children: ProductFamily.values.map((t) => _ProductCategoryTabView(
            products: products,
            type: t,
            onEdit: (prod) => _showProductDialog(prod),
            onDelete: (prod) => _confirmDeleteProduct(prod),
          )).toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: const Icon(Icons.add),
        label: Text('Nouveau Produit'.tr),
      ),
    );
  }
}

class _ProductCategoryTabView extends StatefulWidget {
  final List<Product> products;
  final ProductFamily type;
  final void Function(Product product) onEdit;
  final void Function(Product product) onDelete;

  const _ProductCategoryTabView({
    required this.products,
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProductCategoryTabView> createState() => _ProductCategoryTabViewState();
}

class _ProductCategoryTabViewState extends State<_ProductCategoryTabView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBoutique = widget.type == ProductFamily.revente;

    final filtered = widget.products.where((p) {
      if (p.family != widget.type) return false;
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final nameMatch = p.name.toLowerCase().contains(q);
        final barcodeMatch = p.barcode.toLowerCase().contains(q);
        final unitMatch = p.unit.toLowerCase().contains(q);
        final descMatch = p.description.toLowerCase().contains(q);
        return nameMatch || barcodeMatch || unitMatch || descMatch;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Search Bar with Barcode Scanner for Boutique
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: isBoutique
                  ? 'Recherche par nom, description ou code-barres...'.tr
                  : 'Recherche par nom de produit...'.tr,
              prefixIcon: const Icon(Icons.search, color: AppTheme.accentCyan),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : (isBoutique
                      ? Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: BarcodeScanButton(
                            onScanned: (barcode) {
                              _searchController.text = barcode;
                              setState(() => _searchQuery = barcode);
                            },
                            iconSize: 20,
                            iconColor: AppTheme.accentCyan,
                          ),
                        )
                      : null),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accentCyan, width: 2),
              ),
            ),
          ),
        ),

        // Count Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} produit(s) dans cette catégorie',
                style: const TextStyle(fontSize: 12, color: AppTheme.textHint, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isBoutique ? Icons.shopping_bag_outlined : Icons.inventory_2_outlined, size: 48, color: AppTheme.textHint.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Aucun produit ne correspond à la recherche.'.tr
                            : 'Aucun produit de type "${widget.type.label}"',
                        style: const TextStyle(color: AppTheme.textHint),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isBoutique ? Colors.orange : AppTheme.primaryBlue,
                          child: Icon(isBoutique ? Icons.shopping_bag : Icons.inventory_2, color: Colors.white),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.type == ProductFamily.revente) ...[
                              Text('Code-barres: ${product.barcode.isEmpty ? "N/A" : product.barcode}'),
                              Text('Prix de vente: ${product.unitPrice} DT', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                            ],
                            if (widget.type != ProductFamily.revente) ...[
                              Text('Capacité bidon: ${product.capacityMl} ml/g'.tr),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.accentCyan),
                              onPressed: () => widget.onEdit(product),
                              tooltip: 'Modifier'.tr,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                              onPressed: () => widget.onDelete(product),
                              tooltip: 'Supprimer'.tr,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

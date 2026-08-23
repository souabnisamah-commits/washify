import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/stock_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/providers/inventory_provider.dart';
import 'package:washify/features/stock/models/stock.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/features/inventory/models/inventory.dart';
import 'package:washify/features/inventory/widgets/liquid_inventory_input_card.dart';

class InventoryFormScreen extends ConsumerStatefulWidget {
  const InventoryFormScreen({super.key});

  @override
  ConsumerState<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends ConsumerState<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _notesController.dispose();
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submitInventory(
    String stationId,
    List<Product> products,
    List<StockLevel> stockLevels,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      final inventoryRepo = ref.read(inventoryRepositoryProvider);
      final stockRepo = ref.read(stockRepositoryProvider);

      final List<InventoryItem> items = [];
      final now = DateTime.now();

      for (final prod in products) {
        final currentStock = stockLevels.firstWhere(
          (s) => s.productId == prod.id,
          orElse: () => StockLevel(
            id: '',
            tenantId: stationId,
            productId: prod.id,
            productName: prod.name,
            currentQuantity: 0.0,
            minStock: prod.minStock.toDouble(),
            updatedAt: now,
          ),
        );

        final expected = currentStock.currentQuantity;
        final ctrl = _controllers[prod.id];
        final actual = ctrl != null && ctrl.text.isNotEmpty
            ? double.parse(ctrl.text)
            : expected;

        final diff = actual - expected;

        items.add(InventoryItem(
          productId: prod.id,
          productName: prod.name,
          expectedQuantity: expected,
          actualQuantity: actual,
          difference: diff,
        ));

        if (diff != 0) {
          final updatedStock = currentStock.copyWith(
            currentQuantity: actual,
            updatedAt: now,
          );
          await stockRepo.updateStockLevel(updatedStock);

          final movement = StockMovement(
            id: '',
            tenantId: stationId,
            productId: prod.id,
            productName: prod.name,
            type: AppConstants.stockMovementAdjustment,
            quantity: diff.abs(),
            previousQuantity: expected,
            newQuantity: actual,
            reason: 'Ajustement inventaire (Écart: ${diff > 0 ? '+' : ''}${diff % 1 == 0 ? diff.toInt() : diff.toStringAsFixed(1)})',
            performedBy: user?.name ?? 'System',
            createdAt: now,
          );
          await stockRepo.addStockMovement(movement);
        }
      }

      final newInventory = Inventory(
        id: '',
        tenantId: stationId,
        performedBy: user?.id ?? '',
        performedByName: user?.name ?? 'System',
        date: now,
        items: items,
        notes: _notesController.text.trim(),
        createdAt: now,
      );

      final inventoryId = await inventoryRepo.createInventory(newInventory);

      ref.invalidate(stockStreamProvider(stationId));
      ref.invalidate(inventoriesStreamProvider(stationId));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inventaire enregistré avec succès et stock ajusté'.tr), backgroundColor: AppTheme.successGreen),
      );

      context.replace('/patron/inventory/report/$inventoryId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement: $e'.tr), backgroundColor: AppTheme.errorRed),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final selectedStation = ref.watch(selectedStationProvider);

    final stationId = user?.role == UserRole.patron
        ? selectedStation?.id ?? ''
        : user?.stationId ?? '';

    if (stationId.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station.'.tr)),
      );
    }

    final productsAsync = ref.watch(productsStreamProvider(stationId));
    final stockAsync = ref.watch(stockStreamProvider(stationId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Nouvel Inventaire'.tr),
          bottom: TabBar(
            indicatorColor: AppTheme.accentCyan,
            labelColor: AppTheme.accentCyan,
            unselectedLabelColor: AppTheme.textHint,
            tabs: const [
              Tab(icon: Icon(Icons.shopping_bag_outlined, size: 18), text: 'Boutique (Revente)'),
              Tab(icon: Icon(Icons.auto_awesome_outlined, size: 18), text: 'Consommables Premium'),
              Tab(icon: Icon(Icons.opacity_outlined, size: 18), text: 'Consommables Standard'),
            ],
          ),
        ),
        body: productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return Center(child: Text('Aucun produit disponible en station.'.tr));
            }

            return stockAsync.when(
              data: (stockLevels) {
                if (!_initialized) {
                  for (final prod in products) {
                    final stock = stockLevels.firstWhere(
                      (s) => s.productId == prod.id,
                      orElse: () => StockLevel(
                        id: '',
                        tenantId: stationId,
                        productId: prod.id,
                        productName: prod.name,
                        currentQuantity: 0.0,
                        minStock: prod.minStock.toDouble(),
                        updatedAt: DateTime.now(),
                      ),
                    );

                    final val = stock.currentQuantity % 1 == 0
                        ? stock.currentQuantity.toInt().toString()
                        : stock.currentQuantity.toStringAsFixed(1);

                    _controllers[prod.id] = TextEditingController(text: val);
                  }
                  _initialized = true;
                }

                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header Help Info Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: AppTheme.accentCyan.withValues(alpha: 0.08),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppTheme.accentCyan, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Saisissez les quantités physiques comptées. Les cases sont pré-remplies avec les valeurs théoriques.'.tr,
                                style: const TextStyle(fontSize: 12, color: AppTheme.accentCyan, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tabbed Product Views
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: Boutique (Revente)
                            _InventoryCategoryTabView(
                              family: ProductFamily.revente,
                              products: products,
                              stockLevels: stockLevels,
                              controllers: _controllers,
                              stationId: stationId,
                              onChanged: () => setState(() {}),
                            ),

                            // Tab 2: Consommables Premium (Extra)
                            _InventoryCategoryTabView(
                              family: ProductFamily.extra,
                              products: products,
                              stockLevels: stockLevels,
                              controllers: _controllers,
                              stationId: stationId,
                              onChanged: () => setState(() {}),
                            ),

                            // Tab 3: Consommables Standard
                            _InventoryCategoryTabView(
                              family: ProductFamily.standard,
                              products: products,
                              stockLevels: stockLevels,
                              controllers: _controllers,
                              stationId: stationId,
                              onChanged: () => setState(() {}),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Notes & Submit Action Bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          border: Border(top: BorderSide(color: AppTheme.dividerColor)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _notesController,
                              decoration: InputDecoration(
                                labelText: 'Notes d\'inventaire (ex: Ajustement fin de mois)'.tr,
                                prefixIcon: const Icon(Icons.note, color: AppTheme.accentCyan),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _isSaving ? null : () => _submitInventory(stationId, products, stockLevels),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentCyan,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: _isSaving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                                    : const Icon(Icons.save_alt_outlined),
                                label: Text(
                                  'Enregistrer l\'inventaire'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Erreur stock: $e'.tr)),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Erreur produits: $e'.tr)),
        ),
      ),
    );
  }
}

class _InventoryCategoryTabView extends StatefulWidget {
  final ProductFamily family;
  final List<Product> products;
  final List<StockLevel> stockLevels;
  final Map<String, TextEditingController> controllers;
  final String stationId;
  final VoidCallback onChanged;

  const _InventoryCategoryTabView({
    required this.family,
    required this.products,
    required this.stockLevels,
    required this.controllers,
    required this.stationId,
    required this.onChanged,
  });

  @override
  State<_InventoryCategoryTabView> createState() => _InventoryCategoryTabViewState();
}

class _InventoryCategoryTabViewState extends State<_InventoryCategoryTabView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBoutique = widget.family == ProductFamily.revente;

    final filteredProducts = widget.products.where((p) {
      if (p.family != widget.family) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final nameMatch = p.name.toLowerCase().contains(q);
        final barcodeMatch = p.barcode.toLowerCase().contains(q);
        final unitMatch = p.unit.toLowerCase().contains(q);
        return nameMatch || barcodeMatch || unitMatch;
      }

      return true;
    }).toList();

    return Column(
      children: [
        // Intelligent Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: isBoutique
                  ? 'Rechercher par nom, description ou code-barres...'.tr
                  : 'Rechercher un produit...'.tr,
              prefixIcon: const Icon(Icons.search, color: AppTheme.accentCyan),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : (isBoutique ? const Icon(Icons.qr_code_scanner, color: AppTheme.accentCyan, size: 20) : null),
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
                '${filteredProducts.length} produit(s) à compter',
                style: const TextStyle(fontSize: 12, color: AppTheme.textHint, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Products List
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isBoutique ? Icons.shopping_bag_outlined : Icons.inventory_2_outlined, size: 48, color: AppTheme.textHint.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Aucun produit ne correspond à la recherche.'.tr
                            : 'Aucun produit dans cette catégorie.'.tr,
                        style: const TextStyle(color: AppTheme.textHint),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final prod = filteredProducts[index];
                    final stock = widget.stockLevels.firstWhere(
                      (s) => s.productId == prod.id,
                      orElse: () => StockLevel(
                        id: '',
                        tenantId: widget.stationId,
                        productId: prod.id,
                        productName: prod.name,
                        currentQuantity: 0.0,
                        minStock: prod.minStock.toDouble(),
                        updatedAt: DateTime.now(),
                      ),
                    );

                    final ctrl = widget.controllers[prod.id];
                    if (ctrl == null) return const SizedBox();

                    if (!isBoutique) {
                      return LiquidInventoryInputCard(
                        product: prod,
                        stock: stock,
                        controller: ctrl,
                        onChanged: widget.onChanged,
                      );
                    }

                    final barcodeStr = (isBoutique && prod.barcode.isNotEmpty) ? prod.barcode : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        prod.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      if (barcodeStr.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentCyan.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            'Code: $barcodeStr',
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentCyan.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    prod.unit,
                                    style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Stock Théorique (Système)', style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                                      const SizedBox(height: 2),
                                      Text(
                                        stock.currentQuantity % 1 == 0
                                            ? '${stock.currentQuantity.toInt()}'
                                            : stock.currentQuantity.toStringAsFixed(1),
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: ctrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Quantité Physique Comptée'.tr,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) < 0
                                        ? 'Invalide'.tr
                                        : null,
                                    onChanged: (_) => widget.onChanged(),
                                  ),
                                ),
                              ],
                            ),

                            // Live discrepancy display
                            if (ctrl != null && ctrl.text.isNotEmpty && double.tryParse(ctrl.text) != null) ...[
                              const SizedBox(height: 8),
                              Builder(
                                builder: (context) {
                                  final actual = double.parse(ctrl.text);
                                  final diff = actual - stock.currentQuantity;
                                  if (diff == 0) {
                                    return Row(
                                      children: const [
                                        Icon(Icons.check_circle_outline, size: 14, color: AppTheme.successGreen),
                                        SizedBox(width: 4),
                                        Text('Conforme (Stock exact)', style: TextStyle(color: AppTheme.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    );
                                  }

                                  final diffText = diff > 0
                                      ? '+${diff % 1 == 0 ? diff.toInt() : diff.toStringAsFixed(1)}'
                                      : '${diff % 1 == 0 ? diff.toInt() : diff.toStringAsFixed(1)}';

                                  return Row(
                                    children: [
                                      Icon(
                                        diff > 0 ? Icons.trending_up : Icons.trending_down,
                                        size: 16,
                                        color: diff > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Écart physique : $diffText ${prod.unit}',
                                        style: TextStyle(
                                          color: diff > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
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

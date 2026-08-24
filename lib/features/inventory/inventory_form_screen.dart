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
  final Set<String> _countedProductIds = {};
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
                              countedProductIds: _countedProductIds,
                              stationId: stationId,
                              onChanged: () => setState(() {}),
                              onToggleCounted: (id) {
                                setState(() {
                                  if (_countedProductIds.contains(id)) {
                                    _countedProductIds.remove(id);
                                  } else {
                                    _countedProductIds.add(id);
                                  }
                                });
                              },
                            ),

                            // Tab 2: Consommables Premium (Extra)
                            _InventoryCategoryTabView(
                              family: ProductFamily.extra,
                              products: products,
                              stockLevels: stockLevels,
                              controllers: _controllers,
                              countedProductIds: _countedProductIds,
                              stationId: stationId,
                              onChanged: () => setState(() {}),
                              onToggleCounted: (id) {
                                setState(() {
                                  if (_countedProductIds.contains(id)) {
                                    _countedProductIds.remove(id);
                                  } else {
                                    _countedProductIds.add(id);
                                  }
                                });
                              },
                            ),

                            // Tab 3: Consommables Standard
                            _InventoryCategoryTabView(
                              family: ProductFamily.standard,
                              products: products,
                              stockLevels: stockLevels,
                              controllers: _controllers,
                              countedProductIds: _countedProductIds,
                              stationId: stationId,
                              onChanged: () => setState(() {}),
                              onToggleCounted: (id) {
                                setState(() {
                                  if (_countedProductIds.contains(id)) {
                                    _countedProductIds.remove(id);
                                  } else {
                                    _countedProductIds.add(id);
                                  }
                                });
                              },
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
  final Set<String> countedProductIds;
  final String stationId;
  final VoidCallback onChanged;
  final void Function(String productId) onToggleCounted;

  const _InventoryCategoryTabView({
    required this.family,
    required this.products,
    required this.stockLevels,
    required this.controllers,
    required this.countedProductIds,
    required this.stationId,
    required this.onChanged,
    required this.onToggleCounted,
  });

  @override
  State<_InventoryCategoryTabView> createState() => _InventoryCategoryTabViewState();
}

class _InventoryCategoryTabViewState extends State<_InventoryCategoryTabView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _filterMode = 0; // 0: Reste à compter, 1: Déjà comptés, 2: Tous

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBoutique = widget.family == ProductFamily.revente;
    final categoryProducts = widget.products.where((p) => p.family == widget.family).toList();
    final totalCount = categoryProducts.length;
    final countedCount = categoryProducts.where((p) => widget.countedProductIds.contains(p.id)).length;
    final uncountedCount = totalCount - countedCount;
    final double progress = totalCount > 0 ? (countedCount / totalCount) : 1.0;

    final filteredProducts = categoryProducts.where((p) {
      // Search Filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final nameMatch = p.name.toLowerCase().contains(q);
        final barcodeMatch = p.barcode.toLowerCase().contains(q);
        final unitMatch = p.unit.toLowerCase().contains(q);
        if (!nameMatch && !barcodeMatch && !unitMatch) return false;
      }

      // Classification Filter Mode
      final isCounted = widget.countedProductIds.contains(p.id);
      if (_filterMode == 0 && isCounted) return false; // Reste à compter
      if (_filterMode == 1 && !isCounted) return false; // Déjà comptés

      return true;
    }).toList();

    return Column(
      children: [
        // Category Completion Progress Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avancement ${widget.family.label} :',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$countedCount / $totalCount comptés (${(progress * 100).toInt()}%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: progress == 1.0 ? AppTheme.successGreen : AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    progress == 1.0 ? AppTheme.successGreen : AppTheme.accentCyan,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Intelligent Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
              ),
            ),
          ),
        ),

        // Filter Mode Segmented Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _buildFilterChip(0, '⏳ Reste à compter ($uncountedCount)', Colors.orange),
              const SizedBox(width: 6),
              _buildFilterChip(1, '✅ Déjà comptés ($countedCount)', AppTheme.successGreen),
              const SizedBox(width: 6),
              _buildFilterChip(2, '📋 Tous ($totalCount)', AppTheme.primaryBlue),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Products List or Completion Celebration Banner
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_filterMode == 0 && uncountedCount == 0 && totalCount > 0) ...[
                          const Icon(Icons.stars_rounded, size: 64, color: AppTheme.successGreen),
                          const SizedBox(height: 14),
                          Text(
                            '🎉 Félicitations !'.tr,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.successGreen),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tous les produits de la catégorie "${widget.family.label}" ont été inventoriés avec succès ($totalCount/$totalCount).'
                                .tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textHint, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => setState(() => _filterMode = 2),
                            icon: const Icon(Icons.list_alt),
                            label: Text('Revoir tous les produits comptés'.tr),
                          ),
                        ] else ...[
                          Icon(
                            isBoutique ? Icons.shopping_bag_outlined : Icons.inventory_2_outlined,
                            size: 48,
                            color: AppTheme.textHint.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Aucun produit ne correspond à la recherche.'.tr
                                : (_filterMode == 1
                                    ? 'Aucun produit encore compté dans cette catégorie.'.tr
                                    : 'Aucun produit dans cette catégorie.'.tr),
                            style: const TextStyle(color: AppTheme.textHint),
                          ),
                        ],
                      ],
                    ),
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
                    final isCounted = widget.countedProductIds.contains(prod.id);

                    if (!isBoutique) {
                      return LiquidInventoryInputCard(
                        product: prod,
                        stock: stock,
                        controller: ctrl,
                        isCounted: isCounted,
                        onChanged: widget.onChanged,
                        onToggleCounted: () => widget.onToggleCounted(prod.id),
                      );
                    }

                    final barcodeStr = (isBoutique && prod.barcode.isNotEmpty) ? prod.barcode : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isCounted ? AppTheme.successGreen : Colors.grey.withValues(alpha: 0.3),
                          width: isCounted ? 1.5 : 1,
                        ),
                      ),
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
                                    color: (isCounted ? AppTheme.successGreen : AppTheme.accentCyan).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isCounted ? '✅ Compté' : prod.unit,
                                    style: TextStyle(
                                      color: isCounted ? AppTheme.successGreen : AppTheme.accentCyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
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
                                      const Text('Stock Théorique', style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                                      const SizedBox(height: 2),
                                      Text(
                                        stock.currentQuantity % 1 == 0
                                            ? '${stock.currentQuantity.toInt()}'
                                            : stock.currentQuantity.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
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
                                      labelText: 'Quantité Physique'.tr,
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
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: ElevatedButton.icon(
                                onPressed: () => widget.onToggleCounted(prod.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCounted ? Colors.grey.shade700 : AppTheme.successGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: Icon(isCounted ? Icons.undo : Icons.check_circle_outline, size: 16),
                                label: Text(
                                  isCounted ? 'Rééditer / Démarquer'.tr : 'Valider & Classer (Masquer) ✅'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
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

  Widget _buildFilterChip(int mode, String label, Color color) {
    final isSelected = _filterMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filterMode = mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

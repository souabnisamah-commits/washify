import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/stock_provider.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/stock/models/stock.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/features/stock/widgets/pro_stock_container_card.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  void _showProductHistoryDialog(StockLevel stock, String stationId) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final movementsAsync = ref.watch(stockMovementsProvider((
              stationId: stationId,
              productId: stock.productId,
            )));

            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stock.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Historique des Mouvements de Stock', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                ],
              ),
              content: SizedBox(
                width: 480,
                height: 400,
                child: movementsAsync.when(
                  data: (movements) {
                    if (movements.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun mouvement de stock enregistré pour ce produit.',
                          style: const TextStyle(color: AppTheme.textHint),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: movements.length,
                      itemBuilder: (context, index) {
                        final m = movements[index];
                        final isAdjustment = m.type == AppConstants.stockMovementAdjustment;

                        Color typeColor = AppTheme.successGreen;
                        IconData typeIcon = Icons.arrow_downward;
                        String sign = '+';

                        if (m.type == AppConstants.stockMovementOut) {
                          typeColor = AppTheme.errorRed;
                          typeIcon = Icons.arrow_upward;
                          sign = '-';
                        } else if (isAdjustment) {
                          typeColor = AppTheme.warningOrange;
                          typeIcon = Icons.sync;
                          sign = m.newQuantity >= m.previousQuantity ? '+' : '';
                        }

                        String formatQty(double val) {
                          return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
                        }

                        String formatDate(DateTime dt) {
                          return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: AppTheme.surfaceCard,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: typeColor.withValues(alpha: 0.15),
                              child: Icon(typeIcon, color: typeColor, size: 18),
                            ),
                            title: Text(
                              '$sign${formatQty(m.quantity)} (${formatQty(m.previousQuantity)} ➔ ${formatQty(m.newQuantity)})',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: typeColor),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Raison : ${m.reason}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text(
                                  'Par ${m.performedBy} • ${formatDate(m.createdAt)}',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textHint),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Fermer'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final selectedStation = ref.watch(selectedStationProvider);

    final stationId = user?.role == UserRole.patron
        ? selectedStation?.id
        : user?.stationId;

    if (stationId == null) {
      return Scaffold(
        body: Center(child: Text('Aucune station sélectionnée ou assignée.'.tr)),
      );
    }

    final stockStream = ref.watch(stockStreamProvider(stationId));
    final productsAsync = ref.watch(productsStreamProvider(stationId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stock & Niveaux'.tr),
          bottom: TabBar(
            indicatorColor: AppTheme.accentCyan,
            labelColor: AppTheme.accentCyan,
            unselectedLabelColor: AppTheme.textHint,
            tabs: const [
              Tab(icon: Icon(Icons.shopping_bag_outlined, size: 18), text: 'Boutique (Revente)'),
              Tab(icon: Icon(Icons.auto_awesome_outlined, size: 18), text: 'Consommable Premium'),
              Tab(icon: Icon(Icons.opacity_outlined, size: 18), text: 'Consommable Standard'),
            ],
          ),
        ),
        body: stockStream.when(
          data: (stockLevels) {
            return productsAsync.when(
              data: (products) {
                final productMap = {for (var p in products) p.id: p};

                return TabBarView(
                  children: [
                    // Tab 1: Boutique (Revente)
                    _StockCategoryTabView(
                      family: ProductFamily.revente,
                      stockLevels: stockLevels,
                      productMap: productMap,
                      stationId: stationId,
                      onShowHistory: _showProductHistoryDialog,
                    ),

                    // Tab 2: Consommables Premium (Extra)
                    _StockCategoryTabView(
                      family: ProductFamily.extra,
                      stockLevels: stockLevels,
                      productMap: productMap,
                      stationId: stationId,
                      onShowHistory: _showProductHistoryDialog,
                    ),

                    // Tab 3: Consommables Standard
                    _StockCategoryTabView(
                      family: ProductFamily.standard,
                      stockLevels: stockLevels,
                      productMap: productMap,
                      stationId: stationId,
                      onShowHistory: _showProductHistoryDialog,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('${GoRouterState.of(context).matchedLocation}/entry'),
          icon: const Icon(Icons.add_shopping_cart),
          label: Text('Entrée Stock / Achat', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: AppTheme.accentCyan,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _StockCategoryTabView extends ConsumerStatefulWidget {
  final ProductFamily family;
  final List<StockLevel> stockLevels;
  final Map<String, Product> productMap;
  final String stationId;
  final void Function(StockLevel, String) onShowHistory;

  const _StockCategoryTabView({
    required this.family,
    required this.stockLevels,
    required this.productMap,
    required this.stationId,
    required this.onShowHistory,
  });

  @override
  ConsumerState<_StockCategoryTabView> createState() => _StockCategoryTabViewState();
}

class _StockCategoryTabViewState extends ConsumerState<_StockCategoryTabView> {
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

    final filteredStocks = widget.stockLevels.where((stock) {
      final product = widget.productMap[stock.productId];
      final prodFamily = product?.family ?? ProductFamily.standard;

      if (prodFamily != widget.family) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final nameMatch = stock.productName.toLowerCase().contains(q);
        final barcodeMatch = product != null && product.barcode.toLowerCase().contains(q);
        final unitMatch = product != null && product.unit.toLowerCase().contains(q);

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

        // Result count & alert badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredStocks.length} produit(s) dans cette catégorie',
                style: const TextStyle(fontSize: 12, color: AppTheme.textHint, fontWeight: FontWeight.bold),
              ),
              if (filteredStocks.any((s) => s.isLowStock))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${filteredStocks.where((s) => s.isLowStock).length} en alerte stock',
                        style: const TextStyle(fontSize: 11, color: AppTheme.errorRed, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // List View
        Expanded(
          child: filteredStocks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isBoutique ? Icons.shopping_bag_outlined : Icons.inventory_2_outlined, size: 48, color: AppTheme.textHint.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Aucun produit ne correspond à la recherche.'
                            : 'Aucun produit enregistré dans cette catégorie.',
                        style: const TextStyle(color: AppTheme.textHint),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStocks.length,
                  itemBuilder: (context, index) {
                    final stock = filteredStocks[index];
                    final product = widget.productMap[stock.productId];
                    return ProStockContainerCard(
                      stock: stock,
                      product: product,
                      onTap: () => widget.onShowHistory(stock, widget.stationId),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

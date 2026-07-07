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
                  Text(stock.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Historique des Mouvements de Stock', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
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
                          style: TextStyle(color: AppTheme.textHint),
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

                        // Format quantity: double if decimal, otherwise int
                        String formatQty(double val) {
                          return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
                        }

                        // Simple date formatter
                        String formatDate(DateTime dt) {
                          return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        }

                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
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
                                SizedBox(height: 4),
                                Text('Raison : ${m.reason}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                SizedBox(height: 2),
                                Text(
                                  'Par ${m.performedBy} • ${formatDate(m.createdAt)}',
                                  style: TextStyle(fontSize: 10, color: AppTheme.textHint),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
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

    // Resolve active stationId
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Stock & Niveaux'.tr),
      ),
      body: stockStream.when(
        data: (stockLevels) {
          if (stockLevels.isEmpty) {
            return Center(
              child: Text('Aucun stock enregistré.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return productsAsync.when(
            data: (products) {
              // Map de productId -> Product pour retrouver facilement les informations (catégorie)
              final productMap = {for (var p in products) p.id: p};
              
              // Grouper les niveaux de stock par catégorie
              final Map<String, List<StockLevel>> groupedStocks = {};
              for (var stock in stockLevels) {
                final product = productMap[stock.productId];
                final categoryName = product?.family.label ?? 'Autre';
                groupedStocks.putIfAbsent(categoryName, () => []).add(stock);
              }

              // Trier les catégories par ordre alphabétique
              final categories = groupedStocks.keys.toList()..sort();

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryStocks = groupedStocks[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                        child: Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentCyan,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...categoryStocks.map((stock) {
                        final isLow = stock.isLowStock;
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            onTap: () => _showProductHistoryDialog(stock, stationId),
                            leading: CircleAvatar(
                              backgroundColor: isLow ? AppTheme.errorRed.withValues(alpha: 0.15) : AppTheme.primaryBlue.withValues(alpha: 0.15),
                              child: Icon(
                                Icons.inventory_2,
                                color: isLow ? AppTheme.errorRed : AppTheme.accentCyan,
                              ),
                            ),
                            title: Text(stock.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Seuil min alerte : ${stock.minStock % 1 == 0 ? stock.minStock.toInt().toString() : stock.minStock.toStringAsFixed(2)}'.tr),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  stock.currentQuantity % 1 == 0
                                      ? stock.currentQuantity.toInt().toString()
                                      : stock.currentQuantity.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isLow ? AppTheme.errorRed : AppTheme.successGreen,
                                  ),
                                ),
                                if (isLow)
                                  Text(
                                    'Stock faible',
                                    style: TextStyle(color: AppTheme.errorRed, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 8), // Espace après chaque catégorie
                    ],
                  );
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${GoRouterState.of(context).matchedLocation}/entry'),
        icon: Icon(Icons.add_shopping_cart),
        label: Text('Entrée Stock / Achat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppTheme.accentCyan,
        foregroundColor: Colors.white,
      ),
    );
  }
}

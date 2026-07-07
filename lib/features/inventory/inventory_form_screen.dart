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

      // We'll execute updates inside a Batch or sequential writes
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

        // If there's a difference, update stock level and record adjustment movement
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
        SnackBar(content: Text('Inventaire enregistré avec succès et stock ajusté'.tr)),
      );

      // Redirect to report
      context.replace('/patron/inventory/report/$inventoryId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement: $e')),
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
        body: Center(child: Text('Sélectionnez d\'abord une station.')),
      );
    }

    final productsAsync = ref.watch(productsStreamProvider(stationId));
    final stockAsync = ref.watch(stockStreamProvider(stationId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvel Inventaire'.tr),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(child: Text('Aucun produit disponible en station.'.tr));
          }

          return stockAsync.when(
            data: (stockLevels) {
              // Initialize controllers once with expected stock levels
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

                  // format: remove decimals if whole number
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
                    // Header text
                    Container(
                      padding: EdgeInsets.all(16),
                      color: AppTheme.surfaceCardLight.withValues(alpha: 0.5),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.accentCyan),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Saisissez les quantités réelles comptées physiquement. '
                              'Les cases sont pré-remplies avec les valeurs théoriques attendues.',
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Products list
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final prod = products[index];
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

                          final ctrl = _controllers[prod.id];

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        prod.name,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                      ),
                                      Text(
                                        prod.unit,
                                        style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Théorique (Système)', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                            Text(
                                              stock.currentQuantity % 1 == 0
                                                  ? '${stock.currentQuantity.toInt()}'
                                                  : stock.currentQuantity.toStringAsFixed(1),
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: ctrl,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: InputDecoration(
                                            labelText: 'Quantité Physique'.tr,
                                            isDense: true,
                                          ),
                                          validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) < 0
                                              ? 'Invalide'
                                              : null,
                                          onChanged: (_) => setState(() {}), // refresh live diff
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Live difference display
                                  if (ctrl != null && ctrl.text.isNotEmpty && double.tryParse(ctrl.text) != null) ...[
                                    SizedBox(height: 8),
                                    Builder(
                                      builder: (context) {
                                        final actual = double.parse(ctrl.text);
                                        final diff = actual - stock.currentQuantity;
                                        if (diff == 0) {
                                          return SizedBox.shrink();
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
                                            SizedBox(width: 4),
                                            Text(
                                              'Écart : $diffText',
                                              style: TextStyle(
                                                color: diff > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
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

                    // Bottom notes and submit
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        border: Border(top: BorderSide(color: AppTheme.dividerColor)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Notes d\'.trinventaire (ex: Ajustement fin de mois)',
                              prefixIcon: Icon(Icons.note, color: AppTheme.accentCyan),
                            ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isSaving ? null : () => _submitInventory(stationId, products, stockLevels),
                            child: _isSaving
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                                : Text('Enregistrer l\'inventaire'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Erreur stock: $e'.tr)),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur produits: $e'.tr)),
      ),
    );
  }
}

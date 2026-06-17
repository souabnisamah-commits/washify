import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/stock_provider.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/stock/models/stock.dart';
import 'package:washify/features/products/models/product.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _reasonController = TextEditingController();
  Product? _selectedProduct;
  String _movementType = AppConstants.stockMovementIn;
  bool _isSaving = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _saveMovement(String stationId) async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      final stockRepo = ref.read(stockRepositoryProvider);

      final currentStock = await stockRepo.getStockLevel(stationId, _selectedProduct!.id);
      final previousQty = currentStock?.currentQuantity ?? 0;
      final quantityDelta = int.parse(_qtyController.text);

      int newQty = previousQty;
      if (_movementType == AppConstants.stockMovementIn) {
        newQty += quantityDelta;
      } else if (_movementType == AppConstants.stockMovementOut) {
        newQty -= quantityDelta;
      } else {
        newQty = quantityDelta; // adjustment sets direct level
      }

      // Update Stock Level
      final updatedLevel = StockLevel(
        id: currentStock?.id ?? '',
        tenantId: stationId,
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        currentQuantity: newQty,
        minStock: _selectedProduct!.minStock,
        updatedAt: DateTime.now(),
      );

      await stockRepo.updateStockLevel(updatedLevel);

      // Record movement
      final movement = StockMovement(
        id: '',
        tenantId: stationId,
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        type: _movementType,
        quantity: quantityDelta,
        previousQuantity: previousQty,
        newQuantity: newQty,
        reason: _reasonController.text.trim(),
        performedBy: user?.name ?? 'System',
        createdAt: DateTime.now(),
      );

      await stockRepo.addStockMovement(movement);

      ref.invalidate(stockStreamProvider(stationId));
      ref.invalidate(stockMovementsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mouvement de stock enregistré avec succès')),
      );

      _qtyController.clear();
      _reasonController.clear();
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

  void _showMovementDialog(String stationId) async {
    final products = await ref.read(productRepositoryProvider).getProductsByStation(stationId);

    if (!mounted) return;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord ajouter des produits dans le catalogue')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Enregistrer un Mouvement'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Product>(
                        initialValue: _selectedProduct,
                        decoration: const InputDecoration(labelText: 'Produit'),
                        items: products
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            _selectedProduct = val;
                          });
                        },
                        validator: (v) => v == null ? 'Produit requis' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _movementType,
                        decoration: const InputDecoration(labelText: 'Type de mouvement'),
                        items: const [
                          DropdownMenuItem(value: AppConstants.stockMovementIn, child: Text('Entrée (Approvisionnement)')),
                          DropdownMenuItem(value: AppConstants.stockMovementOut, child: Text('Sortie (Utilisation)')),
                          DropdownMenuItem(value: AppConstants.stockMovementAdjustment, child: Text('Ajustement d\'inventaire')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              _movementType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Quantité'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Quantité invalide' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(labelText: 'Raison / Commentaire'),
                        validator: (v) => v == null || v.isEmpty ? 'Raison requise' : null,
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
                  onPressed: _isSaving ? null : () => _saveMovement(stationId),
                  child: _isSaving
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Valider'),
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
      return const Scaffold(
        body: Center(child: Text('Aucune station sélectionnée ou assignée.')),
      );
    }

    final stockStream = ref.watch(stockStreamProvider(stationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock & Niveaux'),
      ),
      body: stockStream.when(
        data: (stockLevels) {
          if (stockLevels.isEmpty) {
            return const Center(
              child: Text('Aucun stock enregistré.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stockLevels.length,
            itemBuilder: (context, index) {
              final stock = stockLevels[index];
              final isLow = stock.isLowStock;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLow ? AppTheme.errorRed.withValues(alpha: 0.15) : AppTheme.primaryBlue.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.inventory_2,
                      color: isLow ? AppTheme.errorRed : AppTheme.accentCyan,
                    ),
                  ),
                  title: Text(stock.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Seuil min alerte : ${stock.minStock}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${stock.currentQuantity}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLow ? AppTheme.errorRed : AppTheme.successGreen,
                        ),
                      ),
                      if (isLow)
                        const Text(
                          'Stock faible',
                          style: TextStyle(color: AppTheme.errorRed, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMovementDialog(stationId),
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }
}

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
import 'package:washify/features/stock/models/stock.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/core/widgets/barcode_scan_button.dart';

class StockEntryScreen extends ConsumerStatefulWidget {
  const StockEntryScreen({super.key});

  @override
  ConsumerState<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends ConsumerState<StockEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _reasonController = TextEditingController();

  Product? _selectedProduct;
  StockLevel? _currentStockLevel;
  String _entryType = 'purchase'; // 'purchase' (achat) or 'initial' (initialisation)
  bool _isSaving = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _invoiceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onProductChanged(Product? product, String stationId) async {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _priceController.text = product.purchasePrice > 0 ? product.purchasePrice.toString() : '';
        _qtyController.clear();
      }
    });

    if (product != null) {
      final stockRepo = ref.read(stockRepositoryProvider);
      final level = await stockRepo.getStockLevel(stationId, product.id);
      if (mounted) {
        setState(() {
          _currentStockLevel = level;
        });
      }
    }
  }

  void _openProductSearchDialog(List<Product> products, FormFieldState<Product> state, String stationId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: _ProductSearchSheet(
            products: products,
            onSelected: (product) {
              Navigator.pop(context);
              _onProductChanged(product, stationId);
              state.didChange(product);
            },
          ),
        );
      },
    );
  }

  void _confirmSubmit(String stationId) {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) return;

    final qtyEntered = double.tryParse(_qtyController.text) ?? 0.0;
    final purchasePrice = double.tryParse(_priceController.text) ?? 0.0;
    final isPurchase = _entryType == 'purchase';
    final currentQty = _currentStockLevel?.currentQuantity ?? 0.0;
    final double addedQty = (_selectedProduct!.capacityMl > 0)
        ? qtyEntered * _selectedProduct!.capacityMl
        : qtyEntered;
    final newFutureQty = currentQty + addedQty;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: AppTheme.successGreen),
              SizedBox(width: 10),
              Text('Confirmer le Ravitaillement'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Êtes-vous sûr de vouloir valider cette entrée de stock ?', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(height: 20),
                Text('Produit : ${_selectedProduct!.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Type : ${isPurchase ? '🛒 Achat / Ravitaillement' : '⚙️ Initialisation Stock'}'),
                const SizedBox(height: 4),
                Text('Quantité ajoutée : $qtyEntered ${_selectedProduct!.unit}s'),
                if (_selectedProduct!.capacityMl > 0)
                  Text('Volume équivalent : ${addedQty.toStringAsFixed(0)} ml', style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Nouveau stock futur : ${newFutureQty.toStringAsFixed(1)} ${_selectedProduct!.capacityMl > 0 ? "ml" : _selectedProduct!.unit}', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                if (isPurchase && purchasePrice > 0) ...[
                  const SizedBox(height: 4),
                  Text('Prix unitaire d\'achat : ${purchasePrice.toStringAsFixed(1)} DT'),
                  Text('Total coût achat : ${(qtyEntered * purchasePrice).toStringAsFixed(1)} DT', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ],
                if (_invoiceController.text.isNotEmpty) Text('N° Document : ${_invoiceController.text}'),
                if (_reasonController.text.isNotEmpty) Text('Commentaire : ${_reasonController.text}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitEntry(stationId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Valider l\'Entrée'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitEntry(String stationId) async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      final stockRepo = ref.read(stockRepositoryProvider);
      final productRepo = ref.read(productRepositoryProvider);

      final qtyEntered = double.parse(_qtyController.text);
      final purchasePrice = double.tryParse(_priceController.text) ?? 0.0;
      final invoiceNum = _invoiceController.text.trim();
      final comment = _reasonController.text.trim();

      final currentStock = await stockRepo.getStockLevel(stationId, _selectedProduct!.id);
      final previousQty = currentStock?.currentQuantity ?? 0.0;

      final double quantityToAdd = (_selectedProduct!.capacityMl > 0)
          ? qtyEntered * _selectedProduct!.capacityMl
          : qtyEntered;

      final double newQty = previousQty + quantityToAdd;

      final updatedLevel = StockLevel(
        id: currentStock?.id ?? '',
        tenantId: stationId,
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        currentQuantity: newQty,
        minStock: _selectedProduct!.minStock.toDouble(),
        updatedAt: DateTime.now(),
      );

      await stockRepo.updateStockLevel(updatedLevel);

      final String entryTypeLabel = _entryType == 'initial' ? 'Initialisation stock' : 'Achat ravitaillement';
      final String docRefText = invoiceNum.isNotEmpty ? ' (Doc: $invoiceNum)' : '';
      final String reason = '$entryTypeLabel$docRefText. $comment'.trim();

      final movement = StockMovement(
        id: '',
        tenantId: stationId,
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        type: AppConstants.stockMovementIn,
        quantity: quantityToAdd,
        previousQuantity: previousQty,
        newQuantity: newQty,
        reason: reason,
        performedBy: user?.name ?? 'System',
        createdAt: DateTime.now(),
      );

      await stockRepo.addStockMovement(movement);

      if (_entryType == 'purchase' && purchasePrice > 0 && purchasePrice != _selectedProduct!.purchasePrice) {
        final updatedProduct = _selectedProduct!.copyWith(
          purchasePrice: purchasePrice,
          updatedAt: DateTime.now(),
        );
        await productRepo.updateProduct(updatedProduct);
      }

      ref.invalidate(stockStreamProvider(stationId));
      ref.invalidate(stockMovementsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entrée de stock enregistrée avec succès'.tr), backgroundColor: AppTheme.successGreen),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr), backgroundColor: AppTheme.errorRed),
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
        ? selectedStation?.id
        : user?.stationId;

    if (stationId == null) {
      return Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station.'.tr)),
      );
    }

    final productsAsync = ref.watch(productsStreamProvider(stationId));

    final qtyEntered = double.tryParse(_qtyController.text) ?? 0.0;
    final purchasePrice = double.tryParse(_priceController.text) ?? 0.0;
    final currentQty = _currentStockLevel?.currentQuantity ?? 0.0;
    final double addedQty = (_selectedProduct != null && _selectedProduct!.capacityMl > 0)
        ? qtyEntered * _selectedProduct!.capacityMl
        : qtyEntered;
    final newFutureQty = currentQty + addedQty;
    final double totalCost = qtyEntered * purchasePrice;

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrée de Stock / Achat'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CARD 1: SELECTION PRODUIT
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.inventory_2, color: AppTheme.accentCyan, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '1. Sélection du Produit'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      productsAsync.when(
                        data: (products) {
                          if (products.isEmpty) {
                            return Text(
                              'Aucun produit configuré dans le catalogue.'.tr,
                              style: const TextStyle(color: AppTheme.textHint),
                            );
                          }

                          final sortedProducts = List<Product>.from(products);
                          sortedProducts.sort((a, b) {
                            int cmp = a.family.label.compareTo(b.family.label);
                            if (cmp != 0) return cmp;
                            return a.name.compareTo(b.name);
                          });

                          return FormField<Product>(
                            initialValue: _selectedProduct,
                            validator: (v) => _selectedProduct == null ? 'Produit requis'.tr : null,
                            builder: (state) {
                              return InkWell(
                                onTap: () => _openProductSearchDialog(sortedProducts, state, stationId),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: state.hasError ? AppTheme.errorRed : AppTheme.accentCyan.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search, color: AppTheme.accentCyan),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _selectedProduct == null
                                            ? Text('Rechercher ou scanner un produit...'.tr, style: const TextStyle(color: AppTheme.textHint))
                                            : Text(
                                                '[${_selectedProduct!.family.label}] ${_selectedProduct!.name} (${_selectedProduct!.unit})',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                      ),
                                      const Icon(Icons.arrow_drop_down, color: AppTheme.accentCyan),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Text('Erreur: $e'.tr),
                      ),

                      // Selected Product Summary Chip
                      if (_selectedProduct != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCyan.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_selectedProduct!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(
                                    'Stock Actuel: ${currentQty.toStringAsFixed(1)} ${_selectedProduct!.capacityMl > 0 ? "ml" : _selectedProduct!.unit}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Catégorie: ${_selectedProduct!.family.label} | Unité d\'achat: ${_selectedProduct!.unit}${_selectedProduct!.capacityMl > 0 ? " (${_selectedProduct!.capacityMl.toInt()} ml)" : ""}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_selectedProduct != null) ...[
                // CARD 2: TYPE D'OPERATION
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.swap_horiz, color: AppTheme.primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            Text('2. Type d\'Opération'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                avatar: const Icon(Icons.shopping_cart, size: 16),
                                label: Center(child: Text('Achat / Ravitaillement'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                selected: _entryType == 'purchase',
                                onSelected: (val) {
                                  if (val) setState(() => _entryType = 'purchase');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ChoiceChip(
                                avatar: const Icon(Icons.settings, size: 16),
                                label: Center(child: Text('Initialisation Stock'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                selected: _entryType == 'initial',
                                onSelected: (val) {
                                  if (val) setState(() => _entryType = 'initial');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // CARD 3: QUANTITE & PRIX D'ACHAT
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_shopping_cart, color: AppTheme.successGreen, size: 20),
                            const SizedBox(width: 8),
                            Text('3. Quantité & Coût'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Quantity Input
                        TextFormField(
                          controller: _qtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Quantité d\'achat (en ${_selectedProduct!.unit}s)'.tr,
                            prefixIcon: const Icon(Icons.exposure_plus_1, color: AppTheme.accentCyan),
                            suffixText: '${_selectedProduct!.unit}s',
                          ),
                          validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0
                              ? 'Entrez une quantité valide'.tr
                              : null,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),

                        // Purchase Price Input
                        if (_entryType == 'purchase') ...[
                          TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Prix d\'achat unitaire par ${_selectedProduct!.unit} (DT)'.tr,
                              prefixIcon: const Icon(Icons.attach_money, color: AppTheme.accentCyan),
                              suffixText: 'DT',
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // REALTIME IMPACT PREVIEW BANNER
                        if (qtyEntered > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nouveau Stock Futur :',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      '${newFutureQty.toStringAsFixed(1)} ${_selectedProduct!.capacityMl > 0 ? "ml" : _selectedProduct!.unit}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 15),
                                    ),
                                  ],
                                ),
                                if (totalCost > 0 && _entryType == 'purchase') ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Coût Total de l\'Achat :', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                                      Text('${totalCost.toStringAsFixed(1)} DT', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // CARD 4: DOCUMENT & COMMENTAIRE
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long, color: Colors.purple, size: 20),
                            const SizedBox(width: 8),
                            Text('4. Traçabilité (Optionnel)'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _invoiceController,
                          decoration: InputDecoration(
                            labelText: 'N° Facture / Bon de Livraison'.tr,
                            prefixIcon: const Icon(Icons.receipt, color: AppTheme.accentCyan),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _reasonController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Commentaire / Notes du Patron'.tr,
                            prefixIcon: const Icon(Icons.comment, color: AppTheme.accentCyan),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // SUBMIT BUTTON
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : () => _confirmSubmit(stationId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      'Enregistrer le Ravitaillement'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductSearchSheet extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onSelected;

  const _ProductSearchSheet({required this.products, required this.onSelected});

  @override
  State<_ProductSearchSheet> createState() => _ProductSearchSheetState();
}

class _ProductSearchSheetState extends State<_ProductSearchSheet> {
  String _searchQuery = '';
  ProductFamily? _selectedFamily;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.products.where((p) {
      if (_selectedFamily != null && p.family != _selectedFamily) return false;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) || 
             p.barcode.toLowerCase().contains(q) ||
             p.family.label.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sélectionner un produit'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Rechercher (Nom ou Code-barres)'.tr,
              prefixIcon: const Icon(Icons.search, color: AppTheme.accentCyan),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      }
                    ),
                  BarcodeScanIcon(
                    onScanned: (barcode) {
                      final matched = widget.products
                          .where((p) => p.barcode.toLowerCase() == barcode.toLowerCase())
                          .toList();
                      if (matched.length == 1) {
                        widget.onSelected(matched.first);
                        Navigator.of(context).pop();
                      } else if (matched.length > 1) {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text('Sélectionner le produit'.tr),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: matched.map((p) => ListTile(
                                title: Text(p.name),
                                subtitle: Text(p.family.label),
                                onTap: () {
                                  widget.onSelected(p);
                                  Navigator.of(dialogContext).pop();
                                  Navigator.of(context).pop();
                                },
                              )).toList(),
                            ),
                          ),
                        );
                      } else {
                        _searchController.text = barcode;
                        setState(() => _searchQuery = barcode);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Aucun produit trouvé pour ce code-barres'.tr),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('Tous'.tr),
                  selected: _selectedFamily == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFamily = null);
                  },
                ),
                const SizedBox(width: 8),
                ...ProductFamily.values.map((family) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(family.label),
                    selected: _selectedFamily == family,
                    onSelected: (selected) {
                      setState(() => _selectedFamily = selected ? family : null);
                    },
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
              ? Center(child: Text('Aucun produit trouvé.'.tr, style: const TextStyle(color: AppTheme.textHint)))
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.surfaceCard,
                        child: const Icon(Icons.inventory_2, color: AppTheme.accentCyan, size: 18),
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.family.label}${p.barcode.isNotEmpty ? ' • Code: ${p.barcode}' : ''}', style: const TextStyle(color: AppTheme.textHint, fontSize: 12)),
                      trailing: Text(p.unit, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                      onTap: () => widget.onSelected(p),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

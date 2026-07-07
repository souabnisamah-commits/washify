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
  String _entryType = 'purchase'; // 'initial' (initialisation) or 'purchase' (achat)
  bool _isSaving = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _invoiceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onProductChanged(Product? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _priceController.text = product.purchasePrice.toString();
        _qtyController.clear();
      }
    });
  }

  void _openProductSearchDialog(List<Product> products, FormFieldState<Product> state) {
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
              _onProductChanged(product);
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer l\'opération'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Êtes-vous sûr de vouloir valider cette entrée de stock ?', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Produit : ${_selectedProduct!.name}'.tr),
                Text('Opération : ${isPurchase ? 'Achat/Ravitaillement' : 'Initialisation'}'),
                Text('Quantité saisie : $qtyEntered ${_selectedProduct!.unit}${_selectedProduct!.capacityMl > 0 ? "s" : ""}'),
                if (_selectedProduct!.capacityMl > 0)
                  Text('Total en volume : ${(qtyEntered * _selectedProduct!.capacityMl).toStringAsFixed(0)} ml', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                if (isPurchase) Text('Prix unitaire d\'achat : $purchasePrice DT'),
                if (_reasonController.text.isNotEmpty) Text('Commentaire : ${_reasonController.text}'.tr),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
              child: Text('Confirmer'.tr),
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

      // Get current stock
      final currentStock = await stockRepo.getStockLevel(stationId, _selectedProduct!.id);
      final previousQty = currentStock?.currentQuantity ?? 0.0;

      // Calculate quantity to add
      // If product has capacity in ml (e.g. 5000ml for 5L bidon), we add (contenance * number of units)
      final double quantityToAdd = (_selectedProduct!.capacityMl > 0)
          ? qtyEntered * _selectedProduct!.capacityMl
          : qtyEntered;

      final double newQty = previousQty + quantityToAdd;

      // Update Stock Level
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

      // Construct reason description
      final String entryTypeLabel = _entryType == 'initial' ? 'Initialisation stock' : 'Achat ravitaillement';
      final String docRefText = invoiceNum.isNotEmpty ? ' (Facture/Bon: $invoiceNum)' : '';
      final String reason = '$entryTypeLabel$docRefText. $comment'.trim();

      // Record movement
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

      // If it's a purchase and price changed, update purchase price in product catalogue
      if (_entryType == 'purchase' && purchasePrice != _selectedProduct!.purchasePrice) {
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
        SnackBar(content: Text('Entrée de stock enregistrée avec succès'.tr)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr)),
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
        body: Center(child: Text('Sélectionnez d\'abord une station.')),
      );
    }

    final productsAsync = ref.watch(productsStreamProvider(stationId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrée de Stock / Achat'.tr),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Selection
              productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Aucun produit configuré dans le catalogue pour cette station.',
                          style: TextStyle(color: AppTheme.textHint),
                        ),
                      ),
                    );
                  }

                  // Trier les produits par catégorie puis par nom
                  final sortedProducts = List<Product>.from(products);
                  sortedProducts.sort((a, b) {
                    int cmp = a.family.label.compareTo(b.family.label);
                    if (cmp != 0) return cmp;
                    return a.name.compareTo(b.name);
                  });

                  return FormField<Product>(
                    initialValue: _selectedProduct,
                    validator: (v) => _selectedProduct == null ? 'Produit requis' : null,
                    builder: (state) {
                      return InkWell(
                        onTap: () => _openProductSearchDialog(sortedProducts, state),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Sélectionner le Produit'.tr,
                            prefixIcon: Icon(Icons.search, color: AppTheme.accentCyan),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            errorText: state.errorText,
                          ),
                          isEmpty: _selectedProduct == null,
                          child: _selectedProduct == null 
                              ? Text('Rechercher un produit...', style: TextStyle(color: Colors.grey))
                              : Text('[${_selectedProduct!.family.label}] ${_selectedProduct!.name} (${_selectedProduct!.unit})'.tr),
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erreur produits: $e'.tr),
              ),
              SizedBox(height: 16),

              if (_selectedProduct != null) ...[
                // Info block for capacity & unit
                Card(
                  color: AppTheme.surfaceCardLight,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fiche produit : ${_selectedProduct!.name}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text('Type: ${_selectedProduct!.family.label}'.tr),
                        Text('Unité d\'achat: ${_selectedProduct!.unit}'),
                        if (_selectedProduct!.capacityMl > 0) ...[
                          Text('Capacité par ${_selectedProduct!.unit}: ${_selectedProduct!.capacityMl % 1 == 0 ? _selectedProduct!.capacityMl.toInt() : _selectedProduct!.capacityMl} ml/g'.tr),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Entry Type Toggle
                Text('Type d\'opération', style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text('Nouvel Achat / Ravitaillement'.tr)),
                        selected: _entryType == 'purchase',
                        onSelected: (val) {
                          if (val) setState(() => _entryType = 'purchase');
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text('Initialisation Stock'.tr)),
                        selected: _entryType == 'initial',
                        onSelected: (val) {
                          if (val) setState(() => _entryType = 'initial');
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Quantity input
                TextFormField(
                  controller: _qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _selectedProduct!.capacityMl > 0
                        ? 'Quantité (en ${_selectedProduct!.unit}s)'
                        : 'Quantité (en ${_selectedProduct!.unit})',
                    prefixIcon: Icon(Icons.add_shopping_cart, color: AppTheme.accentCyan),
                    helperText: _selectedProduct!.capacityMl > 0
                        ? 'Le système convertira automatiquement en millilitres.'
                        : null,
                  ),
                  validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0
                      ? 'Veuillez entrer une quantité positive'
                      : null,
                  onChanged: (v) {
                    setState(() {}); // refresh calculation text
                  },
                ),
                SizedBox(height: 12),

                // Live conversion display
                if (_qtyController.text.isNotEmpty && double.tryParse(_qtyController.text) != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _selectedProduct!.capacityMl > 0
                          ? 'Total de liquide à ajouter: ${(double.parse(_qtyController.text) * _selectedProduct!.capacityMl).toStringAsFixed(0)} ml'
                          : 'Total d\'unités à ajouter: ${double.parse(_qtyController.text).toStringAsFixed(0)}',
                      style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(height: 16),

                // Purchase price (only if purchase type)
                if (_entryType == 'purchase') ...[
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Prix d\'.trachat unitaire par ${_selectedProduct!.unit} (DT)',
                      prefixIcon: Icon(Icons.attach_money, color: AppTheme.accentCyan),
                    ),
                    validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) < 0
                        ? 'Veuillez entrer un prix valide'
                        : null,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _invoiceController,
                    decoration: InputDecoration(
                      labelText: 'N° Facture / Bon de commande (Optionnel)'.tr,
                      prefixIcon: Icon(Icons.receipt, color: AppTheme.accentCyan),
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // Reason / Comment
                TextFormField(
                  controller: _reasonController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Commentaire / Motif d\'.trentrée',
                    prefixIcon: Icon(Icons.comment, color: AppTheme.accentCyan),
                  ),
                ),
                SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _confirmSubmit(stationId),
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text('Enregistrer l\'entrée de stock'),
                ),
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
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sélectionner un produit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Rechercher (Nom ou Catégorie)'.tr,
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: Icon(Icons.clear), 
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    }
                  )
                : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          SizedBox(height: 12),
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
                SizedBox(width: 8),
                ...ProductFamily.values.map((family) => Padding(
                  padding: EdgeInsets.only(right: 8.0),
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
          SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
              ? Center(child: Text('Aucun produit trouvé.', style: TextStyle(color: AppTheme.textHint)))
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.surfaceCard,
                        child: Icon(Icons.inventory_2, color: AppTheme.accentCyan, size: 18),
                      ),
                      title: Text(p.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.family.label}${p.barcode.isNotEmpty ? ' • Code: ${p.barcode}' : ''}', style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                      trailing: Text(p.unit, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
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

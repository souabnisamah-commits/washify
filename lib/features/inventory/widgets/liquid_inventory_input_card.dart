import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/features/stock/models/stock.dart';
import 'package:washify/features/stock/utils/stock_formatter.dart';

class LiquidInventoryInputCard extends StatefulWidget {
  final Product product;
  final StockLevel stock;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final bool isCounted;
  final VoidCallback onToggleCounted;

  const LiquidInventoryInputCard({
    super.key,
    required this.product,
    required this.stock,
    required this.controller,
    required this.onChanged,
    this.isCounted = false,
    required this.onToggleCounted,
  });

  @override
  State<LiquidInventoryInputCard> createState() => _LiquidInventoryInputCardState();
}

class _LiquidInventoryInputCardState extends State<LiquidInventoryInputCard> {
  late int _fullBidons;
  late double _remainingMl;
  bool _isPercentageMode = false;
  final TextEditingController _remainingController = TextEditingController();

  double get _capacityMl => widget.product.capacityMl > 0 ? widget.product.capacityMl : 5000.0;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    double currentActualMl = widget.stock.currentQuantity;
    if (widget.controller.text.isNotEmpty) {
      currentActualMl = double.tryParse(widget.controller.text) ?? widget.stock.currentQuantity;
    }

    _fullBidons = (currentActualMl / _capacityMl).floor();
    _remainingMl = currentActualMl % _capacityMl;
    _remainingController.text = _remainingMl % 1 == 0 ? _remainingMl.toInt().toString() : _remainingMl.toStringAsFixed(1);
  }

  void _updateParentController() {
    final totalPhysicalMl = (_fullBidons * _capacityMl) + _remainingMl;
    final valStr = totalPhysicalMl % 1 == 0 ? totalPhysicalMl.toInt().toString() : totalPhysicalMl.toStringAsFixed(1);
    widget.controller.text = valStr;
    widget.onChanged();
  }

  void _incrementBidons() {
    setState(() {
      _fullBidons++;
      _updateParentController();
    });
  }

  void _decrementBidons() {
    if (_fullBidons > 0) {
      setState(() {
        _fullBidons--;
        _updateParentController();
      });
    }
  }

  void _onRemainingChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
    setState(() {
      if (_isPercentageMode) {
        final pct = parsed.clamp(0.0, 100.0);
        _remainingMl = (pct / 100.0) * _capacityMl;
      } else {
        _remainingMl = parsed.clamp(0.0, _capacityMl);
      }
      _updateParentController();
    });
  }

  void _toggleMode() {
    setState(() {
      _isPercentageMode = !_isPercentageMode;
      if (_isPercentageMode) {
        final pct = (_remainingMl / _capacityMl) * 100.0;
        _remainingController.text = pct % 1 == 0 ? pct.toInt().toString() : pct.toStringAsFixed(1);
      } else {
        _remainingController.text = _remainingMl % 1 == 0 ? _remainingMl.toInt().toString() : _remainingMl.toStringAsFixed(1);
      }
    });
  }

  void _applyQuickPercentage(double pct) {
    setState(() {
      _remainingMl = (pct / 100.0) * _capacityMl;
      if (_isPercentageMode) {
        _remainingController.text = pct.toInt().toString();
      } else {
        _remainingController.text = _remainingMl % 1 == 0 ? _remainingMl.toInt().toString() : _remainingMl.toStringAsFixed(1);
      }
      _updateParentController();
    });
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = parseStockContainers(
      widget.stock.currentQuantity,
      widget.product.unit,
      family: widget.product.family,
      customCapacityMl: widget.product.capacityMl,
    );

    final totalPhysicalMl = (_fullBidons * _capacityMl) + _remainingMl;
    final diffMl = totalPhysicalMl - widget.stock.currentQuantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: widget.isCounted ? AppTheme.successGreen : AppTheme.accentCyan.withValues(alpha: 0.3),
          width: widget.isCounted ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Nom du produit & Badge de statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.science_rounded, color: AppTheme.accentCyan, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (widget.isCounted ? AppTheme.successGreen : AppTheme.primaryBlue).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (widget.isCounted ? AppTheme.successGreen : AppTheme.primaryBlue).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.isCounted ? '✅ Compté' : '1 Bidon = ${_capacityMl.toInt()} ml',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.isCounted ? AppTheme.successGreen : AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // SECTION 1: STOCK THÉORIQUE FORMATÉ (Écran de Réalité)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, color: AppTheme.accentCyan, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stock Théorique (Système)',
                          style: TextStyle(fontSize: 10, color: AppTheme.textHint, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          breakdown.displayText,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.accentCyan),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // SECTION 2: COMPTAGE DU STOCK PHYSIQUE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Champ 1: Nombre de Bidons Pleins (Boutons + / -)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Bidons Pleins (Cachetés)',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textHint),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton.filledTonal(
                              onPressed: _decrementBidons,
                              icon: const Icon(Icons.remove, size: 16),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                            Text(
                              '$_fullBidons',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                            ),
                            IconButton.filledTonal(
                              onPressed: _incrementBidons,
                              icon: const Icon(Icons.add, size: 16),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Champ 2: Bidon Ouvert / Entamé (ml ou %)
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isPercentageMode ? 'Reste Entamé (%)' : 'Reste Entamé (ml)',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                            InkWell(
                              onTap: _toggleMode,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _isPercentageMode ? 'Mode: %' : 'Mode: ml',
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _remainingController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: _onRemainingChanged,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            suffixText: _isPercentageMode ? '%' : 'ml',
                            suffixStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        // Quick percentage chips (100%, 75%, 50%, 25%, 0%)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildQuickPctChip('Plein', 100.0),
                              const SizedBox(width: 4),
                              _buildQuickPctChip('3/4', 75.0),
                              const SizedBox(width: 4),
                              _buildQuickPctChip('1/2', 50.0),
                              const SizedBox(width: 4),
                              _buildQuickPctChip('1/4', 25.0),
                              const SizedBox(width: 4),
                              _buildQuickPctChip('Vide', 0.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // SECTION 3: RECAPITULATIF DU STOCK PHYSIQUE & ECART TEMPS REEL
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (diffMl == 0 ? AppTheme.successGreen : (diffMl > 0 ? Colors.blue : AppTheme.errorRed)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (diffMl == 0 ? AppTheme.successGreen : (diffMl > 0 ? Colors.blue : AppTheme.errorRed)).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stock Physique Converti : ${totalPhysicalMl.toInt()} ml',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(
                        diffMl == 0 ? Icons.check_circle : (diffMl > 0 ? Icons.trending_up : Icons.trending_down),
                        size: 16,
                        color: diffMl == 0 ? AppTheme.successGreen : (diffMl > 0 ? Colors.blue : AppTheme.errorRed),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        diffMl == 0
                            ? 'Conforme (Stock exact)'.tr
                            : 'Écart : ${diffMl > 0 ? '+' : ''}${diffMl.toInt()} ml',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: diffMl == 0 ? AppTheme.successGreen : (diffMl > 0 ? Colors.blue : AppTheme.errorRed),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // SECTION 4: VALIDATION BUTTON (CLASSIFICATION AUTOMATIQUE)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: widget.onToggleCounted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isCounted ? Colors.grey.shade700 : AppTheme.successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: widget.isCounted ? 0 : 2,
                ),
                icon: Icon(
                  widget.isCounted ? Icons.undo : Icons.check_circle_outline,
                  size: 18,
                ),
                label: Text(
                  widget.isCounted ? 'Rééditer / Démarquer'.tr : 'Valider & Classer (Masquer) ✅'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPctChip(String label, double pct) {
    return InkWell(
      onTap: () => _applyQuickPercentage(pct),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
      ),
    );
  }
}

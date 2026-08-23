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

  const LiquidInventoryInputCard({
    super.key,
    required this.product,
    required this.stock,
    required this.controller,
    required this.onChanged,
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
    final theoreticalBreakdown = parseStockContainers(
      widget.stock.currentQuantity,
      widget.product.unit,
      family: widget.product.family,
      customCapacityMl: _capacityMl,
    );

    double currentActualMl = widget.stock.currentQuantity;
    if (widget.controller.text.isNotEmpty) {
      currentActualMl = double.tryParse(widget.controller.text) ?? widget.stock.currentQuantity;
    }

    _fullBidons = (currentActualMl / _capacityMl).floor();
    _remainingMl = currentActualMl % _capacityMl;
    _remainingController.text = _isPercentageMode
        ? ((_remainingMl / _capacityMl) * 100).toStringAsFixed(1)
        : (_remainingMl % 1 == 0 ? _remainingMl.toInt().toString() : _remainingMl.toStringAsFixed(0));
  }

  void _updateParentController() {
    final double totalPhysicalMl = (_fullBidons * _capacityMl) + _remainingMl;
    final valStr = totalPhysicalMl % 1 == 0 ? totalPhysicalMl.toInt().toString() : totalPhysicalMl.toStringAsFixed(1);
    widget.controller.text = valStr;
    widget.onChanged();
  }

  void _onFullBidonsChanged(int newCount) {
    if (newCount < 0) return;
    setState(() {
      _fullBidons = newCount;
      _updateParentController();
    });
  }

  void _onRemainingInputChanged(String val) {
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

  void _applyQuickPercentage(double pct) {
    setState(() {
      _remainingMl = (pct / 100.0) * _capacityMl;
      if (_isPercentageMode) {
        _remainingController.text = pct % 1 == 0 ? pct.toInt().toString() : pct.toStringAsFixed(1);
      } else {
        _remainingController.text = _remainingMl % 1 == 0 ? _remainingMl.toInt().toString() : _remainingMl.toStringAsFixed(0);
      }
      _updateParentController();
    });
  }

  void _toggleInputMode(bool isPct) {
    setState(() {
      _isPercentageMode = isPct;
      if (_isPercentageMode) {
        final pct = ((_remainingMl / _capacityMl) * 100.0).clamp(0.0, 100.0);
        _remainingController.text = pct % 1 == 0 ? pct.toInt().toString() : pct.toStringAsFixed(1);
      } else {
        _remainingController.text = _remainingMl % 1 == 0 ? _remainingMl.toInt().toString() : _remainingMl.toStringAsFixed(0);
      }
    });
  }

  @override
  void dispose() {
    _remainingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prod = widget.product;
    final stock = widget.stock;
    final capacity = _capacityMl;

    final breakdown = parseStockContainers(
      stock.currentQuantity,
      prod.unit,
      family: prod.family,
      customCapacityMl: capacity,
    );

    final double totalPhysicalMl = (_fullBidons * capacity) + _remainingMl;
    final double diffMl = totalPhysicalMl - stock.currentQuantity;
    final bool isLow = stock.isLowStock;
    final Color themeColor = prod.family == ProductFamily.extra ? Colors.purple : AppTheme.accentCyan;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLow ? AppTheme.errorRed : themeColor.withValues(alpha: 0.25),
          width: isLow ? 2 : 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Product Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.opacity, color: themeColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Capacité Bidon: ${capacity % 1 == 0 ? capacity.toInt() : capacity.toStringAsFixed(0)} ml'.tr,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Bidon ${capacity % 1 == 0 ? capacity.toInt() : capacity.toStringAsFixed(0)}ml',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: themeColor),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // SECTION 1: STOCK THÉORIQUE (Système) - DISPLAY MATCHING "Stock & Niveau"
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.computer, size: 16, color: AppTheme.textHint),
                          const SizedBox(width: 6),
                          Text(
                            'Stock Théorique (Système)'.tr,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textHint),
                          ),
                        ],
                      ),
                      Text(
                        breakdown.rawTotalText,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (breakdown.fullContainersCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            breakdown.sealedLabel,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                          ),
                        ),
                      if (breakdown.hasOpenContainer)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            breakdown.openLabel,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // SECTION 2: SIMPLIFIED PHYSICAL COUNT INPUT FOR PATRON
            Text(
              'Saisie de l\'Inventaire Physique (Comptage Réel) :'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Champ 1: Bidons Pleins / Neufs (Counter)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. Bidons Pleins'.tr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => _onFullBidonsChanged(_fullBidons - 1),
                              icon: const Icon(Icons.remove_circle_outline, color: AppTheme.errorRed, size: 28),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '$_fullBidons',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                            ),
                            IconButton(
                              onPressed: () => _onFullBidonsChanged(_fullBidons + 1),
                              icon: const Icon(Icons.add_circle_outline, color: AppTheme.successGreen, size: 28),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        Center(
                          child: Text(
                            '(${(_fullBidons * capacity).toInt()} ml)',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textHint),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Champ 2: Reste du Bidon Entamé (ml ou %)
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('2. Bidon Entamé'.tr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            // Mode Switcher (ml vs %)
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => _toggleInputMode(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: !_isPercentageMode ? Colors.amber : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'ml',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: !_isPercentageMode ? Colors.black : AppTheme.textHint,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _toggleInputMode(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _isPercentageMode ? Colors.amber : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _isPercentageMode ? Colors.black : AppTheme.textHint,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        TextField(
                          controller: _remainingController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: _onRemainingInputChanged,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: _isPercentageMode ? 'Ex: 98.4%' : 'Ex: 1968 ml',
                            suffixText: _isPercentageMode ? '%' : 'ml',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Quick Percentage Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildQuickPctChip('100%', 100.0),
                              const SizedBox(width: 4),
                              _buildQuickPctChip('75%', 75.0),
                              const SizedBox(width: 4),
                              _buildQuickPctChip('50%', 50.0),
                              const SizedBox(width: 4),
                              _buildQuickPctChip('25%', 25.0),
                              const SizedBox(width: 4),
                              _buildQuickPctChip('0%', 0.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SECTION 3: CONVERTED TOTAL PHYSICAL & LIVE VARIANCE DISCREPANCY
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

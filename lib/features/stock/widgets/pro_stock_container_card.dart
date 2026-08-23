import 'package:flutter/material.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/features/stock/models/stock.dart';
import 'package:washify/features/stock/utils/stock_formatter.dart';

class ProStockContainerCard extends StatelessWidget {
  final StockLevel stock;
  final Product? product;
  final VoidCallback? onTap;

  const ProStockContainerCard({
    super.key,
    required this.stock,
    this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unit = product?.unit ?? 'ml';
    final breakdown = parseStockContainers(stock.currentQuantity, unit);
    final isLow = stock.isLowStock;
    final prod = product;
    final barcodeStr = (prod != null && prod.barcode.isNotEmpty) ? prod.barcode : '';
    final isLiquid = unit.toLowerCase().contains('ml') ||
        unit.toLowerCase().contains('l') ||
        unit.toLowerCase().contains('cl');

    final Color themeColor = (product?.family == ProductFamily.extra)
        ? Colors.purple
        : (isLiquid ? AppTheme.accentCyan : AppTheme.primaryBlue);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLow ? AppTheme.errorRed : themeColor.withValues(alpha: 0.25),
          width: isLow ? 2 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row: Product Name, Family, Barcode & Low Alert
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Avatar
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isLow ? AppTheme.errorRed : themeColor).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: (isLow ? AppTheme.errorRed : themeColor).withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      isLiquid ? Icons.opacity_rounded : Icons.inventory_2_rounded,
                      color: isLow ? AppTheme.errorRed : themeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Barcode
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              'Seuil d\'alerte : ${stock.minStock % 1 == 0 ? stock.minStock.toInt() : stock.minStock.toStringAsFixed(1)} $unit',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                            ),
                            if (barcodeStr.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentCyan.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Code: $barcodeStr',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Low Stock Badge
                  if (isLow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.errorRed),
                          SizedBox(width: 4),
                          Text(
                            'ALERTE STOCK',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.errorRed),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Divider(height: 20),

              // Main Section: Container Breakdown Banner (Ex: 2 Bidons (5L) + 850 ml)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isLow ? AppTheme.errorRed : themeColor).withValues(alpha: 0.08),
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (isLow ? AppTheme.errorRed : themeColor).withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isLiquid ? Icons.propane_tank_outlined : Icons.inventory_2_outlined,
                              size: 18,
                              color: isLow ? AppTheme.errorRed : themeColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Récapitulatif en Réserve',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isLow ? AppTheme.errorRed : themeColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Total brut : ${stock.currentQuantity % 1 == 0 ? stock.currentQuantity.toInt().toString() : stock.currentQuantity.toStringAsFixed(1)} $unit',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textHint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Big Clear Container Breakdown Badge (e.g. 1x Bidon (5000ml) + 968 ml)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: themeColor.withValues(alpha: 0.45), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🛢️ ', style: TextStyle(fontSize: 16)),
                          Text(
                            breakdown.displayText,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isLow ? AppTheme.errorRed : themeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Visual Jerrycan Containers Graphic Representation
              if (isLiquid && (breakdown.fullContainers > 0 || breakdown.remainingQuantity > 0)) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Full Sealed Bidons
                      for (int i = 0; i < breakdown.fullContainers && i < 6; i++) ...[
                        _buildJerrycanGraphicItem(
                          index: i + 1,
                          fillRatio: 1.0,
                          label: 'Bidon 5L',
                          isFull: true,
                          themeColor: themeColor,
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Open / Partial Bidon
                      if (breakdown.remainingQuantity > 0 && breakdown.fullContainers < 6) ...[
                        _buildJerrycanGraphicItem(
                          index: breakdown.fullContainers + 1,
                          fillRatio: breakdown.fillPercentageOfOpenContainer.clamp(0.05, 0.95),
                          label: '${breakdown.remainingQuantity % 1 == 0 ? breakdown.remainingQuantity.toInt() : breakdown.remainingQuantity.toStringAsFixed(0)} ${breakdown.remainingUnit}',
                          isFull: false,
                          themeColor: AppTheme.successGreen,
                        ),
                      ],

                      if (breakdown.fullContainers >= 6) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+ ${breakdown.fullContainers - 6} bidon(s)',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textHint),
                          ),
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
    );
  }

  Widget _buildJerrycanGraphicItem({
    required int index,
    required double fillRatio,
    required String label,
    required bool isFull,
    required Color themeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isFull ? themeColor.withValues(alpha: 0.08) : AppTheme.successGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (isFull ? themeColor : AppTheme.successGreen).withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Jerrycan Visual
          Container(
            width: 20,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isFull ? themeColor : AppTheme.successGreen, width: 1),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FractionallySizedBox(
                  heightFactor: fillRatio,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isFull ? themeColor : AppTheme.successGreen,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#$index ${isFull ? 'Plein' : 'Entamé'}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isFull ? themeColor : AppTheme.successGreen,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: AppTheme.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

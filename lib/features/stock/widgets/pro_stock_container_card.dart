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
    final prod = product;
    final unit = prod?.unit ?? 'ml';
    final breakdown = parseStockContainers(stock.currentQuantity, unit, customCapacity: prod?.capacityMl ?? 0.0);
    final isLow = stock.isLowStock;
    final barcodeStr = (prod != null && prod.barcode.isNotEmpty) ? prod.barcode : '';
    final isLiquid = unit.toLowerCase().contains('ml') ||
        unit.toLowerCase().contains('l') ||
        unit.toLowerCase().contains('cl') ||
        unit.toLowerCase().contains('bidon');

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
              // Header Row: Product Name, Seuil, Barcode & Low Stock Alert
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

                  // Name & Details
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

                  // Low Stock Alert Badge
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

              // Main Section: Inventory Breakdown (Image de la Réalité Terrain)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
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
                              Icons.shelves,
                              size: 18,
                              color: isLow ? AppTheme.errorRed : themeColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Inventaire Terrain (Étagère Local Stock)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isLow ? AppTheme.errorRed : themeColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Stock brut : ${stock.currentQuantity % 1 == 0 ? stock.currentQuantity.toInt().toString() : stock.currentQuantity.toStringAsFixed(1)} $unit',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textHint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Clear Dual Badges: Sealed Bidons vs Open Bidon
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Sealed Bidons Badge
                        if (breakdown.fullContainersCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock, size: 16, color: AppTheme.successGreen),
                                const SizedBox(width: 6),
                                Text(
                                  '${breakdown.fullContainersCount}x Bidon${breakdown.fullContainersCount > 1 ? 's' : ''} Cacheté${breakdown.fullContainersCount > 1 ? 's' : ''} (100% Neuf)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Open Bidon Badge
                        if (breakdown.hasOpenContainer)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.opacity, size: 16, color: Colors.amber),
                                const SizedBox(width: 6),
                                Text(
                                  'Bidon Entamé : ${breakdown.openContainerMl.toInt()} ml / ${breakdown.containerCapacityMl.toInt()} ml (${(breakdown.openContainerRatio * 100).toInt()}%)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Visual Physical Containers Representation (Individual Bidons on Shelf)
              if (isLiquid && breakdown.totalPhysicalContainers > 0) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Full Sealed Bidons
                      for (int i = 0; i < breakdown.fullContainersCount && i < 6; i++) ...[
                        _buildJerrycanGraphicItem(
                          index: i + 1,
                          fillRatio: 1.0,
                          label: 'Cacheté (100%)',
                          isFull: true,
                          themeColor: AppTheme.successGreen,
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Open / Partial Bidon
                      if (breakdown.hasOpenContainer && breakdown.fullContainersCount < 6) ...[
                        _buildJerrycanGraphicItem(
                          index: breakdown.fullContainersCount + 1,
                          fillRatio: breakdown.openContainerRatio.clamp(0.04, 0.96),
                          label: 'Entamé (${breakdown.openContainerMl.toInt()}ml / ${breakdown.containerCapacityMl.toInt()}ml)',
                          isFull: false,
                          themeColor: Colors.amber.shade800,
                        ),
                      ],

                      if (breakdown.fullContainersCount >= 6) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+ ${breakdown.fullContainersCount - 6} bidon(s)',
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
    final ordinalStr = getFrenchOrdinal(index);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Jerrycan Visual
          Container(
            width: 24,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: themeColor, width: 1.2),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FractionallySizedBox(
                  heightFactor: fillRatio,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                    ),
                  ),
                ),
                if (isFull)
                  const Positioned(
                    top: 2,
                    child: Icon(Icons.lock, size: 10, color: Colors.white),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Bidon #$index ($ordinalStr)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isFull ? Icons.check_circle : Icons.warning,
                    size: 12,
                    color: themeColor,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppTheme.textHint, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

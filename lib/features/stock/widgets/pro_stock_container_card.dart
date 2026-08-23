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
    final family = prod?.family ?? ProductFamily.standard;
    final unit = prod?.unit ?? 'ml';
    final breakdown = parseStockContainers(
      stock.currentQuantity,
      unit,
      family: family,
      customCapacityMl: prod?.capacityMl ?? 0.0,
    );
    final isLow = stock.isLowStock;
    final barcodeStr = (prod != null && prod.barcode.isNotEmpty) ? prod.barcode : '';
    final isBoutique = breakdown.isBoutiqueItem;

    final Color themeColor = isBoutique
        ? Colors.orange
        : (family == ProductFamily.extra ? Colors.purple : AppTheme.accentCyan);

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
                      isBoutique ? Icons.shopping_bag_outlined : Icons.opacity_rounded,
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
                              'Seuil d\'alerte : ${stock.minStock % 1 == 0 ? stock.minStock.toInt() : stock.minStock.toStringAsFixed(1)} ${isBoutique ? (prod?.unit ?? "pièce") : "ml"}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                            ),
                            if (prod != null && prod.unitPrice > 0) ...[
                              const SizedBox(width: 10),
                              Text(
                                'Prix : ${prod.unitPrice.toStringAsFixed(1)} DT',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                              ),
                            ],
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

              // ==============================================================
              // CASE A: BOUTIQUE (Revente) ITEMS -> Raw Pieces/Units Card
              // ==============================================================
              if (isBoutique) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantité en Magasin :',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textHint, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: (isLow ? AppTheme.errorRed : Colors.orange).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: (isLow ? AppTheme.errorRed : Colors.orange).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        breakdown.displayText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isLow ? AppTheme.errorRed : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ]
              // ==============================================================
              // CASE B: LIQUID CONSUMABLES -> Bidon Conversion & Visual Shelf
              // ==============================================================
              else ...[
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
                                'Inventaire Réel Stock (Local)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isLow ? AppTheme.errorRed : themeColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          // Small text showing raw volume in ml requested by Patron ("2/- oui")
                          Text(
                            breakdown.rawTotalText,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textHint),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Clear Dual Badges: Full Bidons vs Open Bidon with exact % fill
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Full Bidons Chip
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
                                    breakdown.sealedLabel,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Open Bidon Chip with exact ml/capacity and % fill
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
                                    breakdown.openLabel,
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

                // Visual Graphic Jerrycan Row representing exact fill % of open bidon
                if (breakdown.totalPhysicalContainers > 0) ...[
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
                            percentLabel: '100% Plein',
                            isFull: true,
                            themeColor: AppTheme.successGreen,
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Open Bidon with exact % fill
                        if (breakdown.hasOpenContainer && breakdown.fullContainersCount < 6) ...[
                          _buildJerrycanGraphicItem(
                            index: breakdown.fullContainersCount + 1,
                            fillRatio: (breakdown.openContainerPercent / 100.0).clamp(0.04, 0.98),
                            percentLabel: '${breakdown.openContainerMl.toInt()}ml (${breakdown.openContainerPercent % 1 == 0 ? breakdown.openContainerPercent.toInt() : breakdown.openContainerPercent.toStringAsFixed(1)}% Plein)',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJerrycanGraphicItem({
    required int index,
    required double fillRatio,
    required String percentLabel,
    required bool isFull,
    required Color themeColor,
  }) {
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
          // Mini Jerrycan Visual with liquid fill level
          Container(
            width: 24,
            height: 34,
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
                    'Bidon #$index ${isFull ? '(Plein)' : '(Entamé)'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isFull ? Icons.check_circle : Icons.water_drop,
                    size: 12,
                    color: themeColor,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                percentLabel,
                style: const TextStyle(fontSize: 10, color: AppTheme.textHint, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

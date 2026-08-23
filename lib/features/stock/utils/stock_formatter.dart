import 'package:flutter/material.dart';

class StockContainerBreakdown {
  final double rawQuantity;
  final String rawUnit;
  final int fullContainers;
  final double remainingQuantity;
  final String containerName; // e.g. "Bidon (5000ml)"
  final double containerCapacity;
  final String remainingUnit; // e.g. "ml"
  final String displayText; // e.g. "2x Bidons cachetés + 4980 ml / 5000 ml du 3ème bidon"
  final String shortBadgeText; // e.g. "2x Bidons cachetés + 4980ml/5000ml (3ème)"
  final double fillPercentageOfOpenContainer; // 0.0 to 1.0 for open container

  StockContainerBreakdown({
    required this.rawQuantity,
    required this.rawUnit,
    required this.fullContainers,
    required this.remainingQuantity,
    required this.containerName,
    this.containerCapacity = 5000.0,
    required this.remainingUnit,
    required this.displayText,
    required this.shortBadgeText,
    required this.fillPercentageOfOpenContainer,
  });
}

String getFrenchOrdinal(int index) {
  if (index == 1) return '1er';
  return '${index}ème';
}

StockContainerBreakdown parseStockContainers(
  double quantity,
  String rawUnit, {
  double customCapacity = 0.0,
}) {
  final unit = rawUnit.trim().toLowerCase();

  // 1. Milliliters (ml) or Bidon unit
  if (unit == 'ml' || unit == 'millilitre' || unit == 'millilitres' || unit == 'bidon' || unit == 'bidons') {
    final double totalMl = (unit == 'bidon' || unit == 'bidons') ? (quantity * 5000.0) : quantity;
    final double bidonCapacityMl = (customCapacity > 0) ? customCapacity : 5000.0;

    final int fullCount = (totalMl / bidonCapacityMl).floor();
    final double remMl = totalMl % bidonCapacityMl;
    final double openRatio = remMl / bidonCapacityMl;
    final int openOrdinalIndex = fullCount + 1;
    final String openOrdinal = getFrenchOrdinal(openOrdinalIndex);

    final String capIntStr = bidonCapacityMl % 1 == 0 ? bidonCapacityMl.toInt().toString() : bidonCapacityMl.toStringAsFixed(0);

    String text;
    String badge;

    if (fullCount > 0 && remMl > 0) {
      text = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} + ${remMl.toInt()} ml / ${capIntStr} ml du ${openOrdinal} bidon';
      badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} + ${remMl.toInt()}ml/${capIntStr}ml (${openOrdinal})';
    } else if (fullCount > 0 && remMl == 0) {
      text = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} (Plein${fullCount > 1 ? 's' : ''})';
      badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''}';
    } else {
      text = '${remMl.toInt()} ml / ${capIntStr} ml du 1er bidon';
      badge = '${remMl.toInt()}ml / ${capIntStr}ml (1er bidon)';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: fullCount,
      remainingQuantity: remMl,
      containerName: 'Bidon ($capIntStr ml)',
      containerCapacity: bidonCapacityMl,
      remainingUnit: 'ml',
      displayText: text,
      shortBadgeText: badge,
      fillPercentageOfOpenContainer: openRatio,
    );
  }

  // 2. Liters (L)
  if (unit == 'l' || unit == 'litre' || unit == 'litres') {
    final double totalMl = quantity * 1000.0;
    final double bidonCapacityMl = (customCapacity > 0) ? customCapacity : 5000.0;
    final int fullCount = (totalMl / bidonCapacityMl).floor();
    final double remMl = totalMl % bidonCapacityMl;
    final double openRatio = remMl / bidonCapacityMl;
    final int openOrdinalIndex = fullCount + 1;
    final String openOrdinal = getFrenchOrdinal(openOrdinalIndex);

    final String capIntStr = bidonCapacityMl % 1 == 0 ? bidonCapacityMl.toInt().toString() : bidonCapacityMl.toStringAsFixed(0);

    String text;
    String badge;

    if (fullCount > 0 && remMl > 0) {
      text = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} + ${remMl.toInt()} ml / ${capIntStr} ml du ${openOrdinal} bidon';
      badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} + ${remMl.toInt()}ml/${capIntStr}ml (${openOrdinal})';
    } else if (fullCount > 0 && remMl == 0) {
      text = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} (Plein${fullCount > 1 ? 's' : ''})';
      badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''}';
    } else {
      text = '${remMl.toInt()} ml / ${capIntStr} ml du 1er bidon';
      badge = '${remMl.toInt()}ml / ${capIntStr}ml (1er bidon)';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: fullCount,
      remainingQuantity: remMl,
      containerName: 'Bidon ($capIntStr ml)',
      containerCapacity: bidonCapacityMl,
      remainingUnit: 'ml',
      displayText: text,
      shortBadgeText: badge,
      fillPercentageOfOpenContainer: openRatio,
    );
  }

  // 3. Centiliters (cl)
  if (unit == 'cl' || unit == 'centilitre' || unit == 'centilitres') {
    final double totalMl = quantity * 10.0;
    final double bidonCapacityMl = (customCapacity > 0) ? customCapacity : 5000.0;
    final int fullCount = (totalMl / bidonCapacityMl).floor();
    final double remMl = totalMl % bidonCapacityMl;
    final double openRatio = remMl / bidonCapacityMl;
    final int openOrdinalIndex = fullCount + 1;
    final String openOrdinal = getFrenchOrdinal(openOrdinalIndex);

    final String capIntStr = bidonCapacityMl % 1 == 0 ? bidonCapacityMl.toInt().toString() : bidonCapacityMl.toStringAsFixed(0);

    String text;
    String badge;

    if (fullCount > 0 && remMl > 0) {
      text = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} + ${remMl.toInt()} ml / ${capIntStr} ml du ${openOrdinal} bidon';
      badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} + ${remMl.toInt()}ml (${openOrdinal})';
    } else if (fullCount > 0 && remMl == 0) {
      text = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} (Plein${fullCount > 1 ? 's' : ''})';
      badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''}';
    } else {
      text = '${remMl.toInt()} ml / ${capIntStr} ml du 1er bidon';
      badge = '${remMl.toInt()}ml / ${capIntStr}ml (1er bidon)';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: fullCount,
      remainingQuantity: remMl / 10.0,
      containerName: 'Bidon ($capIntStr ml)',
      containerCapacity: bidonCapacityMl,
      remainingUnit: 'cl',
      displayText: text,
      shortBadgeText: badge,
      fillPercentageOfOpenContainer: openRatio,
    );
  }

  // 4. Grams (g) or Kilograms (kg)
  if (unit == 'g' || unit == 'gramme' || unit == 'grammes' || unit == 'kg' || unit == 'kilo' || unit == 'kilogrammes') {
    final double totalG = (unit == 'kg' || unit == 'kilo' || unit == 'kilogrammes') ? (quantity * 1000.0) : quantity;
    final double sacCapacityG = (customCapacity > 0) ? customCapacity : 5000.0;
    final int fullCount = (totalG / sacCapacityG).floor();
    final double remG = totalG % sacCapacityG;
    final double openRatio = remG / sacCapacityG;
    final int openOrdinalIndex = fullCount + 1;
    final String openOrdinal = getFrenchOrdinal(openOrdinalIndex);

    final String capIntStr = sacCapacityG >= 1000 ? '${(sacCapacityG / 1000).toInt()}kg' : '${sacCapacityG.toInt()}g';

    String text;
    String badge;

    if (fullCount > 0 && remG > 0) {
      text = '${fullCount}x Sac${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} + ${remG.toInt()} g / ${sacCapacityG.toInt()} g du ${openOrdinal} sac';
      badge = '${fullCount}x Sac${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} + ${remG.toInt()}g (${openOrdinal})';
    } else if (fullCount > 0 && remG == 0) {
      text = '${fullCount}x Sac${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''} (Plein${fullCount > 1 ? 's' : ''})';
      badge = '${fullCount}x Sac${fullCount > 1 ? 's' : ''} cacheté${fullCount > 1 ? 's' : ''}';
    } else {
      text = '${remG.toInt()} g / ${sacCapacityG.toInt()} g du 1er sac';
      badge = '${remG.toInt()}g / ${sacCapacityG.toInt()}g (1er sac)';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: fullCount,
      remainingQuantity: remG,
      containerName: 'Sac ($capIntStr)',
      containerCapacity: sacCapacityG,
      remainingUnit: 'g',
      displayText: text,
      shortBadgeText: badge,
      fillPercentageOfOpenContainer: openRatio,
    );
  }

  // Default fallback for piece/unit/unite
  final qtyStr = quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toStringAsFixed(1);
  final text = '$qtyStr ${rawUnit.isEmpty ? 'unité(s)' : rawUnit}';
  return StockContainerBreakdown(
    rawQuantity: quantity,
    rawUnit: rawUnit,
    fullContainers: 0,
    remainingQuantity: quantity,
    containerName: rawUnit,
    containerCapacity: 1,
    remainingUnit: rawUnit,
    displayText: text,
    shortBadgeText: text,
    fillPercentageOfOpenContainer: 1.0,
  );
}

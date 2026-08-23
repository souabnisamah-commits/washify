import 'package:flutter/material.dart';

class StockContainerBreakdown {
  final double rawQuantity;
  final String rawUnit;
  final int fullContainers;
  final double remainingQuantity;
  final String containerName; // e.g. "Bidon (5000ml)"
  final double containerCapacity;
  final String remainingUnit; // e.g. "ml"
  final String displayText; // e.g. "1x Bidon (5000ml) + 968 ml"
  final String shortBadgeText; // e.g. "1x Bidon (5000ml) + 968 ml"
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

StockContainerBreakdown parseStockContainers(double quantity, String rawUnit) {
  final unit = rawUnit.trim().toLowerCase();

  // 1. Milliliters (ml)
  if (unit == 'ml' || unit == 'millilitre' || unit == 'millilitres') {
    const double bidonCapacityMl = 5000.0;
    final int count = (quantity / bidonCapacityMl).floor();
    final double remMl = quantity % bidonCapacityMl;
    final double openRatio = remMl / bidonCapacityMl;

    String text;
    String badge;

    if (count > 0 && remMl > 0) {
      text = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) + ${remMl.toInt()} ml';
      badge = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) + ${remMl.toInt()} ml';
    } else if (count > 0 && remMl == 0) {
      text = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) Plein${count > 1 ? 's' : ''}';
      badge = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml)';
    } else {
      text = '${remMl.toInt()} ml';
      badge = '${remMl.toInt()} ml';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: count,
      remainingQuantity: remMl,
      containerName: 'Bidon (5000ml)',
      containerCapacity: 5000.0,
      remainingUnit: 'ml',
      displayText: text,
      shortBadgeText: badge,
      fillPercentageOfOpenContainer: openRatio,
    );
  }

  // 2. Unit specified as "Bidon" or "Bidons" in database
  if (unit == 'bidon' || unit == 'bidons') {
    // 1 Bidon = 5000 ml
    final double totalMl = quantity * 5000.0;
    const double bidonCapacityMl = 5000.0;
    final int count = (totalMl / bidonCapacityMl).floor();
    final double remMl = totalMl % bidonCapacityMl;
    final double openRatio = remMl / bidonCapacityMl;

    String text;
    String badge;

    if (count > 0 && remMl > 0) {
      text = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) + ${remMl.toInt()} ml';
      badge = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) + ${remMl.toInt()} ml';
    } else if (count > 0 && remMl == 0) {
      text = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) Plein${count > 1 ? 's' : ''}';
      badge = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml)';
    } else {
      text = '${remMl.toInt()} ml';
      badge = '${remMl.toInt()} ml';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: count,
      remainingQuantity: remMl,
      containerName: 'Bidon (5000ml)',
      containerCapacity: 5000.0,
      remainingUnit: 'ml',
      displayText: text,
      shortBadgeText: badge,
      fillPercentageOfOpenContainer: openRatio,
    );
  }

  // 3. Liters (L)
  if (unit == 'l' || unit == 'litre' || unit == 'litres') {
    final double totalMl = quantity * 1000.0;
    const double bidonCapacityMl = 5000.0;
    final int count = (totalMl / bidonCapacityMl).floor();
    final double remMl = totalMl % bidonCapacityMl;
    final double openRatio = remMl / bidonCapacityMl;

    String text;
    String badge;

    if (count > 0 && remMl > 0) {
      final remText = remMl >= 1000 ? '${(remMl / 1000).toStringAsFixed(1)} L' : '${remMl.toInt()} ml';
      text = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) + $remText';
      badge = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) + $remText';
    } else if (count > 0 && remMl == 0) {
      text = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) Plein${count > 1 ? 's' : ''}';
      badge = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml)';
    } else {
      final remText = remMl >= 1000 ? '${(remMl / 1000).toStringAsFixed(1)} L' : '${remMl.toInt()} ml';
      text = remText;
      badge = remText;
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: count,
      remainingQuantity: remMl >= 1000 ? remMl / 1000 : remMl,
      containerName: 'Bidon (5000ml)',
      containerCapacity: 5000.0,
      remainingUnit: remMl >= 1000 ? 'L' : 'ml',
      displayText: text,
      shortBadgeText: badge,
      fillPercentageOfOpenContainer: openRatio,
    );
  }

  // 4. Centiliters (cl)
  if (unit == 'cl' || unit == 'centilitre' || unit == 'centilitres') {
    final double totalMl = quantity * 10.0;
    const double bidonCapacityMl = 5000.0;
    final int count = (totalMl / bidonCapacityMl).floor();
    final double remMl = totalMl % bidonCapacityMl;
    final double openRatio = remMl / bidonCapacityMl;

    String text;
    String badge;

    if (count > 0 && remMl > 0) {
      text = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) + ${(remMl / 10).toInt()} cl';
      badge = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) + ${(remMl / 10).toInt()} cl';
    } else if (count > 0 && remMl == 0) {
      text = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml) Plein${count > 1 ? 's' : ''}';
      badge = '${count}x Bidon${count > 1 ? 's' : ''} (5000ml)';
    } else {
      text = '${(remMl / 10).toInt()} cl';
      badge = '${(remMl / 10).toInt()} cl';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: count,
      remainingQuantity: remMl / 10,
      containerName: 'Bidon (5000ml)',
      containerCapacity: 5000.0,
      remainingUnit: 'cl',
      displayText: text,
      shortBadgeText: badge,
      fillPercentageOfOpenContainer: openRatio,
    );
  }

  // 5. Grams (g)
  if (unit == 'g' || unit == 'gramme' || unit == 'grammes') {
    const double sacCapacityG = 5000.0; // 5kg sac/bidon
    final int count = (quantity / sacCapacityG).floor();
    final double remG = quantity % sacCapacityG;
    final double openRatio = remG / sacCapacityG;

    String text;
    String badge;

    if (count > 0 && remG > 0) {
      text = '${count}x Sac${count > 1 ? 's' : ''} (5kg) + ${remG.toInt()} g';
      badge = '${count}x Sac${count > 1 ? 's' : ''} (5kg) + ${remG.toInt()} g';
    } else if (count > 0 && remG == 0) {
      text = '${count}x Sac${count > 1 ? 's' : ''} (5kg) Plein${count > 1 ? 's' : ''}';
      badge = '${count}x Sac${count > 1 ? 's' : ''} (5kg)';
    } else {
      text = '${remG.toInt()} g';
      badge = '${remG.toInt()} g';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: count,
      remainingQuantity: remG,
      containerName: 'Sac (5kg)',
      containerCapacity: 5000.0,
      remainingUnit: 'g',
      displayText: text,
      shortBadgeText: badge,
      fillPercentageOfOpenContainer: openRatio,
    );
  }

  // 6. Kilograms (kg)
  if (unit == 'kg' || unit == 'kilo' || unit == 'kilogrammes') {
    const double sacCapacityKg = 5.0;
    final int count = (quantity / sacCapacityKg).floor();
    final double remKg = quantity % sacCapacityKg;
    final double openRatio = remKg / sacCapacityKg;

    String text;
    String badge;

    if (count > 0 && remKg > 0) {
      final remG = (remKg * 1000).toInt();
      final remStr = remG >= 1000 ? '${remKg.toStringAsFixed(1)} kg' : '$remG g';
      text = '${count}x Sac${count > 1 ? 's' : ''} (5kg) + $remStr';
      badge = '${count}x Sac${count > 1 ? 's' : ''} (5kg) + $remStr';
    } else if (count > 0 && remKg == 0) {
      text = '${count}x Sac${count > 1 ? 's' : ''} (5kg) Plein${count > 1 ? 's' : ''}';
      badge = '${count}x Sac${count > 1 ? 's' : ''} (5kg)';
    } else {
      final remStr = remKg % 1 == 0 ? '${remKg.toInt()} kg' : '${remKg.toStringAsFixed(1)} kg';
      text = remStr;
      badge = remStr;
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainers: count,
      remainingQuantity: remKg,
      containerName: 'Sac (5kg)',
      containerCapacity: 5.0,
      remainingUnit: 'kg',
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

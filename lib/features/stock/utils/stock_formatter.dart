import 'package:flutter/material.dart';

String getFrenchOrdinal(int index) {
  if (index == 1) return '1er';
  return '${index}ème';
}

class StockContainerBreakdown {
  final double rawQuantity;
  final String rawUnit;
  final int fullContainersCount;
  final bool hasOpenContainer;
  final double openContainerMl;
  final double containerCapacityMl;
  final double openContainerRatio; // 0.0 to 1.0
  final int totalPhysicalContainers; // fullContainersCount + (hasOpenContainer ? 1 : 0)
  final String containerName; // e.g. "Bidon (5000ml)"
  final String remainingUnit; // e.g. "ml"
  final String sealedLabel; // e.g. "2x Bidons Cachetés"
  final String openLabel; // e.g. "200 ml / 5000 ml (Bidon Entamé)"
  final String displayText; // e.g. "2x Bidons Cachetés + 200 ml / 5000 ml (Entamé)"
  final String shortBadgeText; // e.g. "2 Cachetés + 200ml/5000ml"

  StockContainerBreakdown({
    required this.rawQuantity,
    required this.rawUnit,
    required this.fullContainersCount,
    required this.hasOpenContainer,
    required this.openContainerMl,
    required this.containerCapacityMl,
    required this.openContainerRatio,
    required this.totalPhysicalContainers,
    required this.containerName,
    required this.remainingUnit,
    required this.sealedLabel,
    required this.openLabel,
    required this.displayText,
    required this.shortBadgeText,
  });
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
    final double capacity = (customCapacity > 0) ? customCapacity : 5000.0;

    final int fullCount = (totalMl / capacity).floor();
    final double remMl = totalMl % capacity;
    final bool hasOpen = remMl > 0;
    final double openRatio = remMl / capacity;
    final int totalContainers = fullCount + (hasOpen ? 1 : 0);

    final String capIntStr = capacity % 1 == 0 ? capacity.toInt().toString() : capacity.toStringAsFixed(0);
    final String remIntStr = remMl % 1 == 0 ? remMl.toInt().toString() : remMl.toStringAsFixed(0);

    final String sealedStr = fullCount > 0 ? '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}' : '';
    final String openStr = hasOpen ? '$remIntStr ml / $capIntStr ml (Bidon Entamé)' : '';

    String text;
    String badge;

    if (fullCount > 0 && hasOpen) {
      text = '$fullCount Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''} + $remIntStr ml / $capIntStr ml (Entamé)';
      badge = '${fullCount}x Cacheté${fullCount > 1 ? 's' : ''} + $remIntStr ml / $capIntStr ml';
    } else if (fullCount > 0 && !hasOpen) {
      text = '$fullCount Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''} (100% Plein${fullCount > 1 ? 's' : ''})';
      badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}';
    } else if (hasOpen) {
      text = '$remIntStr ml / $capIntStr ml (Bidon Entamé)';
      badge = '$remIntStr ml / $capIntStr ml';
    } else {
      text = 'Stock vide (0 ml)';
      badge = '0 ml';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainersCount: fullCount,
      hasOpenContainer: hasOpen,
      openContainerMl: remMl,
      containerCapacityMl: capacity,
      openContainerRatio: openRatio,
      totalPhysicalContainers: totalContainers,
      containerName: 'Bidon ($capIntStr ml)',
      remainingUnit: 'ml',
      sealedLabel: sealedStr,
      openLabel: openStr,
      displayText: text,
      shortBadgeText: badge,
    );
  }

  // 2. Liters (L)
  if (unit == 'l' || unit == 'litre' || unit == 'litres') {
    final double totalMl = quantity * 1000.0;
    final double capacity = (customCapacity > 0) ? customCapacity : 5000.0;

    final int fullCount = (totalMl / capacity).floor();
    final double remMl = totalMl % capacity;
    final bool hasOpen = remMl > 0;
    final double openRatio = remMl / capacity;
    final int totalContainers = fullCount + (hasOpen ? 1 : 0);

    final String capIntStr = capacity % 1 == 0 ? capacity.toInt().toString() : capacity.toStringAsFixed(0);
    final String remIntStr = remMl % 1 == 0 ? remMl.toInt().toString() : remMl.toStringAsFixed(0);

    final String sealedStr = fullCount > 0 ? '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}' : '';
    final String openStr = hasOpen ? '$remIntStr ml / $capIntStr ml (Bidon Entamé)' : '';

    String text;
    String badge;

    if (fullCount > 0 && hasOpen) {
      text = '$fullCount Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''} + $remIntStr ml / $capIntStr ml (Entamé)';
      badge = '${fullCount}x Cacheté${fullCount > 1 ? 's' : ''} + $remIntStr ml / $capIntStr ml';
    } else if (fullCount > 0 && !hasOpen) {
      text = '$fullCount Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''} (100% Plein)';
      badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}';
    } else if (hasOpen) {
      text = '$remIntStr ml / $capIntStr ml (Bidon Entamé)';
      badge = '$remIntStr ml / $capIntStr ml';
    } else {
      text = 'Stock vide (0 L)';
      badge = '0 L';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainersCount: fullCount,
      hasOpenContainer: hasOpen,
      openContainerMl: remMl,
      containerCapacityMl: capacity,
      openContainerRatio: openRatio,
      totalPhysicalContainers: totalContainers,
      containerName: 'Bidon ($capIntStr ml)',
      remainingUnit: 'ml',
      sealedLabel: sealedStr,
      openLabel: openStr,
      displayText: text,
      shortBadgeText: badge,
    );
  }

  // 3. Centiliters (cl)
  if (unit == 'cl' || unit == 'centilitre' || unit == 'centilitres') {
    final double totalMl = quantity * 10.0;
    final double capacity = (customCapacity > 0) ? customCapacity : 5000.0;

    final int fullCount = (totalMl / capacity).floor();
    final double remMl = totalMl % capacity;
    final bool hasOpen = remMl > 0;
    final double openRatio = remMl / capacity;
    final int totalContainers = fullCount + (hasOpen ? 1 : 0);

    final String capIntStr = capacity % 1 == 0 ? capacity.toInt().toString() : capacity.toStringAsFixed(0);
    final String remIntStr = remMl % 1 == 0 ? remMl.toInt().toString() : remMl.toStringAsFixed(0);

    final String sealedStr = fullCount > 0 ? '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}' : '';
    final String openStr = hasOpen ? '$remIntStr ml / $capIntStr ml (Bidon Entamé)' : '';

    String text;
    String badge;

    if (fullCount > 0 && hasOpen) {
      text = '$fullCount Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''} + $remIntStr ml / $capIntStr ml (Entamé)';
      badge = '${fullCount}x Cacheté${fullCount > 1 ? 's' : ''} + $remIntStr ml / $capIntStr ml';
    } else if (fullCount > 0 && !hasOpen) {
      text = '$fullCount Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}';
      badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}';
    } else if (hasOpen) {
      text = '$remIntStr ml / $capIntStr ml (Bidon Entamé)';
      badge = '$remIntStr ml / $capIntStr ml';
    } else {
      text = 'Stock vide (0 cl)';
      badge = '0 cl';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainersCount: fullCount,
      hasOpenContainer: hasOpen,
      openContainerMl: remMl,
      containerCapacityMl: capacity,
      openContainerRatio: openRatio,
      totalPhysicalContainers: totalContainers,
      containerName: 'Bidon ($capIntStr ml)',
      remainingUnit: 'cl',
      sealedLabel: sealedStr,
      openLabel: openStr,
      displayText: text,
      shortBadgeText: badge,
    );
  }

  // 4. Grams (g) or Kilograms (kg)
  if (unit == 'g' || unit == 'gramme' || unit == 'grammes' || unit == 'kg' || unit == 'kilo' || unit == 'kilogrammes') {
    final double totalG = (unit == 'kg' || unit == 'kilo' || unit == 'kilogrammes') ? (quantity * 1000.0) : quantity;
    final double capacity = (customCapacity > 0) ? customCapacity : 5000.0;

    final int fullCount = (totalG / capacity).floor();
    final double remG = totalG % capacity;
    final bool hasOpen = remG > 0;
    final double openRatio = remG / capacity;
    final int totalContainers = fullCount + (hasOpen ? 1 : 0);

    final String capIntStr = capacity >= 1000 ? '${(capacity / 1000).toInt()}kg' : '${capacity.toInt()}g';
    final String remIntStr = remG % 1 == 0 ? remG.toInt().toString() : remG.toStringAsFixed(0);

    final String sealedStr = fullCount > 0 ? '${fullCount}x Sac${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}' : '';
    final String openStr = hasOpen ? '$remIntStr g / ${capacity.toInt()} g (Sac Entamé)' : '';

    String text;
    String badge;

    if (fullCount > 0 && hasOpen) {
      text = '$fullCount Sac${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''} + $remIntStr g / ${capacity.toInt()} g (Entamé)';
      badge = '${fullCount}x Cacheté${fullCount > 1 ? 's' : ''} + $remIntStr g / ${capacity.toInt()}g';
    } else if (fullCount > 0 && !hasOpen) {
      text = '$fullCount Sac${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}';
      badge = '${fullCount}x Sac${fullCount > 1 ? 's' : ''} Cacheté${fullCount > 1 ? 's' : ''}';
    } else if (hasOpen) {
      text = '$remIntStr g / ${capacity.toInt()} g (Sac Entamé)';
      badge = '$remIntStr g / ${capacity.toInt()}g';
    } else {
      text = 'Stock vide';
      badge = '0 g';
    }

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      fullContainersCount: fullCount,
      hasOpenContainer: hasOpen,
      openContainerMl: remG,
      containerCapacityMl: capacity,
      openContainerRatio: openRatio,
      totalPhysicalContainers: totalContainers,
      containerName: 'Sac ($capIntStr)',
      remainingUnit: 'g',
      sealedLabel: sealedStr,
      openLabel: openStr,
      displayText: text,
      shortBadgeText: badge,
    );
  }

  // Default fallback for piece/unit/unite
  final qtyStr = quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toStringAsFixed(1);
  final text = '$qtyStr ${rawUnit.isEmpty ? 'unité(s)' : rawUnit}';
  return StockContainerBreakdown(
    rawQuantity: quantity,
    rawUnit: rawUnit,
    fullContainersCount: 0,
    hasOpenContainer: true,
    openContainerMl: quantity,
    containerCapacityMl: 1,
    openContainerRatio: 1.0,
    totalPhysicalContainers: 1,
    containerName: rawUnit,
    remainingUnit: rawUnit,
    sealedLabel: '',
    openLabel: text,
    displayText: text,
    shortBadgeText: text,
  );
}

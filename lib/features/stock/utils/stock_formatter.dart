import 'package:flutter/material.dart';
import 'package:washify/features/products/models/product.dart';

class StockContainerBreakdown {
  final double rawQuantity;
  final String rawUnit;
  final bool isBoutiqueItem; // True for Boutique (Revente) items
  final int fullContainersCount;
  final bool hasOpenContainer;
  final double openContainerMl;
  final double containerCapacityMl;
  final double openContainerPercent; // 0.0 to 100.0 %
  final int totalPhysicalContainers; // fullContainersCount + (hasOpenContainer ? 1 : 0)
  final String containerName; // e.g. "Bidon (5000ml)"
  final String remainingUnit; // e.g. "ml" or "pièces"
  final String sealedLabel; // e.g. "2x Bidons Pleins"
  final String openLabel; // e.g. "1968 ml / 2000 ml (98.4% Plein)"
  final String displayText; // e.g. "2x Bidon(s) + 1968 ml / 2000 ml (98.4% Plein)"
  final String rawTotalText; // e.g. "Volume total brut : 5 968 ml"

  StockContainerBreakdown({
    required this.rawQuantity,
    required this.rawUnit,
    required this.isBoutiqueItem,
    required this.fullContainersCount,
    required this.hasOpenContainer,
    required this.openContainerMl,
    required this.containerCapacityMl,
    required this.openContainerPercent,
    required this.totalPhysicalContainers,
    required this.containerName,
    required this.remainingUnit,
    required this.sealedLabel,
    required this.openLabel,
    required this.displayText,
    required this.rawTotalText,
  });
}

class ConsumedContainerBreakdown {
  final double consumedMl;
  final double containerCapacityMl;
  final int fullContainersConsumed;
  final bool hasPartialConsumed;
  final double partialConsumedMl;
  final double partialConsumedPercent; // 0.0 to 100.0 %
  final int totalContainersTouched;
  final String displayText; // e.g. "2x Bidon(s) (10 000 ml) + 2500 ml / 5000 ml"
  final String shortBadgeText; // e.g. "2500 ml / 5000 ml" or "2 Bidons + 2500ml/5000ml"

  ConsumedContainerBreakdown({
    required this.consumedMl,
    required this.containerCapacityMl,
    required this.fullContainersConsumed,
    required this.hasPartialConsumed,
    required this.partialConsumedMl,
    required this.partialConsumedPercent,
    required this.totalContainersTouched,
    required this.displayText,
    required this.shortBadgeText,
  });
}

StockContainerBreakdown parseStockContainers(
  double quantity,
  String rawUnit, {
  ProductFamily family = ProductFamily.standard,
  double customCapacityMl = 0.0,
}) {
  final unit = rawUnit.trim().toLowerCase();
  final isBoutique = family == ProductFamily.revente || unit == 'pièce' || unit == 'pièces' || unit == 'unité' || unit == 'unités';

  // 1. BOUTIQUE (Revente) ITEMS: Strictly raw units (pièces / unités), NO bidon conversion!
  if (isBoutique) {
    final qtyInt = quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toStringAsFixed(1);
    final unitLabel = rawUnit.isEmpty ? 'pièce(s)' : rawUnit;
    final text = '$qtyInt $unitLabel';

    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      isBoutiqueItem: true,
      fullContainersCount: 0,
      hasOpenContainer: true,
      openContainerMl: quantity,
      containerCapacityMl: 1.0,
      openContainerPercent: 100.0,
      totalPhysicalContainers: 1,
      containerName: unitLabel,
      remainingUnit: unitLabel,
      sealedLabel: '',
      openLabel: text,
      displayText: text,
      rawTotalText: 'Stock total : $text',
    );
  }

  // 2. LIQUID CONSUMABLES (Standard & Premium)
  double totalMl = quantity;
  if (unit == 'l' || unit == 'litre' || unit == 'litres') {
    totalMl = quantity * 1000.0;
  } else if (unit == 'cl' || unit == 'centilitre' || unit == 'centilitres') {
    totalMl = quantity * 10.0;
  } else if (unit == 'bidon' || unit == 'bidons') {
    final capTest = (customCapacityMl > 0) ? customCapacityMl : 5000.0;
    if (quantity < 100 && quantity > 0) {
      totalMl = quantity * capTest;
    } else {
      totalMl = quantity;
    }
  }

  final double capacity = (customCapacityMl > 0) ? customCapacityMl : 5000.0;
  final String capIntStr = capacity % 1 == 0 ? capacity.toInt().toString() : capacity.toStringAsFixed(0);

  if (totalMl <= 0) {
    return StockContainerBreakdown(
      rawQuantity: quantity,
      rawUnit: rawUnit,
      isBoutiqueItem: false,
      fullContainersCount: 0,
      hasOpenContainer: false,
      openContainerMl: 0.0,
      containerCapacityMl: capacity,
      openContainerPercent: 0.0,
      totalPhysicalContainers: 0,
      containerName: 'Bidon ($capIntStr ml)',
      remainingUnit: 'ml',
      sealedLabel: '0 Bidon',
      openLabel: 'Stock vide (0 ml)',
      displayText: 'Stock vide (0 ml)',
      rawTotalText: 'Volume total brut : 0 ml',
    );
  }

  final int fullCount = (totalMl / capacity).floor();
  final double remMl = totalMl % capacity;
  final bool hasOpen = remMl > 0.1;
  final double openPercent = hasOpen ? ((remMl / capacity) * 100.0).clamp(0.1, 99.9) : 0.0;
  final int totalContainers = fullCount + (hasOpen ? 1 : 0);

  final String remIntStr = remMl % 1 == 0 ? remMl.toInt().toString() : remMl.toStringAsFixed(0);
  final String percentStr = openPercent % 1 == 0 ? openPercent.toInt().toString() : openPercent.toStringAsFixed(1);
  final String totalMlStr = totalMl % 1 == 0 ? totalMl.toInt().toString() : totalMl.toStringAsFixed(0);

  final String sealedStr = fullCount > 0 ? '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} Plein${fullCount > 1 ? 's' : ''}' : '';
  final String openStr = hasOpen ? '$remIntStr ml / $capIntStr ml ($percentStr% Plein)' : '';

  String text;
  if (fullCount > 0 && hasOpen) {
    text = '$fullCount Bidon${fullCount > 1 ? 's' : ''} Plein${fullCount > 1 ? 's' : ''} + $remIntStr ml / $capIntStr ml ($percentStr% Plein)';
  } else if (fullCount > 0 && !hasOpen) {
    text = '$fullCount Bidon${fullCount > 1 ? 's' : ''} Plein${fullCount > 1 ? 's' : ''} (100% Plein)';
  } else {
    text = '$remIntStr ml / $capIntStr ml ($percentStr% Plein)';
  }

  return StockContainerBreakdown(
    rawQuantity: quantity,
    rawUnit: rawUnit,
    isBoutiqueItem: false,
    fullContainersCount: fullCount,
    hasOpenContainer: hasOpen,
    openContainerMl: remMl,
    containerCapacityMl: capacity,
    openContainerPercent: openPercent,
    totalPhysicalContainers: totalContainers,
    containerName: 'Bidon ($capIntStr ml)',
    remainingUnit: 'ml',
    sealedLabel: sealedStr,
    openLabel: openStr,
    displayText: text,
    rawTotalText: 'Volume total brut : $totalMlStr ml',
  );
}

ConsumedContainerBreakdown parseConsumedQuantity(
  double consumedMl,
  String rawUnit, {
  double customCapacityMl = 0.0,
}) {
  final capacity = customCapacityMl > 0 ? customCapacityMl : 5000.0;
  final capIntStr = capacity % 1 == 0 ? capacity.toInt().toString() : capacity.toStringAsFixed(0);

  if (consumedMl <= 0) {
    return ConsumedContainerBreakdown(
      consumedMl: 0.0,
      containerCapacityMl: capacity,
      fullContainersConsumed: 0,
      hasPartialConsumed: false,
      partialConsumedMl: 0.0,
      partialConsumedPercent: 0.0,
      totalContainersTouched: 0,
      displayText: 'Aucune consommation (0 ml)',
      shortBadgeText: '0 ml',
    );
  }

  final int fullCount = (consumedMl / capacity).floor();
  final double remMl = consumedMl % capacity;
  final bool hasPartial = remMl > 0.1;
  final double partialPercent = hasPartial ? ((remMl / capacity) * 100.0).clamp(0.1, 99.9) : 0.0;
  final int totalTouched = fullCount + (hasPartial ? 1 : 0);

  final String remIntStr = remMl % 1 == 0 ? remMl.toInt().toString() : remMl.toStringAsFixed(0);
  final String percentStr = partialPercent % 1 == 0 ? partialPercent.toInt().toString() : partialPercent.toStringAsFixed(1);
  final String consumedIntStr = consumedMl % 1 == 0 ? consumedMl.toInt().toString() : consumedMl.toStringAsFixed(0);

  String text;
  String badge;

  if (fullCount > 0 && hasPartial) {
    text = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} + $remIntStr ml / $capIntStr ml ($percentStr% d\'un bidon)';
    badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} + $remIntStr/$capIntStr ml';
  } else if (fullCount > 0 && !hasPartial) {
    text = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} Plein${fullCount > 1 ? 's' : ''} Consommé${fullCount > 1 ? 's' : ''} ($consumedIntStr ml)';
    badge = '${fullCount}x Bidon${fullCount > 1 ? 's' : ''} ($consumedIntStr ml)';
  } else {
    text = '$remIntStr ml / $capIntStr ml ($percentStr% d\'un bidon)';
    badge = '$remIntStr ml / $capIntStr ml';
  }

  return ConsumedContainerBreakdown(
    consumedMl: consumedMl,
    containerCapacityMl: capacity,
    fullContainersConsumed: fullCount,
    hasPartialConsumed: hasPartial,
    partialConsumedMl: remMl,
    partialConsumedPercent: partialPercent,
    totalContainersTouched: totalTouched,
    displayText: text,
    shortBadgeText: badge,
  );
}

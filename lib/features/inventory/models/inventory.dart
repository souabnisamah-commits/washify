import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory.freezed.dart';
part 'inventory.g.dart';

@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String productId,
    required String productName,
    required int expectedQuantity, // Stock théorique (Unités de consommation)
    required int actualQuantity,   // Stock réel mesuré (Unités de consommation)
    required int difference,       // Écart théorique vs réel
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);
}

@freezed
class Inventory with _$Inventory {
  const Inventory._();

  const factory Inventory({
    required String id,
    required String tenantId,
    required String performedBy,
    required String performedByName,
    required DateTime date,
    required List<InventoryItem> items,
    @Default('') String notes,
    required DateTime createdAt,
  }) = _Inventory;

  factory Inventory.fromJson(Map<String, dynamic> json) => _$InventoryFromJson(json);

  String get stationId => tenantId;
}

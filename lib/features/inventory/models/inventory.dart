import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'inventory.freezed.dart';
part 'inventory.g.dart';

@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String productId,
    required String productName,
    required double expectedQuantity, // Stock théorique (décimal ou ml)
    required double actualQuantity,   // Stock réel mesuré (décimal ou ml)
    required double difference,       // Écart théorique vs réel
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);
}

@freezed
class Inventory with _$Inventory {
  const Inventory._();

  const factory Inventory({
    required String id,
    @JsonKey(readValue: readTenantId) required String tenantId,
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

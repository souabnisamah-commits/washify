import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'stock.freezed.dart';
part 'stock.g.dart';

@freezed
class StockLevel with _$StockLevel {
  const StockLevel._();

  const factory StockLevel({
    required String id,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required String productId,
    required String productName,
    required double currentQuantity, // Support des millilitres/décimales
    required double minStock,        // Seuil d'alerte en double
    required DateTime updatedAt,
  }) = _StockLevel;

  factory StockLevel.fromJson(Map<String, dynamic> json) => _$StockLevelFromJson(json);

  bool get isLowStock => currentQuantity <= minStock;
  String get stationId => tenantId;
}

@freezed
class StockMovement with _$StockMovement {
  const StockMovement._();

  const factory StockMovement({
    required String id,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required String productId,
    required String productName,
    required String type, // in, out, adjustment
    required double quantity,
    required double previousQuantity,
    required double newQuantity,
    required String reason,
    required String performedBy,
    required DateTime createdAt,
  }) = _StockMovement;

  factory StockMovement.fromJson(Map<String, dynamic> json) => _$StockMovementFromJson(json);

  String get stationId => tenantId;
}

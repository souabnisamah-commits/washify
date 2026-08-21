import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_movement.freezed.dart';
part 'cash_movement.g.dart';

@freezed
class CashMovement with _$CashMovement {
  const factory CashMovement({
    required String id,
    required String stationId,
    required String sessionId,
    required double amount,
    required String type, // 'in', 'out'
    required String reason, // 'Acompte ouvrier', 'Achat consommables', 'Alimentation caisse', 'Recette' etc.
    @Default('cash') String paymentMethod,
    String? employeeId,
    String? employeeName,
    required String performedBy,
    required DateTime createdAt,
  }) = _CashMovement;

  factory CashMovement.fromJson(Map<String, dynamic> json) => _$CashMovementFromJson(json);
}

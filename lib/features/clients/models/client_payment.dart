import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'client_payment.freezed.dart';
part 'client_payment.g.dart';

@freezed
class ClientPayment with _$ClientPayment {
  const factory ClientPayment({
    required String id,
    required String clientId,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required double amount,
    required String paymentMethod, // Espèces, Chèque, Virement...
    String? reference, // Numéro de chèque, référence virement...
    required String createdBy, // ID ou Nom de la personne qui a enregistré le paiement
    required DateTime paymentDate,
  }) = _ClientPayment;

  factory ClientPayment.fromJson(Map<String, dynamic> json) => _$ClientPaymentFromJson(json);
}

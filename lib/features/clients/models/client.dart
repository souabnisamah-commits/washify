import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/features/clients/models/client_vehicle.dart';

part 'client.freezed.dart';
part 'client.g.dart';

class VehicleListConverter implements JsonConverter<List<ClientVehicle>, List<dynamic>> {
  const VehicleListConverter();

  @override
  List<ClientVehicle> fromJson(List<dynamic> json) {
    return json.map((e) {
      if (e is String) return ClientVehicle(plate: e);
      if (e is Map<String, dynamic>) return ClientVehicle.fromJson(e);
      return ClientVehicle(plate: e.toString());
    }).toList();
  }

  @override
  List<dynamic> toJson(List<ClientVehicle> object) {
    return object.map((e) => e.toJson()).toList();
  }
}

@freezed
class Client with _$Client {
  const factory Client({
    required String id,
    required String tenantId,
    required String companyName,
    required String contactName,
    required String taxId, // Matricule Fiscale
    required String phone,
    @Default(0.0) double alertThreshold, // Seuil d'alerte
    @Default(0.0) double currentBalance, // Montant total non payé
    @VehicleListConverter() @Default([]) List<ClientVehicle> vehicles, // Véhicules du client
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
}

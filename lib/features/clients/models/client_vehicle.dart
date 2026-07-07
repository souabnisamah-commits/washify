import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_vehicle.freezed.dart';
part 'client_vehicle.g.dart';

@freezed
class ClientVehicle with _$ClientVehicle {
  const factory ClientVehicle({
    required String plate,
    @Default('') String brand,
    @Default('') String model,
    @Default('') String categoryId,
  }) = _ClientVehicle;

  factory ClientVehicle.fromJson(Map<String, dynamic> json) => _$ClientVehicleFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'station.freezed.dart';
part 'station.g.dart';

enum LicenceStatus {
  active('active'),
  gracePeriod('grace_period'),
  suspended('suspended');

  const LicenceStatus(this.value);
  final String value;

  static LicenceStatus fromString(String value) {
    return LicenceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => LicenceStatus.suspended,
    );
  }
}

@freezed
class Station with _$Station {
  const Station._();

  const factory Station({
    required String id,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required String name,
    required String gerantName,
    required String phone,
    required String email,
    required String matriculeFiscale,
    required double latitude,
    required double longitude,
    required String logoUrl,
    required LicenceStatus licence,
    DateTime? subscriptionDate,
    DateTime? expiryDate,
    @Default(7) int gracePeriodDays,
    @Default('') String address,
    @Default('') String city,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Station;

  factory Station.fromJson(Map<String, dynamic> json) => _$StationFromJson(json);

  String? get patronId => tenantId;
}

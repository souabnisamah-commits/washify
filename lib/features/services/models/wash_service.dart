import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'wash_service.freezed.dart';
part 'wash_service.g.dart';

@freezed
class WashService with _$WashService {
  const WashService._();

  const factory WashService({
    required String id,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WashService;

  factory WashService.fromJson(Map<String, dynamic> json) => _$WashServiceFromJson(json);

  String get stationId => tenantId;
}

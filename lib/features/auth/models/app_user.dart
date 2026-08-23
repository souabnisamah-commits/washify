import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';
import 'package:washify/core/constants/user_roles.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    required String id,
    @JsonKey(readValue: readTenantId) required String tenantId, // stationId or tenantId
    required String phone,
    required String pinHash,  // PIN stored hashed
    required String name,
    required List<UserRole> roles, // Multi-roles support
    @Default(0.0) double baseDailyWage,
    @Default(0.0) double extraHourRate,
    @Default(true) bool isActive,
    @Default(false) bool isOnline,
    @Default(false) bool forceLogout,
    String? clientId,
    DateTime? lastLoginAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  UserRole get role => roles.isNotEmpty ? roles.first : UserRole.ouvrier;
  String? get stationId => tenantId.isEmpty ? null : tenantId;
}

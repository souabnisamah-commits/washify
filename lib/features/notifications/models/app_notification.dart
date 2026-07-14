import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

enum NotificationType {
  licenceExpire('licence_expire'),
  stockFaible('stock_faible'),
  remboursement('remboursement'),
  ecartCaisse('ecart_caisse'),
  system('system');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

@freezed
class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required String id,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required String userId,
    required String title,
    required String body,
    required NotificationType type, // licence_expire, stock_faible, remboursement, ecart_caisse, system
    @Default(false) bool isRead,
    String? referenceId,
    required DateTime createdAt,
  }) = _AppNotification;

  String? get stationId => tenantId.isEmpty ? null : tenantId;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
}

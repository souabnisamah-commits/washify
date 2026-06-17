import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/notifications/models/app_notification.dart';
import 'package:washify/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationsProvider =
    FutureProvider.family<List<AppNotification>, String>((ref, userId) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotifications(userId);
});

final unreadNotificationCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount(userId);
});

final notificationsStreamProvider =
    StreamProvider.family<List<AppNotification>, String>((ref, userId) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchNotifications(userId);
});

final unreadCountStreamProvider =
    StreamProvider.family<int, String>((ref, userId) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchUnreadCount(userId);
});

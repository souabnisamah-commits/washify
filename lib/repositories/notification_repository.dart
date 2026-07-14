import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/notifications/models/app_notification.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;

  NotificationRepository({FirebaseFirestore? firestore, this.tenantId = ''})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _notificationsRef =>
      _firestore.collection(AppConstants.notificationsCollection);

  AppNotification _notificationFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final typeStr = data['type'] as String? ?? 'system';
    NotificationType type;
    if (typeStr == 'stock_low') {
      type = NotificationType.stockFaible;
    } else {
      type = NotificationType.fromString(typeStr);
    }

    return AppNotification.fromJson({
      ...data,
      'id': doc.id,
      'tenantId': data['tenantId'] ?? data['stationId'] ?? '',
      'userId': data['userId'] ?? '',
      'title': data['title'] ?? '',
      'body': data['body'] ?? '',
      'type': type.value,
      'isRead': data['isRead'] ?? false,
      'referenceId': data['referenceId'],
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> _notificationToDoc(AppNotification notification) {
    final data = notification.toJson();
    data.remove('id');
    data['createdAt'] = Timestamp.fromDate(notification.createdAt);

    String typeStr;
    switch (notification.type) {
      case NotificationType.stockFaible:
        typeStr = 'stock_low';
        break;
      case NotificationType.licenceExpire:
        typeStr = 'licence_expire';
        break;
      case NotificationType.remboursement:
        typeStr = 'remboursement';
        break;
      case NotificationType.ecartCaisse:
        typeStr = 'ecart_caisse';
        break;
      default:
        typeStr = 'system';
        break;
    }
    data['type'] = typeStr;
    data['stationId'] = notification.tenantId;
    return data;
  }

  Future<List<AppNotification>> getNotifications(String userId,
      {int limit = 50}) async {
    final querySnapshot = await _notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return querySnapshot.docs
        .map((doc) => _notificationFromDoc(doc))
        .toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final querySnapshot = await _notificationsRef
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    return querySnapshot.docs.length;
  }

  Future<void> createNotification(AppNotification notification) async {
    await _notificationsRef.add(_notificationToDoc(notification));
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead(String userId) async {
    final querySnapshot = await _notificationsRef
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _notificationFromDoc(doc))
            .toList());
  }

  Stream<int> watchUnreadCount(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

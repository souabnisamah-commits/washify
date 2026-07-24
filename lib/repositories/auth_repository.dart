import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/core/utils/hash_util.dart';
import 'package:washify/repositories/audit_repository.dart';

class AuthRepository {
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  AppUser _appUserFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    data['id'] = doc.id;
    
    // Map Firestore Timestamps to ISO strings so json_serializable can parse them
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['lastLoginAt'] is Timestamp) {
      data['lastLoginAt'] = (data['lastLoginAt'] as Timestamp).toDate().toIso8601String();
    }
    
    // Backward compatibility mappings
    if (data['roles'] == null && data['role'] != null) {
      data['roles'] = [data['role']];
    } else if (data['roles'] == null) {
      data['roles'] = ['ouvrier'];
    }
    
    if (data['tenantId'] == null && data['stationId'] != null) {
      data['tenantId'] = data['stationId'];
    } else if (data['tenantId'] == null) {
      data['tenantId'] = '';
    }

    if (data['pinHash'] == null && data['pin'] != null) {
      data['pinHash'] = hashPin(data['pin'] as String);
    } else if (data['pinHash'] == null) {
      data['pinHash'] = '';
    }

    return AppUser.fromJson(data);
  }

  Map<String, dynamic> _appUserToDoc(AppUser user) {
    final map = user.toJson();
    map.remove('id');
    map['createdAt'] = Timestamp.fromDate(user.createdAt);
    map['updatedAt'] = Timestamp.fromDate(user.updatedAt);
    return map;
  }

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    final updates = <String, dynamic>{
      'isOnline': isOnline,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isOnline) {
      updates['lastLoginAt'] = FieldValue.serverTimestamp();
      updates['forceLogout'] = false; // Reset force logout on new login
    }
    await _usersRef.doc(userId).update(updates);
  }

  Future<void> forceLogoutUser(String userId) async {
    await _usersRef.doc(userId).update({
      'forceLogout': true,
      'isOnline': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser?> loginWithPhoneAndPin(String phone, String pin) async {
    final hash = hashPin(pin);
    final querySnapshot = await _usersRef
        .where('phone', isEqualTo: phone)
        .where('isActive', isEqualTo: true)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    for (final doc in querySnapshot.docs) {
      final user = _appUserFromDoc(doc);
      if (user.pinHash == hash) {
        // Check if the user belongs to a station and if it is suspended
        if (user.tenantId.isNotEmpty && user.tenantId != 'admin_station') {
          final stationDoc = await _firestore.collection(AppConstants.stationsCollection).doc(user.tenantId).get();
          if (stationDoc.exists) {
            final stationData = stationDoc.data()!;
            if (stationData['licence'] == 'suspended') {
              throw Exception('station_suspended');
            }
          }
        }
        return user;
      }
    }
    return null;
  }

  Future<AppUser?> getUserById(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    return _appUserFromDoc(doc);
  }

  Future<AppUser?> getUserByPhone(String phone) async {
    final querySnapshot = await _usersRef
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return _appUserFromDoc(querySnapshot.docs.first);
  }

  Future<void> createUser(AppUser user, {AppUser? actor}) async {
    await _usersRef.doc(user.id).set(_appUserToDoc(user));
    
    if (actor != null) {
      AuditRepository(tenantId: actor.tenantId).log(
        userId: actor.id,
        userName: actor.name,
        action: 'Création Employé',
        module: 'users',
        description: 'A créé le compte ${user.name} (${user.roles.first.name})',
        stationId: actor.tenantId,
        newData: {'userId': user.id, 'name': user.name, 'phone': user.phone},
      );
    }
  }

  Future<void> updateUser(AppUser user, {AppUser? actor}) async {
    await _usersRef.doc(user.id).update(_appUserToDoc(user));

    if (actor != null) {
      AuditRepository(tenantId: actor.tenantId).log(
        userId: actor.id,
        userName: actor.name,
        action: 'Modification Employé',
        module: 'users',
        description: 'A modifié le compte ${user.name}',
        stationId: actor.tenantId,
        newData: {'userId': user.id, 'name': user.name, 'isActive': user.isActive},
      );
    }
  }

  Future<void> ensureAdminExists() async {
    final adminQuery = await _usersRef
        .where('phone', isEqualTo: AppConstants.defaultAdminPhone)
        .limit(1)
        .get();

    if (adminQuery.docs.isEmpty) {
      final now = DateTime.now();
      final admin = AppUser(
        id: 'admin_${AppConstants.defaultAdminPhone}',
        tenantId: 'admin_station',
        phone: AppConstants.defaultAdminPhone,
        pinHash: hashPin(AppConstants.defaultAdminPin),
        name: AppConstants.defaultAdminName,
        roles: const [UserRole.admin],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      await createUser(admin);
    }
  }

  Future<List<AppUser>> getAllUsers() async {
    final querySnapshot = await _usersRef
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs.map((doc) => _appUserFromDoc(doc)).toList();
  }

  Future<void> deactivateUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return;
    final phone = (doc.data() as Map<String, dynamic>?)?['phone'] as String? ?? '';
    await _usersRef.doc(userId).update({
      'isActive': false,
      'phone': 'deleted_${DateTime.now().millisecondsSinceEpoch}_$phone',
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> changePin(String userId, String newPin) async {
    await _usersRef.doc(userId).update({
      'pinHash': hashPin(newPin),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<List<AppUser>> getUsersByStationId(String stationId) async {
    final querySnapshot = await _usersRef
        .where('tenantId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs.map((doc) => _appUserFromDoc(doc)).toList();
  }

  Stream<AppUser?> userStream(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _appUserFromDoc(doc);
    });
  }

  Future<List<AppUser>> getOnlineUsers(String stationId) async {
    final querySnapshot = await _usersRef
        .where('tenantId', isEqualTo: stationId)
        .where('isOnline', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .get();
    return querySnapshot.docs.map((doc) => _appUserFromDoc(doc)).toList();
  }
}

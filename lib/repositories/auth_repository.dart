import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/core/utils/hash_util.dart';

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

  Future<void> createUser(AppUser user) async {
    await _usersRef.doc(user.id).set(_appUserToDoc(user));
  }

  Future<void> updateUser(AppUser user) async {
    await _usersRef.doc(user.id).update(_appUserToDoc(user));
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
    await _usersRef.doc(userId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> changePin(String userId, String newPin) async {
    await _usersRef.doc(userId).update({
      'pinHash': hashPin(newPin),
      'updatedAt': Timestamp.now(),
    });
  }
}

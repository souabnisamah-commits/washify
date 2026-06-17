import 'package:flutter_test/flutter_test.dart';
import 'package:washify/core/utils/hash_util.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/core/constants/user_roles.dart';

void main() {
  group('PIN Hashing Tests', () {
    test('hashPin returns consistent SHA-256 string', () {
      final pin = '1012';
      final hashed = hashPin(pin);
      
      // Known SHA-256 for '1012'
      expect(hashed, '165940940a02a187e4463ff467090930038c5af8fc26107bf301e714f599a1da');
      expect(hashPin(pin), hashed);
    });
  });

  group('AppUser Freezed Model Tests', () {
    test('AppUser fromJson with normal fields', () {
      final json = {
        'id': 'test_id',
        'tenantId': 'station_123',
        'phone': '12345678',
        'pinHash': 'hash123',
        'name': 'Sam',
        'roles': ['caissier'],
        'isActive': true,
        'createdAt': '2026-06-17T16:30:00.000Z',
        'updatedAt': '2026-06-17T16:30:00.000Z',
      };

      final user = AppUser.fromJson(json);
      expect(user.id, 'test_id');
      expect(user.tenantId, 'station_123');
      expect(user.role, UserRole.caissier);
      expect(user.stationId, 'station_123');
    });

    test('AppUser getters fallback when tenantId or roles are empty', () {
      final json = {
        'id': 'test_id',
        'tenantId': '',
        'phone': '12345678',
        'pinHash': 'hash123',
        'name': 'Sam',
        'roles': <String>[],
        'isActive': true,
        'createdAt': '2026-06-17T16:30:00.000Z',
        'updatedAt': '2026-06-17T16:30:00.000Z',
      };

      final user = AppUser.fromJson(json);
      expect(user.role, UserRole.ouvrier);
      expect(user.stationId, isNull);
    });
  });
}

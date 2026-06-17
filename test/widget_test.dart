import 'package:flutter_test/flutter_test.dart';
import 'package:washify/core/constants/user_roles.dart';

void main() {
  group('UserRole Unit Tests', () {
    test('UserRole labels and value mappings', () {
      expect(UserRole.admin.value, 'admin');
      expect(UserRole.admin.label, 'Administrateur');

      expect(UserRole.patron.value, 'patron');
      expect(UserRole.patron.label, 'Patron');

      expect(UserRole.caissier.value, 'caissier');
      expect(UserRole.caissier.label, 'Caissier');

      expect(UserRole.ouvrier.value, 'ouvrier');
      expect(UserRole.ouvrier.label, 'Ouvrier');
    });

    test('UserRole.fromString fallback behavior', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('patron'), UserRole.patron);
      expect(UserRole.fromString('caissier'), UserRole.caissier);
      expect(UserRole.fromString('ouvrier'), UserRole.ouvrier);
      expect(UserRole.fromString('invalid_role'), UserRole.ouvrier); // Default fallback
    });
  });
}

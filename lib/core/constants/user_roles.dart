// User roles enumeration for Washify SaaS
enum UserRole {
  admin('admin', 'Administrateur'),
  patron('patron', 'Patron'),
  caissier('caissier', 'Caissier'),
  ouvrier('ouvrier', 'Ouvrier'),
  clientB2B('client_b2b', 'Client B2B');

  const UserRole(this.value, this.label);
  final String value;
  final String label;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.ouvrier,
    );
  }
}

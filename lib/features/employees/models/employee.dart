import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:washify/core/constants/user_roles.dart';

part 'employee.freezed.dart';
part 'employee.g.dart';

enum ContractType {
  journalier('journalier'),
  mensuel('mensuel');

  const ContractType(this.value);
  final String value;

  static ContractType fromString(String value) {
    return ContractType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ContractType.mensuel,
    );
  }
}

@freezed
class Employee with _$Employee {
  const Employee._();

  const factory Employee({
    required String id,
    required String userId,
    required String tenantId,
    required String nom,
    required String prenom,
    required String phone,
    required ContractType contrat,
    required double valeurJournaliere, // for journalier contract
    required double salaireMensuel,    // for mensuel contract
    @Default(0.0) double extraHourRate, // Extra hour rate
    required double commissionRate,    // commission percentage
    @Default([UserRole.ouvrier]) List<UserRole> roles,
    @Default(true) bool isActive,
    required DateTime dateEmbauche,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);

  String get name => "$prenom $nom".trim();
  double get salary => contrat == ContractType.mensuel ? salaireMensuel : valeurJournaliere;
  DateTime get hireDate => dateEmbauche;
  String get stationId => tenantId;
}

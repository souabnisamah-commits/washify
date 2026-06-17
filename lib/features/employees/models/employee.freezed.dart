// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Employee _$EmployeeFromJson(Map<String, dynamic> json) {
  return _Employee.fromJson(json);
}

/// @nodoc
mixin _$Employee {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String get prenom => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  ContractType get contrat => throw _privateConstructorUsedError;
  double get valeurJournaliere =>
      throw _privateConstructorUsedError; // for journalier contract
  double get salaireMensuel =>
      throw _privateConstructorUsedError; // for mensuel contract
  double get commissionRate =>
      throw _privateConstructorUsedError; // commission percentage
  UserRole get role => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get dateEmbauche => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Employee to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmployeeCopyWith<Employee> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmployeeCopyWith<$Res> {
  factory $EmployeeCopyWith(Employee value, $Res Function(Employee) then) =
      _$EmployeeCopyWithImpl<$Res, Employee>;
  @useResult
  $Res call({
    String id,
    String userId,
    String tenantId,
    String nom,
    String prenom,
    String phone,
    ContractType contrat,
    double valeurJournaliere,
    double salaireMensuel,
    double commissionRate,
    UserRole role,
    bool isActive,
    DateTime dateEmbauche,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$EmployeeCopyWithImpl<$Res, $Val extends Employee>
    implements $EmployeeCopyWith<$Res> {
  _$EmployeeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? tenantId = null,
    Object? nom = null,
    Object? prenom = null,
    Object? phone = null,
    Object? contrat = null,
    Object? valeurJournaliere = null,
    Object? salaireMensuel = null,
    Object? commissionRate = null,
    Object? role = null,
    Object? isActive = null,
    Object? dateEmbauche = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            prenom: null == prenom
                ? _value.prenom
                : prenom // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            contrat: null == contrat
                ? _value.contrat
                : contrat // ignore: cast_nullable_to_non_nullable
                      as ContractType,
            valeurJournaliere: null == valeurJournaliere
                ? _value.valeurJournaliere
                : valeurJournaliere // ignore: cast_nullable_to_non_nullable
                      as double,
            salaireMensuel: null == salaireMensuel
                ? _value.salaireMensuel
                : salaireMensuel // ignore: cast_nullable_to_non_nullable
                      as double,
            commissionRate: null == commissionRate
                ? _value.commissionRate
                : commissionRate // ignore: cast_nullable_to_non_nullable
                      as double,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as UserRole,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            dateEmbauche: null == dateEmbauche
                ? _value.dateEmbauche
                : dateEmbauche // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmployeeImplCopyWith<$Res>
    implements $EmployeeCopyWith<$Res> {
  factory _$$EmployeeImplCopyWith(
    _$EmployeeImpl value,
    $Res Function(_$EmployeeImpl) then,
  ) = __$$EmployeeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String tenantId,
    String nom,
    String prenom,
    String phone,
    ContractType contrat,
    double valeurJournaliere,
    double salaireMensuel,
    double commissionRate,
    UserRole role,
    bool isActive,
    DateTime dateEmbauche,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$EmployeeImplCopyWithImpl<$Res>
    extends _$EmployeeCopyWithImpl<$Res, _$EmployeeImpl>
    implements _$$EmployeeImplCopyWith<$Res> {
  __$$EmployeeImplCopyWithImpl(
    _$EmployeeImpl _value,
    $Res Function(_$EmployeeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? tenantId = null,
    Object? nom = null,
    Object? prenom = null,
    Object? phone = null,
    Object? contrat = null,
    Object? valeurJournaliere = null,
    Object? salaireMensuel = null,
    Object? commissionRate = null,
    Object? role = null,
    Object? isActive = null,
    Object? dateEmbauche = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$EmployeeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        prenom: null == prenom
            ? _value.prenom
            : prenom // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        contrat: null == contrat
            ? _value.contrat
            : contrat // ignore: cast_nullable_to_non_nullable
                  as ContractType,
        valeurJournaliere: null == valeurJournaliere
            ? _value.valeurJournaliere
            : valeurJournaliere // ignore: cast_nullable_to_non_nullable
                  as double,
        salaireMensuel: null == salaireMensuel
            ? _value.salaireMensuel
            : salaireMensuel // ignore: cast_nullable_to_non_nullable
                  as double,
        commissionRate: null == commissionRate
            ? _value.commissionRate
            : commissionRate // ignore: cast_nullable_to_non_nullable
                  as double,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as UserRole,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        dateEmbauche: null == dateEmbauche
            ? _value.dateEmbauche
            : dateEmbauche // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmployeeImpl extends _Employee {
  const _$EmployeeImpl({
    required this.id,
    required this.userId,
    required this.tenantId,
    required this.nom,
    required this.prenom,
    required this.phone,
    required this.contrat,
    required this.valeurJournaliere,
    required this.salaireMensuel,
    required this.commissionRate,
    this.role = UserRole.ouvrier,
    this.isActive = true,
    required this.dateEmbauche,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$EmployeeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmployeeImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String tenantId;
  @override
  final String nom;
  @override
  final String prenom;
  @override
  final String phone;
  @override
  final ContractType contrat;
  @override
  final double valeurJournaliere;
  // for journalier contract
  @override
  final double salaireMensuel;
  // for mensuel contract
  @override
  final double commissionRate;
  // commission percentage
  @override
  @JsonKey()
  final UserRole role;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime dateEmbauche;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Employee(id: $id, userId: $userId, tenantId: $tenantId, nom: $nom, prenom: $prenom, phone: $phone, contrat: $contrat, valeurJournaliere: $valeurJournaliere, salaireMensuel: $salaireMensuel, commissionRate: $commissionRate, role: $role, isActive: $isActive, dateEmbauche: $dateEmbauche, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmployeeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prenom, prenom) || other.prenom == prenom) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.contrat, contrat) || other.contrat == contrat) &&
            (identical(other.valeurJournaliere, valeurJournaliere) ||
                other.valeurJournaliere == valeurJournaliere) &&
            (identical(other.salaireMensuel, salaireMensuel) ||
                other.salaireMensuel == salaireMensuel) &&
            (identical(other.commissionRate, commissionRate) ||
                other.commissionRate == commissionRate) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.dateEmbauche, dateEmbauche) ||
                other.dateEmbauche == dateEmbauche) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    tenantId,
    nom,
    prenom,
    phone,
    contrat,
    valeurJournaliere,
    salaireMensuel,
    commissionRate,
    role,
    isActive,
    dateEmbauche,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmployeeImplCopyWith<_$EmployeeImpl> get copyWith =>
      __$$EmployeeImplCopyWithImpl<_$EmployeeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmployeeImplToJson(this);
  }
}

abstract class _Employee extends Employee {
  const factory _Employee({
    required final String id,
    required final String userId,
    required final String tenantId,
    required final String nom,
    required final String prenom,
    required final String phone,
    required final ContractType contrat,
    required final double valeurJournaliere,
    required final double salaireMensuel,
    required final double commissionRate,
    final UserRole role,
    final bool isActive,
    required final DateTime dateEmbauche,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$EmployeeImpl;
  const _Employee._() : super._();

  factory _Employee.fromJson(Map<String, dynamic> json) =
      _$EmployeeImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get tenantId;
  @override
  String get nom;
  @override
  String get prenom;
  @override
  String get phone;
  @override
  ContractType get contrat;
  @override
  double get valeurJournaliere; // for journalier contract
  @override
  double get salaireMensuel; // for mensuel contract
  @override
  double get commissionRate; // commission percentage
  @override
  UserRole get role;
  @override
  bool get isActive;
  @override
  DateTime get dateEmbauche;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Employee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmployeeImplCopyWith<_$EmployeeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

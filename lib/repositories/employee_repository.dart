import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/employees/models/employee.dart';

class EmployeeRepository {
  final FirebaseFirestore _firestore;

  EmployeeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _employeesRef =>
      _firestore.collection(AppConstants.employeesCollection);

  Employee _employeeFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    data['id'] = doc.id;

    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['hireDate'] is Timestamp) {
      data['dateEmbauche'] = (data['hireDate'] as Timestamp).toDate().toIso8601String();
    } else if (data['dateEmbauche'] is Timestamp) {
      data['dateEmbauche'] = (data['dateEmbauche'] as Timestamp).toDate().toIso8601String();
    } else if (data['dateEmbauche'] == null) {
      data['dateEmbauche'] = DateTime.now().toIso8601String();
    }

    // Fallbacks for legacy DB records
    if (data['tenantId'] == null && data['stationId'] != null) {
      data['tenantId'] = data['stationId'];
    } else if (data['tenantId'] == null) {
      data['tenantId'] = '';
    }

    if (data['nom'] == null || data['prenom'] == null) {
      final String fullName = data['name'] as String? ?? '';
      final parts = fullName.split(' ');
      data['prenom'] = parts.isNotEmpty ? parts.first : '';
      data['nom'] = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    if (data['contrat'] == null) {
      data['contrat'] = 'mensuel';
    }
    if (data['valeurJournaliere'] == null) {
      data['valeurJournaliere'] = 0.0;
    }
    if (data['salaireMensuel'] == null) {
      data['salaireMensuel'] = (data['salary'] as num?)?.toDouble() ?? 0.0;
    }
    if (data['commissionRate'] == null) {
      data['commissionRate'] = 0.0;
    }
    if (data['role'] == null) {
      data['role'] = 'ouvrier';
    }

    return Employee.fromJson(data);
  }

  Map<String, dynamic> _employeeToDoc(Employee employee) {
    final map = employee.toJson();
    map.remove('id');
    map['stationId'] = employee.tenantId;
    map['name'] = employee.name;
    map['salary'] = employee.salary;
    map['hireDate'] = Timestamp.fromDate(employee.hireDate);
    map['createdAt'] = Timestamp.fromDate(employee.createdAt);
    map['updatedAt'] = Timestamp.fromDate(employee.updatedAt);
    return map;
  }

  Future<List<Employee>> getAllEmployees() async {
    final querySnapshot = await _employeesRef
        .orderBy('name')
        .get();
    return querySnapshot.docs.map((doc) => _employeeFromDoc(doc)).toList();
  }

  Future<List<Employee>> getEmployeesByStation(String stationId) async {
    final querySnapshot = await _employeesRef
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return querySnapshot.docs.map((doc) => _employeeFromDoc(doc)).toList();
  }

  Future<Employee?> getEmployeeById(String employeeId) async {
    final doc = await _employeesRef.doc(employeeId).get();
    if (!doc.exists) return null;
    return _employeeFromDoc(doc);
  }

  Future<Employee?> getEmployeeByUserId(String userId) async {
    final querySnapshot = await _employeesRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) return null;
    return _employeeFromDoc(querySnapshot.docs.first);
  }

  Future<String> createEmployee(Employee employee) async {
    final docRef = await _employeesRef.add(_employeeToDoc(employee));
    return docRef.id;
  }

  Future<void> updateEmployee(Employee employee) async {
    await _employeesRef.doc(employee.id).update(_employeeToDoc(employee));
  }

  Future<void> deleteEmployee(String employeeId) async {
    await _employeesRef.doc(employeeId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<Employee>> watchEmployeesByStation(String stationId) {
    return _employeesRef
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _employeeFromDoc(doc)).toList());
  }
}

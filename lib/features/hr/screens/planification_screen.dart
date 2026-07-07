import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/employees/models/employee.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/features/hr/models/shift.dart';
import 'package:washify/features/hr/models/attendance.dart';
import 'package:washify/features/hr/providers/hr_provider.dart';
import 'package:washify/features/hr/repositories/hr_repository.dart';
import 'package:washify/providers/auth_provider.dart';

class PlanificationScreen extends ConsumerStatefulWidget {
  const PlanificationScreen({super.key});

  @override
  ConsumerState<PlanificationScreen> createState() => _PlanificationScreenState();
}

class _PlanificationScreenState extends ConsumerState<PlanificationScreen> {
  DateTime _selectedDate = DateTime.now();
  Shift? _selectedShift;
  
  final Map<String, bool> _optimisticMap = {};
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _optimisticMap.clear();
      });
    }
  }

  void _onShiftChanged(Shift? newShift) {
    setState(() {
      _selectedShift = newShift;
      _optimisticMap.clear();
    });
  }

  Future<void> _togglePlanification(Employee emp, bool isPlanned, Attendance? exist, String tenantId) async {
    setState(() {
      _optimisticMap[emp.id] = isPlanned;
    });
    
    final repo = ref.read(hrRepositoryProvider);
    try {
      if (isPlanned && exist == null) {
        final att = Attendance(
          id: '', stationId: tenantId, employeeId: emp.id, date: _selectedDate, shiftId: _selectedShift!.id,
          status: AttendanceStatus.planned, extraHours: 0, deduction: 0.0,
          netDailyWage: 0.0,
          createdAt: DateTime.now(),
        );
        await repo.createAttendance(att);
      } else if (!isPlanned && exist != null) {
        await repo.deleteAttendance(exist.id);
      }
    } catch (e) {
      setState(() {
        _optimisticMap.remove(emp.id);
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'.tr)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.tenantId.isEmpty) return Center(child: Text('Aucune station'.tr));

    final shiftsAsync = ref.watch(shiftsStreamProvider(user.tenantId));
    final employeesAsync = ref.watch(employeesStreamProvider(user.tenantId));
    final attendancesAsync = ref.watch(attendancesStreamProvider((stationId: user.tenantId, date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day))));

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Date & Shift Selection
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: 'Date de Planification'.tr, border: OutlineInputBorder()),
                        child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: shiftsAsync.when(
                      data: (shifts) {
                        if (_selectedShift == null && shifts.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _selectedShift = shifts.first;
                              });
                            }
                          });
                        }
                        return DropdownButtonFormField<Shift>(
                          initialValue: _selectedShift,
                          decoration: InputDecoration(labelText: 'Shift'.tr, border: OutlineInputBorder()),
                          items: shifts.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                          onChanged: _onShiftChanged,
                        );
                      },
                      loading: () => CircularProgressIndicator(),
                      error: (e, s) => Text('Erreur'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Employees List
          Expanded(
            child: employeesAsync.when(
              data: (employees) {
                return attendancesAsync.when(
                  data: (attendances) {
                    return ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final emp = employees[index];
                        final existList = _selectedShift != null ? attendances.where((a) => a.employeeId == emp.id && a.shiftId == _selectedShift!.id) : <Attendance>[];
                        final exist = existList.isNotEmpty ? existList.first : null;
                        
                        final dbIsPlanned = exist != null;
                        final isPlanned = _optimisticMap.containsKey(emp.id) ? _optimisticMap[emp.id]! : dbIsPlanned;
                        
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text(emp.name[0])),
                            title: Text(emp.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(emp.roles.map((r) => r.name.toUpperCase()).join(' - ')),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: isPlanned,
                                  activeColor: AppTheme.warningOrange,
                                  onChanged: _selectedShift == null ? null : (val) {
                                    if (val != null) {
                                      _togglePlanification(emp, val, exist, user.tenantId);
                                    }
                                  },
                                ),
                                Text('Planifié', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Erreur: $e'.tr),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur: $e'.tr),
            ),
          ),
          SizedBox(height: 16),

          // Summary of All Shifts
          if (employeesAsync.valueOrNull != null && attendancesAsync.valueOrNull != null && shiftsAsync.valueOrNull != null)
            Card(
              color: Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceCardLight : Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Résumé des planifications (Tous les shifts) :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    ...shiftsAsync.value!.map((shift) {
                      final plannedInShift = employeesAsync.value!.where((emp) {
                        final existList = attendancesAsync.value!.where((a) => a.employeeId == emp.id && a.shiftId == shift.id);
                        if (_selectedShift != null && shift.id == _selectedShift!.id) {
                          final isPlanned = _optimisticMap.containsKey(emp.id) ? _optimisticMap[emp.id]! : existList.isNotEmpty;
                          return isPlanned;
                        }
                        return existList.isNotEmpty;
                      }).toList();
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '${shift.name} : ${plannedInShift.isEmpty ? 'Aucun' : plannedInShift.map((e) => e.name).join(', ')}',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
        ],
      ),
    );
  }
}

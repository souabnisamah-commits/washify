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
import 'package:washify/features/wallet/models/wallet.dart';
import 'package:washify/providers/wallet_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  Shift? _selectedShift;
  
  final Map<String, AttendanceStatus?> _statusMap = {};
  final Map<String, int> _extraHoursMap = {};
  final Map<String, int> _extraMinsMap = {};

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
        _statusMap.clear();
        _extraHoursMap.clear();
        _extraMinsMap.clear();
      });
    }
  }

  void _onShiftChanged(Shift? newShift) {
    setState(() {
      _selectedShift = newShift;
      _statusMap.clear();
      _extraHoursMap.clear();
      _extraMinsMap.clear();
    });
  }

  void _validatePointage(List<Employee> allEmployees, List<Attendance> existingAttendances) async {
    if (_selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez sélectionner un shift'.tr)));
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    final repo = ref.read(hrRepositoryProvider);
    final walletRepo = ref.read(walletRepositoryProvider);

    for (final emp in allEmployees) {
      final existList = existingAttendances.where((a) => a.employeeId == emp.id && a.shiftId == _selectedShift!.id);
      final exist = existList.isNotEmpty ? existList.first : null;

      if (exist == null) continue; // Only process planned employees

      final uiStatus = _statusMap.containsKey(emp.id) ? _statusMap[emp.id] : (exist.status != AttendanceStatus.planned ? exist.status : null);
      final finalStatus = uiStatus ?? AttendanceStatus.planned;
      
      final h = _extraHoursMap[emp.id] ?? (exist.extraHours.truncate());
      final m = _extraMinsMap[emp.id] ?? (((exist.extraHours - exist.extraHours.truncate()) * 60).round());
      final newExtraH = h + (m / 60.0);

      final baseDailyWage = emp.salary;
      final netWage = baseDailyWage + (newExtraH * emp.extraHourRate);
      final finalWage = finalStatus == AttendanceStatus.present ? netWage : 0.0;

      // Check if anything changed
      if (exist.status == finalStatus && exist.extraHours == newExtraH) {
        continue;
      }

      final updatedAtt = exist.copyWith(
        status: finalStatus,
        extraHours: newExtraH,
        netDailyWage: finalWage,
      );

      try {
        await repo.updateAttendance(updatedAtt);

        // Handle wallet transactions
        if (exist.status != AttendanceStatus.present && finalStatus == AttendanceStatus.present) {
          // Becoming present: Add full wage
          await walletRepo.addTransaction(
            WalletTransaction(
              id: '', walletId: '', userId: emp.id, tenantId: user.tenantId, type: WalletTransactionType.salaireJour,
              amount: netWage, balanceBefore: 0, balanceAfter: 0,
              description: 'Salaire du jour: ${_selectedDate.day}/${_selectedDate.month} (Shift: ${_selectedShift!.name})',
              createdAt: DateTime.now(),
            )
          );
        } else if (exist.status == AttendanceStatus.present && finalStatus != AttendanceStatus.present) {
          // Becoming absent/planned: Reverse previous wage
          await walletRepo.addTransaction(
            WalletTransaction(
              id: '', walletId: '', userId: emp.id, tenantId: user.tenantId, type: WalletTransactionType.salaireJour,
              amount: -exist.netDailyWage, balanceBefore: 0, balanceAfter: 0,
              description: 'Annulation salaire du jour: ${_selectedDate.day}/${_selectedDate.month}',
              createdAt: DateTime.now(),
            )
          );
        } else if (exist.status == AttendanceStatus.present && finalStatus == AttendanceStatus.present && exist.extraHours != newExtraH) {
          // Extra hours changed while present: Adjust difference
          final diff = netWage - exist.netDailyWage;
          if (diff != 0) {
            await walletRepo.addTransaction(
              WalletTransaction(
                id: '', walletId: '', userId: emp.id, tenantId: user.tenantId, type: WalletTransactionType.salaireJour,
                amount: diff, balanceBefore: 0, balanceAfter: 0,
                description: 'Ajustement heures sup: ${_selectedDate.day}/${_selectedDate.month}',
                createdAt: DateTime.now(),
              )
            );
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur pour ${emp.name}: $e'.tr)));
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pointage validé avec succès'.tr)));
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
                        decoration: InputDecoration(labelText: 'Date de Pointage'.tr, border: OutlineInputBorder()),
                        child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: shiftsAsync.when(
                      data: (shifts) {
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
                        
                        if (existList.isEmpty) return SizedBox.shrink(); // Only show planned employees

                        final exist = existList.first;
                        
                        final currentStatus = _statusMap.containsKey(emp.id) ? _statusMap[emp.id] : (exist.status != AttendanceStatus.planned ? exist.status : null);

                        final currentH = _extraHoursMap[emp.id] ?? (exist.extraHours.truncate());
                        final currentM = _extraMinsMap[emp.id] ?? (((exist.extraHours - exist.extraHours.truncate()) * 60).round());
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(child: Text(emp.name[0])),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(emp.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text(emp.roles.map((r) => r.name.toUpperCase()).join(' - '), style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    // Extra hours dropdowns
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark ? AppTheme.surfaceCardLight : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          DropdownButton<int>(
                                            value: currentH,
                                            underline: SizedBox(),
                                            items: List.generate(13, (i) => DropdownMenuItem(value: i, child: Text('${i}h'))),
                                            onChanged: (val) => setState(() => _extraHoursMap[emp.id] = val ?? 0),
                                          ),
                                          SizedBox(width: 8),
                                          DropdownButton<int>(
                                            value: currentM,
                                            underline: SizedBox(),
                                            items: [0, 15, 30, 45].map((i) => DropdownMenuItem(value: i, child: Text('${i}m'))).toList(),
                                            onChanged: (val) => setState(() => _extraMinsMap[emp.id] = val ?? 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Presence Toggle
                                    SegmentedButton<AttendanceStatus>(
                                      emptySelectionAllowed: true,
                                      segments: [
                                        ButtonSegment(value: AttendanceStatus.present, label: Text('Présent'.tr), icon: Icon(Icons.check, color: AppTheme.successGreen)),
                                        ButtonSegment(value: AttendanceStatus.absent, label: Text('Absent'.tr), icon: Icon(Icons.close, color: AppTheme.errorRed)),
                                      ],
                                      selected: currentStatus != null ? {currentStatus} : {},
                                      onSelectionChanged: (Set<AttendanceStatus> newSelection) {
                                        setState(() {
                                          _statusMap[emp.id] = newSelection.isNotEmpty ? newSelection.first : null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
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
          // Validate Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
            onPressed: () {
              final emps = employeesAsync.valueOrNull;
              final atts = attendancesAsync.valueOrNull;
              if (emps != null && atts != null) {
                _validatePointage(emps, atts);
              }
            },
            child: Text('VALIDER LE POINTAGE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

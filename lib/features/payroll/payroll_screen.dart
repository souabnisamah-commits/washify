import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/payroll_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/payroll/models/payroll.dart';

class PayrollScreen extends ConsumerStatefulWidget {
  const PayrollScreen({super.key});

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen> {
  Future<void> _approve(Payroll payroll) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final repo = ref.read(payrollRepositoryProvider);
    await repo.approvePayroll(payroll.id, user.name);

    final selectedStation = ref.read(selectedStationProvider);
    if (selectedStation != null) {
      ref.invalidate(payrollStreamProvider(selectedStation.id));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fiche de paie approuvée'.tr)),
      );
    }
  }

  Future<void> _markPaid(Payroll payroll) async {
    final repo = ref.read(payrollRepositoryProvider);
    await repo.markAsPaid(payroll.id);

    final selectedStation = ref.read(selectedStationProvider);
    if (selectedStation != null) {
      ref.invalidate(payrollStreamProvider(selectedStation.id));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fiche de paie payée'.tr)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = ref.watch(selectedStationProvider);

    if (selectedStation == null) {
      return Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station.')),
      );
    }

    final payrollStream = ref.watch(payrollStreamProvider(selectedStation.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Fiches de Paie - ${selectedStation.name}'.tr),
      ),
      body: payrollStream.when(
        data: (payrolls) {
          if (payrolls.isEmpty) {
            return Center(
              child: Text('Aucun bulletin généré.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: payrolls.length,
            itemBuilder: (context, index) {
              final pay = payrolls[index];

              Color statusColor = AppTheme.textHint;
              switch (pay.status) {
                case AppConstants.payrollApproved:
                  statusColor = AppTheme.warningOrange;
                  break;
                case AppConstants.payrollPaid:
                  statusColor = AppTheme.successGreen;
                  break;
              }

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pay.employeeName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pay.status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Période: ${pay.period}'.tr),
                      Text('Base: ${pay.baseSalary} DT | Comm: ${pay.commissionTotal} DT'.tr),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Net à Payer: ${pay.netAmount} DT',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCyan, fontSize: 16),
                          ),
                          Row(
                            children: [
                              if (pay.status == AppConstants.payrollPending)
                                TextButton(
                                  onPressed: () => _approve(pay),
                                  child: Text('Approuver'.tr),
                                ),
                              if (pay.status == AppConstants.payrollApproved)
                                TextButton(
                                  onPressed: () => _markPaid(pay),
                                  child: Text('Payer'.tr),
                                ),
                            ],
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
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
    );
  }
}

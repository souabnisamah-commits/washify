import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/providers/ticket_provider.dart';

class RendementReportScreen extends ConsumerStatefulWidget {
  const RendementReportScreen({super.key});

  @override
  ConsumerState<RendementReportScreen> createState() => _RendementReportScreenState();
}

class _RendementReportScreenState extends ConsumerState<RendementReportScreen> {
  String _period = '24h'; // '24h', '1w', '1m'

  DateTime _getStartDate() {
    final now = DateTime.now();
    if (_period == '24h') {
      return DateTime(now.year, now.month, now.day);
    } else if (_period == '1w') {
      return now.subtract(const Duration(days: 7));
    } else {
      return DateTime(now.year, now.month - 1, now.day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.tenantId.isEmpty) return Center(child: Text('Aucune station'.tr));

    final employeesAsync = ref.watch(employeesStreamProvider(user.tenantId));

    // We can fetch all tickets for the station in the date range to calculate rendement
    // For a real app, a dedicated provider/backend aggregation would be better.
    // For now we'll fetch tickets by station and filter in memory since we are on client side.
    
    final ticketsAsync = ref.watch(ticketsByStationProvider((stationId: user.tenantId, status: 'paye')));

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rendement par Employé', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _period,
                items: [
                  DropdownMenuItem(value: '24h', child: Text('Aujourd\'hui (24h)')),
                  DropdownMenuItem(value: '1w', child: Text('7 derniers jours'.tr)),
                  DropdownMenuItem(value: '1m', child: Text('Ce mois-ci'.tr)),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _period = val);
                },
              ),
            ],
          ),
          SizedBox(height: 16),

          Expanded(
            child: employeesAsync.when(
              data: (employees) {
                if (employees.isEmpty) return Center(child: Text('Aucun employé enregistré.'.tr));
                
                return ticketsAsync.when(
                  data: (tickets) {
                    final startDate = _getStartDate();
                    // Filter tickets by date
                    final filteredTickets = tickets.where((t) => t.createdAt.isAfter(startDate)).toList();

                    return ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final emp = employees[index];
                        
                        // Calculate stats for this employee
                        final empTickets = filteredTickets.where((t) => t.assignedWorkerId == emp.id).toList();
                        final ticketCount = empTickets.length;
                        final caGenere = empTickets.fold<double>(0, (sum, t) => sum + t.montant);

                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.accentCyan,
                              child: Icon(Icons.bar_chart, color: Colors.white),
                            ),
                            title: Text(emp.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(emp.roles.map((r) => r.name.toUpperCase()).join(' - ')),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$ticketCount Tickets', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                                Text('${caGenere.toStringAsFixed(2)} DT générés', style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Erreur tickets: $e'.tr),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur employés: $e'.tr),
            ),
          ),
        ],
      ),
    );
  }
}

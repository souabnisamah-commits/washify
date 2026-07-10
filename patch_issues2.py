import os
import re

# 1. Patch Wallet Screen
wallet_path = 'lib/features/wallet/wallet_screen.dart'
with open(wallet_path, 'r', encoding='utf-8') as f:
    wallet_code = f.read()

# I will just replace the `return Card(` inside `itemBuilder` with a wrapped try-catch.
new_item_builder = """                  itemBuilder: (context, index) {
                    try {
                      final tx = list[index];
                      final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt);
                      final isCredit = tx.type == WalletTransactionType.bonus || tx.type == WalletTransactionType.gainTicket || tx.type == WalletTransactionType.salaireJour;

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCredit ? AppTheme.successGreen.withValues(alpha: 0.15) : AppTheme.errorRed.withValues(alpha: 0.15),
                            child: Icon(
                              isCredit ? Icons.add : Icons.remove,
                              color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
                            ),
                          ),
                          title: Text(tx.description, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(dateStr),
                          trailing: Text(
                            '${isCredit ? "+" : "-"}${tx.amount.toStringAsFixed(2)} DT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
                            ),
                          ),
                        ),
                      );
                    } catch (e) {
                      return Card(child: ListTile(title: Text('Erreur transaction'), subtitle: Text(e.toString())));
                    }
                  },"""

# Replace the whole item builder
wallet_code = re.sub(
    r'itemBuilder:\s*\(context,\s*index\)\s*\{.*?\n\s*},\n',
    new_item_builder + "\n",
    wallet_code,
    flags=re.DOTALL
)

with open(wallet_path, 'w', encoding='utf-8') as f:
    f.write(wallet_code)

# 2. Patch Dashboards
dashboards = [
    'lib/features/dashboard/worker_dashboard.dart',
    'lib/features/dashboard/cashier_dashboard.dart',
    'lib/features/dashboard/multi_role_dashboards.dart'
]

helper = """
  String _getStationName(WidgetRef ref, String stationId) {
    if (stationId.isEmpty) return '';
    final stationAsync = ref.watch(stationByIdProvider(stationId));
    return stationAsync.value?.name ?? '';
  }

  void _showPlanificationBottomSheet(BuildContext context, WidgetRef ref, String stationId, String userId) {
    final employeeAsync = ref.watch(employeeByUserIdProvider(userId));
    final employee = employeeAsync.value;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        if (employee == null) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final attendancesAsync = ref.watch(employeeAttendancesProvider((stationId: stationId, employeeId: employee.id)));
        final shiftsAsync = ref.watch(shiftsStreamProvider(stationId));
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ma Planification',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: attendancesAsync.when(
                  data: (attendances) {
                    final upcoming = attendances.where((a) => a.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();
                    upcoming.sort((a, b) => a.date.compareTo(b.date));
                    
                    if (upcoming.isEmpty) {
                      return const Center(child: Text('Aucune planification à venir.'));
                    }
                    
                    return ListView.builder(
                      itemCount: upcoming.length,
                      itemBuilder: (context, index) {
                        final a = upcoming[index];
                        final dateStr = DateFormat('dd/MM/yyyy').format(a.date);
                        
                        return shiftsAsync.when(
                          data: (shifts) {
                            final shift = shifts.firstWhere((s) => s.id == a.shiftId, orElse: () => Shift(id: '', stationId: '', name: 'Inconnu', startTime: '', endTime: '', createdAt: DateTime.now()));
                            return ListTile(
                              leading: const Icon(Icons.calendar_month, color: Colors.blueAccent),
                              title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${shift.name} (${shift.startTime} - ${shift.endTime})'),
                              trailing: Text(a.status == AttendanceStatus.planned ? 'Planifié' : 'Présent', style: TextStyle(color: a.status == AttendanceStatus.planned ? Colors.orange : Colors.green)),
                            );
                          },
                          loading: () => const ListTile(title: Text('Chargement...')),
                          error: (e, s) => ListTile(title: Text('Erreur...')),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erreur...')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
"""

imports_to_add = """
import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/features/hr/providers/hr_provider.dart';
import 'package:washify/features/hr/models/attendance.dart';
import 'package:washify/features/hr/models/shift.dart';
import 'package:washify/providers/theme_provider.dart';
"""

for p in dashboards:
    with open(p, 'r', encoding='utf-8') as f:
        code = f.read()

    # Imports
    if "import 'package:washify/providers/theme_provider.dart';" not in code:
        code = code.replace("import 'package:intl/intl.dart';", f"import 'package:intl/intl.dart';{imports_to_add}")

    # Inject helper
    if "_getStationName" not in code:
        if "class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {" in code:
            code = code.replace("class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {", "class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {" + helper)
        if "class _CashierDashboardState extends ConsumerState<CashierDashboard> {" in code:
            code = code.replace("class _CashierDashboardState extends ConsumerState<CashierDashboard> {", "class _CashierDashboardState extends ConsumerState<CashierDashboard> {" + helper)
        if "class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {" in code:
            code = code.replace("class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {", "class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {" + helper)

    # Patch Title
    code = re.sub(
        r"text:\s*'Bienvenue \$\{user\.name\}[^']*'\.tr,",
        r"text: 'Bienvenue ${user.name}, dans votre Espace ${_getStationName(ref, user.stationId ?? '')}'.tr,",
        code
    )

    # Patch Planification
    code = re.sub(
        r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(content: Text\('Le module de planification sera bientôt disponible\.'\)\),\s*\);",
        r"_showPlanificationBottomSheet(context, ref, user.stationId!, user.id);",
        code
    )

    # Patch Zero Balance
    code = code.replace(
        "final walletStream = ref.watch(walletStreamProvider(user.id));",
        """final employeeAsync = ref.watch(employeeByUserIdProvider(user.id));
    final walletStream = ref.watch(walletStreamProvider(employeeAsync.value?.id ?? user.id));"""
    )
    
    with open(p, 'w', encoding='utf-8') as f:
        f.write(code)

print("All patched")

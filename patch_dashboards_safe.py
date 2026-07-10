import os

dashboards = [
    'lib/features/dashboard/worker_dashboard.dart',
    'lib/features/dashboard/cashier_dashboard.dart',
    'lib/features/dashboard/multi_role_dashboards.dart'
]

imports = """import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/features/hr/providers/hr_provider.dart';
import 'package:washify/features/hr/models/attendance.dart';
import 'package:washify/features/hr/models/shift.dart';
"""

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ma Planification',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
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

for path in dashboards:
    with open(path, 'r', encoding='utf-8') as f:
        code = f.read()

    if "import 'package:washify/providers/station_provider.dart';" not in code:
        code = code.replace("import 'package:intl/intl.dart';", f"import 'package:intl/intl.dart';\n{imports}")

    if "_getStationName" not in code:
        if "class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {" in code:
            code = code.replace("class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {", "class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {" + helper)
        if "class _CashierDashboardState extends ConsumerState<CashierDashboard> {" in code:
            code = code.replace("class _CashierDashboardState extends ConsumerState<CashierDashboard> {", "class _CashierDashboardState extends ConsumerState<CashierDashboard> {" + helper)
        if "class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {" in code:
            code = code.replace("class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {", "class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {" + helper)

    # Replace Title logic. Note that it depends on the exact string I generated earlier in `revamp_*`.
    # `text: 'Bienvenue ${user.name}, Espace Ouvrier'.tr,`
    # `text: 'Bienvenue ${user.name}, Espace Caissier'.tr,`
    # `text: 'Bienvenue ${user.name}, Espace Ouvrier & Caissier'.tr,`
    if "Bienvenue ${user.name}, Espace Ouvrier'.tr" in code:
        code = code.replace(
            "text: 'Bienvenue ${user.name}, Espace Ouvrier'.tr,",
            "text: 'Bienvenue ${user.name}, dans votre Espace ${_getStationName(ref, user.stationId ?? '')}'.tr,"
        )
    if "Bienvenue ${user.name}, Espace Caissier'.tr" in code:
        code = code.replace(
            "text: 'Bienvenue ${user.name}, Espace Caissier'.tr,",
            "text: 'Bienvenue ${user.name}, dans votre Espace ${_getStationName(ref, user.stationId ?? '')}'.tr,"
        )
    if "Bienvenue ${user.name}, Espace Ouvrier & Caissier'.tr" in code:
        code = code.replace(
            "text: 'Bienvenue ${user.name}, Espace Ouvrier & Caissier'.tr,",
            "text: 'Bienvenue ${user.name}, dans votre Espace ${_getStationName(ref, user.stationId ?? '')}'.tr,"
        )

    # Replace Planification Snackbar
    target_snackbar = "ScaffoldMessenger.of(context).showSnackBar(\n                  SnackBar(content: Text('Le module de planification sera bientôt disponible.')),\n                );"
    if target_snackbar in code:
        code = code.replace(target_snackbar, "_showPlanificationBottomSheet(context, ref, user.stationId!, user.id);")

    # Replace Wallet logic
    # In `revamp_*`, it says `final walletStream = ref.watch(walletStreamProvider(user.id));`
    # For `multi_role_dashboards.dart`, it says `final walletStream = ref.watch(walletStreamProvider(user.id));`
    
    target_wallet1 = "final walletStream = ref.watch(walletStreamProvider(user.id));"
    replacement_wallet1 = "final employeeAsync = ref.watch(employeeByUserIdProvider(user.id));\n    final walletStream = ref.watch(walletStreamProvider(employeeAsync.value?.id ?? user.id));"
    
    if target_wallet1 in code:
        code = code.replace(target_wallet1, replacement_wallet1)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(code)

print("dashboards patched")

import os
import re

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
                          error: (e, s) => const ListTile(title: Text('Erreur...')),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const Center(child: Text('Erreur...')),
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

    # Clean missing methods
    if "_getStationName" not in code:
        if "class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {" in code:
            code = code.replace("class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {", "class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {" + helper)
        if "class _CashierDashboardState extends ConsumerState<CashierDashboard> {" in code:
            code = code.replace("class _CashierDashboardState extends ConsumerState<CashierDashboard> {", "class _CashierDashboardState extends ConsumerState<CashierDashboard> {" + helper)
        if "class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {" in code:
            code = code.replace("class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {", "class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {" + helper)

    # Clean Marquee safely by matching the generic structure of the title block.
    # The title block is usually `title: SizedBox( ... ),`
    # We will replace it with a clean `ColorAnimatedTitle` wrapped in a `SizedBox`.
    
    # We will just replace everything from `title: SizedBox(` up to the matching `actions:` or the end of AppBar.
    # We can use regex to match `title: [\s\S]*?actions: \[` and replace it.
    
    title_text = ""
    if "worker_dashboard" in path:
        title_text = "'Bienvenue ${user.name}, dans votre Espace ${_getStationName(ref, user.stationId ?? '')}'.tr"
    elif "cashier_dashboard" in path:
        title_text = "'Bienvenue ${user.name}, dans votre Espace ${_getStationName(ref, user.stationId ?? '')}'.tr"
    else:
        title_text = "'Bienvenue ${employeeAsync.value?.name ?? user.name}, dans votre Espace ${_getStationName(ref, user.stationId ?? '')}'.tr"
    
    # Let's replace the whole `title: SizedBox( ... ),` with `title: ColorAnimatedTitle(...)`
    # Actually, a simpler regex: `title: SizedBox\([\s\S]*?child: Marquee[\s\S]*?velocity: 50\.0,[\s\S]*?\),[\s\S]*?\),` is too brittle.
    # Let's just match `title: SizedBox\([\s\S]*?actions: \[`.
    
    pattern = r"title:\s*SizedBox\([\s\S]*?actions:\s*\["
    replacement = f"""title: ColorAnimatedTitle(
          text: {title_text},
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: ["""
    code = re.sub(pattern, replacement, code)
    
    # What if it's inside Shimmer in cashier?
    pattern2 = r"title:\s*SizedBox\([\s\S]*?child:\s*Shimmer\.fromColors\([\s\S]*?actions:\s*\["
    code = re.sub(pattern2, replacement, code)
    
    # Also fix imports
    if "import 'package:marquee/marquee.dart';" in code:
        code = code.replace("import 'package:marquee/marquee.dart';", "")
    if "import 'package:washify/core/widgets/color_animated_title.dart';" not in code:
        code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:washify/core/widgets/color_animated_title.dart';")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(code)

print("Final safe dashboard patch applied")

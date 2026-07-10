import os
import re

# 1. Patch Wallet Screen
wallet_path = 'lib/features/wallet/wallet_screen.dart'
with open(wallet_path, 'r', encoding='utf-8') as f:
    wallet_code = f.read()

# Add try/catch in itemBuilder
item_builder_pattern = re.compile(r'(itemBuilder:\s*\(context,\s*index\)\s*\{)(.*?)(return Card\()', re.DOTALL)

def replace_item_builder(match):
    prefix = match.group(1)
    body = match.group(2)
    return_card = match.group(3)
    new_code = f'''{prefix}
                    try {{
{body}{return_card}'''
    return new_code

wallet_code = item_builder_pattern.sub(replace_item_builder, wallet_code)

# Add closing try/catch
return_card_end_pattern = re.compile(r'(\s*\),\s*\n\s*\);)(?=\s*\},)', re.DOTALL)
def replace_return_card_end(match):
    return f"{match.group(1)}\n                    }} catch (e) {{\n                      return Card(child: ListTile(title: Text('Erreur transaction')));\n                    }}"

wallet_code = return_card_end_pattern.sub(replace_return_card_end, wallet_code)

with open(wallet_path, 'w', encoding='utf-8') as f:
    f.write(wallet_code)

# 2. Patch Dashboards
dashboards = [
    'lib/features/dashboard/worker_dashboard.dart',
    'lib/features/dashboard/cashier_dashboard.dart',
    'lib/features/dashboard/multi_role_dashboards.dart'
]

def patch_dashboard(path):
    with open(path, 'r', encoding='utf-8') as f:
        code = f.read()

    # Add missing imports
    imports_to_add = """import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/features/hr/providers/hr_provider.dart';
import 'package:washify/features/hr/models/attendance.dart';
import 'package:washify/features/hr/models/shift.dart';
"""
    if "import 'package:washify/providers/station_provider.dart';" not in code:
        code = code.replace("import 'package:intl/intl.dart';", f"import 'package:intl/intl.dart';\n{imports_to_add}")

    # Patch Title
    code = re.sub(
        r"text:\s*'Bienvenue \$\{user\.name\}[^']*'\.tr,",
        r"text: 'Bienvenue ${user.name}, dans votre Espace ${_getStationName(ref, user.stationId ?? '')}'.tr,",
        code
    )

    # Inject helper methods in the state class if not exist
    if "_getStationName" not in code:
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
                            final shift = shifts.firstWhere((s) => s.id == a.shiftId, orElse: () => const Shift(id: '', stationId: '', name: 'Inconnu', startTime: '', endTime: '', createdAt: null) as Shift);
                            return ListTile(
                              leading: const Icon(Icons.calendar_month, color: Colors.blueAccent),
                              title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${shift.name} (${shift.startTime} - ${shift.endTime})'),
                              trailing: Text(a.status == AttendanceStatus.planned ? 'Planifié' : 'Présent', style: TextStyle(color: a.status == AttendanceStatus.planned ? Colors.orange : Colors.green)),
                            );
                          },
                          loading: () => const ListTile(title: Text('Chargement...')),
                          error: (e, s) => ListTile(title: Text('Erreur: $e')),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erreur: $e')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
"""
        code = re.sub(r'class _(.*?)DashboardState extends ConsumerState<(.*?)> \{', r'class _\1DashboardState extends ConsumerState<\2> {\n' + helper, code)

    # Fix Planification Button
    code = re.sub(
        r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(content: Text\('Le module de planification sera bientôt disponible\.'\)\),\s*\);",
        r"_showPlanificationBottomSheet(context, ref, user.stationId!, user.id);",
        code
    )

    # Fix Wallet Zero Balance issue
    # Replace `final walletStream = ref.watch(walletStreamProvider(user.id));` with fetching employee id.
    # Since we can't `ref.watch` conditionally easily in a neat way without a provider, we'll use a hack or just build the wallet stream provider directly inside a Consumer or just use `ref.watch(employeeByUserIdProvider(user.id))` and `walletStreamProvider(employee?.id ?? user.id)`.
    # Let's see: `walletStreamProvider` requires `String`. If employee is null, we can pass `user.id`.
    code = code.replace(
        "final walletStream = ref.watch(walletStreamProvider(user.id));",
        """final employeeAsync = ref.watch(employeeByUserIdProvider(user.id));
    final walletStream = ref.watch(walletStreamProvider(employeeAsync.value?.id ?? user.id));"""
    )
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(code)

for p in dashboards:
    patch_dashboard(p)

print("Patch applied successfully.")

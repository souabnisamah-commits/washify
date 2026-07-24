import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/audit_provider.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:flutter/services.dart';
import 'package:washify/features/station/models/station.dart';

class AuditDashboardTab extends ConsumerStatefulWidget {
  const AuditDashboardTab({super.key});

  @override
  ConsumerState<AuditDashboardTab> createState() => _AuditDashboardTabState();
}

class _AuditDashboardTabState extends ConsumerState<AuditDashboardTab> {
  String? _selectedStationId;
  bool _simulateCrash = false;

  @override
  Widget build(BuildContext context) {
    if (_simulateCrash) {
      throw Exception('TEST CRASH DÉLIBÉRÉ POUR VÉRIFICATION (Généré par l\'admin)');
    }
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return const SizedBox.shrink();

    final isAdmin = currentUser.roles.any((r) => r == UserRole.admin);
    final targetStationId = isAdmin ? _selectedStationId : currentUser.tenantId;

    final logsStream = ref.watch(auditLogsStreamProvider((stationId: targetStationId, limit: 1000)));

    final stationsAsync = isAdmin 
        ? ref.watch(allStationsProvider) 
        : const AsyncValue<List<Station>>.data([]);

    return Column(
      children: [
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: stationsAsync.when(
              data: (stations) {
                if (stations.isEmpty) return const Text('Aucune station disponible', style: TextStyle(color: AppTheme.textHint));
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sélectionner une station (Lavage)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                    filled: true,
                    fillColor: AppTheme.surfaceCard,
                  ),
                  initialValue: _selectedStationId,
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Système (Erreurs Globales)'),
                    ),
                    ...stations.map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedStationId = val;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Erreur: $e'),
            ),
          ),
          
        Expanded(
          child: targetStationId == null && isAdmin
              ? const Center(child: Text('Veuillez sélectionner une station pour voir le tableau de bord.', style: TextStyle(color: AppTheme.textHint)))
              : logsStream.when(
                  data: (logs) {
                    final today = DateTime.now();
                    final todayLogs = logs.where((l) => l.createdAt.year == today.year && l.createdAt.month == today.month && l.createdAt.day == today.day).toList();
                    
                    final crashes = todayLogs.where((l) => l.severity == 'critical').length;
                    final logins = todayLogs.where((l) => l.action == 'login').length;
                    final warnings = todayLogs.where((l) => l.severity == 'warning').length;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Aujourd\'hui', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                              if (isAdmin)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _simulateCrash = true;
                                    });
                                  },
                                  icon: const Icon(Icons.bug_report),
                                  label: const Text('Simuler Crash'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  'Crash (Critiques)',
                                  crashes.toString(),
                                  Icons.bug_report,
                                  Colors.redAccent,
                                  onTap: () => _showCrashesDialog(
                                    context,
                                    todayLogs.where((l) => l.severity == 'critical').toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildKpiCard(
                                  'Connexions',
                                  logins.toString(),
                                  Icons.login,
                                  AppTheme.successGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildKpiCard(
                                  'Avertissements',
                                  warnings.toString(),
                                  Icons.warning,
                                  Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('Vue Globale (Bientôt)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.bar_chart, size: 64, color: AppTheme.textHint),
                                SizedBox(height: 16),
                                Text('Les graphiques et statistiques détaillées seront intégrés ici dans une future mise à jour.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textHint)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erreur: $e')),
                ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCrashesDialog(BuildContext context, List logs) {
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun crash aujourd\'hui 🎉'), backgroundColor: AppTheme.successGreen),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          title: const Text('Rapports de Crash (Aujourd\'hui)', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(color: AppTheme.dividerColor),
              itemBuilder: (context, index) {
                final log = logs[index];
                final dateStr = '${log.createdAt.day.toString().padLeft(2, '0')}/${log.createdAt.month.toString().padLeft(2, '0')}/${log.createdAt.year} ${log.createdAt.hour.toString().padLeft(2, '0')}:${log.createdAt.minute.toString().padLeft(2, '0')}';
                
                final report = '''
--- RAPPORT TECHNIQUE DE CRASH ---
Date: $dateStr
Utilisateur: ${log.userName} (ID: ${log.userId})
Station ID: ${log.tenantId}
Module: ${log.module}
Action: ${log.action}

Description:
${log.description}

Stack Trace:
${log.newData?['stackTrace'] ?? 'Non spécifié'}
''';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Heure: $dateStr', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(log.description, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copier le rapport technique'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                        ),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: report));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Rapport technique copié !'),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer', style: TextStyle(color: AppTheme.textHint)),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/audit_provider.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:intl/intl.dart';

class AuditJournalTab extends ConsumerStatefulWidget {
  const AuditJournalTab({super.key});

  @override
  ConsumerState<AuditJournalTab> createState() => _AuditJournalTabState();
}

class _AuditJournalTabState extends ConsumerState<AuditJournalTab> {
  String? _selectedStationId;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return const SizedBox.shrink();

    final isAdmin = currentUser.roles.any((r) => r == UserRole.admin);
    final targetStationId = isAdmin ? _selectedStationId : currentUser.tenantId;

    final logsStream = ref.watch(auditLogsStreamProvider((stationId: targetStationId, limit: 100)));

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
                  items: stations.map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name),
                  )).toList(),
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
              ? const Center(child: Text('Veuillez sélectionner une station pour voir le journal.', style: TextStyle(color: AppTheme.textHint)))
              : logsStream.when(
                  data: (logs) {
                    if (logs.isEmpty) {
                      return const Center(
                        child: Text('Aucun journal d\'audit disponible.', style: TextStyle(color: AppTheme.textHint)),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(log.createdAt);
                        final isError = log.severity == 'critical' || log.action == 'crash' || log.module == 'system';
                        final isWarning = log.severity == 'warning';
                        final isLogin = log.action == 'login' || log.action == 'logout';

                        Color cardColor = isError ? Colors.red.withValues(alpha: 0.1) : (isWarning ? Colors.orange.withValues(alpha: 0.1) : Colors.transparent);
                        Color borderColor = isError ? Colors.red.withValues(alpha: 0.5) : (isWarning ? Colors.orange.withValues(alpha: 0.5) : Colors.transparent);
                        Color iconColor = isError ? Colors.red : (isWarning ? Colors.orange : AppTheme.accentCyan);
                        IconData icon = isError ? Icons.bug_report : (isWarning ? Icons.warning : (isLogin ? Icons.login : Icons.history));

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: borderColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          icon,
                                          color: iconColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          log.userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            color: isError ? Colors.red.shade300 : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Module: ${log.module} | Action: ${log.action}',
                                  style: TextStyle(
                                    color: isError ? Colors.redAccent : AppTheme.accentCyan, 
                                    fontSize: 13, 
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  log.description,
                                  style: TextStyle(
                                    color: isError ? Colors.red.shade100 : AppTheme.textSecondary, 
                                    fontSize: 14,
                                  ),
                                ),
                                if (isError && log.newData?['stackTrace'] != null) ...[
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
                                      onPressed: () {
                                        final report = '''
--- RAPPORT TECHNIQUE DE CRASH ---
Date: $dateStr
Utilisateur: ${log.userName} (ID: ${log.userId})
Station ID: ${log.tenantId}
Module: ${log.module}
Action: ${log.action}

Description:
${log.description}

Détails de l'erreur:
${log.description}

Stack Trace:
${log.newData?['stackTrace'] ?? 'Non spécifié'}

Device Info:
${log.deviceInfo ?? 'Non spécifié'}
----------------------------------
''';
                                        Clipboard.setData(ClipboardData(text: report));
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Rapport technique copié dans le presse-papier. Collez-le à votre agent IA.')),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erreur: $e')),
                ),
        ),
      ],
    );
  }
}

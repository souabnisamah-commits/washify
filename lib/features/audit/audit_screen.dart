import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/audit_provider.dart';
import 'package:intl/intl.dart';

class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsStream = ref.watch(auditLogsStreamProvider((stationId: null, limit: 100)));

    return Scaffold(
      appBar: AppBar(
        title: Text('Journaux d\'Audit'),
      ),
      body: logsStream.when(
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Text('Aucun journal d\'audit disponible.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(log.createdAt);

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
                            log.userName,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(color: AppTheme.textHint, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Module: ${log.module} | Action: ${log.action}',
                        style: TextStyle(color: AppTheme.accentCyan, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6),
                      Text(
                        log.description,
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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

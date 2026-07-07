import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/inventory_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:intl/intl.dart';

class InventoryHistoryScreen extends ConsumerWidget {
  const InventoryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final selectedStation = ref.watch(selectedStationProvider);

    final stationId = user?.role == UserRole.patron
        ? selectedStation?.id
        : user?.stationId;

    if (stationId == null) {
      return Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station.')),
      );
    }

    final inventoriesAsync = ref.watch(inventoriesStreamProvider(stationId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Inventaires'.tr),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/patron/inventory/new'),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Faire un Inventaire', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: inventoriesAsync.when(
        data: (inventories) {
          if (inventories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppTheme.textHint.withValues(alpha: 0.3)),
                  SizedBox(height: 16),
                  Text(
                    'Aucun inventaire enregistré.',
                    style: TextStyle(color: AppTheme.textHint, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cliquez sur le bouton ci-dessous pour démarrer.',
                    style: TextStyle(color: AppTheme.textHint, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: inventories.length,
            itemBuilder: (context, index) {
              final inv = inventories[index];
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(inv.createdAt);
              
              // Calculate discrepancies
              int discrepanciesCount = 0;
              for (final item in inv.items) {
                if (item.difference != 0) {
                  discrepanciesCount++;
                }
              }

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => context.push('/patron/inventory/report/${inv.id}'),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Inventaire du $dateStr',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: discrepanciesCount > 0
                                    ? AppTheme.warningOrange.withValues(alpha: 0.15)
                                    : AppTheme.successGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                discrepanciesCount > 0 ? '$discrepanciesCount Écarts' : 'Conforme',
                                style: TextStyle(
                                  color: discrepanciesCount > 0 ? AppTheme.warningOrange : AppTheme.successGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Effectué par : ${inv.performedByName}'.tr),
                        Text('Nombre d\'articles audités : ${inv.items.length}'),
                        if (inv.notes.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            'Notes : ${inv.notes}',
                            style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textSecondary, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
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

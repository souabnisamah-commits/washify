import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/inventory_provider.dart';
import 'package:intl/intl.dart';

class InventoryReportScreen extends ConsumerWidget {
  final String inventoryId;

  const InventoryReportScreen({
    super.key,
    required this.inventoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryByIdProvider(inventoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Rapport d\'Inventaire'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/patron/inventory'),
        ),
      ),
      body: inventoryAsync.when(
        data: (inventory) {
          if (inventory == null) {
            return Center(child: Text('Rapport d\'inventaire introuvable.'));
          }

          final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(inventory.date);

          // Calculations
          int discrepanciesCount = 0;

          for (final item in inventory.items) {
            if (item.difference != 0) {
              discrepanciesCount++;
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Inventaire du $dateStr',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                            ),
                            Icon(
                              discrepanciesCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              color: discrepanciesCount > 0 ? AppTheme.warningOrange : AppTheme.successGreen,
                              size: 28,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text('Effectué par : ${inventory.performedByName}', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 6),
                        Text('Rôle : Auditeur Station', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        if (inventory.notes.isNotEmpty) ...[
                          SizedBox(height: 12),
                          Text('Notes de l\'auditeur :', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCardLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              inventory.notes,
                              style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Metrics grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Total Produits',
                        '${inventory.items.length}',
                        Icons.category_outlined,
                        AppTheme.accentCyan,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Écarts Trouvés',
                        '$discrepanciesCount',
                        Icons.difference_outlined,
                        discrepanciesCount > 0 ? AppTheme.warningOrange : AppTheme.successGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Audited Items Table
                Text(
                  'Détail des Écarts et Résultats',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),

                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inventory.items.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = inventory.items[index];
                      final hasDiff = item.difference != 0;

                      final expectedStr = item.expectedQuantity % 1 == 0
                          ? item.expectedQuantity.toInt().toString()
                          : item.expectedQuantity.toStringAsFixed(1);
                      final actualStr = item.actualQuantity % 1 == 0
                          ? item.actualQuantity.toInt().toString()
                          : item.actualQuantity.toStringAsFixed(1);
                      final diffStr = item.difference > 0
                          ? '+${item.difference % 1 == 0 ? item.difference.toInt() : item.difference.toStringAsFixed(1)}'
                          : (item.difference % 1 == 0 ? item.difference.toInt().toString() : item.difference.toStringAsFixed(1));

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(item.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Attendu : $expectedStr  |  Compté : $actualStr',
                          style: TextStyle(color: AppTheme.textHint),
                        ),
                        trailing: hasDiff
                            ? Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: item.difference > 0
                                      ? AppTheme.successGreen.withValues(alpha: 0.15)
                                      : AppTheme.errorRed.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  diffStr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: item.difference > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                                  ),
                                ),
                              )
                            : Icon(Icons.check_circle_outline, color: AppTheme.successGreen),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),

                // Return button
                ElevatedButton(
                  onPressed: () => context.go('/patron/inventory'),
                  child: Text('Fermer le Rapport'.tr),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

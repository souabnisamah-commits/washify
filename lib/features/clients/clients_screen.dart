import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/clients/client_details_screen.dart';
import 'package:washify/features/clients/models/client.dart';
import 'package:washify/features/clients/models/client_vehicle.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/repositories/client_repository.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  void _showAddClientDialog() {
    final formKey = GlobalKey<FormState>();
    String companyName = '';
    String contactName = '';
    String taxId = '';
    String phone = '';
    String thresholdStr = '0';
    String initialVehicle = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.business_outlined, color: AppTheme.accentCyan),
              const SizedBox(width: 10),
              Text('Nouveau Compte Client B2B'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nom de la Société (ou Client) *'.tr, prefixIcon: const Icon(Icons.business, color: AppTheme.accentCyan)),
                    validator: (v) => v == null || v.isEmpty ? 'Requis'.tr : null,
                    onSaved: (v) => companyName = v!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nom du Responsable'.tr, prefixIcon: const Icon(Icons.person, color: AppTheme.accentCyan)),
                    onSaved: (v) => contactName = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Matricule Fiscale'.tr, prefixIcon: const Icon(Icons.receipt, color: AppTheme.accentCyan)),
                    onSaved: (v) => taxId = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Téléphone'.tr, prefixIcon: const Icon(Icons.phone, color: AppTheme.accentCyan)),
                    keyboardType: TextInputType.phone,
                    onSaved: (v) => phone = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Seuil d\'alerte (DT)'.tr, prefixIcon: const Icon(Icons.warning_amber_rounded, color: AppTheme.accentCyan)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    initialValue: '500',
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Invalide'.tr : null,
                    onSaved: (v) => thresholdStr = v!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Immatriculation initiale (Optionnel)'.tr, prefixIcon: const Icon(Icons.directions_car, color: AppTheme.accentCyan)),
                    onSaved: (v) => initialVehicle = v ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final user = ref.read(currentUserProvider);
                  if (user == null) return;

                  final newClient = Client(
                    id: '',
                    tenantId: user.stationId!,
                    companyName: companyName,
                    contactName: contactName,
                    taxId: taxId,
                    phone: phone,
                    alertThreshold: double.parse(thresholdStr),
                    currentBalance: 0.0,
                    vehicles: initialVehicle.isNotEmpty ? [ClientVehicle(plate: initialVehicle.toUpperCase())] : [],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  await ref.read(clientRepositoryProvider).createClient(newClient);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.white),
              child: Text('Créer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.stationId == null) {
      return Scaffold(
        body: Center(child: Text('Erreur d\'authentification'.tr)),
      );
    }

    final clientsAsync = ref.watch(clientsStreamProvider(user.stationId!));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comptes Clients B2B'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClientDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Nouveau Client'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.accentCyan,
      ),
      body: clientsAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined, size: 54, color: AppTheme.textHint.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun compte client B2B n\'a été créé.'.tr,
                    style: const TextStyle(fontSize: 15, color: AppTheme.textHint),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              final isOverThreshold = client.alertThreshold > 0 && client.currentBalance >= client.alertThreshold;
              final bool hasBalance = client.currentBalance > 0;

              final cardBg = isOverThreshold
                  ? (isDarkMode ? AppTheme.errorRed.withValues(alpha: 0.15) : Colors.red.shade50)
                  : Theme.of(context).colorScheme.surface;

              final titleColor = isOverThreshold
                  ? AppTheme.errorRed
                  : Theme.of(context).colorScheme.onSurface;

              return Card(
                elevation: isOverThreshold ? 4 : 2,
                margin: const EdgeInsets.only(bottom: 12),
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: isOverThreshold
                      ? BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.6), width: 1.5)
                      : BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2), width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isOverThreshold ? AppTheme.errorRed.withValues(alpha: 0.15) : AppTheme.primaryBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business,
                      color: isOverThreshold ? AppTheme.errorRed : AppTheme.accentCyan,
                    ),
                  ),
                  title: Text(
                    client.companyName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: titleColor,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Resp: ${client.contactName}\nTél: ${client.phone}'.tr,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${client.currentBalance.toStringAsFixed(3)} DT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isOverThreshold
                              ? AppTheme.errorRed
                              : (hasBalance ? AppTheme.warningOrange : AppTheme.successGreen),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Seuil: ${client.alertThreshold.toStringAsFixed(0)} DT'.tr,
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClientDetailsScreen(client: client),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e'.tr)),
      ),
    );
  }
}

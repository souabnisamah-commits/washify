import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/clients/client_details_screen.dart';
import 'package:washify/features/clients/models/client.dart';
import 'package:washify/features/clients/models/client_vehicle.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/repositories/client_repository.dart';

import 'client_details_screen.dart';

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
          title: Text('Nouveau Compte Client', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nom de la Société (ou Client) *'.tr, prefixIcon: Icon(Icons.business)),
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                    onSaved: (v) => companyName = v!,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nom du Responsable'.tr, prefixIcon: Icon(Icons.person)),
                    onSaved: (v) => contactName = v ?? '',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Matricule Fiscale'.tr, prefixIcon: Icon(Icons.receipt)),
                    onSaved: (v) => taxId = v ?? '',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Téléphone'.tr, prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    onSaved: (v) => phone = v ?? '',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Seuil d\'.tralerte (DT)', prefixIcon: Icon(Icons.warning)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    initialValue: '500',
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Invalide' : null,
                    onSaved: (v) => thresholdStr = v!,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Immatriculation initiale (Optionnel)'.tr, prefixIcon: Icon(Icons.directions_car)),
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
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: Text('Créer'.tr),
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
      return Center(child: Text('Erreur d\'authentification'));
    }

    final clientsAsync = ref.watch(clientsStreamProvider(user.stationId!));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Comptes Clients B2B', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClientDialog,
        icon: Icon(Icons.add),
        label: Text('Nouveau Client'.tr),
        backgroundColor: AppTheme.accentCyan,
      ),
      body: clientsAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Text('Aucun compte client B2B n\'a été créé.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              final isOverThreshold = client.alertThreshold > 0 && client.currentBalance >= client.alertThreshold;

              final bool hasBalance = client.currentBalance > 0;

              return Card(
                elevation: isOverThreshold ? 4 : 1,
                margin: EdgeInsets.only(bottom: 12),
                color: isOverThreshold ? Colors.red.shade50 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isOverThreshold
                      ? BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.5), width: 1.5)
                      : BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isOverThreshold ? AppTheme.errorRed.withValues(alpha: 0.1) : AppTheme.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business, 
                      color: isOverThreshold ? AppTheme.errorRed : AppTheme.primaryBlue,
                    ),
                  ),
                  title: Text(
                    client.companyName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isOverThreshold ? AppTheme.errorRed : Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text('Resp: ${client.contactName}\nTél: ${client.phone}'.tr),
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
                          fontSize: 18,
                          color: isOverThreshold 
                              ? AppTheme.errorRed 
                              : (hasBalance ? AppTheme.warningOrange : AppTheme.successGreen),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Seuil: ${client.alertThreshold.toStringAsFixed(0)} DT',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
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
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e'.tr)),
      ),
    );
  }
}

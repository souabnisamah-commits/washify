import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/offer_provider.dart';
import 'package:washify/providers/service_definition_provider.dart';
import 'package:washify/providers/vehicle_category_provider.dart';
import 'package:washify/features/services/models/offer.dart';
import 'package:washify/providers/product_provider.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  void _showOfferDialog([Offer? offer]) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final stationId = user.tenantId;

    final nameController = TextEditingController(text: offer?.name ?? '');
    final priceController = TextEditingController(text: (offer?.offerPrice ?? 0).toString());
    final formKey = GlobalKey<FormState>();

    String? selectedCategoryId = offer?.categoryId;
    String? selectedCategoryName = offer?.categoryName;
    List<String> selectedServiceIds = List.from(offer?.serviceIds ?? []);
    List<String> selectedServiceNames = List.from(offer?.serviceNames ?? []);
    List<String> selectedProductIds = List.from(offer?.productIds ?? []);
    List<String> selectedProductNames = List.from(offer?.productNames ?? []);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(offer == null ? 'Nouvelle Offre' : 'Modifier l\'Offre'),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nom de l\'.troffre',
                            hintText: 'ex: Offre Premium Citadine'.tr,
                            prefixIcon: Icon(Icons.local_offer, color: AppTheme.accentCyan),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        SizedBox(height: 16),
                        
                        // Category selection
                        ref.watch(vehicleCategoriesByStationProvider(stationId)).when(
                          data: (categories) => DropdownButtonFormField<String>(
                            initialValue: selectedCategoryId,
                            decoration: InputDecoration(
                              labelText: 'Catégorie de véhicule (Optionnel)'.tr,
                              prefixIcon: Icon(Icons.directions_car),
                            ),
                            items: [
                              DropdownMenuItem(value: null, child: Text('Toutes catégories / Aucune'.tr)),
                              ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                            ],
                            onChanged: (val) {
                              setDialogState(() {
                                selectedCategoryId = val;
                                if (val != null) {
                                  selectedCategoryName = categories.firstWhere((c) => c.id == val).name;
                                } else {
                                  selectedCategoryName = null;
                                }
                              });
                            },
                          ),
                          loading: () => CircularProgressIndicator(),
                          error: (e, _) => Text('Erreur catégories: $e'.tr),
                        ),
                        SizedBox(height: 16),

                        // Services selection
                        Text('Services Inclus :', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        ref.watch(serviceDefinitionsByStationProvider(stationId)).when(
                          data: (services) {
                            if (services.isEmpty) return Text('Aucun service disponible.'.tr);
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.dividerColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: services.length,
                                itemBuilder: (context, index) {
                                  final svc = services[index];
                                  final isSelected = selectedServiceIds.contains(svc.id);
                                  return CheckboxListTile(
                                    title: Text(svc.name),
                                    subtitle: Text(svc.serviceType.label, style: TextStyle(fontSize: 12)),
                                    value: isSelected,
                                    onChanged: (checked) {
                                      setDialogState(() {
                                        if (checked == true) {
                                          selectedServiceIds.add(svc.id);
                                          selectedServiceNames.add(svc.name);
                                        } else {
                                          final idx = selectedServiceIds.indexOf(svc.id);
                                          if (idx >= 0) {
                                            selectedServiceIds.removeAt(idx);
                                            selectedServiceNames.removeAt(idx);
                                          }
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          loading: () => CircularProgressIndicator(),
                          error: (e, _) => Text('Erreur services: $e'.tr),
                        ),
                        SizedBox(height: 16),

                        // Products & Extras selection
                        Text('Produits & Extras Inclus :', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        ref.watch(productsStreamProvider(stationId)).when(
                          data: (products) {
                            if (products.isEmpty) return Text('Aucun produit disponible.'.tr);
                            return Container(
                              height: 180,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.dividerColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final prod = products[index];
                                  final isSelected = selectedProductIds.contains(prod.id);
                                  return CheckboxListTile(
                                    title: Text(prod.name),
                                    subtitle: Text('${prod.family.label} | ${prod.unitPrice} DT', style: TextStyle(fontSize: 12)),
                                    value: isSelected,
                                    onChanged: (checked) {
                                      setDialogState(() {
                                        if (checked == true) {
                                          selectedProductIds.add(prod.id);
                                          selectedProductNames.add(prod.name);
                                        } else {
                                          final idx = selectedProductIds.indexOf(prod.id);
                                          if (idx >= 0) {
                                            selectedProductIds.removeAt(idx);
                                            selectedProductNames.removeAt(idx);
                                          }
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          loading: () => CircularProgressIndicator(),
                          error: (e, _) => Text('Erreur produits: $e'.tr),
                        ),
                        SizedBox(height: 16),

                        // Price
                        TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Prix Forfaitaire (DT)'.tr,
                            prefixIcon: Icon(Icons.attach_money, color: AppTheme.successGreen),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Annuler'.tr),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    if (selectedServiceIds.isEmpty && selectedProductIds.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('Veuillez sélectionner au moins un service ou un produit/extra'.tr)),
                      );
                      return;
                    }

                    setDialogState(() => isSaving = true);

                    try {
                      final repo = ref.read(offerRepositoryProvider);
                      final now = DateTime.now();

                      final newOffer = Offer(
                        id: offer?.id ?? '',
                        tenantId: stationId,
                        name: nameController.text.trim(),
                        categoryId: selectedCategoryId,
                        categoryName: selectedCategoryName,
                        serviceIds: selectedServiceIds,
                        serviceNames: selectedServiceNames,
                        productIds: selectedProductIds,
                        productNames: selectedProductNames,
                        offerPrice: double.tryParse(priceController.text) ?? 0.0,
                        isActive: true,
                        createdAt: offer?.createdAt ?? now,
                        updatedAt: now,
                      );

                      if (offer == null) {
                        await repo.create(newOffer);
                      } else {
                        await repo.update(newOffer);
                      }

                      ref.invalidate(offersStreamProvider(stationId));
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    } catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Erreur : $e'.tr)));
                      }
                    } finally {
                      if (dialogContext.mounted) setDialogState(() => isSaving = false);
                    }
                  },
                  child: isSaving ? const CircularProgressIndicator() : Text(offer == null ? 'Créer' : 'Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteOffer(Offer offer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer l\'offre'),
        content: Text('Supprimer "${offer.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Annuler'.tr)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(offerRepositoryProvider);
      await repo.delete(offer.id);
      final user = ref.read(currentUserProvider);
      if (user != null) ref.invalidate(offersStreamProvider(user.tenantId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Scaffold(body: Center(child: CircularProgressIndicator()));

    final offersAsync = ref.watch(offersStreamProvider(user.tenantId));

    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Offres / Packages'.tr)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOfferDialog(),
        backgroundColor: AppTheme.primaryBlue,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Nouvelle Offre', style: TextStyle(color: Colors.white)),
      ),
      body: offersAsync.when(
        data: (offers) {
          if (offers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 64, color: AppTheme.textHint.withValues(alpha: 0.4)),
                  SizedBox(height: 16),
                  Text('Aucune offre configurée.', style: TextStyle(color: AppTheme.textHint)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.accentTeal,
                    child: Icon(Icons.local_offer, color: Colors.white),
                  ),
                  title: Text(offer.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (offer.categoryName != null) 
                        Text('Catégorie: ${offer.categoryName}', style: TextStyle(color: AppTheme.primaryBlue)),
                      if (offer.serviceNames.isNotEmpty)
                        Text('Services: ${offer.serviceNames.join(", ")}'),
                      if (offer.productNames.isNotEmpty)
                        Text('Produits/Extras: ${offer.productNames.join(", ")}', style: TextStyle(color: AppTheme.accentCyan)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${offer.offerPrice.toStringAsFixed(2)} DT', 
                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.successGreen)),
                      SizedBox(width: 16),
                      IconButton(icon: Icon(Icons.edit_outlined, color: AppTheme.accentCyan), onPressed: () => _showOfferDialog(offer)),
                      IconButton(icon: Icon(Icons.delete_outline, color: AppTheme.errorRed), onPressed: () => _deleteOffer(offer)),
                    ],
                  ),
                  isThreeLine: true,
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

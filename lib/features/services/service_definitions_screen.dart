import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/service_definition_provider.dart';
import 'package:washify/providers/vehicle_category_provider.dart';
import 'package:washify/features/services/models/service_definition.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/features/products/models/product.dart';

class ServiceDefinitionsScreen extends ConsumerStatefulWidget {
  const ServiceDefinitionsScreen({super.key});

  @override
  ConsumerState<ServiceDefinitionsScreen> createState() => _ServiceDefinitionsScreenState();
}

class _ServiceDefinitionsScreenState extends ConsumerState<ServiceDefinitionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showServiceDialog({ServiceType type = ServiceType.lavage, ServiceDefinition? service}) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final stationId = user.tenantId;

    final nameController = TextEditingController(text: service?.name ?? '');
    final fixedPriceController = TextEditingController(
      text: service != null && service.serviceType != ServiceType.lavage
          ? service.fixedPrice.toString()
          : '',
    );
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    // For lavage type: price per category
    final Map<String, TextEditingController> priceControllers = {};
    
    // For linked products: map of controllers for doses
    final Map<String, TextEditingController> consumptionControllers = {};
    final List<ServiceProductLink> selectedLinks = List.from(service?.linkedProducts ?? []);

    // The selected type for this dialog
    ServiceType dialogType = service?.serviceType ?? type;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Consumer(
              builder: (dialogContext, ref, _) {
                final categoriesAsync = ref.watch(vehicleCategoriesStreamProvider(stationId));
                final productsAsync = ref.watch(productsStreamProvider(stationId));

                return AlertDialog(
                  title: Text(
                    service == null ? 'Nouveau Service' : 'Modifier le Service',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: SizedBox(
                    width: 500,
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Service Name
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Nom du service'.tr,
                                hintText: 'ex: Lavage Intérieur & Extérieur'.tr,
                                prefixIcon: Icon(Icons.dry_cleaning, color: AppTheme.accentCyan),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                            ),
                            SizedBox(height: 16),

                            // Service Type (only for new services)
                            if (service == null) ...[
                              DropdownButtonFormField<ServiceType>(
                                initialValue: dialogType,
                                decoration: InputDecoration(
                                  labelText: 'Type de service'.tr,
                                  prefixIcon: Icon(Icons.label, color: AppTheme.accentCyan),
                                ),
                                items: ServiceType.values.map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.label),
                                )).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => dialogType = val);
                                  }
                                },
                              ),
                              SizedBox(height: 16),
                            ],

                            // For lavage type: prices per category
                            if (dialogType == ServiceType.lavage) ...[
                              Text(
                                'Prix par catégorie de véhicule :',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              categoriesAsync.when(
                                data: (categories) {
                                  if (categories.isEmpty) {
                                    return Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningOrange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '⚠️ Aucune catégorie de véhicule trouvée.\n'
                                        'Créez d\'abord vos catégories de véhicules.',
                                        style: TextStyle(color: AppTheme.warningOrange),
                                      ),
                                    );
                                  }
                                  return Column(
                                    children: categories.map((cat) {
                                      // Initialize controller with existing price or empty
                                      if (!priceControllers.containsKey(cat.id)) {
                                        final existingPrice = service?.pricesByCategory[cat.id];
                                        priceControllers[cat.id] = TextEditingController(
                                          text: existingPrice != null ? existingPrice.toString() : '',
                                        );
                                      }
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: TextFormField(
                                          controller: priceControllers[cat.id],
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: InputDecoration(
                                            labelText: cat.name,
                                            hintText: 'Prix en DT'.tr,
                                            suffixText: 'DT',
                                            prefixIcon: Icon(Icons.directions_car, size: 18),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                                loading: () => Center(child: CircularProgressIndicator()),
                                error: (e, _) => Text('Erreur: $e'.tr),
                              ),
                            ],

                            // For supplement & special: fixed price
                            if (dialogType != ServiceType.lavage) ...[
                              TextFormField(
                                controller: fixedPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Prix fixe'.tr,
                                  suffixText: 'DT',
                                  prefixIcon: Icon(Icons.attach_money, color: AppTheme.accentCyan),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Requis';
                                  if (double.tryParse(v) == null) return 'Nombre invalide';
                                  return null;
                                },
                              ),
                            ],
                            
                            SizedBox(height: 24),
                            Text(
                              'Produits de stock associés (Traçabilité) :',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 8),

                            // Dropdown to link a product
                            productsAsync.when(
                              data: (products) {
                                final availableProducts = products.where(
                                  (p) => !selectedLinks.any((link) => link.productId == p.id)
                                ).toList();

                                if (availableProducts.isEmpty) {
                                  return SizedBox.shrink();
                                }

                                return DropdownButtonFormField<Product>(
                                  decoration: InputDecoration(
                                    labelText: 'Lier un produit'.tr,
                                    prefixIcon: Icon(Icons.add_link, color: AppTheme.accentCyan),
                                  ),
                                  items: availableProducts.map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text('${p.name} (${p.unit})'),
                                  )).toList(),
                                  onChanged: (prod) {
                                    if (prod != null) {
                                      setDialogState(() {
                                        final double defaultDose = 1.0;
                                        selectedLinks.add(ServiceProductLink(
                                          productId: prod.id,
                                          productName: prod.name,
                                          consumptionPerUse: defaultDose,
                                        ));
                                        consumptionControllers[prod.id] = TextEditingController(
                                          text: defaultDose.toString(),
                                        );
                                      });
                                    }
                                  },
                                );
                              },
                              loading: () => Center(child: CircularProgressIndicator()),
                              error: (e, _) => Text('Erreur produits: $e'.tr),
                            ),
                            SizedBox(height: 12),

                            // List of linked products with editable doses
                            if (selectedLinks.isNotEmpty) ...[
                              Column(
                                children: selectedLinks.map((link) {
                                  // Default controller
                                  final defCtrlKey = '${link.productId}_default';
                                  final defCtrl = consumptionControllers[defCtrlKey] ??= TextEditingController(
                                    text: link.consumptionPerUse.toString(),
                                  );

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  link.productName,
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete, color: AppTheme.errorRed, size: 20),
                                                onPressed: () {
                                                  setDialogState(() {
                                                    selectedLinks.removeWhere((l) => l.productId == link.productId);
                                                    consumptionControllers.removeWhere((k, v) => k.startsWith(link.productId));
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(child: Text('Dose par défaut (ml/g):'.tr)),
                                              SizedBox(
                                                width: 100,
                                                child: TextFormField(
                                                  controller: defCtrl,
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                  decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                                                  validator: (v) => v == null || double.tryParse(v) == null ? 'Inv' : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text('Dose spécifique par catégorie:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                          categoriesAsync.when(
                                            data: (cats) => Column(
                                              children: cats.map((c) {
                                                final catCtrlKey = '${link.productId}_${c.id}';
                                                final catCtrl = consumptionControllers[catCtrlKey] ??= TextEditingController(
                                                  text: link.consumptionByCategory[c.id]?.toString() ?? '',
                                                );
                                                return Padding(
                                                  padding: EdgeInsets.only(top: 4.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(child: Text('- ${c.name}', style: TextStyle(fontSize: 13))),
                                                      SizedBox(
                                                        width: 100,
                                                        child: TextFormField(
                                                          controller: catCtrl,
                                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                          decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8), hintText: 'Défaut'.tr),
                                                          validator: (v) => (v != null && v.isNotEmpty && double.tryParse(v) == null) ? 'Inv' : null,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            loading: () => SizedBox.shrink(),
                                            error: (e, _) => SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ] else
                              Text(
                                'Aucun produit de stock lié à ce service.',
                                style: TextStyle(color: AppTheme.textHint, fontSize: 12, fontStyle: FontStyle.italic),
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
                        setDialogState(() => isSaving = true);

                        try {
                          final repo = ref.read(serviceDefinitionRepositoryProvider);
                          final now = DateTime.now();

                          // Build pricesByCategory
                          Map<String, double> prices = {};
                          if (dialogType == ServiceType.lavage) {
                            priceControllers.forEach((catId, controller) {
                              if (controller.text.isNotEmpty) {
                                prices[catId] = double.tryParse(controller.text) ?? 0.0;
                              }
                            });
                          }

                          // Build linkedProducts
                          List<ServiceProductLink> finalLinks = [];
                          for (final link in selectedLinks) {
                            final defCtrl = consumptionControllers['${link.productId}_default'];
                            final consumption = defCtrl != null
                                ? double.tryParse(defCtrl.text) ?? link.consumptionPerUse
                                : link.consumptionPerUse;
                            
                            Map<String, double> byCategory = {};
                            consumptionControllers.forEach((key, ctrl) {
                              if (key.startsWith('${link.productId}_') && key != '${link.productId}_default' && ctrl.text.isNotEmpty) {
                                final catId = key.replaceFirst('${link.productId}_', '');
                                final dose = double.tryParse(ctrl.text);
                                if (dose != null) {
                                  byCategory[catId] = dose;
                                }
                              }
                            });

                            finalLinks.add(ServiceProductLink(
                              productId: link.productId,
                              productName: link.productName,
                              consumptionPerUse: consumption,
                              consumptionByCategory: byCategory,
                            ));
                          }

                          if (service == null) {
                            await repo.create(ServiceDefinition(
                              id: '',
                              tenantId: stationId,
                              name: nameController.text.trim(),
                              serviceType: dialogType,
                              pricesByCategory: prices,
                              fixedPrice: dialogType != ServiceType.lavage
                                  ? double.tryParse(fixedPriceController.text) ?? 0.0
                                  : 0.0,
                              linkedProducts: finalLinks,
                              createdAt: now,
                              updatedAt: now,
                            ));
                          } else {
                            await repo.update(service.copyWith(
                              name: nameController.text.trim(),
                              pricesByCategory: dialogType == ServiceType.lavage ? prices : service.pricesByCategory,
                              fixedPrice: dialogType != ServiceType.lavage
                                  ? double.tryParse(fixedPriceController.text) ?? service.fixedPrice
                                  : service.fixedPrice,
                              linkedProducts: finalLinks,
                              updatedAt: now,
                            ));
                          }

                          ref.invalidate(serviceDefinitionsStreamProvider(stationId));
                          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        } catch (e) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('Erreur : $e'.tr)),
                            );
                          }
                        } finally {
                          if (dialogContext.mounted) setDialogState(() => isSaving = false);
                        }
                      },
                      child: isSaving
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(service == null ? 'Créer' : 'Enregistrer'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _deleteService(ServiceDefinition service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le service'.tr),
        content: Text('Supprimer "${service.name}" ?'),
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
      final repo = ref.read(serviceDefinitionRepositoryProvider);
      await repo.delete(service.id);
      final user = ref.read(currentUserProvider);
      if (user != null) ref.invalidate(serviceDefinitionsStreamProvider(user.tenantId));
    }
  }

  Widget _buildServicesList(List<ServiceDefinition> services, ServiceType type) {
    final filtered = services.where((s) => s.serviceType == type).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textHint.withValues(alpha: 0.4)),
            SizedBox(height: 12),
            Text(
              'Aucun service de type "${type.label}"',
              style: TextStyle(color: AppTheme.textHint),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final svc = filtered[index];
        final priceDisplay = svc.serviceType == ServiceType.lavage
            ? '${svc.pricesByCategory.length} prix définis'
            : '${svc.fixedPrice.toStringAsFixed(0)} DT';

        final iconData = switch (svc.serviceType) {
          ServiceType.lavage => Icons.local_car_wash,
          ServiceType.supplement => Icons.auto_awesome,
          ServiceType.special => Icons.build_circle_outlined,
        };

        final iconColor = switch (svc.serviceType) {
          ServiceType.lavage => AppTheme.primaryBlue,
          ServiceType.supplement => AppTheme.warningOrange,
          ServiceType.special => AppTheme.accentTeal,
        };

        return Card(
          margin: EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(iconData, color: iconColor),
            ),
            title: Text(svc.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(priceDisplay, style: TextStyle(color: AppTheme.textHint)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: AppTheme.accentCyan),
                  onPressed: () => _showServiceDialog(type: svc.serviceType, service: svc),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppTheme.errorRed),
                  onPressed: () => _deleteService(svc),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Scaffold(body: Center(child: CircularProgressIndicator()));

    final servicesAsync = ref.watch(serviceDefinitionsStreamProvider(user.tenantId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Services'.tr),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Lavage', icon: Icon(Icons.local_car_wash, size: 18)),
            Tab(text: 'Suppléments', icon: Icon(Icons.auto_awesome, size: 18)),
            Tab(text: 'Spéciaux', icon: Icon(Icons.build_circle_outlined, size: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final type = ServiceType.values[_tabController.index];
          _showServiceDialog(type: type);
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Nouveau Service', style: TextStyle(color: Colors.white)),
      ),
      body: servicesAsync.when(
        data: (services) => TabBarView(
          controller: _tabController,
          children: [
            _buildServicesList(services, ServiceType.lavage),
            _buildServicesList(services, ServiceType.supplement),
            _buildServicesList(services, ServiceType.special),
          ],
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
    );
  }
}

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

import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/core/widgets/barcode_scan_button.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
                            // Button to open 3-tab Product Link Modal
                            productsAsync.when(
                              data: (products) {
                                final availableProducts = products.where(
                                  (p) => !selectedLinks.any((link) => link.productId == p.id)
                                ).toList();

                                if (availableProducts.isEmpty) {
                                  return Text(
                                    'Tous les produits configurés sont déjà liés.'.tr,
                                    style: const TextStyle(color: AppTheme.textHint, fontSize: 12, fontStyle: FontStyle.italic),
                                  );
                                }

                                return InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: dialogContext,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) => FractionallySizedBox(
                                        heightFactor: 0.85,
                                        child: _LinkProductModalSheet(
                                          availableProducts: availableProducts,
                                          onProductSelected: (prod) {
                                            setDialogState(() {
                                              final double defaultDose = 1.0;
                                              selectedLinks.add(ServiceProductLink(
                                                productId: prod.id,
                                                productName: prod.name,
                                                consumptionPerUse: defaultDose,
                                              ));
                                              consumptionControllers['${prod.id}_default'] = TextEditingController(
                                                text: defaultDose.toString(),
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentCyan.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_link, color: AppTheme.accentCyan),
                                        const SizedBox(width: 8),
                                        Text(
                                          '+ Lier un produit de stock (Boutique, Extra, Standard)'.tr,
                                          style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, _) => Text('Erreur produits: $e'.tr),
                            ),
                            const SizedBox(height: 12),

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
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final servicesAsync = ref.watch(serviceDefinitionsStreamProvider(user.tenantId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Services'.tr),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Lavage'.tr, icon: const Icon(Icons.local_car_wash, size: 18)),
            Tab(text: 'Suppléments'.tr, icon: const Icon(Icons.auto_awesome, size: 18)),
            Tab(text: 'Spéciaux'.tr, icon: const Icon(Icons.build_circle_outlined, size: 18)),
            Tab(text: 'Moquettes'.tr, icon: const Icon(Icons.grid_view, size: 18)),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          if (_tabController.index == 3) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              final type = ServiceType.values[_tabController.index];
              _showServiceDialog(type: type);
            },
            backgroundColor: AppTheme.primaryBlue,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Nouveau Service'.tr, style: const TextStyle(color: Colors.white)),
          );
        },
      ),
      body: servicesAsync.when(
        data: (services) => TabBarView(
          controller: _tabController,
          children: [
            _buildServicesList(services, ServiceType.lavage),
            _buildServicesList(services, ServiceType.supplement),
            _buildServicesList(services, ServiceType.special),
            CarpetServiceConfigTab(stationId: user.tenantId),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
    );
  }
}

class CarpetServiceConfigTab extends ConsumerStatefulWidget {
  final String stationId;
  const CarpetServiceConfigTab({super.key, required this.stationId});

  @override
  ConsumerState<CarpetServiceConfigTab> createState() => _CarpetServiceConfigTabState();
}

class _CarpetServiceConfigTabState extends ConsumerState<CarpetServiceConfigTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _carpetPriceController;
  bool _initialized = false;
  bool _isSaving = false;
  Station? _station;

  final List<ServiceProductLink> _carpetLinks = [];
  final Map<String, TextEditingController> _consumptionControllers = {};

  @override
  void dispose() {
    if (_initialized) {
      _carpetPriceController.dispose();
      for (final ctrl in _consumptionControllers.values) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  void _initFields(Station station) {
    if (_initialized) return;
    _station = station;
    _carpetPriceController = TextEditingController(text: station.carpetPricePerMeter.toString());
    _carpetLinks.clear();
    _carpetLinks.addAll(station.carpetLinkedProducts);
    for (final link in _carpetLinks) {
      _consumptionControllers[link.productId] = TextEditingController(
        text: link.consumptionPerUse.toString(),
      );
    }
    _initialized = true;
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    if (_station == null) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(stationRepositoryProvider);
      final List<ServiceProductLink> finalLinks = [];
      for (final link in _carpetLinks) {
        final ctrl = _consumptionControllers[link.productId];
        final val = double.tryParse(ctrl?.text ?? '0') ?? 0.0;
        finalLinks.add(link.copyWith(consumptionPerUse: val));
      }

      final updatedStation = _station!.copyWith(
        carpetPricePerMeter: double.tryParse(_carpetPriceController.text.trim()) ?? 0.0,
        carpetLinkedProducts: finalLinks,
        updatedAt: DateTime.now(),
      );

      await repo.updateStation(updatedStation);
      ref.invalidate(stationByIdProvider(_station!.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Configuration Moquette enregistrée avec succès'.tr),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'.tr)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddProductDialog(AsyncValue<List<Product>> productsAsync) {
    productsAsync.whenData((products) {
      final availableProducts = products.where(
        (p) => !_carpetLinks.any((l) => l.productId == p.id),
      ).toList();

      if (availableProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tous les produits sont déjà liés.'.tr)),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.85,
          child: _LinkProductModalSheet(
            availableProducts: availableProducts,
            onProductSelected: (prod) {
              final double defaultDose = 50.0;
              setState(() {
                _carpetLinks.add(ServiceProductLink(
                  productId: prod.id,
                  productName: prod.name,
                  consumptionPerUse: defaultDose,
                ));
                _consumptionControllers[prod.id] = TextEditingController(text: defaultDose.toString());
              });
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final stationAsync = ref.watch(stationByIdProvider(widget.stationId));
    final productsAsync = ref.watch(productsStreamProvider(widget.stationId));

    return stationAsync.when(
      data: (station) {
        if (station == null) return Center(child: Text('Station introuvable'.tr));
        _initFields(station);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: AppTheme.surfaceCard,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.accentCyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.grid_view, color: AppTheme.accentCyan),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Tarif & Consommables Moquette'.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Configurez le tarif de lavage au m² et affectez les produits consommables nécessaires par m² de moquette.'.tr,
                          style: TextStyle(color: AppTheme.textHint, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _carpetPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Prix de lavage par m² (DT) *'.tr,
                            prefixIcon: const Icon(Icons.monetization_on_outlined, color: AppTheme.successGreen),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requis'.tr;
                            if (double.tryParse(v) == null) return 'Nombre invalide'.tr;
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Produits Consommables Liés'.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddProductDialog(productsAsync),
                              icon: const Icon(Icons.add),
                              label: Text('Ajouter Produit'.tr),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (_carpetLinks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: Text(
                                'Aucun produit consommable lié à la moquette.'.tr,
                                style: TextStyle(color: AppTheme.textHint, fontStyle: FontStyle.italic),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _carpetLinks.length,
                            itemBuilder: (context, index) {
                              final link = _carpetLinks[index];
                              final ctrl = _consumptionControllers[link.productId] ??= TextEditingController(
                                text: link.consumptionPerUse.toString(),
                              );

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10.0),
                                color: AppTheme.surfaceCard,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              link.productName,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 20),
                                            onPressed: () {
                                              setState(() {
                                                _carpetLinks.removeAt(index);
                                                _consumptionControllers.remove(link.productId);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text('Consommation par m² (ml/g):'.tr, style: const TextStyle(fontSize: 13)),
                                          ),
                                          SizedBox(
                                            width: 110,
                                            child: TextFormField(
                                              controller: ctrl,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.all(8),
                                              ),
                                              validator: (v) => v == null || double.tryParse(v) == null ? 'Requis'.tr : null,
                                              onChanged: (val) {
                                                final d = double.tryParse(val);
                                                if (d != null) {
                                                  _carpetLinks[index] = link.copyWith(consumptionPerUse: d);
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.save),
                  label: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Enregistrer la Configuration Moquette'.tr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
    );
  }
}

class _LinkProductModalSheet extends ConsumerStatefulWidget {
  final List<Product> availableProducts;
  final Function(Product) onProductSelected;

  const _LinkProductModalSheet({
    required this.availableProducts,
    required this.onProductSelected,
  });

  @override
  ConsumerState<_LinkProductModalSheet> createState() => _LinkProductModalSheetState();
}

class _LinkProductModalSheetState extends ConsumerState<_LinkProductModalSheet> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_link, color: AppTheme.accentCyan, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Lier un Produit de Stock'.tr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // TabBar
            TabBar(
              indicatorColor: AppTheme.accentCyan,
              labelColor: AppTheme.accentCyan,
              unselectedLabelColor: AppTheme.textHint,
              tabs: const [
                Tab(icon: Icon(Icons.shopping_bag_outlined, size: 18), text: 'Boutique (Revente)'),
                Tab(icon: Icon(Icons.auto_awesome_outlined, size: 18), text: 'Consommable Premium'),
                Tab(icon: Icon(Icons.opacity_outlined, size: 18), text: 'Consommable Standard'),
              ],
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  _LinkProductCategoryTabView(
                    family: ProductFamily.revente,
                    products: widget.availableProducts,
                    onSelected: (p) => widget.onProductSelected(p),
                  ),
                  _LinkProductCategoryTabView(
                    family: ProductFamily.extra,
                    products: widget.availableProducts,
                    onSelected: (p) => widget.onProductSelected(p),
                  ),
                  _LinkProductCategoryTabView(
                    family: ProductFamily.standard,
                    products: widget.availableProducts,
                    onSelected: (p) => widget.onProductSelected(p),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkProductCategoryTabView extends StatefulWidget {
  final ProductFamily family;
  final List<Product> products;
  final Function(Product) onSelected;

  const _LinkProductCategoryTabView({
    required this.family,
    required this.products,
    required this.onSelected,
  });

  @override
  State<_LinkProductCategoryTabView> createState() => _LinkProductCategoryTabViewState();
}

class _LinkProductCategoryTabViewState extends State<_LinkProductCategoryTabView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBoutique = widget.family == ProductFamily.revente;

    final filtered = widget.products.where((p) {
      if (p.family != widget.family) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final nameMatch = p.name.toLowerCase().contains(q);
        final barcodeMatch = p.barcode.toLowerCase().contains(q);
        final unitMatch = p.unit.toLowerCase().contains(q);
        return nameMatch || barcodeMatch || unitMatch;
      }

      return true;
    }).toList();

    return Column(
      children: [
        // Intelligent Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: isBoutique
                  ? 'Rechercher par nom ou code-barres...'.tr
                  : 'Rechercher un produit...'.tr,
              prefixIcon: const Icon(Icons.search, color: AppTheme.accentCyan),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : (isBoutique
                      ? Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: BarcodeScanButton(
                            onScanned: (barcode) {
                              _searchController.text = barcode;
                              setState(() => _searchQuery = barcode);
                            },
                            iconSize: 20,
                            iconColor: AppTheme.accentCyan,
                          ),
                        )
                      : null),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accentCyan, width: 2),
              ),
            ),
          ),
        ),

        // Count banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} produit(s) disponible(s)',
                style: const TextStyle(fontSize: 12, color: AppTheme.textHint, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Product items list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isBoutique ? Icons.shopping_bag_outlined : Icons.inventory_2_outlined, size: 48, color: AppTheme.textHint.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Aucun produit ne correspond à la recherche.'.tr
                            : 'Aucun produit disponible dans cette catégorie.'.tr,
                        style: const TextStyle(color: AppTheme.textHint),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final prod = filtered[index];
                    final barcodeStr = (isBoutique && prod.barcode.isNotEmpty) ? prod.barcode : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () => widget.onSelected(prod),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                          child: Icon(
                            isBoutique ? Icons.shopping_bag : Icons.opacity,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                prod.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (barcodeStr.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentCyan.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'Code: $barcodeStr',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          'Unité: ${prod.unit}${prod.capacityMl > 0 ? " (${prod.capacityMl.toInt()} ml)" : ""}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                        ),
                        trailing: const Icon(Icons.add_link, color: AppTheme.accentCyan),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

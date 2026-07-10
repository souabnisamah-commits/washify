import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/clients/models/client.dart';
import 'package:washify/features/clients/models/client_vehicle.dart';
import 'package:washify/repositories/client_repository.dart';
import 'package:washify/features/tickets/components/vehicle_info_input.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/service_definition_provider.dart';
import 'package:washify/providers/vehicle_category_provider.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/features/services/models/service_definition.dart';
import 'package:washify/features/services/models/vehicle_category.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/providers/offer_provider.dart';
import 'package:washify/features/services/models/offer.dart';
import 'package:washify/features/employees/models/employee.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/features/hr/providers/hr_provider.dart';
import 'package:washify/features/hr/models/attendance.dart';
import 'package:washify/features/hr/models/shift.dart';

class NewTicketScreen extends ConsumerStatefulWidget {
  const NewTicketScreen({super.key});

  @override
  ConsumerState<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends ConsumerState<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _productSearchController = TextEditingController();

  String _vehiclePlate = '';
  String _vehicleBrand = '';
  String _vehicleModel = '';
  final GlobalKey<VehicleInfoInputState> _vehicleInfoKey = GlobalKey<VehicleInfoInputState>();
  
  // To avoid redundant queries
  String _lastQueriedPlate = '';
  bool _isQueryingHistory = false;
  
  String _clientName = '';
  String _clientPhone = '';

  VehicleCategory? _selectedVehicleCategory;
  Employee? _assignedWorker;
  String _selectedPaymentMethod = 'cash';
  Client? _selectedClient;

  final List<ServiceDefinition> _selectedServices = [];
  Offer? _selectedOffer;
  final List<TicketProduct> _selectedProducts = [];
  String _productSearchQuery = '';
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }


  void _updateIncludedProducts() {
    final productsAsync = ref.read(productsStreamProvider(ref.read(currentUserProvider)?.tenantId ?? ''));
    if (productsAsync.value == null) return;
    
    // Calculate required free quotas for revente products
    final Map<String, double> requiredFreeQuotas = {};
    
    // 1. From Offer
    if (_selectedOffer != null) {
      for (final prodId in _selectedOffer!.productIds) {
        requiredFreeQuotas[prodId] = (requiredFreeQuotas[prodId] ?? 0.0) + 1.0;
      }
    }
    
    // 2. From Selected Services
    for (final srv in _selectedServices) {
      for (final link in srv.linkedProducts) {
        requiredFreeQuotas[link.productId] = (requiredFreeQuotas[link.productId] ?? 0.0) + link.consumptionPerUse;
      }
    }
    
    // Apply required quotas to _selectedProducts
    for (final entry in requiredFreeQuotas.entries) {
      final productId = entry.key;
      final requiredQty = entry.value;
      
      final productMatches = productsAsync.value!.where((p) => p.id == productId && p.family == ProductFamily.revente);
      if (productMatches.isEmpty) continue; // Only process revente products
      
      final product = productMatches.first;
      
      final existingIndex = _selectedProducts.indexWhere((p) => p.productId == productId);
      if (existingIndex >= 0) {
        final existing = _selectedProducts[existingIndex];
        if (existing.quantity < requiredQty) {
          // Increase quantity to at least the required free quota
          _selectedProducts[existingIndex] = TicketProduct(
            productId: product.id,
            productName: product.name,
            quantity: requiredQty.ceil(),
            unitPrice: product.unitPrice,
          );
        }
      } else {
        // Add the product with the required free quota
        if (requiredQty > 0) {
          _selectedProducts.add(TicketProduct(
            productId: product.id,
            productName: product.name,
            quantity: requiredQty.ceil(),
            unitPrice: product.unitPrice,
          ));
        }
      }
    }
  }

  double _getFreeQuota(String productId) {
    double quota = 0.0;
    if (_selectedOffer != null && _selectedOffer!.productIds.contains(productId)) {
      quota += 1.0;
    }
    for (final srv in _selectedServices) {
      for (final link in srv.linkedProducts) {
        if (link.productId == productId) {
          quota += link.consumptionPerUse;
        }
      }
    }
    return quota;
  }

  void _addProduct(Product product) {
    setState(() {
      final existingIndex = _selectedProducts.indexWhere((p) => p.productId == product.id);
      final price = product.unitPrice;
      if (existingIndex >= 0) {
        final existing = _selectedProducts[existingIndex];
        _selectedProducts[existingIndex] = TicketProduct(
          productId: product.id,
          productName: product.name,
          quantity: existing.quantity + 1,
          unitPrice: price,
        );
      } else {
        _selectedProducts.add(TicketProduct(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          unitPrice: price,
        ));
      }
    });
  }

  void _removeProduct(String productId) {
    setState(() {
      final existingIndex = _selectedProducts.indexWhere((p) => p.productId == productId);
      if (existingIndex >= 0) {
        final existing = _selectedProducts[existingIndex];
        final freeQuota = _getFreeQuota(productId);
        
        if (existing.quantity > freeQuota && existing.quantity > 1) {
          _selectedProducts[existingIndex] = TicketProduct(
            productId: productId,
            productName: existing.productName,
            quantity: existing.quantity - 1,
            unitPrice: existing.unitPrice,
          );
        } else if (existing.quantity <= freeQuota) {
          // Cannot remove below free quota, do nothing or show message
        } else {
          _selectedProducts.removeAt(existingIndex);
        }
      }
    });
  }

  double _calculateTotalAmount(VehicleCategory? selectedCategory) {
    if (selectedCategory == null) return 0.0;
    double total = 0.0;
    if (_selectedOffer != null) {
      total += _selectedOffer!.offerPrice;
      for (final p in _selectedProducts) {
        final isIncluded = _selectedOffer!.productIds.contains(p.productId);
        if (isIncluded) {
          if (p.quantity > 1) {
            total += (p.quantity - 1) * p.unitPrice;
          }
        } else {
          total += p.total;
        }
      }
    } else {
      for (final srv in _selectedServices) {
        total += srv.getPriceForCategory(selectedCategory.id);
      }
      for (final p in _selectedProducts) {
        total += p.total;
      }
    }
    return total;
  }

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    if (_productSearchQuery.isEmpty) return allProducts;
    return allProducts.where((p) {
      final nameMatch = p.name.toLowerCase().contains(_productSearchQuery);
      final barcodeMatch = p.barcode.toLowerCase().contains(_productSearchQuery);
      return nameMatch || barcodeMatch;
    }).toList();
  }

  void _onSearchChanged(String val, List<Product> products) {
    final query = val.trim();
    setState(() {
      _productSearchQuery = query.toLowerCase();
    });

    if (query.length == 5) {
      final matchedProduct = products.firstWhere(
        (p) => p.barcode == query,
        orElse: () => Product(
          id: '',
          tenantId: '',
          name: '',
          description: '',
          unit: '',
          unitPrice: 0.0,
          minStock: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (matchedProduct.id.isNotEmpty) {
        _addProduct(matchedProduct);
        _productSearchController.clear();
        setState(() {
          _productSearchQuery = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${matchedProduct.name} ajouté via code-barres'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    }
  }

  Future<void> _submitTicket(VehicleCategory? selectedCategory) async {
    if (_assignedWorker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un ouvrier pour laver le véhicule'.tr)),
      );
      return;
    }

    if (_vehiclePlate.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir la plaque d\'immatriculation')),
      );
      return;
    }

    if (!_formKey.currentState!.validate() || _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner au moins un service de lavage'.tr)),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une catégorie de véhicule'.tr)),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null || user.stationId == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(ticketRepositoryProvider);

      final now = DateTime.now();
      final dateStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final timeStr = "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}";
      final randomStr = (1000 + (DateTime.now().millisecond % 9000)).toString();
      final ticketNum = "ST-${user.stationId}-$dateStr-$timeStr-$randomStr";

      final Map<String, dynamic> servicePrices = {};
      final List<TicketService> ticketServices = [];

      if (_selectedOffer != null) {
        final pricePerService = _selectedOffer!.offerPrice / _selectedServices.length;
        servicePrices['offerId'] = _selectedOffer!.id;
        servicePrices['offerName'] = _selectedOffer!.name;
        servicePrices['offerPrice'] = _selectedOffer!.offerPrice;
        
        for (final srv in _selectedServices) {
          servicePrices[srv.id] = pricePerService;
          ticketServices.add(TicketService(
            serviceId: srv.id,
            serviceName: srv.name,
            price: pricePerService,
          ));
        }
      } else {
        for (final srv in _selectedServices) {
          final price = srv.getPriceForCategory(selectedCategory.id);
          servicePrices[srv.id] = price;
          ticketServices.add(TicketService(
            serviceId: srv.id,
            serviceName: srv.name,
            price: price,
          ));
        }
      }

      final joinedNames = _selectedOffer != null 
          ? "${_selectedOffer!.name} (${_selectedServices.map((s) => s.name).join(' + ')})"
          : _selectedServices.map((s) => s.name).join(" + ");
      final firstServiceId = _selectedServices.isNotEmpty ? _selectedServices.first.id : "";

      final List<TicketProduct> finalProducts = [];
      for (final tp in _selectedProducts) {
        final double freeQuota = _getFreeQuota(tp.productId);
        final double billedQty = (tp.quantity - freeQuota).clamp(0.0, double.infinity);
        final double includedQty = tp.quantity - billedQty;

        if (includedQty > 0) {
          finalProducts.add(TicketProduct(
            productId: tp.productId,
            productName: "${tp.productName} (Inclus)",
            quantity: includedQty.toInt(),
            unitPrice: 0.0,
          ));
        }
        if (billedQty > 0) {
          finalProducts.add(TicketProduct(
            productId: tp.productId,
            productName: tp.productName,
            quantity: billedQty.toInt(),
            unitPrice: tp.unitPrice,
          ));
        }
      }

      final newTicket = Ticket(
        id: '',
        tenantId: user.stationId!,
        ticketNumber: ticketNum,
        createdBy: user.name,
        paidBy: user.name,
        status: TicketStatus.enAttente,
        montant: _calculateTotalAmount(selectedCategory),
        snapshotPrice: servicePrices,
        vehiclePlate: _vehiclePlate.toUpperCase(),
        vehicleCategoryId: selectedCategory.id,
        vehicleType: selectedCategory.name,
        vehicleBrand: _vehicleBrand,
        vehicleModel: _vehicleModel,
        clientId: _selectedClient?.id,
        clientName: _selectedClient != null ? _selectedClient!.companyName : (_clientName.isEmpty ? null : _clientName),
        clientPhone: _selectedClient != null ? _selectedClient!.phone : (_clientPhone.isEmpty ? null : _clientPhone),
        paymentMethod: _selectedPaymentMethod,
        assignedWorkerId: _assignedWorker!.id,
        assignedWorkerName: _assignedWorker!.name,
        serviceId: firstServiceId,
        serviceName: joinedNames,
        servicesSelected: ticketServices,
        productsUsed: finalProducts,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Auto-learning: add or update vehicle in B2B client's list
      if (_selectedPaymentMethod == 'compte_client' && _selectedClient != null) {
        bool needsClientUpdate = false;
        final clientVehicles = List<ClientVehicle>.from(_selectedClient!.vehicles);
        final plateUpper = _vehiclePlate.toUpperCase();
        
        final idx = clientVehicles.indexWhere((v) => v.plate == plateUpper);
        if (idx == -1) {
          // New vehicle for this client! Learn it.
          clientVehicles.add(ClientVehicle(
            plate: plateUpper, 
            brand: _vehicleBrand, 
            model: _vehicleModel,
            categoryId: selectedCategory.id,
          ));
          needsClientUpdate = true;
        } else {
          // Existing vehicle. Did we learn a new brand, model or category?
          final existing = clientVehicles[idx];
          if ((existing.brand.isEmpty && _vehicleBrand.isNotEmpty) || 
              (existing.model.isEmpty && _vehicleModel.isNotEmpty) ||
              (existing.brand != _vehicleBrand && _vehicleBrand.isNotEmpty) ||
              (existing.model != _vehicleModel && _vehicleModel.isNotEmpty) ||
              (existing.categoryId != selectedCategory.id)) {
            clientVehicles[idx] = ClientVehicle(
              plate: existing.plate,
              brand: _vehicleBrand.isNotEmpty ? _vehicleBrand : existing.brand,
              model: _vehicleModel.isNotEmpty ? _vehicleModel : existing.model,
              categoryId: selectedCategory.id,
            );
            needsClientUpdate = true;
          }
        }

        if (needsClientUpdate) {
          final updatedClient = _selectedClient!.copyWith(
            vehicles: clientVehicles,
            updatedAt: DateTime.now(),
          );
          await ref.read(clientRepositoryProvider).updateClient(updatedClient);
        }
      }

      await repo.createTicket(newTicket);
      ref.invalidate(todayTicketsStreamProvider(user.stationId!));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket créé avec succès'.tr)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.stationId == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final categoriesAsync = ref.watch(vehicleCategoriesStreamProvider(user.tenantId));
    final serviceDefsAsync = ref.watch(serviceDefinitionsStreamProvider(user.tenantId));
    final productsAsync = ref.watch(productsStreamProvider(user.tenantId));
    final offersAsync = ref.watch(offersStreamProvider(user.tenantId));
    final employeesAsync = ref.watch(employeesStreamProvider(user.tenantId));
    final clientsAsync = ref.watch(clientsStreamProvider(user.tenantId));
    final now = DateTime.now();
    final attendancesAsync = ref.watch(attendancesStreamProvider((stationId: user.tenantId, date: DateTime(now.year, now.month, now.day))));
    final shiftsAsync = ref.watch(shiftsStreamProvider(user.tenantId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Ticket'.tr),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
// Vehicle Info
              VehicleInfoInput(
                key: _vehicleInfoKey,
                onChanged: (plate, brand, model) {
                  _vehiclePlate = plate;
                  _vehicleBrand = brand;
                  _vehicleModel = model;
                  _checkVehicleHistory();
                },
              ),
              SizedBox(height: 16),

              // Vehicle Category (dynamic)
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⚠️ Aucune catégorie de véhicule configurée.\n'
                        'Veuillez d\'abord configurer les catégories de véhicules dans l\'espace Patron.',
                        style: TextStyle(color: AppTheme.errorRed),
                      ),
                    );
                  }

                  final selectedCategory = _selectedVehicleCategory ?? categories.first;

                  return DropdownButtonFormField<VehicleCategory>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Catégorie de Véhicule'.tr,
                      prefixIcon: Icon(Icons.directions_car, color: AppTheme.accentCyan),
                    ),
                    items: categories
                        .map((cat) => DropdownMenuItem<VehicleCategory>(
                              value: cat,
                              child: Text('${cat.name} (${cat.examples})'),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedVehicleCategory = val;
                          _selectedOffer = null;
                          _selectedServices.clear();
                          _selectedProducts.clear();
                        });
                      }
                    },
                    validator: (v) => v == null ? 'Veuillez sélectionner une catégorie' : null,
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erreur catégories: $e', style: TextStyle(color: AppTheme.errorRed)),
              ),
              SizedBox(height: 16),

              // Offers/Packages Selection (dynamic based on category)
              offersAsync.when(
                data: (offers) {
                  final category = _selectedVehicleCategory ?? (categoriesAsync.value?.isNotEmpty == true ? categoriesAsync.value!.first : null);
                  if (category == null) return SizedBox();

                  // Filter offers for the selected category
                  final categoryOffers = offers.where((o) => o.categoryId == category.id).toList();
                  if (categoryOffers.isEmpty) return SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<Offer?>(
                        value: _selectedOffer,
                        decoration: InputDecoration(
                          labelText: 'Offre / Package Promotionnel (Optionnel)'.tr,
                          prefixIcon: Icon(Icons.card_giftcard, color: AppTheme.accentCyan),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Aucune offre (Tarifs standards)'.tr),
                          ),
                          ...categoryOffers.map((o) => DropdownMenuItem<Offer?>(
                                value: o,
                                child: Text('${o.name} (${o.offerPrice.toStringAsFixed(0)} DT)'),
                              )),
                        ],
                        onChanged: (Offer? val) {
                          setState(() {
                            _selectedOffer = val;
                            if (val != null) {
                              // Auto-select the services included in the offer
                              _selectedServices.clear();
                              if (serviceDefsAsync.value != null) {
                                for (final serviceId in val.serviceIds) {
                                  final matches = serviceDefsAsync.value!.where((s) => s.id == serviceId);
                                  if (matches.isNotEmpty) {
                                    _selectedServices.add(matches.first);
                                  }
                                }
                              }
                              // Auto-select products/extras included in the offer
                              _selectedProducts.clear();
                              if (productsAsync.value != null) {
                                for (final prodId in val.productIds) {
                                  final matches = productsAsync.value!.where((p) => p.id == prodId);
                                  if (matches.isNotEmpty) {
                                    final prod = matches.first;
                                    final price = prod.unitPrice;
                                    _selectedProducts.add(TicketProduct(
                                      productId: prod.id,
                                      productName: prod.name,
                                      quantity: 1,
                                      unitPrice: price,
                                    ));
                                  }
                                }
                              }
                            } else {
                              _selectedServices.clear();
                              _selectedProducts.clear();
                            }
                          });
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                },
                loading: () => SizedBox(),
                error: (e, s) => SizedBox(),
              ),

              // Services Selection (dynamic based on category)
              serviceDefsAsync.when(
                data: (services) {
                  if (services.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⚠️ Aucun service configuré.\n'
                        'Veuillez d\'abord configurer les services dans l\'espace Patron.',
                        style: TextStyle(color: AppTheme.errorRed),
                      ),
                    );
                  }

                  final category = _selectedVehicleCategory ?? (categoriesAsync.value?.isNotEmpty == true ? categoriesAsync.value!.first : null);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services de Lavage (Sélectionnez un ou plusieurs)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: services.where((s) => s.serviceType == ServiceType.lavage).map((srv) {
                          final price = category != null ? srv.getPriceForCategory(category.id) : 0.0;
                          final isSelected = _selectedServices.any((s) => s.id == srv.id);
                          return FilterChip(
                            label: Text('${srv.name} (${price.toStringAsFixed(0)} DT)'),
                            selected: isSelected,
                            selectedColor: AppTheme.accentCyan.withValues(alpha: 0.2),
                            checkmarkColor: AppTheme.accentCyan,
                            onSelected: (selected) {
                              setState(() {
                                _selectedOffer = null; // deselect offer on manual change
                                if (selected) {
                                  _selectedServices.add(srv);
                                } else {
                                  _selectedServices.removeWhere((s) => s.id == srv.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erreur services: $e', style: TextStyle(color: AppTheme.errorRed)),
              ),
              SizedBox(height: 16),

                            serviceDefsAsync.when(
                data: (services) {
                  final extras = services.where((s) => s.serviceType == ServiceType.supplement).toList();
                  final category = _selectedVehicleCategory ?? (categoriesAsync.value?.isNotEmpty == true ? categoriesAsync.value!.first : null);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (extras.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text(
                          'Options & Suppléments (Extras)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: extras.map((srv) {
                            final isSelected = _selectedServices.any((s) => s.id == srv.id);
                            final price = category != null ? srv.getPriceForCategory(category.id) : 0.0;
                            final isIncludedInOffer = _selectedOffer != null && _selectedOffer!.serviceIds.contains(srv.id);
                            final labelText = isIncludedInOffer 
                                ? '${srv.name} (Inclus)'
                                : '${srv.name} (+${price.toStringAsFixed(0)} DT)';
                            return FilterChip(
                              label: Text(labelText),
                              selected: isSelected,
                              selectedColor: AppTheme.accentCyan.withValues(alpha: 0.2),
                              checkmarkColor: AppTheme.accentCyan,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedOffer = null;
                                  if (selected) {
                                    _selectedServices.add(srv);
                                  } else {
                                    _selectedServices.removeWhere((s) => s.id == srv.id);
                                  }
                                  _updateIncludedProducts();
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20),
                      ],
                    ],
                  );
                },
                loading: () => SizedBox(),
                error: (e, s) => SizedBox(),
              ),

              productsAsync.when(
                data: (products) {
                  final filteredBoutique = _getFilteredProducts(products.where((p) => p.family == ProductFamily.revente).toList());

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Boutique (Revente)', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _productSearchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher un produit/article (Nom ou Code-barres)'.tr,
                          prefixIcon: Icon(Icons.search, color: AppTheme.accentCyan),
                          hintText: 'Saisir le nom ou scanner le code-barres...'.tr,
                          suffixIcon: _productSearchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _productSearchController.clear();
                                      _productSearchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _productSearchQuery = val.trim().toLowerCase();
                          });
                        },
                        onFieldSubmitted: (val) {
                          final query = val.trim();
                          if (query.isNotEmpty) {
                            if (filteredBoutique.isNotEmpty) {
                              _addProduct(filteredBoutique.first);
                              _productSearchController.clear();
                              setState(() {
                                _productSearchQuery = '';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${filteredBoutique.first.name} ajouté'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppTheme.successGreen,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      SizedBox(height: 8),
                      if (filteredBoutique.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Aucun produit correspondant.',
                            style: TextStyle(color: AppTheme.textHint, fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        Container(
                          height: 100,
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredBoutique.length,
                            itemBuilder: (context, index) {
                              final product = filteredBoutique[index];
                              return Card(
                                margin: EdgeInsets.only(right: 8),
                                color: AppTheme.surfaceCard,
                                child: InkWell(
                                  onTap: () => _addProduct(product),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                  child: Container(
                                    width: 150,
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        if (product.barcode.isNotEmpty)
                                          Text(
                                            'CB: ${product.barcode}',
                                            style: TextStyle(fontSize: 10, color: AppTheme.textHint),
                                          ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${product.unitPrice} DT',
                                              style: TextStyle(fontSize: 11, color: AppTheme.accentCyan, fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Icon(Icons.add, size: 14, color: AppTheme.primaryBlue),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erreur produits: $e', style: TextStyle(color: AppTheme.errorRed)),
              ),

              // Selected Products List
              if (_selectedProducts.isNotEmpty) ...[
                productsAsync.when(
                  data: (products) => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedProducts.length,
                    itemBuilder: (context, index) {
                      final item = _selectedProducts[index];
                      final double freeQuota = _getFreeQuota(item.productId);
                      final double billedQuantity = (item.quantity - freeQuota).clamp(0.0, double.infinity);
                      final double displayTotal = billedQuantity * item.unitPrice;
                      
                      String priceText;
                      if (freeQuota > 0) {
                        if (billedQuantity > 0) {
                          priceText = '${freeQuota.toStringAsFixed(0)} Inclus + ${billedQuantity.toStringAsFixed(0)} Facturé(s) = ${displayTotal.toStringAsFixed(2)} DT';
                        } else {
                          priceText = 'Inclus (${freeQuota.toStringAsFixed(0)} max) - 0.00 DT';
                        }
                      } else {
                        priceText = '${item.quantity} x ${item.unitPrice.toStringAsFixed(2)} DT = ${displayTotal.toStringAsFixed(2)} DT';
                      }

                      return ListTile(
                        title: Text(item.productName),
                        subtitle: Text(priceText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, color: AppTheme.warningOrange),
                              onPressed: () => _removeProduct(item.productId),
                            ),
                            Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: AppTheme.successGreen),
                              onPressed: () {
                                final prod = products.firstWhere((p) => p.id == item.productId);
                                _addProduct(prod);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  loading: () => SizedBox(),
                  error: (e, s) => SizedBox(),
                ),
                SizedBox(height: 16),
              ],

// Worker Assignment
              employeesAsync.when(
                data: (employees) {
                  final shifts = shiftsAsync.valueOrNull ?? [];
                  final attendances = attendancesAsync.valueOrNull ?? [];
                  
                  Shift? currentShift;
                  final now = DateTime.now();
                  final currentMinutes = now.hour * 60 + now.minute;
                  for (final shift in shifts) {
                    final startParts = shift.startTime.split(':');
                    final endParts = shift.endTime.split(':');
                    if (startParts.length != 2 || endParts.length != 2) continue;
                    final startMins = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
                    final endMins = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
                    
                    if (startMins <= endMins) {
                      if (currentMinutes >= startMins && currentMinutes <= endMins) currentShift = shift;
                    } else {
                      if (currentMinutes >= startMins || currentMinutes <= endMins) currentShift = shift;
                    }
                  }

                  List<Employee> ouvriers = employees.toList();
                  
                  if (currentShift != null) {
                    final plannedEmployeeIds = attendances
                        .where((a) => a.shiftId == currentShift!.id && (a.status == AttendanceStatus.planned || a.status == AttendanceStatus.present))
                        .map((a) => a.employeeId)
                        .toSet();
                    ouvriers = ouvriers.where((e) => plannedEmployeeIds.contains(e.id)).toList();
                  } else {
                    final plannedEmployeeIds = attendances
                        .where((a) => (a.status == AttendanceStatus.planned || a.status == AttendanceStatus.present))
                        .map((a) => a.employeeId)
                        .toSet();
                    if (plannedEmployeeIds.isNotEmpty) {
                      ouvriers = ouvriers.where((e) => plannedEmployeeIds.contains(e.id)).toList();
                    }
                  }

                  // Force le filtre : l'ouvrier doit posséder le rôle 'ouvrier'
                  ouvriers = ouvriers.where((e) => e.roles.contains(UserRole.ouvrier)).toList();

                  if (ouvriers.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⚠️ Aucun ouvrier planifié pour le shift actuel. Veuillez planifier le pointage d\'abord.',
                        style: TextStyle(color: AppTheme.errorRed),
                      ),
                    );
                  }
                  
                  // Reset assigned worker if not in list
                  if (_assignedWorker != null && !ouvriers.any((e) => e.id == _assignedWorker!.id)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _assignedWorker = null);
                    });
                  }

                  return DropdownButtonFormField<Employee>(
                    value: _assignedWorker,
                    decoration: InputDecoration(
                      labelText: 'Ouvrier Assigné (Laveur)'.tr,
                      prefixIcon: Icon(Icons.engineering, color: AppTheme.accentCyan),
                      hintText: 'Qui va laver ce véhicule ?'.tr,
                    ),
                    items: ouvriers.map((emp) {
                      return DropdownMenuItem(
                        value: emp,
                        child: Text(emp.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _assignedWorker = val;
                      });
                    },
                    validator: (v) => v == null ? 'Veuillez sélectionner un ouvrier' : null,
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Erreur ouvriers: $e'.tr),
              ),
              SizedBox(height: 16),

              
              // Payment Method & Client Info
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paiement & Client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPaymentMethod,
                        decoration: InputDecoration(labelText: 'Moyen de paiement'.tr, prefixIcon: Icon(Icons.payment, color: AppTheme.primaryBlue)),
                        items: [
                          DropdownMenuItem(value: 'cash', child: Text('Espèces (Cash)'.tr)),
                          DropdownMenuItem(value: 'card', child: Text('Carte Bancaire'.tr)),
                          DropdownMenuItem(value: 'wallet', child: Text('Wallet / Mobile'.tr)),
                          DropdownMenuItem(value: 'compte_client', child: Text('Compte Client B2B'.tr)),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedPaymentMethod = val!;
                            if (val != 'compte_client') {
                              _selectedClient = null;
                            }
                          });
                        },
                      ),
                      SizedBox(height: 12),
                      if (_selectedPaymentMethod == 'compte_client') ...[
                        clientsAsync.when(
                          data: (clients) {
                            if (clients.isEmpty) return Text('Aucun client B2B trouvé. Créez-en un dans l\'espace Patron.', style: TextStyle(color: AppTheme.warningOrange));
                            return DropdownButtonFormField<Client>(
                              initialValue: _selectedClient,
                              decoration: InputDecoration(labelText: 'Sélectionner le compte client *'.tr, prefixIcon: Icon(Icons.business, color: AppTheme.primaryBlue)),
                              items: clients.map((c) => DropdownMenuItem(value: c, child: Text(c.companyName))).toList(),
                              onChanged: (val) => setState(() => _selectedClient = val),
                              validator: (v) => v == null ? 'Veuillez sélectionner un compte' : null,
                            );
                          },
                          loading: () => CircularProgressIndicator(),
                          error: (e, _) => Text('Erreur: $e'.tr),
                        ),
                        SizedBox(height: 12),
                      ],
                      if (_selectedPaymentMethod != 'compte_client') ...[
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Nom du client (Optionnel)'.tr, prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryBlue)),
                          onChanged: (val) => _clientName = val,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Téléphone (Optionnel)'.tr, prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryBlue)),
                          keyboardType: TextInputType.phone,
                          onChanged: (val) => _clientPhone = val,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Notes Input
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (options, état véhicule...)'.tr,
                  prefixIcon: Icon(Icons.note, color: AppTheme.accentCyan),
                ),
              ),
              SizedBox(height: 24),

              // Summary Total
              categoriesAsync.when(
                data: (categories) {
                  final selectedCategory = _selectedVehicleCategory ?? (categories.isNotEmpty ? categories.first : null);
                  final total = _calculateTotalAmount(selectedCategory);
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total à Payer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '${total.toStringAsFixed(2)} DT',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => SizedBox(),
                error: (e, s) => SizedBox(),
              ),
              SizedBox(height: 24),

              // Create Ticket Button
              categoriesAsync.when(
                data: (categories) {
                  final selectedCategory = _selectedVehicleCategory ?? (categories.isNotEmpty ? categories.first : null);
                  return ElevatedButton(
                    onPressed: _isSaving ? null : () => _submitTicket(selectedCategory),
                    child: _isSaving
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : Text('Enregistrer le Ticket'.tr),
                  );
                },
                loading: () => ElevatedButton(onPressed: null, child: Text('Chargement...'.tr)),
                error: (e, s) => ElevatedButton(onPressed: null, child: Text('Erreur'.tr)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkVehicleHistory() async {
    final plateUpper = _vehiclePlate.trim().toUpperCase();
    if (plateUpper.length < 6 || _lastQueriedPlate == plateUpper || _isQueryingHistory) return;

    _lastQueriedPlate = plateUpper;
    _isQueryingHistory = true;

    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.tenantId == null) return;
      
      bool foundB2B = false;
      bool uiUpdated = false;

      // 1. Check B2B clients
      final clientsAsync = ref.read(clientsStreamProvider(user.tenantId));
      if (clientsAsync.value != null) {
        for (final client in clientsAsync.value!) {
          for (final vehicle in client.vehicles) {
            if (vehicle.plate == plateUpper) {
              foundB2B = true;
              if (mounted) {
                setState(() {
                  _selectedPaymentMethod = 'compte_client';
                  _selectedClient = client;
                  if (vehicle.brand.isNotEmpty && _vehicleBrand.isEmpty) _vehicleBrand = vehicle.brand;
                  if (vehicle.model.isNotEmpty && _vehicleModel.isEmpty) _vehicleModel = vehicle.model;
                  
                  if (vehicle.categoryId.isNotEmpty) {
                    final categoriesAsync = ref.read(vehicleCategoriesStreamProvider(user.tenantId));
                    if (categoriesAsync.value != null) {
                      try {
                        _selectedVehicleCategory = categoriesAsync.value!.firstWhere((c) => c.id == vehicle.categoryId);
                      } catch (_) {}
                    }
                  }

                  if (_vehicleBrand.isNotEmpty || _vehicleModel.isNotEmpty) {
                    _vehicleInfoKey.currentState?.updateFields(_vehicleBrand, _vehicleModel);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Véhicule B2B détecté pour le client: ${client.companyName}'.tr), backgroundColor: AppTheme.successGreen),
                );
              }
              break;
            }
          }
          if (foundB2B) break;
        }
      }

      // 2. Query past tickets for walk-in clients (Client X) or to fill gaps for B2B
      if (!foundB2B || _vehicleBrand.isEmpty || _selectedVehicleCategory == null) {
        final repo = ref.read(ticketRepositoryProvider);
        final history = await repo.getTicketsByStation(user.tenantId, limit: 20); // We query latest tickets and filter locally to avoid indexing requirements
        
        final pastTickets = history.where((t) => t.vehiclePlate == plateUpper).toList();
        if (pastTickets.isNotEmpty) {
          final lastTicket = pastTickets.first;
          
          if (mounted) {
            setState(() {
              if (_vehicleBrand.isEmpty && (lastTicket.vehicleBrand?.isNotEmpty == true)) {
                _vehicleBrand = lastTicket.vehicleBrand!;
                uiUpdated = true;
              }
              if (_vehicleModel.isEmpty && (lastTicket.vehicleModel?.isNotEmpty == true)) {
                _vehicleModel = lastTicket.vehicleModel!;
                uiUpdated = true;
              }
              if (_selectedVehicleCategory == null && (lastTicket.vehicleCategoryId?.isNotEmpty == true)) {
                final categoriesAsync = ref.read(vehicleCategoriesStreamProvider(user.tenantId));
                if (categoriesAsync.value != null) {
                  try {
                    _selectedVehicleCategory = categoriesAsync.value!.firstWhere((c) => c.id == lastTicket.vehicleCategoryId);
                    uiUpdated = true;
                  } catch (_) {}
                }
              }

              if (uiUpdated) {
                _vehicleInfoKey.currentState?.updateFields(_vehicleBrand, _vehicleModel);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Véhicule connu détecté !'.tr), backgroundColor: AppTheme.accentCyan),
                );
              }
            });
          }
        }
      }

    } finally {
      _isQueryingHistory = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/service_provider.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/features/services/models/wash_service.dart';
import 'package:washify/features/products/models/product.dart';

class NewTicketScreen extends ConsumerStatefulWidget {
  const NewTicketScreen({super.key});

  @override
  ConsumerState<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends ConsumerState<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedVehicleType = 'Compacte';
  String _selectedPaymentMethod = 'cash';
  WashService? _selectedService;
  final List<TicketProduct> _selectedProducts = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _plateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addProduct(Product product) {
    setState(() {
      final existingIndex = _selectedProducts.indexWhere((p) => p.productId == product.id);
      if (existingIndex >= 0) {
        final existing = _selectedProducts[existingIndex];
        _selectedProducts[existingIndex] = TicketProduct(
          productId: product.id,
          productName: product.name,
          quantity: existing.quantity + 1,
          unitPrice: product.unitPrice,
        );
      } else {
        _selectedProducts.add(TicketProduct(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          unitPrice: product.unitPrice,
        ));
      }
    });
  }

  void _removeProduct(String productId) {
    setState(() {
      final existingIndex = _selectedProducts.indexWhere((p) => p.productId == productId);
      if (existingIndex >= 0) {
        final existing = _selectedProducts[existingIndex];
        if (existing.quantity > 1) {
          _selectedProducts[existingIndex] = TicketProduct(
            productId: productId,
            productName: existing.productName,
            quantity: existing.quantity - 1,
            unitPrice: existing.unitPrice,
          );
        } else {
          _selectedProducts.removeAt(existingIndex);
        }
      }
    });
  }

  double get _totalAmount {
    double total = _selectedService?.price ?? 0;
    for (final p in _selectedProducts) {
      total += p.total;
    }
    return total;
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate() || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un service de lavage')),
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

      final newTicket = Ticket(
        id: '',
        tenantId: user.stationId!,
        ticketNumber: ticketNum,
        createdBy: user.name,
        paidBy: user.name,
        status: TicketStatus.enAttente,
        montant: _totalAmount,
        snapshotPrice: {'price': _selectedService!.price},
        vehiclePlate: _plateController.text.trim().toUpperCase(),
        vehicleType: _selectedVehicleType,
        serviceId: _selectedService!.id,
        serviceName: _selectedService!.name,
        productsUsed: _selectedProducts,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.createTicket(newTicket);
      ref.invalidate(todayTicketsStreamProvider(user.stationId!));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket créé avec succès')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final servicesAsync = ref.watch(servicesByStationProvider(user.stationId!));
    final productsAsync = ref.watch(productsByStationProvider(user.stationId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Plate
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Plaque d\'Immatriculation',
                  prefixIcon: Icon(Icons.pin, color: AppTheme.accentCyan),
                  hintText: 'ex: 123 TUN 4567',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Vehicle Type
              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleType,
                decoration: const InputDecoration(
                  labelText: 'Type de Véhicule',
                  prefixIcon: Icon(Icons.directions_car, color: AppTheme.accentCyan),
                ),
                items: const [
                  DropdownMenuItem(value: 'Compacte', child: Text('Berline / Compacte')),
                  DropdownMenuItem(value: 'SUV', child: Text('SUV / 4x4')),
                  DropdownMenuItem(value: 'Moto', child: Text('Moto / Scooter')),
                  DropdownMenuItem(value: 'Utilitaire', child: Text('Camionnette / Utilitaire')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedVehicleType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Services Selection
              servicesAsync.when(
                data: (services) => DropdownButtonFormField<WashService>(
                  initialValue: _selectedService,
                  decoration: const InputDecoration(
                    labelText: 'Service de Lavage',
                    prefixIcon: Icon(Icons.dry_cleaning, color: AppTheme.accentCyan),
                  ),
                  items: services
                      .map((srv) => DropdownMenuItem(
                            value: srv,
                            child: Text('${srv.name} (${srv.price.toStringAsFixed(2)} DT)'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedService = val;
                    });
                  },
                  validator: (v) => v == null ? 'Veuillez sélectionner un service' : null,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erreur services: $e'),
              ),
              const SizedBox(height: 16),

              // Payment Method
              DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Moyen de Paiement',
                  prefixIcon: Icon(Icons.payment, color: AppTheme.accentCyan),
                ),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Espèces (Cash)')),
                  DropdownMenuItem(value: 'card', child: Text('Carte Bancaire')),
                  DropdownMenuItem(value: 'wallet', child: Text('Wallet / Mobile')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedPaymentMethod = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Products Used Section
              Text(
                'Consommation Détergents / Produits',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Text('Aucun produit disponible en station.', style: TextStyle(color: AppTheme.textHint));
                  }
                  return Container(
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _addProduct(product),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${product.unitPrice} DT/${product.unit}', style: const TextStyle(fontSize: 10, color: AppTheme.accentCyan)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erreur produits: $e'),
              ),

              // Selected Products List
              if (_selectedProducts.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedProducts.length,
                  itemBuilder: (context, index) {
                    final item = _selectedProducts[index];
                    return ListTile(
                      title: Text(item.productName),
                      subtitle: Text('${item.quantity} x ${item.unitPrice} DT = ${item.total.toStringAsFixed(2)} DT'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.errorRed),
                            onPressed: () => _removeProduct(item.productId),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Notes Input
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (options, état véhicule...)',
                  prefixIcon: Icon(Icons.note, color: AppTheme.accentCyan),
                ),
              ),
              const SizedBox(height: 24),

              // Summary Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total à Payer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '${_totalAmount.toStringAsFixed(2)} DT',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Create Ticket Button
              ElevatedButton(
                onPressed: _isSaving ? null : _submitTicket,
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Text('Enregistrer le Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

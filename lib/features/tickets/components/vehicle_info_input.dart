import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/vehicle_catalog_provider.dart';
import 'package:washify/features/tickets/models/vehicle_catalog.dart';
import 'package:washify/providers/auth_provider.dart';

class VehicleInfoInput extends ConsumerStatefulWidget {
  final Function(String plate, String brand, String model) onChanged;
  final String? initialPlate;
  final String? initialBrand;
  final String? initialModel;

  const VehicleInfoInput({
    super.key,
    required this.onChanged,
    this.initialPlate,
    this.initialBrand,
    this.initialModel,
  });

  @override
  ConsumerState<VehicleInfoInput> createState() => VehicleInfoInputState();
}

class VehicleInfoInputState extends ConsumerState<VehicleInfoInput> {
  bool _isStandardPlate = true;

  final _tuPart1Controller = TextEditingController();
  final _tuPart2Controller = TextEditingController();
  final _otherPlateController = TextEditingController();

  String _selectedBrand = '';
  final _otherBrandController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize plate
    if (widget.initialPlate != null && widget.initialPlate!.isNotEmpty) {
      final parts = widget.initialPlate!.split(' TU ');
      if (parts.length == 2) {
        _isStandardPlate = true;
        _tuPart1Controller.text = parts[0];
        _tuPart2Controller.text = parts[1];
      } else {
        _isStandardPlate = false;
        _otherPlateController.text = widget.initialPlate!;
      }
    }

    // Initialize brand
    if (widget.initialBrand != null && widget.initialBrand!.isNotEmpty) {
      _selectedBrand = widget.initialBrand!;
    }

    // Initialize model
    if (widget.initialModel != null) {
      _modelController.text = widget.initialModel!;
    }

    _tuPart1Controller.addListener(_notifyChange);
    _tuPart2Controller.addListener(_notifyChange);
    _otherPlateController.addListener(_notifyChange);
    _otherBrandController.addListener(_notifyChange);
    _modelController.addListener(_notifyChange);
  }

  @override
  void dispose() {
    _tuPart1Controller.dispose();
    _tuPart2Controller.dispose();
    _otherPlateController.dispose();
    _otherBrandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void updateFields(String brand, String model) {
    if (brand.isNotEmpty) {
      _selectedBrand = brand;
    }
    if (model.isNotEmpty) {
      _modelController.text = model;
    }
    if (mounted) setState(() {});
    _notifyChange();
  }

  void _notifyChange() {
    String plate = '';
    if (_isStandardPlate) {
      if (_tuPart1Controller.text.isNotEmpty || _tuPart2Controller.text.isNotEmpty) {
        plate = '${_tuPart1Controller.text} TU ${_tuPart2Controller.text}'.trim();
      }
    } else {
      plate = _otherPlateController.text.trim();
    }

    String brand = _selectedBrand == 'Autre' ? _otherBrandController.text.trim() : _selectedBrand;
    String model = _modelController.text.trim();

    widget.onChanged(plate, brand, model);
  }

  void _showBrandManagementDialog(VehicleCatalog catalog) {
    final user = ref.read(currentUserProvider);
    final stationId = user?.tenantId ?? '';
    final repo = ref.read(vehicleCatalogRepositoryProvider);
    final newBrandController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDState) {
          final customBrands = catalog.customBrands;

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.style, color: AppTheme.accentCyan),
                const SizedBox(width: 8),
                Text('Gestion des Marques'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ajouter ou gérer vos marques personnalisées de la station :'.tr,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newBrandController,
                          decoration: InputDecoration(
                            labelText: 'Nouvelle Marque (ex: BYD, Geely)'.tr,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final bName = newBrandController.text.trim();
                          if (bName.isNotEmpty) {
                            await repo.addBrand(stationId, bName);
                            newBrandController.clear();
                            if (dialogCtx.mounted) setDState(() {});
                          }
                        },
                        child: Text('Ajouter'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('Marques Personnalisées (Ajoutées) :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (customBrands.isEmpty)
                    Text('Aucune marque personnalisée.'.tr, style: const TextStyle(fontSize: 12, color: AppTheme.textHint))
                  else
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        itemCount: customBrands.length,
                        itemBuilder: (ctx, i) {
                          final brandName = customBrands[i];
                          return ListTile(
                            dense: true,
                            title: Text(brandName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 20),
                              onPressed: () async {
                                await repo.deleteBrand(stationId, brandName);
                                if (dialogCtx.mounted) setDState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('Fermer'.tr),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlateSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Plaque d\'immatriculation'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    Text('Standard (TU)'.tr, style: const TextStyle(fontSize: 12)),
                    Switch(
                      value: _isStandardPlate,
                      onChanged: (val) {
                        setState(() => _isStandardPlate = val);
                        _notifyChange();
                      },
                      activeThumbColor: AppTheme.accentCyan,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isStandardPlate)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tuPart1Controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                      decoration: InputDecoration(
                        hintText: '1234',
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('TU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppTheme.primaryBlue)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _tuPart2Controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                      decoration: InputDecoration(
                        hintText: '56',
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              )
            else
              TextField(
                controller: _otherPlateController,
                decoration: InputDecoration(
                  labelText: 'Saisir la plaque'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.directions_car),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection(VehicleCatalog catalog) {
    final availableBrands = catalog.allBrands;

    // Check if current _selectedBrand is not in availableBrands and not 'Autre'
    bool isCustomUnlisted = _selectedBrand.isNotEmpty &&
        _selectedBrand != 'Autre' &&
        !availableBrands.contains(_selectedBrand);

    if (isCustomUnlisted && _otherBrandController.text.isEmpty) {
      _otherBrandController.text = _selectedBrand;
      _selectedBrand = 'Autre';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marque et Modèle'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            // All Brands Choice Chips (Includes newly saved custom brands!)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: availableBrands.map((brand) {
                  final isSelected = _selectedBrand == brand;
                  final isCustom = catalog.customBrands.contains(brand);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCustom) const Icon(Icons.star, size: 12, color: Colors.amber),
                          if (isCustom) const SizedBox(width: 4),
                          Text(
                            brand,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: AppTheme.accentCyan,
                      backgroundColor: Colors.grey.shade200,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedBrand = brand);
                          _notifyChange();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            if (_selectedBrand.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedBrand == 'Autre')
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TextField(
                          controller: _otherBrandController,
                          decoration: InputDecoration(
                            labelText: 'Préciser la marque (ex: BYD, Geely)'.tr,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: 'Modèle (ex: 208, Clio, Golf)'.tr,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(currentVehicleCatalogStreamProvider);
    final catalog = catalogAsync.value ?? VehicleCatalog.empty('');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPlateSection(),
        const SizedBox(height: 12),
        _buildBrandSection(catalog),
      ],
    );
  }
}

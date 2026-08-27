import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/vehicle_catalog_provider.dart';
import 'package:washify/features/tickets/models/vehicle_catalog.dart';

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

  final List<String> _brands = [
    'Peugeot',
    'Citroën',
    'Renault',
    'VW',
    'Dacia',
    'Toyota',
    'Hyundai',
    'Kia',
    'Isuzu',
    'BYD',
    'Mercedes',
    'BMW',
    'Audi',
    'MG',
    'Chery',
    'Ford',
    'Fiat',
    'Nissan',
    'Skoda',
    'Seat',
    'Suzuki',
    'Autre',
  ];

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
      if (_brands.contains(widget.initialBrand)) {
        _selectedBrand = widget.initialBrand!;
      } else {
        _selectedBrand = 'Autre';
        _otherBrandController.text = widget.initialBrand!;
      }
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
      if (_brands.contains(brand)) {
        _selectedBrand = brand;
      } else {
        _selectedBrand = 'Autre';
        _otherBrandController.text = brand;
      }
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
    final effectiveBrandName = _selectedBrand == 'Autre' ? _otherBrandController.text.trim() : _selectedBrand;
    final allKnownModels = catalog.getModelsForBrand(effectiveBrandName);

    // Filter matching models based on what user typed in _modelController
    final modelInputText = _modelController.text.trim().toLowerCase();
    final matchingModels = modelInputText.isEmpty
        ? <String>[]
        : allKnownModels
            .where((m) => m.toLowerCase().contains(modelInputText))
            .toList();

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
            const SizedBox(height: 12),

            // Standard clean brands list with 'Autre' at the end
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _brands.map((brand) {
                  final isSelected = _selectedBrand == brand;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        brand,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _modelController,
                          onChanged: (_) {
                            setState(() {}); // Rebuild to update matching autocomplete suggestions
                          },
                          decoration: InputDecoration(
                            labelText: 'Modèle (ex: Golf 7, Tang, Q7)'.tr,
                            hintText: 'Saisissez le modèle...'.tr,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: matchingModels.isNotEmpty
                                ? const Icon(Icons.auto_awesome, color: AppTheme.accentCyan, size: 20)
                                : null,
                          ),
                        ),

                        // Inline Autocomplete suggestion list if user types e.g. "Q" and "Q7" exists in history
                        if (matchingModels.isNotEmpty &&
                            !matchingModels.any((m) => m.toLowerCase() == modelInputText)) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.25)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.auto_awesome, size: 14, color: AppTheme.accentCyan),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Suggestions d\'autocomplétion :'.tr,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: matchingModels.take(5).map((m) {
                                    return InkWell(
                                      onTap: () {
                                        _modelController.text = m;
                                        setState(() {});
                                        _notifyChange();
                                      },
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentCyan,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              m,
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.check_circle_outline, color: Colors.white, size: 13),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

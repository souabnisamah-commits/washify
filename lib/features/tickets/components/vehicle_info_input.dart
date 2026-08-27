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
  final _modelController = TextEditingController();
  final Set<String> _addedBrands = {};

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
      _addedBrands.add(widget.initialBrand!);
    }

    // Initialize model
    if (widget.initialModel != null) {
      _modelController.text = widget.initialModel!;
    }

    _tuPart1Controller.addListener(_notifyChange);
    _tuPart2Controller.addListener(_notifyChange);
    _otherPlateController.addListener(_notifyChange);
    _modelController.addListener(_notifyChange);
  }

  @override
  void dispose() {
    _tuPart1Controller.dispose();
    _tuPart2Controller.dispose();
    _otherPlateController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void updateFields(String brand, String model) {
    if (brand.isNotEmpty) {
      _selectedBrand = brand;
      _addedBrands.add(brand);
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

    String brand = _selectedBrand;
    String model = _modelController.text.trim();

    widget.onChanged(plate, brand, model);
  }

  void _showAddNewBrandDialog() {
    final user = ref.read(currentUserProvider);
    final stationId = user?.tenantId ?? '';
    final repo = ref.read(vehicleCatalogRepositoryProvider);
    final newBrandController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_circle_outline, color: AppTheme.accentCyan),
            const SizedBox(width: 8),
            Text('Ajouter une Nouvelle Marque'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Saisissez la marque (ex: Geely, BYD, Chery). Elle s\'ajoutera immédiatement à la liste et sera enregistrée pour la station :'.tr,
              style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newBrandController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nom de la Marque *'.tr,
                hintText: 'ex: Geely, BYD, Chery',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Annuler'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.white),
            onPressed: () async {
              final bName = newBrandController.text.trim();
              if (bName.isNotEmpty) {
                if (mounted) {
                  setState(() {
                    _addedBrands.add(bName);
                    _selectedBrand = bName;
                  });
                  _notifyChange();
                }
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);

                if (stationId.isNotEmpty) {
                  await repo.addBrand(stationId, bName);
                  ref.invalidate(currentVehicleCatalogStreamProvider);
                }
              }
            },
            child: Text('Ajouter & Sélectionner'.tr),
          ),
        ],
      ),
    );
  }

  void _showEditDeleteBrandDialog(String currentBrand) {
    final user = ref.read(currentUserProvider);
    final stationId = user?.tenantId ?? '';
    final repo = ref.read(vehicleCatalogRepositoryProvider);
    final editController = TextEditingController(text: currentBrand);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppTheme.accentCyan),
            const SizedBox(width: 8),
            Text('Gérer la marque "$currentBrand"'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Vous pouvez modifier le nom de la marque ou la supprimer définitivement du catalogue de la station :'.tr,
              style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nouveau nom de la marque'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text('Supprimer'.tr),
            onPressed: () async {
              if (stationId.isNotEmpty) {
                await repo.deleteBrand(stationId, currentBrand);
                _addedBrands.remove(currentBrand);
                if (_selectedBrand.toLowerCase() == currentBrand.toLowerCase()) {
                  _selectedBrand = '';
                }
                if (mounted) setState(() {});
                _notifyChange();
                ref.invalidate(currentVehicleCatalogStreamProvider);
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Annuler'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.white),
            onPressed: () async {
              final newName = editController.text.trim();
              if (newName.isNotEmpty && newName != currentBrand) {
                if (stationId.isNotEmpty) {
                  await repo.updateBrand(stationId, currentBrand, newName);
                  _addedBrands.remove(currentBrand);
                  _addedBrands.add(newName);
                  if (_selectedBrand.toLowerCase() == currentBrand.toLowerCase()) {
                    _selectedBrand = newName;
                  }
                  if (mounted) setState(() {});
                  _notifyChange();
                  ref.invalidate(currentVehicleCatalogStreamProvider);
                }
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            child: Text('Enregistrer'.tr),
          ),
        ],
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
    // Combine catalog brands + locally added brands
    final allBrandsSet = <String>{
      ...VehicleCatalog.defaultBrands,
      ...catalog.customBrands,
      ..._addedBrands,
    };
    final availableBrands = allBrandsSet.toList()..sort();

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
                Text('Marque et Modèle'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text(
                  '⭐ = Marque ajoutée (cliquer ✏️ pour modifier/supprimer)',
                  style: TextStyle(fontSize: 11, color: AppTheme.textHint),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Brands Chips + Plus Button (+)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...availableBrands.map((brand) {
                    final isSelected = _selectedBrand.toLowerCase() == brand.toLowerCase();
                    final isCustom = catalog.customBrands.any((b) => b.toLowerCase() == brand.toLowerCase()) ||
                        (_addedBrands.contains(brand) && !VehicleCatalog.defaultBrands.contains(brand));

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accentCyan : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? Border.all(color: AppTheme.primaryBlue, width: 1.5) : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Brand Selection Target
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  setState(() => _selectedBrand = brand);
                                  _notifyChange();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isCustom) const Icon(Icons.star, size: 12, color: Colors.amber),
                                      if (isCustom) const SizedBox(width: 4),
                                      Text(
                                        brand,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black87,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Independent Edit Pencil Button Target (for custom brands)
                              if (isCustom)
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => _showEditDeleteBrandDialog(brand),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0, left: 2.0, top: 6.0, bottom: 6.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit_rounded,
                                        size: 13,
                                        color: isSelected ? Colors.white : AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // [+] Button to add a new brand instantly to the list!
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      avatar: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: Text(
                        '+ Marque'.tr,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppTheme.accentCyan,
                      onPressed: _showAddNewBrandDialog,
                    ),
                  ),
                ],
              ),
            ),

            if (_selectedBrand.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Modèle de la voiture (ex: Golf 7, Tang, Clio)'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.directions_car_filled, color: AppTheme.accentCyan),
                ),
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

import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:washify/core/theme/app_theme.dart';

class VehicleInfoInput extends StatefulWidget {
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
  State<VehicleInfoInput> createState() => VehicleInfoInputState();
}

class VehicleInfoInputState extends State<VehicleInfoInput> {
  bool _isStandardPlate = true;
  
  final _tuPart1Controller = TextEditingController();
  final _tuPart2Controller = TextEditingController();
  final _otherPlateController = TextEditingController();
  
  final List<String> _brands = [
    'Peugeot', 'Citroën', 'Renault', 'VW', 'Dacia', 'Toyota', 
    'Hyundai', 'Kia', 'Isuzu', 'BYD', 'Mercedes', 'BMW', 'Audi', 'MG', 'Chery', 'Autre'
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
    setState(() {}); // Trigger rebuild to show the updated chips
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Plaque d\'immatriculation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    Text('Standard (TU)', style: TextStyle(fontSize: 12)),
                    Switch(
                      value: _isStandardPlate,
                      onChanged: (val) {
                        setState(() => _isStandardPlate = val);
                        _notifyChange();
                      },
                      activeThumbColor: AppTheme.accentCyan,
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 8),
            if (_isStandardPlate)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tuPart1Controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                      decoration: InputDecoration(
                        hintText: '1234',
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('TU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppTheme.primaryBlue)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _tuPart2Controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                      decoration: InputDecoration(
                        hintText: '56',
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                  prefixIcon: Icon(Icons.directions_car),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marque et Modèle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _brands.map((brand) {
                  final isSelected = _selectedBrand == brand;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(brand, style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      )),
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
              SizedBox(height: 16),
              Row(
                children: [
                  if (_selectedBrand == 'Autre')
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: TextField(
                          controller: _otherBrandController,
                          decoration: InputDecoration(
                            labelText: 'Préciser la marque'.tr,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: 'Modèle (ex: 208, Clio)'.tr,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPlateSection(),
        SizedBox(height: 12),
        _buildBrandSection(),
      ],
    );
  }
}

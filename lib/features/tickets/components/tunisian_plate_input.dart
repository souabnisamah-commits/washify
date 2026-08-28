import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:washify/core/theme/app_theme.dart';

class TunisianPlateInput extends StatefulWidget {
  final Function(String plate) onChanged;
  final String? initialValue;

  const TunisianPlateInput({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<TunisianPlateInput> createState() => _TunisianPlateInputState();
}

class _TunisianPlateInputState extends State<TunisianPlateInput> {
  bool _isStandardPlate = true;
  
  final _tuPart1Controller = TextEditingController();
  final _tuPart2Controller = TextEditingController();
  final _otherPlateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tuPart1Controller.addListener(_notifyChange);
    _tuPart2Controller.addListener(_notifyChange);
    _otherPlateController.addListener(_notifyChange);

    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      if (widget.initialValue!.contains(' TU ')) {
        final parts = widget.initialValue!.split(' TU ');
        if (parts.length == 2) {
          _tuPart1Controller.text = parts[0];
          _tuPart2Controller.text = parts[1];
          _isStandardPlate = true;
        }
      } else {
        _otherPlateController.text = widget.initialValue!;
        _isStandardPlate = false;
      }
    }
  }

  @override
  void dispose() {
    _tuPart1Controller.dispose();
    _tuPart2Controller.dispose();
    _otherPlateController.dispose();
    super.dispose();
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
    
    widget.onChanged(plate.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Plaque d\'immatriculation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Text('Standard (TU)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(width: 8),
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
          SizedBox(height: 12),
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
                  child: Text('TU'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue)),
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
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Saisir la plaque'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.directions_car),
              ),
            ),
        ],
      ),
    );
  }
}

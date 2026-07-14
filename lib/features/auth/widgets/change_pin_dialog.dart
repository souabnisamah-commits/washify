import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';

class ChangePinDialog extends ConsumerStatefulWidget {
  const ChangePinDialog({super.key});

  @override
  ConsumerState<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends ConsumerState<ChangePinDialog> {
  final _oldPinController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPinController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final oldPin = _oldPinController.text.trim();
      final newPin = _pinController.text.trim();
      
      final success = await ref.read(currentUserProvider.notifier).changePin(oldPin, newPin);
      
      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code PIN modifié avec succès.'.tr)),
          );
        } else {
          setState(() {
            _errorMessage = "L'ancien PIN est incorrect.".tr;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur: $e";
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Changer mon code PIN'.tr),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _oldPinController,
              decoration: InputDecoration(labelText: 'Ancien code PIN'.tr),
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Requis'.tr : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'Nouveau code PIN (4 chiffres)'.tr),
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (v) => v == null || v.length < 4 ? 'PIN invalide'.tr : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPinController,
              decoration: InputDecoration(labelText: 'Confirmer le code PIN'.tr),
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis'.tr;
                if (v != _pinController.text) return 'Les PINs ne correspondent pas'.tr;
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'.tr),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Enregistrer'.tr),
        ),
      ],
    );
  }
}

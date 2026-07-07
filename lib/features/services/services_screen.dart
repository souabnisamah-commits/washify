import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/service_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/services/models/wash_service.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _createService() async {
    if (!_formKey.currentState!.validate()) return;

    final station = ref.read(selectedStationProvider);
    if (station == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(serviceRepositoryProvider);
      final newService = WashService(
        id: '',
        tenantId: station.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text),
        durationMinutes: int.parse(_durationController.text),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.createService(newService);
      ref.invalidate(servicesStreamProvider(station.id));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service créé avec succès'.tr)),
      );

      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _durationController.clear();
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

  Future<void> _updateService(WashService service) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(serviceRepositoryProvider);
      final updatedService = service.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text),
        durationMinutes: int.parse(_durationController.text),
        updatedAt: DateTime.now(),
      );

      await repo.updateService(updatedService);
      ref.invalidate(servicesStreamProvider(service.tenantId));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service modifié avec succès'.tr)),
      );

      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _durationController.clear();
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

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un Service'.tr),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nom du service'.tr),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(labelText: 'Description'.tr),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Prix (DT)'.tr),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Prix invalide' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Durée (minutes)'.tr),
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Durée invalide' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : _createService,
              child: _isSaving
                  ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Créer'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showEditServiceDialog(WashService service) {
    _nameController.text = service.name;
    _descController.text = service.description;
    _priceController.text = service.price.toString();
    _durationController.text = service.durationMinutes.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le Service'.tr),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nom du service'.tr),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(labelText: 'Description'.tr),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Prix (DT)'.tr),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Prix invalide' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Durée (minutes)'.tr),
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Durée invalide' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _nameController.clear();
                _descController.clear();
                _priceController.clear();
                _durationController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : () => _updateService(service),
              child: _isSaving
                  ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Enregistrer'.tr),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = ref.watch(selectedStationProvider);

    if (selectedStation == null) {
      return Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station sur le Dashboard.')),
      );
    }

    final servicesStream = ref.watch(servicesStreamProvider(selectedStation.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Services - ${selectedStation.name}'.tr),
      ),
      body: servicesStream.when(
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Text('Aucun service configuré pour cette station.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.accentTeal,
                    child: Icon(Icons.dry_cleaning, color: Colors.white),
                  ),
                  title: Text(service.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${service.description}\nDurée: ${service.durationMinutes} min'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${service.price.toStringAsFixed(2)} DT',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCyan, fontSize: 16),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.edit, color: AppTheme.textHint),
                        onPressed: () => _showEditServiceDialog(service),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

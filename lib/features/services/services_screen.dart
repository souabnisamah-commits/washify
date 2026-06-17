import 'package:flutter/material.dart';
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
        const SnackBar(content: Text('Service créé avec succès')),
      );

      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _durationController.clear();
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

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un Service'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom du service'),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Prix (DT)'),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Prix invalide' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Durée (minutes)'),
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Durée invalide' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : _createService,
              child: _isSaving
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Créer'),
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
      return const Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station sur le Dashboard.')),
      );
    }

    final servicesStream = ref.watch(servicesStreamProvider(selectedStation.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Services - ${selectedStation.name}'),
      ),
      body: servicesStream.when(
        data: (services) {
          if (services.isEmpty) {
            return const Center(
              child: Text('Aucun service configuré pour cette station.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.accentTeal,
                    child: Icon(Icons.dry_cleaning, color: Colors.white),
                  ),
                  title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${service.description}\nDurée: ${service.durationMinutes} min'),
                  trailing: Text(
                    '${service.price.toStringAsFixed(2)} DT',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCyan, fontSize: 16),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

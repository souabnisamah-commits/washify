import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/station/models/station.dart';

class StationsScreen extends ConsumerStatefulWidget {
  const StationsScreen({super.key});

  @override
  ConsumerState<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends ConsumerState<StationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createStation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(stationRepositoryProvider);
      final newStation = Station(
        id: '',
        tenantId: '',
        name: _nameController.text.trim(),
        gerantName: 'Gérant ${_nameController.text.trim()}',
        phone: _phoneController.text.trim(),
        email: 'station@washify.tn',
        matriculeFiscale: 'MF-0000',
        latitude: 36.8065,
        longitude: 10.1815,
        logoUrl: '',
        licence: LicenceStatus.active,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.createStation(newStation);
      ref.invalidate(stationsStreamProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station créée avec succès')),
      );

      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
      _phoneController.clear();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du traitement : $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showAddStationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une Station'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom de la station'),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Ville'),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
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
              onPressed: _isSaving ? null : _createStation,
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
    final stationsStream = ref.watch(stationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Stations'),
      ),
      body: stationsStream.when(
        data: (stations) {
          if (stations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 48, color: AppTheme.textHint.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('Aucune station disponible', style: TextStyle(color: AppTheme.textHint)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: Icon(Icons.store, color: Colors.white),
                  ),
                  title: Text(station.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${station.address}, ${station.city}\nTel: ${station.phone}'),
                  trailing: const Icon(Icons.edit, color: AppTheme.accentCyan),
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
        onPressed: _showAddStationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

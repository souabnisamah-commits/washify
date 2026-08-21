import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/features/services/models/service_definition.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/repositories/ticket_repository.dart';

class PatronStationSettingsScreen extends ConsumerStatefulWidget {
  const PatronStationSettingsScreen({super.key});

  @override
  ConsumerState<PatronStationSettingsScreen> createState() => _PatronStationSettingsScreenState();
}

class _PatronStationSettingsScreenState extends ConsumerState<PatronStationSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;

  bool _initialized = false;
  bool _isSaving = false;
  Station? _station;
  int _ticketResetHour = 21;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _initFields(Station station) {
    if (_initialized) return;
    _station = station;
    _phoneController = TextEditingController(text: station.phone);
    _addressController = TextEditingController(text: station.address);
    _cityController = TextEditingController(text: station.city);
    _ticketResetHour = station.ticketResetHour;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.stationId == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stationAsync = ref.watch(stationByIdProvider(user.stationId!));
    final productsAsync = ref.watch(productsStreamProvider(user.stationId!));

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres Station'.tr),
      ),
      body: stationAsync.when(
        data: (station) {
          if (station == null) {
            return Center(child: Text('Station introuvable.'.tr));
          }
          _initFields(station);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Glassmorphism Card for general settings
                  _buildGlassCard(
                    title: 'Informations Générales'.tr,
                    icon: Icons.storefront,
                    children: [
                      Text(
                        'Nom de la Station: ${station.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Téléphone'.tr,
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Requis'.tr : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Adresse'.tr,
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'Ville'.tr,
                          prefixIcon: const Icon(Icons.location_city),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Glassmorphism Card for Ticket Counter Settings
                  _buildGlassCard(
                    title: 'Réinitialisation des Tickets'.tr,
                    icon: Icons.access_time,
                    children: [
                      Text(
                        'Choisissez l\'heure quotidienne à laquelle le numéro des tickets se réinitialise automatiquement à N°:001 (ex: 21:00 à la clôture ou 00:00 à minuit).'.tr,
                        style: TextStyle(color: AppTheme.textHint, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _ticketResetHour,
                        decoration: InputDecoration(
                          labelText: 'Heure de réinitialisation quotidienne'.tr,
                          prefixIcon: const Icon(Icons.timer_outlined),
                        ),
                        items: List.generate(24, (index) {
                          final hourStr = '${index.toString().padLeft(2, '0')}:00';
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(index == 21 ? '$hourStr (Recommandé : 21h)' : (index == 0 ? '$hourStr (Minuit : 00h)' : hourStr)),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _ticketResetHour = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Réinitialiser le compteur du jour ?'.tr),
                              content: Text('Voulez-vous forcer la réinitialisation du compteur à N°:001 pour la journée en cours ?'.tr),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Annuler'.tr),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Réinitialiser à N°:001'.tr, style: const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && _station != null) {
                            await ref.read(ticketRepositoryProvider).resetTodayCounter(_station!.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Le compteur du jour a été réinitialisé à N°:001'.tr),
                                  backgroundColor: AppTheme.successGreen,
                                ),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.warningOrange,
                          side: const BorderSide(color: AppTheme.warningOrange),
                        ),
                        icon: const Icon(Icons.restart_alt),
                        label: Text('Réinitialiser le compteur du jour à N°:001'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.save),
                    label: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Enregistrer les Paramètres'.tr, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    if (_station == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(stationRepositoryProvider);

      final updatedStation = _station!.copyWith(
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        ticketResetHour: _ticketResetHour,
        updatedAt: DateTime.now(),
      );

      await repo.updateStation(updatedStation);
      ref.invalidate(stationByIdProvider(_station!.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paramètres enregistrés avec succès'.tr),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'.tr)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/features/stations/manage_profiles_dialog.dart';

// Tailwind Colors
const _cPrimary = Color(0xFF0052FF);
const _cSurface = Color(0xFFF8F9FF);
const _cWhite = Colors.white;

const _cSlate50 = Color(0xFFF8FAFC);
const _cSlate100 = Color(0xFFF1F5F9);
const _cSlate400 = Color(0xFF94A3B8);
const _cSlate500 = Color(0xFF64748B);
const _cSlate600 = Color(0xFF475569);
const _cSlate800 = Color(0xFF1E293B);
const _cSlate900 = Color(0xFF0F172A);

const _cGreen100 = Color(0xFFDCFCE7);
const _cGreen700 = Color(0xFF15803D);

const _cOrange100 = Color(0xFFFFEDD5);
const _cOrange700 = Color(0xFFC2410C);

const _cRed500 = Color(0xFFEF4444);

class StationsScreen extends ConsumerStatefulWidget {
  const StationsScreen({super.key});

  @override
  ConsumerState<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends ConsumerState<StationsScreen> {
  String _searchQuery = '';

  Future<void> _deleteStation(Station station) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Supprimer la station'.tr),
          content: Text('Voulez-vous vraiment supprimer la station "${station.name}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _cRed500),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Supprimer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final repo = ref.read(stationRepositoryProvider);
        await repo.deleteStation(station.id);
        ref.invalidate(stationsStreamProvider);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Station supprimée avec succès'.tr)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : $e'.tr)),
        );
      }
    }
  }

  Future<void> _showRenewalDialog(Station station) async {
    int selectedMonths = 1;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Renouveler l\'abonnement'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Station : ${station.name}'.tr),
                  SizedBox(height: 16),
                  Text('Durée de renouvellement :'.tr),
                  SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: selectedMonths,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      DropdownMenuItem(value: 1, child: Text('1 mois'.tr)),
                      DropdownMenuItem(value: 2, child: Text('2 mois'.tr)),
                      DropdownMenuItem(value: 3, child: Text('3 mois'.tr)),
                      DropdownMenuItem(value: 6, child: Text('6 mois'.tr)),
                      DropdownMenuItem(value: 12, child: Text('1 an (12 mois)'.tr)),
                    ],
                    onChanged: (v) => setState(() => selectedMonths = v ?? 1),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Annuler'.tr),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _cGreen700),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Renouveler', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      try {
        final now = DateTime.now();
        DateTime baseDate = station.expiryDate ?? now;
        
        // Si la station est déjà expirée, on repart d'aujourd'hui
        if (baseDate.isBefore(now)) {
          baseDate = now;
        }

        final newExpiry = DateTime(baseDate.year, baseDate.month + selectedMonths, baseDate.day);

        final repo = ref.read(stationRepositoryProvider);
        final updatedStation = station.copyWith(
          expiryDate: newExpiry,
          updatedAt: now,
        );

        await repo.updateStation(updatedStation);
        ref.invalidate(stationsStreamProvider);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abonnement renouvelé jusqu\'au ${newExpiry.day}/${newExpiry.month}/${newExpiry.year}')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du renouvellement : $e'.tr)),
        );
      }
    }
  }

  void _showManageProfiles(Station station) {
    showDialog(
      context: context,
      builder: (context) => ManageProfilesDialog(station: station),
    );
  }

  Widget _buildStatusBadge(LicenceStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case LicenceStatus.active:
        bgColor = _cGreen100;
        textColor = _cGreen700;
        text = 'Active';
        break;
      case LicenceStatus.gracePeriod:
        bgColor = _cOrange100;
        textColor = _cOrange700;
        text = 'Pending';
        break;
      case LicenceStatus.suspended:
        bgColor = _cOrange100;
        textColor = _cOrange700;
        text = 'Suspended';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStationCard(Station station, WidgetRef ref) {
    final usersAsync = ref.watch(stationUsersProvider(station.id));

    // Date and Grace Period Logic
    final now = DateTime.now();
    final expiry = station.expiryDate;
    bool isExpired = false;
    bool inGracePeriod = false;
    int daysLeft = 0;

    if (expiry != null) {
      daysLeft = expiry.difference(now).inDays;
      if (daysLeft < 0) {
        isExpired = true;
        // 7 days grace period
        if (daysLeft >= -7) {
          inGracePeriod = true;
        }
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isExpired && !inGracePeriod ? _cRed500 : _cSlate50),
        boxShadow: [
          BoxShadow(
            color: _cPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _cSlate900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        station.address.isNotEmpty ? station.address : 'Adresse non spécifiée',
                        style: TextStyle(
                          fontSize: 12,
                          color: _cSlate500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(station.licence),
              ],
            ),
            SizedBox(height: 16),

            // Expiration and Grace Period Alert
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cSlate50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Expiration:', style: TextStyle(fontSize: 12, color: _cSlate500)),
                      Text(
                        station.expiryDate != null ? '${station.expiryDate!.day}/${station.expiryDate!.month}/${station.expiryDate!.year}' : 'Non défini',
                        style: TextStyle(
                          fontSize: 13, 
                          fontWeight: FontWeight.bold, 
                          color: isExpired ? _cRed500 : _cSlate800,
                        ),
                      ),
                    ],
                  ),
                  if (station.expiryDate != null && !isExpired)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _cGreen100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Il reste $daysLeft jours',
                              style: TextStyle(fontSize: 11, color: _cGreen700, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8),

            // Grace Period Alerts
            if (isExpired && inGracePeriod)
              Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _cOrange100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _cOrange700.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 20, color: _cOrange700),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'En période de grâce (${7 + daysLeft} jours restants)',
                        style: TextStyle(fontSize: 12, color: _cOrange700, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            if (isExpired && !inGracePeriod)
              Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _cRed500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _cRed500.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 20, color: _cRed500),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Période de grâce dépassée ! Vous devez suspendre la station.',
                        style: TextStyle(fontSize: 12, color: _cRed500, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // Profiles List
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: _cSlate50),
                  bottom: BorderSide(color: _cSlate50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PROFILS (COMPTES)', style: TextStyle(fontSize: 10, color: _cSlate400, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  usersAsync.when(
                    data: (users) {
                      if (users.isEmpty) {
                        return Text('Aucun profil associé', style: TextStyle(fontSize: 12, color: _cSlate500));
                      }
                      return Column(
                        children: users.map((user) {
                          // Clean up role names
                          final formattedRoles = user.roles.map((r) {
                            final roleName = r.toString().split('.').last.toLowerCase();
                            if (roleName == 'gerant') return 'Gérant';
                            if (roleName == 'ouvrier') return 'Ouvrier';
                            if (roleName == 'admin') return 'Administrateur';
                            return roleName.toUpperCase();
                          }).join(', ');

                          final bool isGerant = user.roles.any((r) => r.toString().contains('gerant'));

                          return Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isGerant ? _cPrimary.withValues(alpha: 0.1) : _cSlate100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isGerant ? Icons.manage_accounts : Icons.person,
                                    size: 16,
                                    color: isGerant ? _cPrimary : _cSlate500,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name.isNotEmpty ? user.name : 'Utilisateur',
                                        style: TextStyle(fontSize: 13, color: _cSlate800, fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        formattedRoles,
                                        style: TextStyle(fontSize: 11, color: _cSlate500, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _cSlate50,
                                    border: Border.all(color: _cSlate100),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone_android, size: 12, color: _cSlate400),
                                      SizedBox(width: 4),
                                      Text(
                                        user.phone,
                                        style: TextStyle(fontSize: 12, color: _cSlate600, fontFamily: 'monospace', fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                    error: (e, s) => Text('Erreur de chargement', style: TextStyle(fontSize: 12, color: _cRed500)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showRenewalDialog(station),
                  icon: Icon(Icons.autorenew, size: 18),
                  label: Text('Renouveler', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: _cGreen700,
                    backgroundColor: _cGreen100,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showManageProfiles(station),
                  icon: Icon(Icons.people_outline, size: 18),
                  label: Text('Gérer Profils', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: _cPrimary,
                    backgroundColor: _cPrimary.withValues(alpha: 0.1),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 20),
                  color: _cSlate400,
                  hoverColor: _cPrimary.withValues(alpha: 0.1),
                  onPressed: () => context.go('/admin/stations/edit', extra: station),
                  tooltip: 'Edit Station'.tr,
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20),
                  color: _cSlate400,
                  hoverColor: _cRed500.withValues(alpha: 0.1),
                  onPressed: () => _deleteStation(station),
                  tooltip: 'Delete Station'.tr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stationsStream = ref.watch(stationsStreamProvider);

    return Scaffold(
      backgroundColor: _cSurface,
      appBar: AppBar(
        backgroundColor: _cWhite,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _cSlate600),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Gestion Stations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _cSlate800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _cSlate100, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Search Section
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: _cWhite,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: _cPrimary.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(fontSize: 14, color: _cSlate900),
                decoration: InputDecoration(
                  hintText: 'Search stations...'.tr,
                  hintStyle: TextStyle(color: _cSlate400),
                  prefixIcon: Icon(Icons.search, color: _cSlate400),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Station List
          Expanded(
            child: stationsStream.when(
              data: (stations) {
                final filtered = stations.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront, size: 48, color: _cSlate400),
                        SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty ? 'Aucune station disponible' : 'Aucun résultat',
                          style: TextStyle(color: _cSlate500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildStationCard(filtered[index], ref);
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: _cPrimary)),
              error: (e, s) => Center(child: Text('Erreur: $e', style: TextStyle(color: _cRed500))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/admin/stations/create'),
        backgroundColor: _cPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Icon(Icons.add, color: _cWhite, size: 28),
      ),
    );
  }
}

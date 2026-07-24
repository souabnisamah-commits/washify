import 'package:flutter/material.dart';
import 'package:washify/core/widgets/language_toggle_button.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:washify/features/auth/widgets/change_pin_dialog.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/core/utils/hash_util.dart';
import 'package:uuid/uuid.dart';
import 'package:washify/features/employees/models/employee.dart';
import 'package:washify/providers/employee_provider.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();
  final List<UserRole> _selectedRoles = [UserRole.patron];
  String? _selectedStationId;
  bool _isCreatingUser = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreatingUser = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final phone = _phoneController.text.trim();

      // Check if user already exists
      final existingUser = await authRepo.getUserByPhone(phone);
      if (existingUser != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Un utilisateur avec ce numéro existe déjà'.tr)),
        );
        setState(() {
          _isCreatingUser = false;
        });
        return;
      }

      final now = DateTime.now();
      final newUser = AppUser(
        id: const Uuid().v4(),
        tenantId: !_selectedRoles.contains(UserRole.admin) ? (_selectedStationId ?? '') : '',
        phone: phone,
        pinHash: hashPin(_pinController.text.trim()),
        name: _nameController.text.trim(),
        roles: _selectedRoles.toList(),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final currentUser = ref.read(currentUserProvider);
      await authRepo.createUser(newUser, actor: currentUser);

      // Créer également le profil Employé si ce n'est pas un admin SaaS
      if (!_selectedRoles.contains(UserRole.admin)) {
        final employeeRepo = ref.read(employeeRepositoryProvider);
        final parts = newUser.name.trim().split(' ');
        final prenom = parts.isNotEmpty ? parts.first : '';
        final nom = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        
        final newEmployee = Employee(
          id: '',
          userId: newUser.id,
          tenantId: _selectedStationId ?? '',
          nom: nom,
          prenom: prenom,
          phone: newUser.phone,
          contrat: ContractType.mensuel,
          valeurJournaliere: 0.0,
          salaireMensuel: 0.0,
          commissionRate: 0.0,
          roles: newUser.roles,
          isActive: true,
          dateEmbauche: now,
          createdAt: now,
          updatedAt: now,
        );
        await employeeRepo.createEmployee(newEmployee);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur et profil employé créés avec succès'.tr)),
      );

      // Reset fields
      _phoneController.clear();
      _pinController.clear();
      _nameController.clear();
      setState(() {
        _isCreatingUser = false;
        _selectedStationId = null;
      });
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création: $e'.tr)),
      );
      setState(() {
        _isCreatingUser = false;
      });
    }
  }

  void _showAddUserDialog() {
    _selectedStationId = null;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final stationsAsync = ref.watch(stationsStreamProvider);

            return AlertDialog(
              title: Text('Créer un utilisateur'.tr),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Nom complet'.tr),
                        validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: 'Téléphone'.tr),
                        validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Code PIN (4 chiffres)'.tr),
                        validator: (v) =>
                            v == null || v.length < 4 ? 'PIN invalide' : null,
                      ),
                      SizedBox(height: 12),
                      Text('Rôles :', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: UserRole.values
                            .where((r) => r != UserRole.admin)
                            .map((role) {
                          final isSelected = _selectedRoles.contains(role);
                          return FilterChip(
                            label: Text(role.label),
                            selected: isSelected,
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  _selectedRoles.add(role);
                                } else if (_selectedRoles.length > 1) {
                                  _selectedRoles.remove(role);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Un utilisateur doit avoir au moins un rôle'.tr)),
                                  );
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 12),
                      if (!_selectedRoles.contains(UserRole.admin))
                        stationsAsync.when(
                          data: (stations) => DropdownButtonFormField<String>(
                            initialValue: _selectedStationId,
                            decoration: InputDecoration(labelText: 'Station assignée'.tr),
                            items: stations
                                .map((st) => DropdownMenuItem(
                                      value: st.id,
                                      child: Text(st.name),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                _selectedStationId = val;
                              });
                            },
                            validator: (v) =>
                                v == null && !_selectedRoles.contains(UserRole.admin)
                                    ? 'Station requise'
                                    : null,
                          ),
                          loading: () => CircularProgressIndicator(),
                          error: (e, s) => Text('Erreur stations: $e'.tr),
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
                  onPressed: _isCreatingUser ? null : _createUser,
                  child: _isCreatingUser
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Créer'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final stationsAsync = ref.watch(stationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Super Admin'.tr),
        actions: [
                    const LanguageToggleButton(),
          IconButton(
            icon: Icon(Icons.password),
            tooltip: 'Changer le code PIN'.tr,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ChangePinDialog(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'Bienvenue'.tr}, ${user?.name ?? 'Admin'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Configuration et supervision globale de Washify.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Statistics section
            Text(
              'Statistiques Globales',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Stations Actives',
                    value: stationsAsync.when(
                      data: (list) => list.length.toString(),
                      loading: () => '...',
                      error: (e, s) => '0',
                    ),
                    icon: Icons.store,
                    color: AppTheme.accentCyan,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Rôles gérés',
                    value: '4',
                    icon: Icons.badge_outlined,
                    color: AppTheme.accentTeal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Navigation Links
            Text(
              'Gestion du Système',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            _buildMenuItem(
              context,
              title: 'Gérer les Stations',
              subtitle: 'Créer, éditer et affecter des patrons aux stations de lavage',
              icon: Icons.storefront,
              color: AppTheme.primaryBlue,
              onTap: () => context.go('/admin/stations'),
            ),
            SizedBox(height: 12),
            _buildMenuItem(
              context,
              title: 'Créer un Nouvel Utilisateur',
              subtitle: 'Ajouter un Patron, Caissier ou Laveur',
              icon: Icons.person_add_alt_1,
              color: AppTheme.successGreen,
              onTap: _showAddUserDialog,
            ),
            SizedBox(height: 12),
            _buildMenuItem(
              context,
              title: 'Audit Application',
              subtitle: 'Consulter l\'historique d\'activité de tous les utilisateurs',
              icon: Icons.history_edu,
              color: AppTheme.warningOrange,
              onTap: () => context.go('/admin/audit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}

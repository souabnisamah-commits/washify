import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/core/utils/hash_util.dart';
import 'package:uuid/uuid.dart';

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
  UserRole _selectedRole = UserRole.patron;
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
    context.go('/login');
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
          const SnackBar(content: Text('Un utilisateur avec ce numéro existe déjà')),
        );
        setState(() {
          _isCreatingUser = false;
        });
        return;
      }

      final now = DateTime.now();
      final newUser = AppUser(
        id: const Uuid().v4(),
        tenantId: _selectedRole != UserRole.admin ? (_selectedStationId ?? '') : '',
        phone: phone,
        pinHash: hashPin(_pinController.text.trim()),
        name: _nameController.text.trim(),
        roles: [_selectedRole],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await authRepo.createUser(newUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur créé avec succès')),
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
        SnackBar(content: Text('Erreur lors de la création: $e')),
      );
      setState(() {
        _isCreatingUser = false;
      });
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final stationsAsync = ref.watch(stationsStreamProvider);

            return AlertDialog(
              title: const Text('Créer un utilisateur'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nom complet'),
                        validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Téléphone'),
                        validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Code PIN (4 chiffres)'),
                        validator: (v) =>
                            v == null || v.length < 4 ? 'PIN invalide' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<UserRole>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(labelText: 'Rôle'),
                        items: UserRole.values
                            .where((r) => r != UserRole.admin)
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.label),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              _selectedRole = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_selectedRole != UserRole.admin)
                        stationsAsync.when(
                          data: (stations) => DropdownButtonFormField<String>(
                            initialValue: _selectedStationId,
                            decoration: const InputDecoration(labelText: 'Station assignée'),
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
                                v == null && _selectedRole != UserRole.admin
                                    ? 'Station requise'
                                    : null,
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, s) => Text('Erreur stations: $e'),
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
                  onPressed: _isCreatingUser ? null : _createUser,
                  child: _isCreatingUser
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Créer'),
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
        title: const Text('Dashboard Super Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue, ${user?.name ?? 'Admin'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Configuration et supervision globale de Washify.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics section
            Text(
              'Statistiques Globales',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
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
                const SizedBox(width: 16),
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
            const SizedBox(height: 24),

            // Navigation Links
            Text(
              'Gestion du Système',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              title: 'Gérer les Stations',
              subtitle: 'Créer, éditer et affecter des patrons aux stations de lavage',
              icon: Icons.storefront,
              color: AppTheme.primaryBlue,
              onTap: () => context.go('/admin/stations'),
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              title: 'Créer un Nouvel Utilisateur',
              subtitle: 'Ajouter un Patron, Caissier ou Laveur',
              icon: Icons.person_add_alt_1,
              color: AppTheme.successGreen,
              onTap: _showAddUserDialog,
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              title: 'Journaux d\'Audit',
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}

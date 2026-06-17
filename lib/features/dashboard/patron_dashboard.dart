import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/features/station/models/station.dart';

class PatronDashboard extends ConsumerStatefulWidget {
  const PatronDashboard({super.key});

  @override
  ConsumerState<PatronDashboard> createState() => _PatronDashboardState();
}

class _PatronDashboardState extends ConsumerState<PatronDashboard> {
  Station? _currentStation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFirstStation();
    });
  }

  Future<void> _loadFirstStation() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final repo = ref.read(stationRepositoryProvider);
    final stations = await repo.getStationsByPatron(user.id);
    if (stations.isNotEmpty && mounted) {
      setState(() {
        _currentStation = stations.first;
      });
      ref.read(selectedStationProvider.notifier).state = stations.first;
    }
  }

  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Watch stations by this patron
    final stationsAsync = ref.watch(stationsByPatronProvider(user.id));

    // Stats for selected station
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final statsAsync = _currentStation == null
        ? null
        : ref.watch(revenueStatsProvider((
            stationId: _currentStation!.id,
            startDate: startOfDay,
            endDate: endOfDay,
          )));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Patron'),
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
            // Station Selector
            stationsAsync.when(
              data: (stations) {
                if (stations.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'Aucune station ne vous est assignée. Veuillez contacter le Super Admin.',
                      style: TextStyle(color: AppTheme.errorRed),
                    ),
                  );
                }

                // If not set yet, set it
                if (_currentStation == null && stations.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _currentStation = stations.first;
                    });
                    ref.read(selectedStationProvider.notifier).state = stations.first;
                  });
                }

                return DropdownButtonFormField<Station>(
                  initialValue: _currentStation ?? stations.first,
                  decoration: const InputDecoration(
                    labelText: 'Sélectionner la Station',
                    prefixIcon: Icon(Icons.store, color: AppTheme.accentCyan),
                  ),
                  items: stations
                      .map((st) => DropdownMenuItem(
                            value: st,
                            child: Text(st.name),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _currentStation = val;
                      });
                      ref.read(selectedStationProvider.notifier).state = val;
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur chargement stations: $e'),
            ),
            const SizedBox(height: 24),

            if (_currentStation != null) ...[
              // Stats
              Text(
                'Aujourd\'hui',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (statsAsync != null)
                statsAsync.when(
                  data: (stats) {
                    final revenue = stats['totalRevenue'] ?? 0;
                    final tickets = stats['totalTickets'] ?? 0;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Chiffre d\'Affaires',
                            value: '${revenue.toStringAsFixed(2)} DT',
                            icon: Icons.monetization_on_outlined,
                            color: AppTheme.successGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Lavages Effectués',
                            value: tickets.toInt().toString(),
                            icon: Icons.local_car_wash,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Erreur stats: $e'),
                ),
              const SizedBox(height: 24),

              // Menu
              Text(
                'Gestion de la Station',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                title: 'Employés & Salaires',
                subtitle: 'Gérer les laveurs et caissiers, fixer les commissions',
                icon: Icons.people_outline,
                color: AppTheme.primaryBlue,
                onTap: () => context.go('/patron/employees'),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                title: 'Services de Lavage',
                subtitle: 'Définir les types de lavage et les tarifs',
                icon: Icons.dry_cleaning,
                color: AppTheme.accentTeal,
                onTap: () => context.go('/patron/services'),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                title: 'Produits',
                subtitle: 'Gérer le catalogue des produits et détergents',
                icon: Icons.inventory_2_outlined,
                color: AppTheme.accentCyan,
                onTap: () => context.go('/patron/products'),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                title: 'Stock & Inventaire',
                subtitle: 'Suivre les niveaux et mouvements de stock',
                icon: Icons.equalizer,
                color: AppTheme.warningOrange,
                onTap: () => context.go('/patron/stock'),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                title: 'Fiches de Paie (Payroll)',
                subtitle: 'Générer et approuver les bulletins de paie',
                icon: Icons.payments_outlined,
                color: AppTheme.successGreen,
                onTap: () => context.go('/patron/payroll'),
              ),
            ]
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
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

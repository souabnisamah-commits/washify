import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';

class MultiRoleDashboard extends ConsumerWidget {
  final String title;
  final List<Map<String, dynamic>> roles;

  const MultiRoleDashboard({
    super.key,
    required this.title,
    required this.roles,
  });

  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(currentUserProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    'Bienvenue, ${user?.name ?? ''}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choisissez votre espace de travail.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vos Rôles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...roles.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => context.push(r['route']),
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
                              color: r['color'].withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Icon(r['icon'], color: r['color'], size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r['title'],
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r['subtitle'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppTheme.textHint),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class WorkerCashierDashboard extends StatelessWidget {
  const WorkerCashierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MultiRoleDashboard(
      title: 'Espace Ouvrier & Caissier',
      roles: [
        {
          'title': 'Espace Ouvrier',
          'subtitle': 'Consulter vos tâches et votre portefeuille',
          'icon': Icons.local_car_wash,
          'color': AppTheme.accentCyan,
          'route': '/worker'
        },
        {
          'title': 'Espace Caissier',
          'subtitle': 'Créer des tickets et encaisser',
          'icon': Icons.point_of_sale,
          'color': AppTheme.successGreen,
          'route': '/cashier'
        },
      ],
    );
  }
}

class PatronCashierDashboard extends StatelessWidget {
  const PatronCashierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MultiRoleDashboard(
      title: 'Espace Patron & Caissier',
      roles: [
        {
          'title': 'Espace Patron',
          'subtitle': 'Gérer la station, les employés et la paie',
          'icon': Icons.store,
          'color': AppTheme.primaryBlue,
          'route': '/patron'
        },
        {
          'title': 'Espace Caissier',
          'subtitle': 'Créer des tickets et encaisser',
          'icon': Icons.point_of_sale,
          'color': AppTheme.successGreen,
          'route': '/cashier'
        },
      ],
    );
  }
}

class PatronWorkerDashboard extends StatelessWidget {
  const PatronWorkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MultiRoleDashboard(
      title: 'Espace Patron & Ouvrier',
      roles: [
        {
          'title': 'Espace Patron',
          'subtitle': 'Gérer la station, les employés et la paie',
          'icon': Icons.store,
          'color': AppTheme.primaryBlue,
          'route': '/patron'
        },
        {
          'title': 'Espace Ouvrier',
          'subtitle': 'Consulter vos tâches et votre portefeuille',
          'icon': Icons.local_car_wash,
          'color': AppTheme.accentCyan,
          'route': '/worker'
        },
      ],
    );
  }
}

class PatronWorkerCashierDashboard extends StatelessWidget {
  const PatronWorkerCashierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MultiRoleDashboard(
      title: 'Espace Patron, Ouvrier & Caissier',
      roles: [
        {
          'title': 'Espace Patron',
          'subtitle': 'Gérer la station, les employés et la paie',
          'icon': Icons.store,
          'color': AppTheme.primaryBlue,
          'route': '/patron'
        },
        {
          'title': 'Espace Caissier',
          'subtitle': 'Créer des tickets et encaisser',
          'icon': Icons.point_of_sale,
          'color': AppTheme.successGreen,
          'route': '/cashier'
        },
        {
          'title': 'Espace Ouvrier',
          'subtitle': 'Consulter vos tâches et votre portefeuille',
          'icon': Icons.local_car_wash,
          'color': AppTheme.accentCyan,
          'route': '/worker'
        },
      ],
    );
  }
}

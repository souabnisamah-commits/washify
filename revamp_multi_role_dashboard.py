import os

content = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/providers/wallet_provider.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/features/auth/widgets/change_pin_dialog.dart';
import 'package:washify/core/widgets/language_toggle_button.dart';
import 'package:marquee/marquee.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

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

class WorkerCashierDashboard extends ConsumerStatefulWidget {
  const WorkerCashierDashboard({super.key});

  @override
  ConsumerState<WorkerCashierDashboard> createState() => _WorkerCashierDashboardState();
}

class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {
  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
    context.go('/login');
  }

  void _showTicketsBottomSheet(BuildContext context, List<Ticket> tickets, String title) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: AppTheme.textHint.withValues(alpha: 0.3)),
                            SizedBox(height: 16),
                            Text('Aucun ticket trouvé', style: TextStyle(color: AppTheme.textHint)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          final dateStr = DateFormat('HH:mm').format(ticket.createdAt);
                          
                          Color statusColor = AppTheme.textHint;
                          switch (ticket.status) {
                            case TicketStatus.paye:
                              statusColor = AppTheme.successGreen;
                              break;
                            case TicketStatus.enAttente:
                              statusColor = AppTheme.warningOrange;
                              break;
                            case TicketStatus.rembourse:
                              statusColor = AppTheme.errorRed;
                              break;
                          }

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withValues(alpha: 0.1),
                                child: Icon(Icons.receipt_long, color: statusColor),
                              ),
                              title: Text(ticket.vehiclePlate ?? 'Véhicule', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${ticket.serviceName} • $dateStr\\nLaveur: ${ticket.workerName ?? "Non assigné"}'),
                              trailing: Text('${ticket.totalAmount.toStringAsFixed(2)} DT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.stationId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ticketsStream = ref.watch(todayTicketsStreamProvider(user.stationId!));
    final walletStream = ref.watch(walletStreamProvider(user.id));
    final myTicketsAsync = ref.watch(ticketsByWorkerProvider((
      workerId: user.id,
      status: null,
    )));

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 30,
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.primary,
            highlightColor: AppTheme.accentCyan,
            child: Marquee(
              text: 'Bienvenue ${user.name}, Espace Ouvrier & Caissier'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 100.0,
              velocity: 40.0,
              startPadding: 10.0,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(ref.watch(themeProvider) == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const LanguageToggleButton(),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ChangePinDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Nouveau Ticket
            InkWell(
              onTap: () => context.push('/cashier/tickets/new'),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.add_circle_outline, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Nouveau Ticket'.tr,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Solde Actuel
            walletStream.when(
              data: (wallet) {
                final balance = wallet?.balance ?? 0;
                return _buildActionCard(
                  context,
                  title: 'Mon Solde Actuel',
                  value: '${balance.toStringAsFixed(1)} DT',
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.successGreen,
                  onTap: () => context.go('/worker/wallet'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur Wallet: $e'),
            ),
            const SizedBox(height: 24),

            // 3. Planification
            _buildActionCard(
              context,
              title: 'Planification',
              value: 'Voir Planning',
              icon: Icons.calendar_month,
              color: AppTheme.primaryBlue,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Le module de planification sera bientôt disponible.')),
                );
              },
            ),
            const SizedBox(height: 24),

            // 4. Mes Recettes
            myTicketsAsync.when(
              data: (tickets) {
                double total = 0;
                for (var t in tickets) {
                  total += t.totalAmount;
                }
                return _buildActionCard(
                  context,
                  title: 'Mes Recettes',
                  value: '${total.toStringAsFixed(1)} DT',
                  icon: Icons.person,
                  color: Colors.deepPurpleAccent,
                  onTap: () => _showTicketsBottomSheet(context, tickets, 'Mes Tickets du Jour'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur tâches: $e'),
            ),
            const SizedBox(height: 24),

            // 5. Recettes Équipe
            ticketsStream.when(
              data: (tickets) {
                double total = 0;
                for (var t in tickets) {
                  total += t.totalAmount;
                }
                return _buildActionCard(
                  context,
                  title: 'Recettes Équipe',
                  value: '${total.toStringAsFixed(1)} DT',
                  icon: Icons.groups,
                  color: Colors.orange,
                  onTap: () => _showTicketsBottomSheet(context, tickets, 'Tickets Équipe du Jour'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur tickets: $e'),
            ),
            
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Created By SouTeQSa',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 48),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 36),
          ],
        ),
      ),
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
          'subtitle': 'Statistiques et gestion de la station',
          'icon': Icons.admin_panel_settings,
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
          'subtitle': 'Statistiques et gestion de la station',
          'icon': Icons.admin_panel_settings,
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
      title: 'Portail Multi-Rôles',
      roles: [
        {
          'title': 'Espace Patron',
          'subtitle': 'Statistiques et gestion de la station',
          'icon': Icons.admin_panel_settings,
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
"""

with open('lib/features/dashboard/multi_role_dashboards.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("multi_role_dashboards.dart updated!")

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

class CashierDashboard extends ConsumerStatefulWidget {
  const CashierDashboard({super.key});

  @override
  ConsumerState<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends ConsumerState<CashierDashboard> {
  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
    context.go('/login');
  }

  void _showTicketsBottomSheet(BuildContext context, List<Ticket> tickets) {
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
                'Tickets Équipe du Jour',
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
                            Text('Aucun ticket aujourd\\'hui', style: TextStyle(color: AppTheme.textHint)),
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
    // Provide wallet for the cashier too, as requested
    final walletStream = ref.watch(walletStreamProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 30,
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.primary,
            highlightColor: AppTheme.accentCyan,
            child: Marquee(
              text: 'Bienvenue ${user.name}, dans votre Espace Caissier'.tr,
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
            // 1. Nouveau Ticket (Bouton principal)
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
                  title: 'Solde Actuel',
                  value: '${balance.toStringAsFixed(1)} DT',
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.successGreen,
                  // Cashier doesn't have a wallet screen in routing yet, but let's assume they can view transactions
                  onTap: () {
                     // context.go('/worker/wallet'); // we might need to use /worker/wallet if routing allows it
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Transactions en cours de chargement...')),
                     );
                  },
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

            // 4. Recettes Équipe
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
                  icon: Icons.payments,
                  color: Colors.orange,
                  onTap: () => _showTicketsBottomSheet(context, tickets),
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
"""

with open('lib/features/dashboard/cashier_dashboard.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("cashier_dashboard.dart updated!")

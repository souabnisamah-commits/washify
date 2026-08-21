import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:washify/core/widgets/color_animated_title.dart';
import 'package:washify/core/widgets/language_toggle_button.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/features/auth/widgets/change_pin_dialog.dart';
import 'package:washify/providers/theme_provider.dart';
import 'package:washify/core/widgets/pro_max_stat_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:intl/intl.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/repositories/ticket_repository.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/service_provider.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/features/services/models/service_definition.dart';
import 'package:washify/providers/service_definition_provider.dart';
import 'package:washify/providers/stock_provider.dart';
import 'package:washify/features/stock/models/stock.dart';

class PatronDashboard extends ConsumerStatefulWidget {
  const PatronDashboard({super.key});

  @override
  ConsumerState<PatronDashboard> createState() => _PatronDashboardState();
}

class _PatronDashboardState extends ConsumerState<PatronDashboard> {
  Station? _currentStation;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _startDate = DateTime(today.year, today.month, today.day);
    _endDate = _startDate.add(const Duration(days: 1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFirstStation();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate.subtract(const Duration(days: 1)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentCyan,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end.add(const Duration(days: 1));
      });
    }
  }

  String get _dateRangeText {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    if (_startDate.isAtSameMomentAs(todayStart) &&
        _endDate.difference(_startDate).inDays == 1) {
      return "Aujourd'hui";
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    final endToDisplay = _endDate.subtract(const Duration(days: 1));

    if (_startDate.isAtSameMomentAs(endToDisplay)) {
      return "Le ${dateFormat.format(_startDate)}";
    }

    return "Du ${dateFormat.format(_startDate)} au ${dateFormat.format(endToDisplay)}";
  }

  void _showTicketsDetails(
    BuildContext context,
    String title,
    List<Ticket> tickets,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.96,
            height: MediaQuery.of(context).size.height * 0.88,
            child: _TicketsTableModal(
              title: title,
              tickets: tickets,
            ),
          ),
        );
      },
    );
  }

  void _showWashingAndStockAuditModal(BuildContext context, List<Ticket> tickets, Station? station) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 850),
          child: _WashingAndStockAuditModalContent(tickets: tickets, station: station),
        ),
      ),
    );
  }

  Future<void> _loadFirstStation() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.tenantId.isEmpty) return;

    final repo = ref.read(stationRepositoryProvider);
    final station = await repo.getStationById(user.tenantId);
    if (station != null && mounted) {
      setState(() {
        _currentStation = station;
      });
      ref.read(selectedStationProvider.notifier).state = station;
    }
  }

  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
  }

  Widget _buildSubscriptionBanner() {
    if (_currentStation == null || _currentStation!.expiryDate == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = _currentStation!.expiryDate!;
    final expiryDateOnly = DateTime(expiry.year, expiry.month, expiry.day);
    
    final daysUntilExpiry = expiryDateOnly.difference(today).inDays;
    final gracePeriod = _currentStation!.gracePeriodDays;

    if (daysUntilExpiry > 7) {
      return const SizedBox.shrink();
    }

    String title;
    String message;
    Color color;
    IconData icon;

    if (daysUntilExpiry >= 0) {
      // Cas 1 : Expiration proche
      title = "Abonnement bientôt expiré".tr;
      message = "${"Votre abonnement expire le".tr} ${DateFormat('dd/MM/yyyy').format(expiry)}. ${"Il vous reste".tr} $daysUntilExpiry ${"jour(s)".tr}.";
      color = AppTheme.accentCyan; // Premium touch instead of simple orange
      icon = Icons.warning_amber_rounded;
    } else {
      // Expiré
      final remainingGrace = gracePeriod + daysUntilExpiry; // daysUntilExpiry est négatif
      if (remainingGrace >= 0) {
        // Cas 2 : Période de grâce
        title = "Période de grâce".tr;
        message = "${"Abonnement expiré le".tr} ${DateFormat('dd/MM/yyyy').format(expiry)}. ${"Il vous reste".tr} $remainingGrace ${"jour(s) de période de grâce".tr}.";
        color = Colors.orangeAccent;
        icon = Icons.error_outline_rounded;
      } else {
        // Cas 3 : Suspendu
        title = "Abonnement Terminé".tr;
        message = "Votre abonnement et la période de grâce sont terminés. Veuillez renouveler votre abonnement.".tr;
        color = AppTheme.errorRed;
        icon = Icons.block;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Watch station assigned to this patron
    final stationAsync = user.tenantId.isEmpty
        ? const AsyncValue<Station?>.data(null)
        : ref.watch(stationByIdProvider(user.tenantId));

    // Stats for selected station
    final statsAsync = _currentStation == null
        ? null
        : ref.watch(
            revenueStatsProvider((
              stationId: _currentStation!.id,
              startDate: _startDate,
              endDate: _endDate,
            )),
          );

    return Scaffold(
      appBar: AppBar(
        title: ColorAnimatedTitle(
          text: '${'Bienvenue'.tr} ${user.name},\n${'dans votre Espace'.tr} ${_currentStation?.name ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.2),
        ),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const LanguageToggleButton(),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Changer le code PIN'.tr,
            onPressed: () {
              showDialog(context: context, builder: (_) => ChangePinDialog());
            },
          ),
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Station Selector
            stationAsync.when(
              data: (station) {
                if (station == null) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      border: Border.all(
                        color: AppTheme.errorRed.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'Aucune station ne vous est assignée. Veuillez contacter le Super Admin.',
                      style: TextStyle(color: AppTheme.errorRed),
                    ),
                  );
                }

                // If not set yet, set it
                if (_currentStation == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _currentStation = station;
                    });
                    ref.read(selectedStationProvider.notifier).state = station;
                  });
                }

                return const SizedBox.shrink();
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur chargement station: $e'.tr),
            ),
            SizedBox(height: 24),

            if (_currentStation != null) ...[
              _buildSubscriptionBanner(),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle(context, 'Statistiques', Icons.bar_chart),
                  InkWell(
                    onTap: () => _selectDateRange(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCardLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accentCyan),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: AppTheme.accentCyan,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _dateRangeText,
                            style: TextStyle(
                              color: AppTheme.accentCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: AppTheme.accentCyan,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
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
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) =>
                                    Center(child: CircularProgressIndicator()),
                              );
                              try {
                                final tickets = await ref.read(
                                  ticketsByDateRangeProvider((
                                    stationId: _currentStation!.id,
                                    startDate: _startDate,
                                    endDate: _endDate,
                                  )).future,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _showTicketsDetails(
                                    context,
                                    'Détail Chiffre d\'Affaires',
                                    tickets,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur: $e'.tr)),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Lavages Effectués',
                            value: tickets.toInt().toString(),
                            icon: Icons.local_car_wash,
                            color: AppTheme.accentCyan,
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) =>
                                    Center(child: CircularProgressIndicator()),
                              );
                              try {
                                final t = await ref.read(
                                  ticketsByDateRangeProvider((
                                    stationId: _currentStation!.id,
                                    startDate: _startDate,
                                    endDate: _endDate,
                                  )).future,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _showWashingAndStockAuditModal(context, t, _currentStation);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erreur: $e'.tr)),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Erreur stats: $e'.tr),
                ),
              SizedBox(height: 32),

              // Section: Opérations Quotidiennes
              _buildSectionTitle(
                context,
                'Opérations Quotidiennes',
                Icons.calendar_today,
              ),
              SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 800
                      ? 3
                      : (constraints.maxWidth > 500 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildGridItem(
                        context,
                        title: 'RH & Pointage',
                        icon: Icons.access_time_filled,
                        color: Colors.orange,
                        onTap: () => context.go('/patron/hr'),
                      ),
                      _buildGridItem(
                        context,
                        title: 'Employés',
                        icon: Icons.people,
                        color: Colors.orangeAccent,
                        onTap: () => context.go('/patron/employees'),
                      ),
                      _buildGridItem(
                        context,
                        title: 'Stock & Achats',
                        icon: Icons.local_shipping,
                        color: AppTheme.accentCyan,
                        onTap: () => context.go('/patron/stock'),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 32),

              // Section: Inventaire & Audits
              _buildSectionTitle(
                context,
                'Inventaire & Audits',
                Icons.fact_check_outlined,
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3.5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(
                    context,
                    title: 'Audits',
                    icon: Icons.checklist_rtl,
                    color: Colors.purpleAccent,
                    onTap: () => context.go('/patron/inventory'),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // Section: Comptes Clients
              _buildSectionTitle(
                context,
                'Comptes Clients',
                Icons.people_alt,
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800
                    ? 3
                    : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(
                    context,
                    title: 'Comptes B2B',
                    icon: Icons.business_center,
                    color: AppTheme.successGreen,
                    onTap: () => context.go('/patron/clients'),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // Section: Gestion de Caisse & Finance
              _buildSectionTitle(
                context,
                'Gestion de Caisse & Finance',
                Icons.account_balance_wallet_outlined,
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800
                    ? 3
                    : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(
                    context,
                    title: 'Session de Caisse',
                    icon: Icons.payments,
                    color: AppTheme.successGreen,
                    onTap: () => context.go('/patron/caisse'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Rapport Journalier',
                    icon: Icons.analytics_outlined,
                    color: AppTheme.primaryBlue,
                    onTap: () => context.go('/patron/daily-recap'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Salaires & RH',
                    icon: Icons.wallet,
                    color: Colors.amber.shade700,
                    onTap: () => context.go('/patron/payroll'),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // Section: Offres et Promotions
              _buildSectionTitle(
                context,
                'Offres et Promotions',
                Icons.campaign,
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800
                    ? 3
                    : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(
                    context,
                    title: 'Offres & Pack',
                    icon: Icons.stars,
                    color: Colors.blueAccent,
                    onTap: () => context.go('/patron/offers'),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // Section: Configuration & Catalogue
              _buildSectionTitle(
                context,
                'Configuration & Catalogue',
                Icons.settings,
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800
                    ? 3
                    : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(
                    context,
                    title: 'Catégories',
                    icon: Icons.directions_car,
                    color: AppTheme.primaryBlue,
                    onTap: () => context.go('/patron/vehicle-categories'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Services Lavage',
                    icon: Icons.water_drop,
                    color: AppTheme.accentTeal,
                    onTap: () => context.go('/patron/service-definitions'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Produits',
                    icon: Icons.inventory_2,
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.go('/patron/products'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Paramètres Station',
                    icon: Icons.settings,
                    color: Colors.blueGrey,
                    onTap: () => context.go('/patron/settings'),
                  ),
                ],
              ),

              SizedBox(height: 48),
              Center(
                child: Text(
                  'Created By SouTeQsa',
                  style: TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 24),
        SizedBox(width: 8),
        Text(
          title.tr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ProMaxStatCard(
      title: title.tr,
      value: value,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1) 
                : Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: isDark ? 0.15 : 0.1),
              color.withValues(alpha: 0.0),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketsTableModal extends ConsumerStatefulWidget {
  final String title;
  final List<Ticket> tickets;

  const _TicketsTableModal({
    required this.title,
    required this.tickets,
  });

  @override
  ConsumerState<_TicketsTableModal> createState() => _TicketsTableModalState();
}

class _TicketsTableModalState extends ConsumerState<_TicketsTableModal> {
  String _filterType = 'all'; // 'all', 'vehicule', 'moquette'
  String _filterPayment = 'all'; // 'all', 'especes', 'compte_client', 'tpe'
  String _filterWorker = 'all'; // 'all', or worker name
  final ScrollController _horizontalScroll = ScrollController();
  final ScrollController _verticalScroll = ScrollController();

  @override
  void dispose() {
    _horizontalScroll.dispose();
    _verticalScroll.dispose();
    super.dispose();
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
              Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final stationId = user?.stationId ?? '';
    final allProducts = ref.watch(productsStreamProvider(stationId)).value ?? [];
    final allServicesDef = ref.watch(serviceDefinitionsStreamProvider(stationId)).value ?? [];
    final productMap = {for (final p in allProducts) p.id: p};
    final serviceMap = {for (final s in allServicesDef) s.id: s};

    // Extract unique workers
    final Set<String> workerNamesSet = {};
    for (final t in widget.tickets) {
      final name = (t.assignedWorkerName != null && t.assignedWorkerName!.trim().isNotEmpty)
          ? t.assignedWorkerName!.trim()
          : 'Non assigné';
      workerNamesSet.add(name);
    }
    final List<String> workerList = workerNamesSet.toList()..sort();

    final filteredTickets = widget.tickets.where((t) {
      if (_filterType == 'vehicule' && t.operationType != 'vehicule') return false;
      if (_filterType == 'moquette' && t.operationType != 'moquette') return false;

      if (_filterPayment != 'all') {
        final pm = t.paymentMethod?.toLowerCase() ?? '';
        final isCompte = pm.contains('compte') || pm.contains('b2b');
        final isTpe = pm.contains('tpe') || pm.contains('carte');
        final isCash = !isCompte && !isTpe;

        if (_filterPayment == 'especes' && !isCash) return false;
        if (_filterPayment == 'compte_client' && !isCompte) return false;
        if (_filterPayment == 'tpe' && !isTpe) return false;
      }

      if (_filterWorker != 'all') {
        final name = (t.assignedWorkerName != null && t.assignedWorkerName!.trim().isNotEmpty)
            ? t.assignedWorkerName!.trim()
            : 'Non assigné';
        if (name != _filterWorker) return false;
      }

      return true;
    }).toList();

    // Calculate total amount of current filtered tickets for counting caisse & worker efficiency
    final double filterTotal = filteredTickets.fold(0.0, (sum, t) {
      if (t.status == TicketStatus.efface || t.status == TicketStatus.annule) return sum;
      return sum + t.totalAmount;
    });

    // Strategic metrics for upselling and worker performance
    int totalUpsellTickets = 0;
    double optionsSum = 0.0;
    double boutiqueSum = 0.0;

    for (final t in filteredTickets) {
      if (t.status == TicketStatus.efface || t.status == TicketStatus.annule) continue;

      // Options & supplements
      final optionServices = t.servicesSelected.where((s) {
        final def = serviceMap[s.serviceId];
        if (def != null) return def.serviceType == ServiceType.supplement || def.serviceType == ServiceType.special;
        final nameLower = s.serviceName.toLowerCase();
        return nameLower.contains('option') || nameLower.contains('supplément') || nameLower.contains('extra') || nameLower.contains('décrass') || nameLower.contains('produit');
      });
      final optionProducts = t.productsUsed.where((p) {
        final prod = productMap[p.productId];
        if (prod != null) return prod.family == ProductFamily.extra || prod.family == ProductFamily.standard;
        final nameLower = p.productName.toLowerCase();
        return !nameLower.contains('sapin') && !nameLower.contains('fresh') && !nameLower.contains('tapis');
      });

      final optVal = optionServices.fold(0.0, (sum, s) => sum + s.price) + optionProducts.fold(0.0, (sum, p) => sum + p.total);
      optionsSum += optVal;

      // Boutique
      final boutiqueProducts = t.productsUsed.where((p) {
        final prod = productMap[p.productId];
        if (prod != null) return prod.family == ProductFamily.revente;
        final nameLower = p.productName.toLowerCase();
        return nameLower.contains('sapin') || nameLower.contains('fresh') || nameLower.contains('tapis') || p.productName.contains('Boutique');
      });
      final boutVal = boutiqueProducts.fold(0.0, (sum, p) => sum + p.total);
      boutiqueSum += boutVal;

      if (optVal > 0 || boutVal > 0) {
        totalUpsellTickets++;
      }
    }

    final int validTicketsCount = filteredTickets.where((t) => t.status != TicketStatus.efface && t.status != TicketStatus.annule).length;
    final double upsellRate = validTicketsCount > 0 ? (totalUpsellTickets / validTicketsCount * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: AppTheme.primaryBlue),
                  const SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filters & Actions Bar
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Type Filters
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilterChip(
                    label: Text('Tous (${widget.tickets.length})'),
                    selected: _filterType == 'all',
                    onSelected: (_) => setState(() => _filterType = 'all'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('Véhicules (${widget.tickets.where((t) => t.operationType == 'vehicule').length})'),
                    selected: _filterType == 'vehicule',
                    onSelected: (_) => setState(() => _filterType = 'vehicule'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('Moquettes (${widget.tickets.where((t) => t.operationType == 'moquette').length})'),
                    selected: _filterType == 'moquette',
                    onSelected: (_) => setState(() => _filterType = 'moquette'),
                  ),
                ],
              ),

              // Worker Filter Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: _filterWorker == 'all'
                      ? Theme.of(context).colorScheme.surface
                      : AppTheme.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _filterWorker == 'all'
                        ? AppTheme.textHint.withValues(alpha: 0.3)
                        : AppTheme.accentCyan,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_outlined, size: 16, color: _filterWorker == 'all' ? AppTheme.textHint : AppTheme.accentCyan),
                    const SizedBox(width: 6),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterWorker,
                        isDense: true,
                        dropdownColor: AppTheme.surfaceCard,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _filterWorker == 'all'
                              ? Theme.of(context).colorScheme.onSurface
                              : AppTheme.accentCyan,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Tous les Ouvriers (${widget.tickets.length})'),
                          ),
                          ...workerList.map((w) {
                            final count = widget.tickets.where((t) {
                              final name = (t.assignedWorkerName != null && t.assignedWorkerName!.trim().isNotEmpty)
                                  ? t.assignedWorkerName!.trim()
                                  : 'Non assigné';
                              return name == w;
                            }).length;
                            return DropdownMenuItem(
                              value: w,
                              child: Text('$w ($count)'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _filterWorker = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Payment Method Filters
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list, size: 16, color: AppTheme.textHint),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: const Text('Tous Modes'),
                    selected: _filterPayment == 'all',
                    onSelected: (_) => setState(() => _filterPayment = 'all'),
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    avatar: const Icon(Icons.payments_outlined, size: 14, color: AppTheme.successGreen),
                    label: Text('Espèces (${widget.tickets.where((t) {
                      final pm = t.paymentMethod?.toLowerCase() ?? '';
                      return !pm.contains('compte') && !pm.contains('b2b') && !pm.contains('tpe') && !pm.contains('carte');
                    }).length})'),
                    selected: _filterPayment == 'especes',
                    onSelected: (_) => setState(() => _filterPayment = 'especes'),
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    avatar: const Icon(Icons.credit_card, size: 14, color: Colors.purple),
                    label: Text('Compte Client (${widget.tickets.where((t) {
                      final pm = t.paymentMethod?.toLowerCase() ?? '';
                      return pm.contains('compte') || pm.contains('b2b');
                    }).length})'),
                    selected: _filterPayment == 'compte_client',
                    onSelected: (_) => setState(() => _filterPayment = 'compte_client'),
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    avatar: const Icon(Icons.contactless, size: 14, color: AppTheme.primaryBlue),
                    label: Text('TPE (${widget.tickets.where((t) {
                      final pm = t.paymentMethod?.toLowerCase() ?? '';
                      return pm.contains('tpe') || pm.contains('carte');
                    }).length})'),
                    selected: _filterPayment == 'tpe',
                    onSelected: (_) => setState(() => _filterPayment = 'tpe'),
                  ),
                ],
              ),

              // Total badge & Copy Button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Total Filtre: ${filterTotal.toStringAsFixed(1)} DT',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _copyTableToClipboard(filteredTickets),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    label: Text('Copier le Tableau'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Strategic Worker Performance Card (when worker selected)
          if (_filterWorker != 'all') ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Rendement Stratégique & Commercial : $_filterWorker',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.accentCyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildMetricTile('Tickets Traités', '$validTicketsCount', Icons.local_car_wash, Colors.blue),
                      _buildMetricTile('Chiffre d\'Affaires', '${filterTotal.toStringAsFixed(1)} DT', Icons.monetization_on, AppTheme.successGreen),
                      _buildMetricTile('Ventes Options/Suppléments', '${optionsSum.toStringAsFixed(1)} DT', Icons.auto_awesome, Colors.purple),
                      _buildMetricTile('Ventes Boutique', '${boutiqueSum.toStringAsFixed(1)} DT', Icons.shopping_bag, Colors.orange),
                      _buildMetricTile('Taux de Conversion Up-Selling', '${upsellRate.toStringAsFixed(0)}%', Icons.trending_up, Colors.teal),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Data Table View
          Expanded(
            child: filteredTickets.isEmpty
                ? Center(
                    child: Text('Aucun ticket trouvé pour ce filtre.'.tr, style: TextStyle(color: AppTheme.textHint)),
                  )
                : Scrollbar(
                    controller: _horizontalScroll,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScroll,
                      scrollDirection: Axis.horizontal,
                      child: Scrollbar(
                        controller: _verticalScroll,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _verticalScroll,
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columnSpacing: 18,
                            horizontalMargin: 16,
                            dataRowMinHeight: 64,
                            dataRowMaxHeight: double.infinity,
                            headingRowColor: WidgetStateProperty.all(AppTheme.primaryBlue.withValues(alpha: 0.12)),
                            columns: const [
                              DataColumn(label: Text('N° Ticket', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Véhicule / Client', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Service Lavage', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Options & Suppléments', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Boutique', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Remise & Motif', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Caissier', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Ouvrier', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Paiement', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredTickets.map((ticket) {
                              final isDeleted = ticket.status == TicketStatus.efface || ticket.status == TicketStatus.annule;
                              final isMoquette = ticket.operationType == 'moquette';

                              final vehiculeDisplay = isMoquette
                                  ? '${ticket.carpetMeters ?? 0} m²'
                                  : '${ticket.vehiclePlate ?? '-'} ${ticket.vehicleBrand ?? ''} ${ticket.vehicleModel ?? ''}'.trim();

                              // 1. Service Lavage: Only actual wash services
                              final washServices = ticket.servicesSelected.where((s) {
                                final def = serviceMap[s.serviceId];
                                if (def != null) {
                                  return def.serviceType == ServiceType.lavage;
                                }
                                final nameLower = s.serviceName.toLowerCase();
                                return !nameLower.contains('option') && !nameLower.contains('supplément') && !nameLower.contains('extra') && !nameLower.contains('décrass') && !nameLower.contains('produit');
                              }).toList();

                              final serviceDisplay = isMoquette
                                  ? 'Moquette (${((ticket.carpetMeters ?? 0) * (ticket.carpetUnitPrice ?? 0)).toStringAsFixed(1)} DT)'
                                  : (washServices.isNotEmpty
                                      ? washServices.map((s) => '${s.serviceName} (${s.price.toStringAsFixed(1)} DT)').join('\n')
                                      : (ticket.servicesSelected.isNotEmpty ? '${ticket.servicesSelected.first.serviceName} (${ticket.servicesSelected.first.price.toStringAsFixed(1)} DT)' : '-'));

                              // 2. Options & Suppléments: Services of type supplement/special OR extra/standard products
                              final optionServices = ticket.servicesSelected.where((s) {
                                final def = serviceMap[s.serviceId];
                                if (def != null) {
                                  return def.serviceType == ServiceType.supplement || def.serviceType == ServiceType.special;
                                }
                                final nameLower = s.serviceName.toLowerCase();
                                return nameLower.contains('option') || nameLower.contains('supplément') || nameLower.contains('extra') || nameLower.contains('décrass') || nameLower.contains('produit');
                              }).toList();

                              final optionProducts = ticket.productsUsed.where((p) {
                                final prod = productMap[p.productId];
                                if (prod != null) {
                                  return prod.family == ProductFamily.extra || prod.family == ProductFamily.standard;
                                }
                                final nameLower = p.productName.toLowerCase();
                                return !nameLower.contains('sapin') && !nameLower.contains('fresh') && !nameLower.contains('tapis');
                              }).toList();

                              final List<String> optionLines = [
                                ...optionServices.map((s) => '${s.serviceName} (${s.price.toStringAsFixed(1)} DT)'),
                                ...optionProducts.map((p) => '${p.productName} x${p.quantity} (${p.total.toStringAsFixed(1)} DT)'),
                              ];
                              final optionsDisplay = optionLines.isEmpty ? '-' : optionLines.join('\n');

                              // 3. Boutique: Shop resale articles with barcode
                              final boutiqueProducts = ticket.productsUsed.where((p) {
                                final prod = productMap[p.productId];
                                if (prod != null) {
                                  return prod.family == ProductFamily.revente;
                                }
                                final nameLower = p.productName.toLowerCase();
                                return nameLower.contains('sapin') || nameLower.contains('fresh') || nameLower.contains('tapis') || p.productName.contains('Boutique');
                              }).toList();

                              final List<String> boutiqueLines = boutiqueProducts.map((p) {
                                final prod = productMap[p.productId];
                                final barcodeStr = (prod != null && prod.barcode.isNotEmpty) ? ' [Code: ${prod.barcode}]' : '';
                                return '${p.productName}$barcodeStr x${p.quantity} (${p.total.toStringAsFixed(1)} DT)';
                              }).toList();
                              final boutiqueDisplay = boutiqueLines.isEmpty ? '-' : boutiqueLines.join('\n');

                              final discountDisplay = (ticket.discountAmount != null && ticket.discountAmount! > 0)
                                  ? '-${ticket.discountAmount!.toStringAsFixed(1)} DT (${ticket.discountReason ?? ''})'
                                  : '-';

                              return DataRow(
                                color: isDeleted ? WidgetStateProperty.all(AppTheme.errorRed.withValues(alpha: 0.08)) : null,
                                cells: [
                                  // N° Ticket
                                  DataCell(
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ticket.ticketNumber,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDeleted ? AppTheme.errorRed : null,
                                            decoration: isDeleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        if (isDeleted)
                                          Text(
                                            'Effacé: ${ticket.deleteReason ?? ''}',
                                            style: const TextStyle(fontSize: 10, color: AppTheme.errorRed, fontStyle: FontStyle.italic),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Type
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (isMoquette ? Colors.orange : AppTheme.accentCyan).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isMoquette ? 'Moquette' : 'Véhicule',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isMoquette ? Colors.orange : AppTheme.accentCyan,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Véhicule / Client
                                  DataCell(
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(vehiculeDisplay.isEmpty ? '-' : vehiculeDisplay),
                                        if (ticket.clientName != null && ticket.clientName!.trim().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.person_outline, size: 12, color: AppTheme.primaryBlue),
                                                const SizedBox(width: 3),
                                                Text(
                                                  ticket.clientName!,
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Service Lavage
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        serviceDisplay.isEmpty ? '-' : serviceDisplay,
                                        style: const TextStyle(height: 1.35),
                                      ),
                                    ),
                                  ),
                                  // Options & Suppléments
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        optionsDisplay,
                                        style: const TextStyle(height: 1.35),
                                      ),
                                    ),
                                  ),
                                  // Boutique
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        boutiqueDisplay,
                                        style: const TextStyle(height: 1.35),
                                      ),
                                    ),
                                  ),
                                  // Remise & Motif
                                  DataCell(Text(discountDisplay)),
                                  // Caissier
                                  DataCell(Text(ticket.paidBy ?? ticket.createdBy)),
                                  // Ouvrier
                                  DataCell(Text(ticket.assignedWorkerName ?? 'Non assigné')),
                                  // Mode Paiement & Client
                                  DataCell(
                                    Builder(
                                      builder: (context) {
                                        final pm = ticket.paymentMethod?.toLowerCase() ?? '';
                                        final isCompte = pm.contains('compte') || pm.contains('b2b');
                                        final isTpe = pm.contains('tpe') || pm.contains('carte');
                                        final String label = isCompte ? 'Compte Client' : (isTpe ? 'TPE' : 'Espèces');
                                        final IconData icon = isCompte ? Icons.credit_card : (isTpe ? Icons.contactless : Icons.payments_outlined);
                                        final Color color = isCompte ? Colors.purple : (isTpe ? AppTheme.primaryBlue : AppTheme.successGreen);

                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: color.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: color.withValues(alpha: 0.3)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(icon, size: 14, color: color),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    label,
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (ticket.clientName != null && ticket.clientName!.trim().isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 3.0),
                                                child: Text(
                                                  ticket.clientName!,
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  // Total
                                  DataCell(
                                    Text(
                                      '${ticket.totalAmount.toStringAsFixed(1)} DT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDeleted ? AppTheme.errorRed : AppTheme.successGreen,
                                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                  // Actions
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!isDeleted) ...[
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 18),
                                            tooltip: 'Modifier',
                                            onPressed: () {
                                              Navigator.pop(context);
                                              context.push('/patron/tickets/new', extra: ticket);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 18),
                                            tooltip: 'Supprimer',
                                            onPressed: () => _confirmDeleteTicket(context, ticket),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _copyTableToClipboard(List<Ticket> filteredTickets) {
    final user = ref.read(currentUserProvider);
    final stationId = user?.stationId ?? '';
    final allProducts = ref.read(productsStreamProvider(stationId)).value ?? [];
    final allServicesDef = ref.read(serviceDefinitionsStreamProvider(stationId)).value ?? [];
    final productMap = {for (final p in allProducts) p.id: p};
    final serviceMap = {for (final s in allServicesDef) s.id: s};

    final StringBuffer buffer = StringBuffer();
    buffer.writeln("=== DÉTAIL CHIFFRE D'AFFAIRES - ${widget.title} ===");
    buffer.writeln("Date d'exportation : ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}");
    buffer.writeln("Total tickets : ${filteredTickets.length}");
    buffer.writeln("===================================================\n");

    for (var i = 0; i < filteredTickets.length; i++) {
      final t = filteredTickets[i];
      final isMoquette = t.operationType == 'moquette';
      buffer.writeln("N° ${i + 1} | Ticket : ${t.ticketNumber} | Statut : ${t.status.name.toUpperCase()}");
      buffer.writeln("Type : ${isMoquette ? 'Moquette' : 'Véhicule'}");
      if (isMoquette) {
        buffer.writeln("Surface : ${t.carpetMeters ?? 0} m²");
        buffer.writeln("Service : Lavage Moquette (${((t.carpetMeters ?? 0) * (t.carpetUnitPrice ?? 0)).toStringAsFixed(1)} DT)");
        if (t.discountAmount != null && t.discountAmount! > 0) {
          buffer.writeln("Remise : -${t.discountAmount!.toStringAsFixed(1)} DT (Motif: ${t.discountReason ?? '-'})");
        }
      } else {
        buffer.writeln("Véhicule : ${t.vehiclePlate ?? '-'} ${t.vehicleBrand ?? ''} ${t.vehicleModel ?? ''}".trim());
        
        final washServices = t.servicesSelected.where((s) {
          final def = serviceMap[s.serviceId];
          if (def != null) return def.serviceType == ServiceType.lavage;
          final nameLower = s.serviceName.toLowerCase();
          return !nameLower.contains('option') && !nameLower.contains('supplément') && !nameLower.contains('extra') && !nameLower.contains('décrass') && !nameLower.contains('produit');
        }).toList();
        buffer.writeln("Service Lavage : ${washServices.isNotEmpty ? washServices.map((s) => '${s.serviceName} (${s.price.toStringAsFixed(1)} DT)').join(', ') : '-'}");

        final optionServices = t.servicesSelected.where((s) {
          final def = serviceMap[s.serviceId];
          if (def != null) return def.serviceType == ServiceType.supplement || def.serviceType == ServiceType.special;
          final nameLower = s.serviceName.toLowerCase();
          return nameLower.contains('option') || nameLower.contains('supplément') || nameLower.contains('extra') || nameLower.contains('décrass') || nameLower.contains('produit');
        }).toList();
        final optionProducts = t.productsUsed.where((p) {
          final prod = productMap[p.productId];
          if (prod != null) return prod.family == ProductFamily.extra || prod.family == ProductFamily.standard;
          final nameLower = p.productName.toLowerCase();
          return !nameLower.contains('sapin') && !nameLower.contains('fresh') && !nameLower.contains('tapis');
        }).toList();
        final optionLines = [
          ...optionServices.map((s) => '${s.serviceName} (${s.price.toStringAsFixed(1)} DT)'),
          ...optionProducts.map((p) => '${p.productName} x${p.quantity} (${p.total.toStringAsFixed(1)} DT)'),
        ];
        buffer.writeln("Options & Suppléments : ${optionLines.isNotEmpty ? optionLines.join(', ') : '-'}");

        final boutiqueProducts = t.productsUsed.where((p) {
          final prod = productMap[p.productId];
          if (prod != null) return prod.family == ProductFamily.revente;
          final nameLower = p.productName.toLowerCase();
          return nameLower.contains('sapin') || nameLower.contains('fresh') || nameLower.contains('tapis') || p.productName.contains('Boutique');
        }).toList();
        final boutiqueLines = boutiqueProducts.map((p) {
          final prod = productMap[p.productId];
          final barcodeStr = (prod != null && prod.barcode.isNotEmpty) ? ' [Code: ${prod.barcode}]' : '';
          return '${p.productName}$barcodeStr x${p.quantity} (${p.total.toStringAsFixed(1)} DT)';
        }).toList();
        buffer.writeln("Boutique : ${boutiqueLines.isNotEmpty ? boutiqueLines.join(', ') : '-'}");
      }
      final pm = t.paymentMethod?.toLowerCase() ?? '';
      final isCompte = pm.contains('compte') || pm.contains('b2b');
      final isTpe = pm.contains('tpe') || pm.contains('carte');
      final String pmLabel = isCompte ? 'Compte Client' : (isTpe ? 'TPE' : 'Espèces');
      final clientStr = (t.clientName != null && t.clientName!.trim().isNotEmpty) ? t.clientName! : '-';
      buffer.writeln("Caissier : ${t.paidBy ?? t.createdBy} | Laveur : ${t.assignedWorkerName ?? 'Non assigné'} | Paiement : $pmLabel | Client : $clientStr");
      buffer.writeln("Total à Payer : ${t.totalAmount.toStringAsFixed(1)} DT");
      buffer.writeln("---------------------------------------------------");
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tableau copié dans le presse-papier ! Vous pouvez le coller dans un email ou Excel.'.tr),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _confirmDeleteTicket(BuildContext context, Ticket ticket) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Supprimer le ticket ?'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous vraiment effacer ce ticket ? Son solde sera déduit de la recette et le stock sera restauré.'.tr),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Motif de suppression'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Annuler'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Le motif est requis'.tr)),
                );
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: Text('Confirmer'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(ticketRepositoryProvider).deleteTicket(
          ticket.id,
          reason: reasonController.text.trim(),
        );
        if (context.mounted) {
          Navigator.pop(context); // Close details modal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ticket effacé avec succès'.tr)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'.tr)),
          );
        }
      }
    }
  }
}

// ============================================================================
// WIDGET: JERRYCAN / BIDON GAUGE (Visual liquid level indicator)
// ============================================================================
class _JerrycanGaugeWidget extends StatelessWidget {
  final String productName;
  final String familyLabel;
  final double currentStock;
  final double consumedQuantity;
  final String unit;
  final double minStock;
  final Color themeColor;
  final int projectedWashes;

  const _JerrycanGaugeWidget({
    required this.productName,
    required this.familyLabel,
    required this.currentStock,
    required this.consumedQuantity,
    required this.unit,
    required this.minStock,
    required this.themeColor,
    required this.projectedWashes,
  });

  @override
  Widget build(BuildContext context) {
    final totalCapacity = (currentStock + consumedQuantity);
    final fillRatio = totalCapacity > 0 ? (currentStock / totalCapacity).clamp(0.0, 1.0) : 1.0;
    final isLowStock = currentStock <= minStock;

    return Container(
      width: 290,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowStock ? AppTheme.errorRed : themeColor.withValues(alpha: 0.3),
          width: isLowStock ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLowStock ? AppTheme.errorRed : themeColor).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Visual Jerrycan Graphic
          Container(
            width: 56,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Liquid Fill Level
                FractionallySizedBox(
                  heightFactor: fillRatio,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeColor.withValues(alpha: 0.6),
                          themeColor,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                    ),
                  ),
                ),
                // Cap visual
                Positioned(
                  top: 2,
                  child: Container(
                    width: 14,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Fill Percentage Text
                Center(
                  child: Text(
                    '${(fillRatio * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  familyLabel,
                  style: TextStyle(fontSize: 10, color: themeColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reste: ${currentStock.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLowStock ? AppTheme.errorRed : AppTheme.successGreen,
                      ),
                    ),
                    Text(
                      'Consommé: ${consumedQuantity.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Stock Projection
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.query_builder, size: 10, color: themeColor),
                      const SizedBox(width: 4),
                      Text(
                        projectedWashes > 0 ? '~ $projectedWashes lavages autonomes' : 'Rupture imminente',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: themeColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODAL: AUDIT STRATEGIQUE (LAVAGES, STOCK & DOSES CONSOMMABLES)
// ============================================================================
class _WashingAndStockAuditModalContent extends ConsumerStatefulWidget {
  final List<Ticket> tickets;
  final Station? station;

  const _WashingAndStockAuditModalContent({
    required this.tickets,
    required this.station,
  });

  @override
  ConsumerState<_WashingAndStockAuditModalContent> createState() => _WashingAndStockAuditModalContentState();
}

class _WashingAndStockAuditModalContentState extends ConsumerState<_WashingAndStockAuditModalContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stationId = widget.station?.id ?? '';
    final allProducts = ref.watch(productsStreamProvider(stationId)).value ?? [];
    final allStockLevels = ref.watch(stockStreamProvider(stationId)).value ?? [];
    final stockMap = {for (final s in allStockLevels) s.productId: s};

    final allServicesDef = ref.watch(serviceDefinitionsStreamProvider(stationId)).value ?? [];
    final serviceMap = {for (final s in allServicesDef) s.id: s};

    final validTickets = widget.tickets.where((t) => t.status != TicketStatus.efface && t.status != TicketStatus.annule).toList();

    // 1. Activity Summaries
    final vehicleTickets = validTickets.where((t) => t.operationType == 'vehicule').toList();
    final moquetteTickets = validTickets.where((t) => t.operationType == 'moquette').toList();
    final int vehicleCount = vehicleTickets.length;
    final double moquetteMeters = moquetteTickets.fold(0.0, (sum, t) => sum + (t.carpetMeters ?? 0.0));
    final double totalRevenue = validTickets.fold(0.0, (sum, t) => sum + t.totalAmount);

    // 2. Aggregate Product Consumption (from direct productsUsed AND linked service products)
    final Map<String, double> consumedProductQuantities = {};
    for (final ticket in validTickets) {
      // Direct products used (shop or extras)
      for (final item in ticket.productsUsed) {
        consumedProductQuantities[item.productId] = (consumedProductQuantities[item.productId] ?? 0.0) + item.quantity;
      }

      // Products linked to services performed
      for (final s in ticket.servicesSelected) {
        final def = serviceMap[s.serviceId];
        if (def != null && def.linkedProducts.isNotEmpty) {
          for (final link in def.linkedProducts) {
            final dose = (ticket.vehicleCategoryId != null && link.consumptionByCategory.containsKey(ticket.vehicleCategoryId))
                ? link.consumptionByCategory[ticket.vehicleCategoryId]!
                : (link.consumptionPerUse > 0 ? link.consumptionPerUse : 1.0);
            consumedProductQuantities[link.productId] = (consumedProductQuantities[link.productId] ?? 0.0) + dose;
          }
        }
      }
    }

    // Filter to display ONLY products that were ACTUALLY USED/CONSUMED during this period
    final List<Product> standardConsumables = allProducts.where((p) {
      final consumed = consumedProductQuantities[p.id] ?? 0.0;
      return p.family == ProductFamily.standard && consumed > 0;
    }).toList();

    final List<Product> premiumConsumables = allProducts.where((p) {
      final consumed = consumedProductQuantities[p.id] ?? 0.0;
      return p.family == ProductFamily.extra && consumed > 0;
    }).toList();

    final List<Product> shopProducts = allProducts.where((p) {
      final consumed = consumedProductQuantities[p.id] ?? 0.0;
      return p.family == ProductFamily.revente && consumed > 0;
    }).toList();

    // 3. Worker breakdown
    final Map<String, List<Ticket>> workerTicketsMap = {};
    for (final t in validTickets) {
      final worker = (t.assignedWorkerName != null && t.assignedWorkerName!.trim().isNotEmpty)
          ? t.assignedWorkerName!.trim()
          : 'Non assigné';
      workerTicketsMap.putIfAbsent(worker, () => []).add(t);
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_car_wash, color: AppTheme.accentCyan, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Lavages, Stock & Consommation Doses'.tr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Vue stratégique de l\'activité, des réserves de stock et de la productivité par employé'.tr,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary Badges Banner
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildSummaryCard('Véhicules Lavés', '$vehicleCount', Icons.directions_car, AppTheme.primaryBlue),
              _buildSummaryCard('Moquettes Lavées', '${moquetteMeters.toStringAsFixed(1)} m²', Icons.layers, Colors.orange),
              _buildSummaryCard('Chiffre d\'Affaires', '${totalRevenue.toStringAsFixed(1)} DT', Icons.monetization_on, AppTheme.successGreen),
              _buildSummaryCard('Ouvriers Actifs', '${workerTicketsMap.length}', Icons.badge, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Bar Navigation
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.textHint.withValues(alpha: 0.2)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentCyan,
              labelColor: AppTheme.accentCyan,
              unselectedLabelColor: AppTheme.textHint,
              tabs: const [
                Tab(icon: Icon(Icons.group, size: 18), text: 'Lavages par Employé'),
                Tab(icon: Icon(Icons.opacity, size: 18), text: 'Stock & Doses Consommables'),
                Tab(icon: Icon(Icons.shopping_bag, size: 18), text: 'Stock Boutique (Revente)'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Lavages par Employé
                _buildEmployeeBreakdownTab(workerTicketsMap),

                // Tab 2: Stock & Doses Consommables
                _buildConsumablesStockTab(standardConsumables, premiumConsumables, consumedProductQuantities, stockMap, vehicleCount),

                // Tab 3: Stock Boutique (Revente)
                _buildShopStockTab(shopProducts, consumedProductQuantities, stockMap),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  // --- Tab 1: Lavages par Employé ---
  Widget _buildEmployeeBreakdownTab(Map<String, List<Ticket>> workerTicketsMap) {
    if (workerTicketsMap.isEmpty) {
      return Center(child: Text('Aucun lavage enregistré pour cette période.'.tr));
    }

    return ListView(
      children: workerTicketsMap.entries.map((entry) {
        final workerName = entry.key;
        final workerTickets = entry.value;

        final vCount = workerTickets.where((t) => t.operationType == 'vehicule').length;
        final mMeters = workerTickets.where((t) => t.operationType == 'moquette').fold(0.0, (sum, t) => sum + (t.carpetMeters ?? 0.0));
        final caTotal = workerTickets.fold(0.0, (sum, t) => sum + t.totalAmount);
        final shopCount = workerTickets.fold(0, (sum, t) => sum + t.productsUsed.where((p) => p.productName.contains('Sapin') || p.productName.contains('Fresh') || p.productName.contains('Boutique')).length);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.accentCyan,
                          child: Text(
                            workerName.isNotEmpty ? workerName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(workerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${workerTickets.length} ticket(s) traités', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'CA : ${caTotal.toStringAsFixed(1)} DT',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildSubBadge('🚗 Véhicules', '$vCount', AppTheme.primaryBlue),
                    _buildSubBadge('🧼 Moquettes', '${mMeters.toStringAsFixed(1)} m²', Colors.orange),
                    _buildSubBadge('🛍️ Articles Boutique Vendus', '$shopCount art.', Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label : $value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  // --- Tab 2: Stock & Doses Consommables ---
  Widget _buildConsumablesStockTab(
    List<Product> standardConsumables,
    List<Product> premiumConsumables,
    Map<String, double> consumedMap,
    Map<String, StockLevel> stockMap,
    int totalVehicles,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Consommable Standard
          Row(
            children: const [
              Icon(Icons.waves, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 6),
              Text(
                'Consommables Standard (Lavage Courant)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (standardConsumables.isEmpty)
            const Text('Aucun consommable standard défini.', style: TextStyle(color: AppTheme.textHint))
          else
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: standardConsumables.map((prod) {
                final consumed = consumedMap[prod.id] ?? 0.0;
                final stockLevel = stockMap[prod.id];
                final currentQty = stockLevel?.currentQuantity ?? 0.0;
                final minStock = stockLevel?.minStock ?? prod.minStock.toDouble();

                final avgPerWash = totalVehicles > 0 ? (consumed / totalVehicles) : 0.1;
                final projected = avgPerWash > 0 ? (currentQty / avgPerWash).toInt() : 99;

                return _JerrycanGaugeWidget(
                  productName: prod.name,
                  familyLabel: 'Standard (Chaque lavage)',
                  currentStock: currentQty,
                  consumedQuantity: consumed,
                  unit: prod.unit,
                  minStock: minStock,
                  themeColor: AppTheme.accentCyan,
                  projectedWashes: projected,
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          // Section 2: Consommable Premium / Extra
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.purple, size: 18),
              SizedBox(width: 6),
              Text(
                'Consommables Premium / Extra (Options VIP & Céramique)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (premiumConsumables.isEmpty)
            const Text('Aucun consommable premium défini.', style: TextStyle(color: AppTheme.textHint))
          else
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: premiumConsumables.map((prod) {
                final consumed = consumedMap[prod.id] ?? 0.0;
                final stockLevel = stockMap[prod.id];
                final currentQty = stockLevel?.currentQuantity ?? 0.0;
                final minStock = stockLevel?.minStock ?? prod.minStock.toDouble();

                final avgPerWash = totalVehicles > 0 ? (consumed / totalVehicles) : 0.05;
                final projected = avgPerWash > 0 ? (currentQty / avgPerWash).toInt() : 99;

                return _JerrycanGaugeWidget(
                  productName: prod.name,
                  familyLabel: 'Premium (Options Extra)',
                  currentStock: currentQty,
                  consumedQuantity: consumed,
                  unit: prod.unit,
                  minStock: minStock,
                  themeColor: Colors.purple,
                  projectedWashes: projected,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // --- Tab 3: Stock Boutique (Revente) ---
  Widget _buildShopStockTab(
    List<Product> shopProducts,
    Map<String, double> consumedMap,
    Map<String, StockLevel> stockMap,
  ) {
    if (shopProducts.isEmpty) {
      return Center(child: Text('Aucun produit boutique (revente) configuré.'.tr));
    }

    return ListView.builder(
      itemCount: shopProducts.length,
      itemBuilder: (context, index) {
        final prod = shopProducts[index];
        final soldQty = consumedMap[prod.id] ?? 0.0;
        final stockLevel = stockMap[prod.id];
        final currentQty = stockLevel?.currentQuantity ?? 0.0;
        final minStock = stockLevel?.minStock ?? prod.minStock.toDouble();
        final isLow = currentQty <= minStock;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isLow ? AppTheme.errorRed.withValues(alpha: 0.2) : AppTheme.successGreen.withValues(alpha: 0.2),
              child: Icon(Icons.shopping_bag, color: isLow ? AppTheme.errorRed : AppTheme.successGreen, size: 20),
            ),
            title: Text('${prod.name} ${prod.barcode.isNotEmpty ? "[Code: ${prod.barcode}]" : ""}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Prix Vente: ${prod.unitPrice.toStringAsFixed(1)} DT | Prix Achat: ${prod.purchasePrice.toStringAsFixed(1)} DT'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Stock Restant: ${currentQty.toInt()} ${prod.unit}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLow ? AppTheme.errorRed : AppTheme.successGreen,
                  ),
                ),
                Text('Vendus: ${soldQty.toInt()}', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
              ],
            ),
          ),
        );
      },
    );
  }
}

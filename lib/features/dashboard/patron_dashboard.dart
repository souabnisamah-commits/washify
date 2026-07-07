import 'package:flutter/material.dart';
import 'package:washify/core/widgets/language_toggle_button.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:washify/features/auth/widgets/change_pin_dialog.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:intl/intl.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/features/tickets/models/ticket.dart';

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
    
    if (_startDate.isAtSameMomentAs(todayStart) && _endDate.difference(_startDate).inDays == 1) {
      return "Aujourd'hui";
    }
    
    final dateFormat = DateFormat('dd/MM/yyyy');
    final endToDisplay = _endDate.subtract(const Duration(days: 1));
    
    if (_startDate.isAtSameMomentAs(endToDisplay)) {
      return "Le ${dateFormat.format(_startDate)}";
    }
    
    return "Du ${dateFormat.format(_startDate)} au ${dateFormat.format(endToDisplay)}";
  }

  void _showTicketsDetails(BuildContext context, String title, List<Ticket> tickets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: tickets.isEmpty 
                    ? Center(child: Text("Aucun ticket sur cette période.".tr))
                    : ListView.separated(
                        itemCount: tickets.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          final timeStr = DateFormat('dd/MM HH:mm').format(ticket.updatedAt);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text("Ticket ${ticket.id.substring(ticket.id.length > 5 ? ticket.id.length - 5 : 0).toUpperCase()} - ${ticket.totalAmount.toStringAsFixed(1)} DT", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${ticket.servicesSelected.map((s)=>s.serviceName).join(', ')}\nTraité par: ${ticket.assignedWorkerName ?? 'Non assigné'}"),
                            trailing: Text(timeStr, style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmployeeStats(BuildContext context, List<Ticket> tickets) {
    final Map<String, int> washesPerEmployee = {};
    for (final ticket in tickets) {
      final worker = ticket.assignedWorkerName ?? 'Non assigné';
      washesPerEmployee[worker] = (washesPerEmployee[worker] ?? 0) + 1;
    }

    final sortedStats = washesPerEmployee.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Lavages par Employé", style: Theme.of(context).textTheme.titleLarge),
                    IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: sortedStats.isEmpty 
                    ? Center(child: Text("Aucun lavage sur cette période.".tr))
                    : ListView.separated(
                        itemCount: sortedStats.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final stat = sortedStats[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.accentCyan,
                              child: Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                            title: Text(stat.key, style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Text("${stat.value} lavage(s)", style: TextStyle(fontSize: 16, color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Scaffold(body: Center(child: CircularProgressIndicator()));

    // Watch station assigned to this patron
    final stationAsync = user.tenantId.isEmpty 
        ? const AsyncValue<Station?>.data(null)
        : ref.watch(stationByIdProvider(user.tenantId));

    // Stats for selected station
    final statsAsync = _currentStation == null
        ? null
        : ref.watch(revenueStatsProvider((
            stationId: _currentStation!.id,
            startDate: _startDate,
            endDate: _endDate,
          )));

    return Scaffold(
      appBar: AppBar(
        title: Text('Espace Patron'.tr),
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
            // Station Selector
            stationAsync.when(
              data: (station) {
                if (station == null) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.5)),
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

                return DropdownButtonFormField<Station>(
                  initialValue: _currentStation ?? station,
                  decoration: InputDecoration(
                    labelText: 'Sélectionner la Station'.tr,
                    prefixIcon: Icon(Icons.store, color: AppTheme.accentCyan),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: station,
                      child: Text(station.name),
                    )
                  ],
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
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur chargement station: $e'.tr),
            ),
            SizedBox(height: 24),

            if (_currentStation != null) ...[
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statistiques',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  InkWell(
                    onTap: () => _selectDateRange(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCardLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accentCyan),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_month, size: 16, color: AppTheme.accentCyan),
                          SizedBox(width: 8),
                          Text(_dateRangeText, style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.accentCyan),
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
                              showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator()));
                              try {
                                final tickets = await ref.read(ticketsByDateRangeProvider((stationId: _currentStation!.id, startDate: _startDate, endDate: _endDate)).future);
                                if (mounted) {
                                  Navigator.pop(context);
                                  _showTicketsDetails(context, 'Détail Chiffre d\'Affaires', tickets);
                                }
                              } catch (e) {
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'.tr)));
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
                              showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator()));
                              try {
                                final t = await ref.read(ticketsByDateRangeProvider((stationId: _currentStation!.id, startDate: _startDate, endDate: _endDate)).future);
                                if (mounted) {
                                  Navigator.pop(context);
                                  _showEmployeeStats(context, t);
                                }
                              } catch (e) {
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'.tr)));
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
              SizedBox(height: 24),

              // Menu
              Text(
                'Gestion de la Station',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // Bloc Personnel (Orange)
                  _buildGridItem(
                    context,
                    title: 'RH & Pointage',
                    icon: Icons.engineering,
                    color: Colors.orange,
                    onTap: () => context.go('/patron/hr'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Employés',
                    icon: Icons.people_outline,
                    color: Colors.orangeAccent,
                    onTap: () => context.go('/patron/employees'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Fiches de Paie',
                    icon: Icons.payments_outlined,
                    color: Colors.deepOrangeAccent,
                    onTap: () => context.go('/patron/payroll'),
                  ),
                  
                  // Bloc Atelier (Bleu)
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
                    icon: Icons.dry_cleaning,
                    color: AppTheme.accentTeal,
                    onTap: () => context.go('/patron/service-definitions'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Offres & Pack',
                    icon: Icons.local_offer,
                    color: Colors.blueAccent,
                    onTap: () => context.go('/patron/offers'),
                  ),
                  
                  // Bloc Finances & Commerce (Vert)
                  _buildGridItem(
                    context,
                    title: 'Comptes B2B',
                    icon: Icons.business,
                    color: AppTheme.successGreen,
                    onTap: () => context.go('/patron/clients'),
                  ),

                  // Bloc Matériel (Violet/Cyan)
                  _buildGridItem(
                    context,
                    title: 'Produits',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.go('/patron/products'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Stock & Achats',
                    icon: Icons.inventory_2,
                    color: AppTheme.accentCyan,
                    onTap: () => context.go('/patron/stock'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Audits',
                    icon: Icons.assignment_turned_in_outlined,
                    color: Colors.purpleAccent,
                    onTap: () => context.go('/patron/inventory'),
                  ),
                ],
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
    VoidCallback? onTap,
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
              Icon(icon, color: color, size: 28),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 48),
            ),
            SizedBox(height: 12),
            Text(
              title.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

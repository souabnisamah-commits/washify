import re

with open('lib/features/dashboard/patron_dashboard.dart', 'r', encoding='utf-8') as f:
    code = f.read()

new_ui_code = """
            if (_currentStation != null) ...[
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle(context, 'Statistiques', Icons.bar_chart),
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
                            title: 'Chiffre d\\'Affaires',
                            value: '${revenue.toStringAsFixed(2)} DT',
                            icon: Icons.monetization_on_outlined,
                            color: AppTheme.successGreen,
                            onTap: () async {
                              showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator()));
                              try {
                                final tickets = await ref.read(ticketsByDateRangeProvider((stationId: _currentStation!.id, startDate: _startDate, endDate: _endDate)).future);
                                if (mounted) {
                                  Navigator.pop(context);
                                  _showTicketsDetails(context, 'Détail Chiffre d\\'Affaires', tickets);
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
              SizedBox(height: 32),

              // Section: Opérations Quotidiennes
              _buildSectionTitle(context, 'Opérations Quotidiennes', Icons.calendar_today),
              SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
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
                }
              ),

              SizedBox(height: 32),
              
              // Section: Inventaire & Audits
              _buildSectionTitle(context, 'Inventaire & Audits', Icons.fact_check_outlined),
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

              // Section: Configuration & Catalogue
              _buildSectionTitle(context, 'Configuration & Catalogue', Icons.settings),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 500 ? 3 : 2),
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
                    title: 'Offres & Pack',
                    icon: Icons.stars,
                    color: Colors.blueAccent,
                    onTap: () => context.go('/patron/offers'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Comptes B2B',
                    icon: Icons.business_center,
                    color: AppTheme.successGreen,
                    onTap: () => context.go('/patron/clients'),
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
            ]
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title.tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
"""

match_block = re.search(r"            if \(_currentStation != null\) \.\.\.\[[\s\S]*?  Widget _buildGridItem\([\s\S]*?    \);\s+  }", code)
if match_block:
    code = code[:match_block.start()] + new_ui_code + code[match_block.end():]
    with open('lib/features/dashboard/patron_dashboard.dart', 'w', encoding='utf-8') as f:
        f.write(code)
    print("Dashboard restored successfully!")
else:
    print("Could not find the block to replace.")

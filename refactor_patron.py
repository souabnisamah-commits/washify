import re

with open('lib/features/dashboard/patron_dashboard.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 1. Replace the Menu Section (lines 429 to 522)
new_menu_lines = """              // Section: Opérations Quotidiennes
              _buildSectionTitle(context, 'Opérations Quotidiennes', Icons.flash_on),
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
                        title: 'Stock & Achats',
                        icon: Icons.inventory_2,
                        color: AppTheme.accentCyan,
                        onTap: () => context.go('/patron/stock'),
                      ),
                    ],
                  );
                }
              ),

              SizedBox(height: 32),
              
              // Section: Inventaire & Audits
              _buildSectionTitle(context, 'Inventaire & Audits', Icons.assignment_turned_in),
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
                    icon: Icons.fact_check_outlined,
                    color: Colors.purpleAccent,
                    onTap: () => context.go('/patron/inventory'),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // Section: Configuration & Catalogue
              _buildSectionTitle(context, 'Configuration & Catalogue', Icons.settings_suggest),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 500 ? 3 : 2),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.0,
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
                  _buildGridItem(
                    context,
                    title: 'Produits',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.go('/patron/products'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Comptes B2B',
                    icon: Icons.business,
                    color: AppTheme.successGreen,
                    onTap: () => context.go('/patron/clients'),
                  ),
                ],
              ),
"""

# Let's use regex to find the `// Menu` down to `] \n ] \n )` safely
content = "".join(lines)
menu_pattern = re.compile(r"              // Menu\s+Text\([\s\S]*?              \),\s+\]\s+\]\s+,\s+\),\s+\),\s+\);", re.MULTILINE)
new_menu_replacement = new_menu_replacement = new_menu_lines + """            ]
          ],
        ),
      ),
    );
"""
content = menu_pattern.sub(new_menu_replacement, content)

# 2. Replace _buildGridItem and add _buildSectionTitle
grid_item_pattern = re.compile(r"  Widget _buildGridItem\([\s\S]*?    \);\s+  }", re.MULTILINE)
new_grid_item = """  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 28),
        SizedBox(width: 12),
        Text(
          title.tr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title.tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }"""
content = grid_item_pattern.sub(new_grid_item, content)

# 3. Upgrade _buildStatCard to Pro Max Glassmorphism
stat_card_pattern = re.compile(r"  Widget _buildStatCard\([\s\S]*?    \);\s+  }", re.MULTILINE)
new_stat_card = """  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                          color: AppTheme.textHint,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
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
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }"""
content = stat_card_pattern.sub(new_stat_card, content)

import_to_add = "import 'dart:ui';\n"
if "import 'dart:ui';" not in content:
    content = import_to_add + content

with open('lib/features/dashboard/patron_dashboard.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Dashboard rewritten successfully!")

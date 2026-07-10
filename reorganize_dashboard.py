import re

with open('lib/features/dashboard/patron_dashboard.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Helper method _buildSectionTitle
section_title_helper = """
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          SizedBox(width: 8),
          Text(
            title.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
"""
content = content.replace("  Widget _buildStatCard(", section_title_helper)

# The new structure
old_menu_section = """              // Menu
              Text(
                'Gestion de la Station',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              
              GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 80,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // Bloc Personnel (Orange)
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
                    icon: Icons.groups,
                    color: Colors.orangeAccent,
                    onTap: () => context.go('/patron/employees'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Fiches de Paie',
                    icon: Icons.request_quote,
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
                    icon: Icons.water_drop,
                    color: AppTheme.accentTeal,
                    onTap: () => context.go('/patron/service-definitions'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Offres & Pack',
                    icon: Icons.stars,
                    color: Colors.blueAccent,
                    onTap: () => context.go('/patron/offers'),
                  ),
                  
                  // Bloc Finances & Commerce (Vert)
                  _buildGridItem(
                    context,
                    title: 'Comptes B2B',
                    icon: Icons.business_center,
                    color: AppTheme.successGreen,
                    onTap: () => context.go('/patron/clients'),
                  ),

                  // Bloc Matériel (Violet/Cyan)
                  _buildGridItem(
                    context,
                    title: 'Produits',
                    icon: Icons.inventory,
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.go('/patron/products'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Stock & Achats',
                    icon: Icons.local_shipping,
                    color: AppTheme.accentCyan,
                    onTap: () => context.go('/patron/stock'),
                  ),
                  _buildGridItem(
                    context,
                    title: 'Audits',
                    icon: Icons.fact_check,
                    color: Colors.purpleAccent,
                    onTap: () => context.go('/patron/inventory'),
                  ),
                ],
              ),"""

new_menu_section = """              // 1. Opérations Quotidiennes
              _buildSectionTitle(context, 'Opérations Quotidiennes', Icons.calendar_today),
              GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  mainAxisExtent: 90,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
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
                    icon: Icons.groups,
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
                  /* Fiche de Paie masquée temporairement
                  _buildGridItem(
                    context,
                    title: 'Fiches de Paie',
                    icon: Icons.request_quote,
                    color: Colors.deepOrangeAccent,
                    onTap: () => context.go('/patron/payroll'),
                  ),
                  */
                ],
              ),
              
              SizedBox(height: 16),

              // 2. Vérifications Périodiques
              _buildSectionTitle(context, 'Inventaire & Audits', Icons.fact_check),
              GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 80,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(
                    context,
                    title: 'Audits',
                    icon: Icons.fact_check,
                    color: Colors.purpleAccent,
                    onTap: () => context.go('/patron/inventory'),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 3. Configuration & Paramétrage
              _buildSectionTitle(context, 'Configuration & Catalogue', Icons.settings),
              GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisExtent: 70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
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
                    icon: Icons.inventory,
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
              ),"""

if old_menu_section in content:
    content = content.replace(old_menu_section, new_menu_section)
    with open('lib/features/dashboard/patron_dashboard.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Success")
else:
    print("Could not find old menu section to replace.")

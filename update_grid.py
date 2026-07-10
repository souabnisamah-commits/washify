import re

with open('lib/features/dashboard/patron_dashboard.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update GridView settings
old_grid = """              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,"""
new_grid = """              GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,"""
content = content.replace(old_grid, new_grid)

# 2. Update Icons
# RH
content = content.replace("icon: Icons.engineering,", "icon: Icons.badge_outlined,")
# Employes
content = content.replace("icon: Icons.people_outline,", "icon: Icons.groups_outlined,")
# Fiches de Paie
content = content.replace("icon: Icons.payments_outlined,", "icon: Icons.receipt_long_outlined,")
# Categories
content = content.replace("icon: Icons.directions_car,", "icon: Icons.directions_car_outlined,")
# Services
content = content.replace("icon: Icons.dry_cleaning,", "icon: Icons.water_drop_outlined,")
# Offres
content = content.replace("icon: Icons.local_offer,", "icon: Icons.loyalty_outlined,")
# Comptes B2B
content = content.replace("icon: Icons.business,", "icon: Icons.domain_outlined,")
# Produits
content = content.replace("icon: Icons.inventory_2_outlined,", "icon: Icons.shopping_bag_outlined,")
# Stock
content = content.replace("icon: Icons.inventory_2,", "icon: Icons.storefront_outlined,")
# Audits
content = content.replace("icon: Icons.assignment_turned_in_outlined,", "icon: Icons.fact_check_outlined,")

# 3. Update sizes in _buildGridItem
old_grid_item_styles = """                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: -5,
                        )
                      ],
                    ),
                    child: Icon(icon, color: color, size: 40),
                  ),
                  SizedBox(height: 16),
                  Text(
                    title.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,"""

new_grid_item_styles = """                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: -5,
                        )
                      ],
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  SizedBox(height: 12),
                  Text(
                    title.tr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,"""
content = content.replace(old_grid_item_styles, new_grid_item_styles)


with open('lib/features/dashboard/patron_dashboard.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Grid size and icons updated!")

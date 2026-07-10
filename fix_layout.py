import re

with open('lib/features/dashboard/patron_dashboard.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Change GridView.count to GridView with maxCrossAxisExtent to prevent infinite vertical scaling
old_grid = """              GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,"""
new_grid = """              GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 80,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),"""
content = content.replace(old_grid, new_grid)

# 2. Change the icons back to filled or more pro icons
content = content.replace("icon: Icons.badge_outlined,", "icon: Icons.access_time_filled,")
content = content.replace("icon: Icons.groups_outlined,", "icon: Icons.groups,")
content = content.replace("icon: Icons.receipt_long_outlined,", "icon: Icons.request_quote,")
content = content.replace("icon: Icons.directions_car_outlined,", "icon: Icons.directions_car,")
content = content.replace("icon: Icons.water_drop_outlined,", "icon: Icons.water_drop,")
content = content.replace("icon: Icons.loyalty_outlined,", "icon: Icons.stars,")
content = content.replace("icon: Icons.domain_outlined,", "icon: Icons.business_center,")
content = content.replace("icon: Icons.shopping_bag_outlined,", "icon: Icons.inventory,")
content = content.replace("icon: Icons.storefront_outlined,", "icon: Icons.local_shipping,")
content = content.replace("icon: Icons.fact_check_outlined,", "icon: Icons.fact_check,")

# 3. Completely rewrite _buildGridItem to be a horizontal card
old_grid_item = """  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.05 : 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.3), width: 1.5),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
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
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }"""

new_grid_item = """  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.05 : 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.3), width: 1),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.02),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: -2,
                        )
                      ],
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: -0.2,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }"""
content = content.replace(old_grid_item, new_grid_item)

with open('lib/features/dashboard/patron_dashboard.dart', 'w', encoding='utf-8') as f:
    f.write(content)

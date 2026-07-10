import re

with open('lib/features/dashboard/patron_dashboard.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add ProMaxStatCard import
import_statement = "import 'package:washify/core/widgets/pro_max_stat_card.dart';\n"
if "pro_max_stat_card.dart" not in content:
    content = content.replace("import 'package:washify/core/theme/app_theme.dart';", "import 'package:washify/core/theme/app_theme.dart';\n" + import_statement)

# 2. Add dart:ui import for BackdropFilter/ImageFilter if missing
if "import 'dart:ui';" not in content:
    content = "import 'dart:ui';\n" + content

# 3. Replace AppBar with Glassmorphism AppBar
old_appbar = """      appBar: AppBar(
        title: Text('Espace Patron'.tr),"""

new_appbar = """      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Espace Patron'.tr),
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),"""
content = content.replace(old_appbar, new_appbar)

# 4. Modify Scaffold Body to add top padding so it isn't hidden behind the transparent appbar
old_body = "      body: SingleChildScrollView("
new_body = "      body: SingleChildScrollView(\n        padding: EdgeInsets.only(top: kToolbarHeight + 40, left: 16, right: 16, bottom: 16),"
content = content.replace("padding: EdgeInsets.all(16.0),", "") # Remove old padding
content = content.replace(old_body, new_body)


# 5. Replace _buildStatCard body
old_stat_card = """  Widget _buildStatCard(
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: (Theme.of(context).dividerTheme.color ?? Colors.grey)),
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
  }"""

new_stat_card = """  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ProMaxStatCard(
      title: title,
      value: value,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }"""
content = content.replace(old_stat_card, new_stat_card)


# 6. Replace Date Selector aesthetics
old_date_selector = """                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accentCyan),
                      ),"""

new_date_selector = """                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: [
                           BoxShadow(
                             color: AppTheme.accentCyan.withValues(alpha: 0.1),
                             blurRadius: 8,
                             offset: Offset(0, 4),
                           )
                        ],
                      ),"""
content = content.replace(old_date_selector, new_date_selector)

# 7. Add Glassmorphism to _buildGridItem
old_grid_item = """  Widget _buildGridItem(
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
                      fontSize: 15,
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
content = content.replace(old_grid_item, new_grid_item)

with open('lib/features/dashboard/patron_dashboard.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Refactor complete!")

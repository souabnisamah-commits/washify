import re

with open('lib/features/dashboard/patron_dashboard.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Update ColorAnimatedTitle text
title_pattern = r"text: 'Bienvenue Patron, dans votre Espace',"
new_title = "text: 'Bienvenue ${user.name}, dans votre Espace ${_currentStation?.name ?? ''}',"
code = code.replace(title_pattern, new_title)

# 2. Hide DropdownButtonFormField<Station>
dropdown_pattern = re.compile(r"return DropdownButtonFormField<Station>\([\s\S]*?;\s+},\s+\);", re.MULTILINE)
new_dropdown = "return SizedBox.shrink();"
code = dropdown_pattern.sub(new_dropdown, code)

# 3. Update _buildStatCard for light mode
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
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
                      color: isDark ? Colors.white70 : AppTheme.textHint,
                      fontWeight: FontWeight.w600,
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
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }"""
code = stat_card_pattern.sub(new_stat_card, code)

# 4. Update _buildGridItem for light mode
grid_item_pattern = re.compile(r"  Widget _buildGridItem\([\s\S]*?    \);\s+  }", re.MULTILINE)
new_grid_item = """  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
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
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white38 : AppTheme.textHint, size: 20),
          ],
        ),
      ),
    );
  }"""
code = grid_item_pattern.sub(new_grid_item, code)

with open('lib/features/dashboard/patron_dashboard.dart', 'w', encoding='utf-8') as f:
    f.write(code)
print("Dashboard patch 3 applied!")

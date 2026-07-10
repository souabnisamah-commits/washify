import re

with open('lib/features/dashboard/patron_dashboard.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import 'package:washify/providers/ticket_provider.dart';", "import 'package:washify/providers/ticket_provider.dart';\nimport 'package:washify/providers/theme_provider.dart';")

appbar_actions = """actions: [
          IconButton(
            icon: Icon(ref.watch(themeProvider) == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            tooltip: 'Changer le thème'.tr,
          ),"""
content = content.replace("actions: [", appbar_actions)

replacements = {
    "AppTheme.surfaceCard": "Theme.of(context).colorScheme.surface",
    "AppTheme.surfaceCardLight": "(Theme.of(context).inputDecorationTheme.fillColor ?? Colors.white)",
    "AppTheme.textHint": "(Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)",
    "AppTheme.dividerColor": "(Theme.of(context).dividerTheme.color ?? Colors.grey)",
    "AppTheme.errorRed": "Theme.of(context).colorScheme.error",
    "ColorScheme.dark(": "Theme.of(context).colorScheme.copyWith(",
    "onSurface: Colors.white,": "onSurface: Theme.of(context).colorScheme.onSurface,"
}

for old, new in replacements.items():
    content = content.replace(old, new)

with open('lib/features/dashboard/patron_dashboard.dart', 'w', encoding='utf-8') as f:
    f.write(content)

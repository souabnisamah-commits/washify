import os

dashboards = [
    'lib/features/dashboard/worker_dashboard.dart',
    'lib/features/dashboard/cashier_dashboard.dart',
    'lib/features/dashboard/multi_role_dashboards.dart'
]

for p in dashboards:
    with open(p, 'r', encoding='utf-8') as f:
        code = f.read()
    
    if "import 'package:washify/providers/theme_provider.dart';" not in code:
        code = code.replace("import 'package:washify/providers/station_provider.dart';", "import 'package:washify/providers/theme_provider.dart';\nimport 'package:washify/providers/station_provider.dart';")
        
    with open(p, 'w', encoding='utf-8') as f:
        f.write(code)

print("themeProvider injected.")

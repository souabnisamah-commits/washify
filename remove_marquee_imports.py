import os

dashboards = [
    'lib/features/dashboard/worker_dashboard.dart',
    'lib/features/dashboard/cashier_dashboard.dart',
    'lib/features/dashboard/multi_role_dashboards.dart'
]

for path in dashboards:
    with open(path, 'r', encoding='utf-8') as f:
        code = f.read()

    code = code.replace("import 'package:marquee/marquee.dart';", "")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(code)

print("Marquee import removed")

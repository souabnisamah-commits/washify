import os

dashboards = [
    'lib/features/dashboard/worker_dashboard.dart',
    'lib/features/dashboard/cashier_dashboard.dart',
    'lib/features/dashboard/multi_role_dashboards.dart'
]

for p in dashboards:
    with open(p, 'r', encoding='utf-8') as f:
        code = f.read()

    code = code.replace(
        "const Shift(id: '', stationId: '', name: 'Inconnu', startTime: '', endTime: '', createdAt: null) as Shift",
        "Shift(id: '', stationId: '', name: 'Inconnu', startTime: '', endTime: '', createdAt: DateTime.now())"
    )

    with open(p, 'w', encoding='utf-8') as f:
        f.write(code)

print('Fixed Shift.')

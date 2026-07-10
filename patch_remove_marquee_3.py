import os

def replace_in_file(path, target_text, text_param):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add import
    import_stmt = "import 'package:washify/core/widgets/color_animated_title.dart';\n"
    if import_stmt not in content:
        content = content.replace("import 'package:flutter/material.dart';", f"import 'package:flutter/material.dart';\n{import_stmt}")
    
    # Remove marquee import
    content = content.replace("import 'package:marquee/marquee.dart';", "")

    # Replace Marquee widget block
    import re
    # Match the Marquee widget strictly to avoid bracket mismatches
    # Example: child: Marquee(\n ... \n),
    pattern = r"child:\s*Marquee\([\s\S]*?decelerationCurve:\s*Curves\.easeOut,\s*\),"
    replacement = f"""child: ColorAnimatedTitle(
              text: {text_param},
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),"""
            
    content = re.sub(pattern, replacement, content)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# Worker Dashboard
replace_in_file(
    'lib/features/dashboard/worker_dashboard.dart',
    '',
    "'Bienvenue ${user.name}, dans votre Espace Ouvrier'.tr"
)

# Cashier Dashboard
replace_in_file(
    'lib/features/dashboard/cashier_dashboard.dart',
    '',
    "'Bienvenue ${user.name}, dans votre Espace Caissier'.tr"
)

# Multi Role Dashboards
replace_in_file(
    'lib/features/dashboard/multi_role_dashboards.dart',
    '',
    "'Bienvenue ${employeeAsync.value?.name ?? user.name}, dans votre Espace ${_getStationName()}'"
)

print("Dashboards safely patched")

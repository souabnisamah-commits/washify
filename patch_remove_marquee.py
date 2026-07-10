import os
import re

files_to_patch = [
    'lib/features/dashboard/cashier_dashboard.dart',
    'lib/features/dashboard/worker_dashboard.dart',
    'lib/features/dashboard/multi_role_dashboards.dart',
]

import_statement = "import 'package:washify/core/widgets/color_animated_title.dart';\n"

for path in files_to_patch:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove marquee import
    content = re.sub(r"import 'package:marquee/marquee\.dart';\n", "", content)
    
    # Add new import if not exists
    if import_statement not in content:
        # Add after material import
        content = content.replace("import 'package:flutter/material.dart';", f"import 'package:flutter/material.dart';\n{import_statement}")
    
    # Replace Marquee with ColorAnimatedTitle
    # We will use regex to find the Marquee widget and replace it.
    # Since Marquee has multiple lines, we can use a simpler replacement for the specific block.
    # We know it looks like: child: Marquee( ... ),
    
    marquee_pattern = r"child:\s*Marquee\([\s\S]*?decelerationCurve:\s*Curves\.easeOut,\s*\),"
    
    replacement = """child: ColorAnimatedTitle(
                  text: 'Bienvenue ${employeeAsync.value?.name ?? user.name}, dans votre Espace ${_getStationName()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),"""
                
    content = re.sub(marquee_pattern, replacement, content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Dashboards patched")

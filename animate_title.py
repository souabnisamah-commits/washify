import re

with open('lib/features/dashboard/patron_dashboard.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports if missing
if "import 'package:marquee/marquee.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:marquee/marquee.dart';\nimport 'package:shimmer/shimmer.dart';")

# Replace title
old_title = "title: Text('Bienvenue ${user.name}, dans votre Espace ${_currentStation?.name ?? ''}'.tr),"
new_title = """title: SizedBox(
          height: 30,
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.primary,
            highlightColor: AppTheme.accentCyan,
            child: Marquee(
              text: 'Bienvenue ${user.name}, dans votre Espace ${_currentStation?.name ?? ''}'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 100.0,
              velocity: 40.0,
              startPadding: 10.0,
            ),
          ),
        ),"""

if old_title in content:
    content = content.replace(old_title, new_title)
    with open('lib/features/dashboard/patron_dashboard.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Success: Title animation applied.")
else:
    print("Error: Could not find old title string.")

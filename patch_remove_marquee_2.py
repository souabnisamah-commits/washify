import os
import re

files_to_patch = [
    'lib/features/dashboard/cashier_dashboard.dart',
    'lib/features/dashboard/worker_dashboard.dart',
    'lib/features/dashboard/multi_role_dashboards.dart',
]

for path in files_to_patch:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We will just replace any occurrence of Marquee(...) correctly.
    # A simple regex to replace Marquee block:
    # Match from `Marquee(` to the matching closing `),`
    # Since regex is hard for nested parentheses, we'll do it manually.
    
    while 'child: Marquee(' in content:
        start_idx = content.find('child: Marquee(')
        # Find the matching closing parenthesis
        open_count = 0
        end_idx = start_idx + 14 # Index of '('
        for i in range(end_idx, len(content)):
            if content[i] == '(':
                open_count += 1
            elif content[i] == ')':
                open_count -= 1
                if open_count == 0:
                    end_idx = i
                    break
        
        # Replace the chunk
        chunk = content[start_idx:end_idx+1]
        
        # Extract the text parameter to keep it
        text_match = re.search(r"text:\s*(.*?),", chunk)
        text_val = text_match.group(1) if text_match else "'Bienvenue'"
        
        replacement = f"child: ColorAnimatedTitle(text: {text_val})"
        content = content[:start_idx] + replacement + content[end_idx+1:]
        
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Dashboards patched successfully")

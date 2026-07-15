import os
import glob
import re

repo_dir = r"c:\Users\SAM\Pictures\washify\lib\repositories"

# Ignore these as they are either already patched or shouldn't be patched (Auth)
ignore_list = [
    "ticket_repository.dart",
    "client_repository.dart",
    "stock_repository.dart",
    "employee_repository.dart",
    "payroll_repository.dart",
    "wallet_repository.dart",
    "auth_repository.dart"
]

for repo_file in glob.glob(os.path.join(repo_dir, "*.dart")):
    basename = os.path.basename(repo_file)
    if basename in ignore_list:
        continue
        
    with open(repo_file, "r", encoding="utf-8") as f:
        content = f.read()
    
    if "this.tenantId = ''" in content:
        continue
        
    # Find class name
    class_match = re.search(r"class\s+(\w+Repository)", content)
    if not class_match:
        continue
    class_name = class_match.group(1)
    
    # Target 1: Add field
    target_field = "final FirebaseFirestore _firestore;"
    replacement_field = "final FirebaseFirestore _firestore;\n  final String tenantId;"
    
    # Target 2: Update constructor
    target_constructor = f"{class_name}({{FirebaseFirestore? firestore}})"
    replacement_constructor = f"{class_name}({{FirebaseFirestore? firestore, this.tenantId = ''}})"
    
    # Replace
    if target_field in content and target_constructor in content:
        content = content.replace(target_field, replacement_field)
        content = content.replace(target_constructor, replacement_constructor)
        
        with open(repo_file, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Patched {basename}")
    else:
        print(f"Failed to find targets in {basename}")

import os
import glob
import re

prov_dir = r"c:\Users\SAM\Pictures\washify\lib\providers"

for prov_file in glob.glob(os.path.join(prov_dir, "*_provider.dart")):
    with open(prov_file, "r", encoding="utf-8") as f:
        content = f.read()
    
    if "currentUserProvider" in content and "tenantId: user?.tenantId" in content:
        continue
        
    # We want to replace:
    # final xxxRepositoryProvider = Provider<XxxRepository>((ref) {
    #   return XxxRepository();
    # });
    
    pattern = r"(final\s+(\w+)Provider\s*=\s*Provider<(\w+)>\(\(ref\)\s*\{\s*return\s+\3\(\);\s*\}\);)"
    match = re.search(pattern, content)
    
    if match:
        full_match = match.group(1)
        repo_prov_name = match.group(2)
        repo_class_name = match.group(3)
        
        replacement = f"""final {repo_prov_name}Provider = Provider<{repo_class_name}>((ref) {{
  final user = ref.watch(currentUserProvider);
  return {repo_class_name}(tenantId: user?.tenantId ?? '');
}});"""
        
        content = content.replace(full_match, replacement)
        
        # Add import if missing
        auth_import = "import 'package:washify/providers/auth_provider.dart';"
        if auth_import not in content:
            # find first import
            import_idx = content.find("import ")
            if import_idx != -1:
                content = content[:import_idx] + auth_import + "\n" + content[import_idx:]
            else:
                content = auth_import + "\n" + content
                
        with open(prov_file, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Patched {os.path.basename(prov_file)}")

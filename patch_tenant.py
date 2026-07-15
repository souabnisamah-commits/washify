import os
import re

utils_content = """
Object? readTenantId(Map json, String key) => json['tenantId'] ?? json['stationId'] ?? '';
"""
utils_path = r"c:\Users\SAM\Pictures\washify\lib\core\utils\json_utils.dart"
os.makedirs(os.path.dirname(utils_path), exist_ok=True)
with open(utils_path, 'w', encoding='utf-8') as f:
    f.write(utils_content)

files = [
    r"c:\Users\SAM\Pictures\washify\lib\features\audit\models\audit_log.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\auth\models\app_user.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\clients\models\client.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\clients\models\client_payment.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\employees\models\employee.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\inventory\models\inventory.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\notifications\models\app_notification.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\payroll\models\payroll.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\products\models\product.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\services\models\wash_service.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\station\models\station.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\stock\models\stock.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\tickets\models\ticket.dart",
    r"c:\Users\SAM\Pictures\washify\lib\features\wallet\models\wallet.dart"
]

for file_path in files:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if "import 'package:washify/core/utils/json_utils.dart';" not in content:
            content = content.replace(
                "import 'package:freezed_annotation/freezed_annotation.dart';",
                "import 'package:freezed_annotation/freezed_annotation.dart';\nimport 'package:washify/core/utils/json_utils.dart';"
            )
        
        # Avoid double replacing
        if "@JsonKey(readValue: readTenantId)" not in content:
            content = re.sub(
                r'required\s+String\s+tenantId\s*,',
                r"@JsonKey(readValue: readTenantId) required String tenantId,",
                content
            )
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Patched {file_path}")
    except Exception as e:
        print(f"Error on {file_path}: {e}")

import json

with open('firestore.indexes.json', 'r') as f:
    data = json.load(f)

new_indexes = []
for idx in data['indexes']:
    # Keep the original
    new_indexes.append(idx)
    
    # Create a new one with tenantId
    fields = idx['fields']
    if fields and fields[0].get('fieldPath') == 'tenantId':
        continue
    
    new_fields = [{"fieldPath": "tenantId", "order": "ASCENDING"}] + fields
    new_idx = {
        "collectionGroup": idx['collectionGroup'],
        "queryScope": idx.get('queryScope', 'COLLECTION'),
        "fields": new_fields
    }
    new_indexes.append(new_idx)

collections = [
    "tickets", "tasks", "wallet_transactions", "stations", "employees", 
    "services", "products", "stock", "payroll", "attendances", "shifts", 
    "vehicleCategories", "serviceDefinitions", "offers", "stock_movements", 
    "clients", "client_payments", "audit_logs", "notifications", "users"
]

for col in collections:
    new_indexes.append({
        "collectionGroup": col,
        "queryScope": "COLLECTION",
        "fields": [
            {"fieldPath": "tenantId", "order": "ASCENDING"},
            {"fieldPath": "createdAt", "order": "DESCENDING"}
        ]
    })
    
    new_indexes.append({
        "collectionGroup": col,
        "queryScope": "COLLECTION",
        "fields": [
            {"fieldPath": "tenantId", "order": "ASCENDING"},
            {"fieldPath": "date", "order": "DESCENDING"}
        ]
    })
    
    new_indexes.append({
        "collectionGroup": col,
        "queryScope": "COLLECTION",
        "fields": [
            {"fieldPath": "tenantId", "order": "ASCENDING"},
            {"fieldPath": "name", "order": "ASCENDING"}
        ]
    })

# Remove duplicates
seen = set()
unique_indexes = []
for idx in new_indexes:
    key = idx['collectionGroup'] + str(idx['fields'])
    if key not in seen:
        seen.add(key)
        unique_indexes.append(idx)

data['indexes'] = unique_indexes

with open('firestore.indexes.json', 'w') as f:
    json.dump(data, f, indent=2)


Object? readTenantId(Map json, String key) => json['tenantId'] ?? json['stationId'] ?? '';

class VehicleCatalog {
  final String id;
  final String tenantId;
  final List<String> customBrands;
  final Map<String, List<String>> brandModels;
  final DateTime updatedAt;

  static const List<String> defaultBrands = [
    'Peugeot',
    'Citroën',
    'Renault',
    'VW',
    'Dacia',
    'Toyota',
    'Hyundai',
    'Kia',
    'Isuzu',
    'BYD',
    'Mercedes',
    'BMW',
    'Audi',
    'MG',
    'Chery',
    'Ford',
    'Fiat',
    'Nissan',
    'Skoda',
    'Seat',
    'Suzuki',
    'Autre',
  ];

  VehicleCatalog({
    required this.id,
    required this.tenantId,
    required this.customBrands,
    required this.brandModels,
    required this.updatedAt,
  });

  List<String> get allBrands {
    final set = <String>{...defaultBrands, ...customBrands};
    final list = set.where((b) => b != 'Autre').toList()..sort();
    list.add('Autre');
    return list;
  }

  List<String> getModelsForBrand(String brand) {
    if (brand.isEmpty || brand == 'Autre') {
      final allModels = <String>{};
      for (final models in brandModels.values) {
        allModels.addAll(models);
      }
      return allModels.toList()..sort();
    }

    final brandKey = brandModels.keys.firstWhere(
      (k) => k.toLowerCase() == brand.toLowerCase(),
      orElse: () => '',
    );

    if (brandKey.isNotEmpty) {
      return List<String>.from(brandModels[brandKey]!)..sort();
    }
    return [];
  }

  factory VehicleCatalog.fromJson(Map<String, dynamic> json, String docId) {
    List<String> brands = [];
    if (json['customBrands'] is List) {
      brands = List<String>.from(json['customBrands']);
    }

    Map<String, List<String>> modelsMap = {};
    if (json['brandModels'] is Map) {
      final rawMap = json['brandModels'] as Map<String, dynamic>;
      rawMap.forEach((key, value) {
        if (value is List) {
          modelsMap[key] = List<String>.from(value);
        }
      });
    }

    DateTime updated = DateTime.now();
    if (json['updatedAt'] != null) {
      updated = DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now();
    }

    return VehicleCatalog(
      id: docId,
      tenantId: json['tenantId'] ?? docId,
      customBrands: brands,
      brandModels: modelsMap,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'customBrands': customBrands,
      'brandModels': brandModels,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VehicleCatalog.empty(String tenantId) {
    return VehicleCatalog(
      id: tenantId,
      tenantId: tenantId,
      customBrands: [],
      brandModels: {},
      updatedAt: DateTime.now(),
    );
  }
}

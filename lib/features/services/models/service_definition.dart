/// Service definition model for Washify.
/// Replaces the simple WashService with a richer model supporting
/// variable pricing per vehicle category, supplements, and special services.
library;

/// Represents a link between a service and the products it consumes.
class ServiceProductLink {
  final String productId;
  final String productName;
  final double consumptionPerUse; // default ml or g consumed per vehicle
  final Map<String, double> consumptionByCategory; // ml or g consumed per specific categoryId

  const ServiceProductLink({
    required this.productId,
    this.productName = '',
    required this.consumptionPerUse,
    this.consumptionByCategory = const {},
  });

  ServiceProductLink copyWith({
    String? productId,
    String? productName,
    double? consumptionPerUse,
    Map<String, double>? consumptionByCategory,
  }) {
    return ServiceProductLink(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      consumptionPerUse: consumptionPerUse ?? this.consumptionPerUse,
      consumptionByCategory: consumptionByCategory ?? this.consumptionByCategory,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'consumptionPerUse': consumptionPerUse,
    'consumptionByCategory': consumptionByCategory,
  };

  factory ServiceProductLink.fromJson(Map<String, dynamic> json) {
    return ServiceProductLink(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      consumptionPerUse: (json['consumptionPerUse'] as num?)?.toDouble() ?? 0.0,
      consumptionByCategory: (json['consumptionByCategory'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
    );
  }
}

/// Service types:
/// - lavage: washing service with variable price per vehicle category
/// - supplement: extra products/services with fixed additional price
/// - special: standalone services (vapeur, stickage, phare...) with fixed price
enum ServiceType {
  lavage('lavage', 'Lavage'),
  supplement('supplement', 'Supplément'),
  special('special', 'Service Spécial');

  const ServiceType(this.value, this.label);
  final String value;
  final String label;

  static ServiceType fromString(String value) {
    return ServiceType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => ServiceType.lavage,
    );
  }
}

class ServiceDefinition {
  final String id;
  final String tenantId;
  final String name;              // "Lavage Intérieur", "Céramique", "Vapeur Banquette"
  final ServiceType serviceType;

  // For type "lavage": price per vehicle category { categoryId: price }
  final Map<String, double> pricesByCategory;

  // For type "supplement" or "special": fixed price
  final double fixedPrice;

  // Products consumed by this service (for traceability)
  final List<ServiceProductLink> linkedProducts;

  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceDefinition({
    required this.id,
    required this.tenantId,
    required this.name,
    this.serviceType = ServiceType.lavage,
    this.pricesByCategory = const {},
    this.fixedPrice = 0.0,
    this.linkedProducts = const [],
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  ServiceDefinition copyWith({
    String? id,
    String? tenantId,
    String? name,
    ServiceType? serviceType,
    Map<String, double>? pricesByCategory,
    double? fixedPrice,
    List<ServiceProductLink>? linkedProducts,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceDefinition(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      serviceType: serviceType ?? this.serviceType,
      pricesByCategory: pricesByCategory ?? this.pricesByCategory,
      fixedPrice: fixedPrice ?? this.fixedPrice,
      linkedProducts: linkedProducts ?? this.linkedProducts,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Gets the price for a specific vehicle category.
  /// Returns fixedPrice for supplement/special services.
  double getPriceForCategory(String categoryId) {
    if (serviceType != ServiceType.lavage) return fixedPrice;
    return pricesByCategory[categoryId] ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenantId': tenantId,
    'name': name,
    'serviceType': serviceType.value,
    'pricesByCategory': pricesByCategory,
    'fixedPrice': fixedPrice,
    'linkedProducts': linkedProducts.map((lp) => lp.toJson()).toList(),
    'isActive': isActive,
    'sortOrder': sortOrder,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ServiceDefinition.fromJson(Map<String, dynamic> json) {
    // Parse pricesByCategory safely
    Map<String, double> parsedPrices = {};
    if (json['pricesByCategory'] is Map) {
      (json['pricesByCategory'] as Map).forEach((key, value) {
        parsedPrices[key.toString()] = (value as num?)?.toDouble() ?? 0.0;
      });
    }

    // Parse linkedProducts safely
    List<ServiceProductLink> parsedLinks = [];
    if (json['linkedProducts'] is List) {
      parsedLinks = (json['linkedProducts'] as List)
          .map((item) => ServiceProductLink.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ServiceDefinition(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      serviceType: ServiceType.fromString(json['serviceType'] as String? ?? 'lavage'),
      pricesByCategory: parsedPrices,
      fixedPrice: (json['fixedPrice'] as num?)?.toDouble() ?? 0.0,
      linkedProducts: parsedLinks,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

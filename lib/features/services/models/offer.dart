/// Offer model for Washify.
/// The patron can create bundled offers combining multiple services
/// as well as products/extras at a discounted price for a specific vehicle category.
class Offer {
  final String id;
  final String tenantId;
  final String name;                  // "Offre Citadine Premium"
  final String? categoryId;          // target vehicle category (optional)
  final String? categoryName;        // snapshot for display
  final List<String> serviceIds;     // included service definition IDs
  final List<String> serviceNames;   // snapshot for display
  final List<String> productIds;      // included product/extra/boutique IDs
  final List<String> productNames;    // snapshot of product names for display
  final double offerPrice;           // bundled price (ex: 35 DT)
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Offer({
    required this.id,
    required this.tenantId,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.serviceIds = const [],
    this.serviceNames = const [],
    this.productIds = const [],
    this.productNames = const [],
    required this.offerPrice,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Offer copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? categoryId,
    String? categoryName,
    List<String>? serviceIds,
    List<String>? serviceNames,
    List<String>? productIds,
    List<String>? productNames,
    double? offerPrice,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Offer(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      serviceIds: serviceIds ?? this.serviceIds,
      serviceNames: serviceNames ?? this.serviceNames,
      productIds: productIds ?? this.productIds,
      productNames: productNames ?? this.productNames,
      offerPrice: offerPrice ?? this.offerPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenantId': tenantId,
    'name': name,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'serviceIds': serviceIds,
    'serviceNames': serviceNames,
    'productIds': productIds,
    'productNames': productNames,
    'offerPrice': offerPrice,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      serviceIds: (json['serviceIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      serviceNames: (json['serviceNames'] as List?)?.map((e) => e.toString()).toList() ?? [],
      productIds: (json['productIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      productNames: (json['productNames'] as List?)?.map((e) => e.toString()).toList() ?? [],
      offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

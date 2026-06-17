import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

enum ProductFamily {
  vrac('vrac'),
  produit('produit'),
  revente('revente');

  const ProductFamily(this.value);
  final String value;

  static ProductFamily fromString(String value) {
    return ProductFamily.values.firstWhere(
      (family) => family.value == value,
      orElse: () => ProductFamily.produit,
    );
  }
}

@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    required String tenantId,
    required String name,
    required String description,
    @Default(ProductFamily.produit) ProductFamily family, // vrac, produit, revente
    required String unit,          // e.g. "Bidon", "Litre", "Unité"
    required double unitPrice,
    required int minStock,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  String get stationId => tenantId;
}

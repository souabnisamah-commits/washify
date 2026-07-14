import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'product.freezed.dart';
part 'product.g.dart';

enum ProductFamily {
  standard('standard', 'Consommable Standard'),
  extra('extra', 'Consommable Premium (Extra)'),
  revente('revente', 'Boutique (Revente)');

  const ProductFamily(this.value, this.label);
  final String value;
  final String label;

  static ProductFamily fromString(String value) {
    return ProductFamily.values.firstWhere(
      (family) => family.value == value,
      orElse: () => ProductFamily.standard,
    );
  }
}

/// Product family indicates the general usage context:
/// - standard: consumable used during standard services (shampoo, etc)
/// - extra: expensive consumable used for extra/premium services (ceramic)
/// - revente: boutique item sold directly (air fresheners)

@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required String name,
    required String description,
    @JsonKey(unknownEnumValue: ProductFamily.standard)
    @Default(ProductFamily.standard) ProductFamily family, // standard, extra, revente
    required String unit,          // e.g. "Bidon", "Litre", "Unité"
    required double unitPrice,
    required int minStock,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,

    // NEW: Business model fields
    @Default(0.0) double purchasePrice,     // prix d'achat du produit global
    @Default(0.0) double capacityMl,        // capacité totale en ml ou grammes (ex: 5000 pour 5L, ou 1 pour 1 pièce)
    @Default('') String barcode,            // code-barres pour produits boutique
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  String get stationId => tenantId;
}


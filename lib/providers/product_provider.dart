import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getAllProducts();
});

final productsByStationProvider =
    FutureProvider.family<List<Product>, String>((ref, stationId) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductsByStation(stationId);
});

final productByIdProvider =
    FutureProvider.family<Product?, String>((ref, productId) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductById(productId);
});

final productsStreamProvider =
    StreamProvider.family<List<Product>, String>((ref, stationId) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchProductsByStation(stationId);
});

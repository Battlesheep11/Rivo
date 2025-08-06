import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/core/supabase/supabase_provider.dart';
import 'package:rivo_app_beta/features/product/data/product_service.dart';
import 'package:rivo_app_beta/features/product/domain/product.dart';
import 'package:rivo_app_beta/features/product/domain/product_repository.dart';
import 'package:rivo_app_beta/features/product/domain/seller.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  final supabaseClient = ref.watch(supabaseProvider);
  return ProductService(supabaseClient);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ref.watch(productServiceProvider);
});

final productProvider = FutureProvider.family<Product, String>((ref, productId) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.getProduct(productId);
});

final sellerProvider = FutureProvider.family<Seller, String>((ref, sellerId) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.getSeller(sellerId);
});

final recommendedProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, productId) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.getRecommendedProducts(productId);
});

final productProviderByProductId = FutureProvider.family<Product, String>((ref, productId) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProduct(productId); 
});

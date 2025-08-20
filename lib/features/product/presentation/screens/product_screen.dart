import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/features/product/presentation/providers/product_providers.dart';
import 'package:rivo_app_beta/features/product/presentation/widgets/action_buttons.dart';
import 'package:rivo_app_beta/features/product/presentation/widgets/key_info.dart';
import 'package:rivo_app_beta/features/product/presentation/widgets/product_gallery.dart';
import 'package:rivo_app_beta/features/product/presentation/widgets/product_info.dart';
import 'package:rivo_app_beta/features/product/presentation/widgets/recommended_products.dart';
import 'package:rivo_app_beta/features/product/presentation/widgets/seller_info.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.productId});
  final String productId;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isTitleVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final galleryHeight = MediaQuery.of(context).size.height * 0.4;
      final show = _scrollController.offset > galleryHeight - kToolbarHeight;
      if (show != _isTitleVisible) {
        setState(() => _isTitleVisible = show);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          final sellerAsync = ref.watch(sellerProvider(product.sellerId));
          final recommendedProductsAsync =
              ref.watch(recommendedProductsProvider(widget.productId));

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: _isTitleVisible ? 2.0 : 0.0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withAlpha(230),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                title: AnimatedOpacity(
                  opacity: _isTitleVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: ProductGallery(imageUrls: product.imageUrls),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductInfo(product: product),
                    KeyInfo(product: product),
                    ActionButtons(
                      onSavePressed: () {},
                      onSharePressed: () {},
                      onBuyNowPressed: () {},
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),

                    sellerAsync.when(
                      data: (seller) => SellerInfo(seller: seller),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error: $error'),
                      ),
                    ),

                    const Divider(height: 1, indent: 16, endIndent: 16),
                    const SizedBox(height: 24),

                    recommendedProductsAsync.when(
                      data: (products) => RecommendedProducts(products: products),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/product/domain/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rivo_app_beta/core/cache/image_cache_manager.dart';

class RecommendedProducts extends StatelessWidget {
  const RecommendedProducts({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            AppLocalizations.of(context)!.moreFromThisSeller,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 160,
                margin: EdgeInsets.only(
                  left: index == 0 ? 16 : 8,
                  right: index == products.length - 1 ? 16 : 8,
                ),
                child: GestureDetector(
                  onTap: product.postId != null
                      ? () => context.push('/product/${product.postId!}')
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product.imageUrls.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrls.first,
                                cacheManager: ImageCacheManager(),
                                height: 160,
                                width: 160,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  height: 160,
                                  width: 160,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              )
                            : Container(
                                height: 160,
                                width: 160,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rivo_app/features/discovery/domain/entities/search_product_entity.dart';
import 'package:rivo_app/core/design_system/cards/featured_card_base.dart';
import 'package:rivo_app/core/design_system/widgets/glass_text.dart';

class SimpleProductCard extends StatelessWidget {
  final SearchProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onUserTap;
  final VoidCallback? onLikeTap;
  final bool isLiked;

  const SimpleProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onUserTap,
    this.onLikeTap,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    final firstMedia = product.media.firstOrNull;
    final imageUrl = firstMedia?.url ?? 'https://via.placeholder.com/600x800?text=RIVO';

    return FeaturedCardBase(
      imageUrl: imageUrl,
      onTap: onTap,
      overlay: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GlassText(
              text: product.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            GlassText(
              text: '${product.price.toStringAsFixed(0)} ₪',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: onUserTap,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(product.seller.avatarUrl ?? ''),
                    backgroundColor: Colors.grey.shade300,
                    child: product.seller.avatarUrl != null
                        ? const Icon(Icons.person, size: 16, color: Colors.black54)
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: onUserTap,
                    child: GlassText(
                      text: '@${product.seller.username}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: onLikeTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rivo_app/features/discovery/domain/entities/seller_entity.dart';

class PopularSellerCard extends StatelessWidget {
  final SellerEntity seller;
  final VoidCallback? onTap;

  const PopularSellerCard({
    super.key,
    required this.seller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
  onTap: onTap,
  child: Align(
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: seller.avatarUrl != null
              ? NetworkImage(seller.avatarUrl!)
              : null,
          backgroundColor: Colors.grey.shade300,
          child: seller.avatarUrl == null
              ? const Icon(Icons.person, size: 28, color: Colors.black54)
              : null,
        ),
        const SizedBox(width: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '@${seller.username}',
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  ),
);

  }
}
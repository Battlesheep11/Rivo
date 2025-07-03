import 'package:flutter/material.dart';
import 'package:rivo_app/core/design_system/widgets/glass_card.dart';
import 'package:rivo_app/core/design_system/widgets/glass_text.dart';
import 'package:rivo_app/features/discovery/domain/entities/discovery_tag_entity.dart';

class CuratedTagCard extends StatelessWidget {
  final DiscoveryTagEntity tag;
  final VoidCallback? onTap;

  const CuratedTagCard({
    super.key,
    required this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          if (tag.imageUrl != null && tag.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                tag.imageUrl!,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GlassText(
              text: tag.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
